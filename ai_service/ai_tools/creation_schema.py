from typing import Optional, Union, List, Self

from pydantic import BaseModel, Field, model_validator, ConfigDict
from auxiliary.misc import generate_enum_docs
from auxiliary.ui_validation import validate_input_type_config
from auxiliary.json_validation import SliderTypeKeys, InputTypeKeys


class MetricConfig(BaseModel):
    model_config = ConfigDict(use_enum_values=True)
    type: SliderTypeKeys = Field(default=None, description=f"(use ONLY for slider) input type. Must be one of: {generate_enum_docs(SliderTypeKeys)}")
    min: Optional[Union[float, int]] = Field(default=None, description="(required for slider) input minimum allowed value")
    max: Optional[Union[float, int]] = Field(default=None, description="(requred for slider) input maximum allowed value")
    boxes: Optional[List[str]] = Field(default=None, description="(required for form) List of options for the form input type (min 2 options, max 10 options)")


class Metric(BaseModel):
    model_config = ConfigDict(use_enum_values=True)
    name: str = Field(..., description="Metric to be tracked")
    description: Optional[str] = Field(default=None, description="Metric additional Information")
    input: InputTypeKeys = Field(..., description=f"Tracking UI element. Must be one of:\n{generate_enum_docs(InputTypeKeys)}")
    config: MetricConfig

    @model_validator(mode="after")
    def validate_config(self) -> Self:
        filtered_config = validate_input_type_config(self.input, self.config)
        self.config = MetricConfig(**filtered_config)
        return self

    @model_validator(mode="after")
    def validate_names(self) -> Self:
        # TODO check if (habit_name, metric_name) exists
        return self

class Habit(BaseModel):
    name: str = Field(..., description="Habit to be created")
    description: Optional[str] = Field(default=None, description="Habit additional Information")
    goal: Optional[str] = Field(default=None, description="Habit goal/objective")
    metrics: List[Metric]

class HabitCreation(BaseModel):
    creation: List[Habit] = Field(..., description="List of habits to be created")


