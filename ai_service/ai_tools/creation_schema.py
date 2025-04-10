from typing import Optional, Union, List, Self

from pydantic import BaseModel, Field, model_validator, ConfigDict
from enum import Enum

from auxiliary.misc import generate_enum_docs
from auxiliary.UI_validation import InputType

class MetricConfig(BaseModel):
    type: str = Field(..., description="MetricValue Type (int, float, str, time_duration)")
    min: Optional[Union[float, int]] = Field(default=None, description="Metric insertion minimum allowed value")
    max: Optional[Union[float, int]] = Field(default=None, description="Metric insertion maximum allowed value")
    unit: Optional[str] = Field(default=None, description="Unit of measurement (e.g., 'glasses', 'hours', km)")


class Metric(BaseModel):
    model_config = ConfigDict(use_enum_values=True)
    name: str = Field(..., description="Metric to be tracked")
    description: Optional[str] = Field(default=None, description="Metric additional Information")
    input: InputType = Field(..., description=f"Tracking UI element. Options:\n{generate_enum_docs(InputType)}")
    config: MetricConfig

    @model_validator(mode="after")
    def validate_config(self) -> Self:
        # TODO - Add validation logic for config based on input type
        # TODO - Add validation logic for already existing habits or metrics
        return self

class Habit(BaseModel):
    name: str = Field(..., description="Habit to be created")
    description: Optional[str] = Field(default=None, description="Habit additional Information")
    goal: Optional[str] = Field(default=None, description="Habit goal/objective")
    metrics: List[Metric]

class HabitCreation(BaseModel):
    creation: List[Habit] = Field(..., description="List of habits to be created")


