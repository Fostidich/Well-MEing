from typing import Optional, Union, List, Self

from pydantic import BaseModel, Field, model_validator, ConfigDict
from test.emulators import get_context_json_from_db
from auxiliary.json_keys import ActionKeys, JsonKeys
from auxiliary.utils import generate_enum_docs
from auxiliary.ui_rules import SliderTypeKeys, InputTypeKeys, INPUT_VALIDATION_RULES


class MetricConfig(BaseModel):
    model_config = ConfigDict(use_enum_values=True)
    type: SliderTypeKeys = Field(default=None,
                                 description=f"(use ONLY for slider) input type. Must be one of: {generate_enum_docs(SliderTypeKeys)}")
    min: Optional[Union[float, int]] = Field(default=None,
                                             description="(required for slider) input minimum allowed value",
                                             json_schema_extra={"type": "number"})
    max: Optional[Union[float, int]] = Field(default=None,
                                             description="(requred for slider) input maximum allowed value",
                                             json_schema_extra={"type": "number"})
    boxes: Optional[List[str]] = Field(default=None,
                                       description="(required for form) List of options for the form input type (min 2 options, max 10 options)")


class Metric(BaseModel):
    model_config = ConfigDict(use_enum_values=True)
    name: str = Field(..., description="Metric to be tracked")
    description: Optional[str] = Field(default=None, description="Metric additional Information")
    input: InputTypeKeys = Field(...,
                                 description=f"Tracking UI element. Must be one of:\n{generate_enum_docs(InputTypeKeys)}")
    config: MetricConfig

    @model_validator(mode="after")
    def validate_config(self) -> Self:
        filtered_config = validate_input_type_config(self.input, self.config)
        self.config = MetricConfig(**filtered_config)
        return self


class Habit(BaseModel):
    name: str = Field(..., description="Habit to be created")
    description: Optional[str] = Field(default=None, description="Habit additional Information")
    goal: Optional[str] = Field(default=None, description="Habit goal/objective")
    metrics: List[Metric]

    @model_validator(mode="after")
    def validate_names(self) -> Self:
        validate_habit_metric_names(self.name, self.metrics)
        return self


class HabitCreation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    creation: List[Habit] = Field(..., description="List of habits to be created")


def validate_input_type_config(input_type: InputTypeKeys, config: MetricConfig):
    input_rules = INPUT_VALIDATION_RULES.get(ActionKeys.CREATE.value, {}).get(input_type, {})
    required_params = input_rules.get("required_params", [])
    constraint = input_rules.get("constraint", lambda **kwargs: True)
    error_message = input_rules.get("error", lambda **kwargs: "Invalid input")
    config_dict = config.dict()
    # Config required params checking

    missing_params = [param for param in required_params if param not in config_dict]
    if missing_params:
        raise ValueError(
            f"Missing required parameters for input type {input_type}: {', '.join(missing_params)}"
        )

    # Config-Input_type constraing checking
    if not constraint(**config_dict):
        raise ValueError(
            f"Config does not satisfy constraints for input type {input_type}."
            f"Config: {config_dict}, "
            f"{error_message()}"
        )

    filtered_config_dict = {param: config_dict[param] for param in required_params}

    return filtered_config_dict


def validate_habit_metric_names(habit_name: str, metrics: List[Metric]) -> bool:
    """
    Validate that the habit name is unique and the (habit_name, metric_name) pair is unique.
    """
    context_json = get_context_json_from_db()
    habits = {habit[JsonKeys.HABIT_NAME.value]: habit for habit in context_json.get(JsonKeys.HABITS.value, [])}
    # Check if the habit name already exists
    if habit_name in habits:
        raise ValueError(f"Habit '{habit_name}' already exists in the database.")

    # Check if the (habit_name, metric_name) pair is unique
    for metric in metrics:
        metric_name = metric.name
        for existing_habit_name, habit_data in habits.items():
            if existing_habit_name == habit_name:
                existing_metrics = {m[JsonKeys.METRIC_NAME.value] for m in habit_data.get(JsonKeys.METRICS.value, [])}
                if metric_name in existing_metrics:
                    raise ValueError(f"Metric '{metric_name}' already exists for habit '{habit_name}'.")

    return True
