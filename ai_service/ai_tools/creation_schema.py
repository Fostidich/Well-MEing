from typing import Optional, Union, List, Self, Literal

from pydantic import BaseModel, Field, model_validator, ConfigDict

from auxiliary.json_keys import ActionKeys, JsonKeys
from auxiliary.ui_rules import InputTypeKeys, INPUT_VALIDATION_RULES
from auxiliary.utils import generate_enum_docs, context_manager
from test.emulators import get_context_json_from_db


class SliderConfig(BaseModel):
    model_config = ConfigDict(use_enum_values=True)
    type: Literal["int", "float"] = Field(..., description=f"Numeric input type")  # TODO Infer this from max and min
    min: Union[float, int] = Field(...,
                                   description="Minimum allowed value",
                                   json_schema_extra={"type": "number"})
    max: Union[float, int] = Field(...,
                                   description="Maximum allowed value",
                                   json_schema_extra={"type": "number"})


class FormConfig(BaseModel):
    model_config = ConfigDict(use_enum_values=True)
    boxes: List[str] = Field(...,
                             description="List of box options (min 2 options, max 10 options)")


class Metric(BaseModel):
    model_config = ConfigDict(use_enum_values=True)
    name: str = Field(..., description="Metric to be tracked")
    description: Optional[str] = Field(default=None, description="Metric additional Information")
    input: InputTypeKeys = Field(...,
                                 description=f"Tracking UI element. Must be one of:\n{generate_enum_docs(InputTypeKeys)}")
    config: Optional[Union[SliderConfig, FormConfig]] = Field(default=None,
                                                                  description="Config of slider or form input")

    @model_validator(mode="after")
    def validate_config(self) -> Self:

        if self.input == InputTypeKeys.SLIDER.value and not isinstance(self.config, SliderConfig):
            raise ValueError(
                f"Config for {self.input} must be of type {SliderConfig.__name__}."
            )
        elif self.input == InputTypeKeys.FORM.value and not isinstance(self.config, FormConfig):
            raise ValueError(
                f"Config for {self.input} must be of type {FormConfig.__name__}."
            )
        if self.config:
            validate_input_type_config(self.input, self.config)

        return self


class Habit(BaseModel):
    name: str = Field(..., description="Habit to be created")
    description: Optional[str] = Field(default=None, description="Habit additional Information")
    goal: Optional[str] = Field(default=None, description="Habit goal/objective")
    metrics: List[Metric] = Field(..., description="List of metrics to be tracked")

    @model_validator(mode="after")
    def validate_names(self) -> Self:
        validate_habit_metric_names(self.name, self.metrics)
        return self


class HabitCreation(BaseModel):
    model_config = ConfigDict(extra='forbid')
    creation: List[Habit] = Field(..., description="List of habits to be created")


def validate_input_type_config(input_type: InputTypeKeys, config: Union[SliderConfig, FormConfig]) -> None:
    input_rules = INPUT_VALIDATION_RULES.get(ActionKeys.CREATE.value, {}).get(input_type, {})
    constraint = input_rules.get("constraint", lambda **kwargs: True)
    error_message = input_rules.get("error", lambda **kwargs: "Invalid input")
    config_dict = config.dict()

    # Config-Input_type constraing checking
    if not constraint(**config_dict):
        raise ValueError(
            f"Config does not satisfy constraints for input type {input_type}."
            f"{error_message()}"
        )
    return None


def validate_habit_metric_names(habit_name: str, metrics: List[Metric]) -> None:
    # Check if the (habit_name, metric_name) pair is unique
    for metric in metrics:
        if (habit_name, metric.name) in context_manager.names_set:
            raise ValueError(f"Metric '{metric.name}' already exists for habit '{habit_name}'.")
    return None
