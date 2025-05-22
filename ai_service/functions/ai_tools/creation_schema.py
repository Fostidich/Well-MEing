from typing import Optional, List, Self, Literal, Annotated, Dict, Set

from langchain_core.tools import InjectedToolCallId
from langgraph.prebuilt import InjectedState
from pydantic import BaseModel, Field, model_validator, ConfigDict, field_serializer

from auxiliary.utils import generate_enum_docs, ContextInfoManager
from ui_schema.dispacher import validate_input
from ui_schema.schemas import InputTypeKeys


class Config(BaseModel):
    type: Optional[Literal["int", "float"]] = Field(default=None, description="Slider number type")
    min: Optional[int] = Field(default=None,
                               description="Slider Minimum allowed value",
                               json_schema_extra={"type": "number"})
    max: Optional[int] = Field(default=None,
                               description="Slider Maximum allowed value",
                               json_schema_extra={"type": "number"})
    boxes: Optional[List[str]] = Field(default=None,
                                       description="Form Set of box options max 10 options")


class Metric(BaseModel):
    model_config = ConfigDict(use_enum_values=True)
    name: str = Field(..., description="Metric to be tracked")
    description: Optional[str] = Field(default=None, description="Metric additional Information")
    input: InputTypeKeys = Field(...,
                                 description=f"UI element. Must be one of:\n{generate_enum_docs(InputTypeKeys)}")
    config: Optional[Config] = Field(default=None, description="Config of slider or form input")

    @model_validator(mode="after")
    def validate_config(self) -> Self:
        if self.config:
            self.config = validate_input(self.input, self.config.dict())

        return self


class Habit(BaseModel):
    name: str = Field(..., description="Habit to be created")
    description: Optional[str] = Field(default=None, description="Habit additional Information")
    goal: Optional[str] = Field(default=None, description="Habit goal/objective")
    metrics: List[Metric] = Field(..., description="List of metrics to be tracked")


class HabitCreation(BaseModel):
    creation: List[Habit] = Field(..., description="List of habits to be created")
    state: Annotated[Dict, InjectedState] = Field(..., description="Context for the tool")
    tool_call_id: Annotated[str, InjectedToolCallId]

    @model_validator(mode="after")
    def validate_names(self) -> Self:
        context = self.state.get("context")
        context_manager = ContextInfoManager.construct(**context)

        for habit in self.creation:
            validate_habit_metric_names(habit.name, habit.metrics, context_manager)
        return self


def validate_habit_metric_names(habit_name: str, metrics: List[Metric], context_manager: ContextInfoManager) -> None:
    for metric in metrics:
        if (habit_name, metric.name) in context_manager.metrics_names_set:
            raise ValueError(
                f"Metric '{metric.name}' already exists for habit '{habit_name}'. PLEASE chose a different but similar metric name")
    return None
