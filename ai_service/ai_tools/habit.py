from typing import Union, Optional, List, Self
from langchain.tools import BaseTool
from pydantic import BaseModel, Field, ConfigDict, field_validator, ValidationError, model_validator
from auxiliary.habit_validation import InputType, INPUT_VALIDATION_RULES
from auxiliary.misc import generate_enum_docs, wrapper_parse_function, generate_tool_description_with_inputs
from auxiliary.json_building import get_habits_map, append_habit, append_metric_data, out
from test.emulators import save_to_db, get_json_from_db
from datetime import datetime
from auxiliary.json_validation import HabitKeys, MetricKeys, LogKeys, ConfigKeys
from enum import Enum


class CreateHabitTool(BaseTool):
    name: str = "create_habit"

    class InputSchema(BaseModel):
        model_config = ConfigDict(use_enum_values=True)
        habit_name: str = Field(..., description="Habit to be created")
        metric_name: str = Field(..., description="Metric to be tracked")
        input_type: InputType = Field(..., description=f"Tracking UI element. Options:\n{generate_enum_docs(InputType)}")
        value_type: str = Field(..., description="MetricValue Type (int, float, str, time_duration)")
        habit_description: Optional[str] = Field(default=None, description="Habit additional Information")
        metric_description: Optional[str] = Field(default=None, description="Metric additional Information")
        habit_goal: Optional[str] = Field(default=None, description="Habit goal/objective")
        min_value: Optional[Union[float, int]] = Field(default=None, description="Metric insertion minimum allowed value")
        max_value: Optional[Union[float, int]] = Field(default=None, description="Metric insertion maximum allowed value")
        unit: Optional[str] = Field(default=None, description="Unit of measurement (e.g., 'glasses', 'hours', km)")

        @model_validator(mode="after")
        def check_existing_habit(self) -> Self:
            existing_habits = get_habits_map()
            if self.metric_name in existing_habits.get(self.habit_name, {}):
                raise ValueError(f"'{self.metric_name}' already exists in '{self.habit_name}' change metric or habit name")

            # TODO Add value_type validation
            return self

    description: str = generate_tool_description_with_inputs(
        InputSchema,
        intro_text="Tool used to create a new habit and its associated metric(s). Provide all relevant fields:"
    )

    def _run(self, input_string: str):
        validaded_parsed_data = wrapper_parse_function(input_string, self.InputSchema, self.JsonMap)
        if isinstance(validaded_parsed_data, str):
            return validaded_parsed_data

        habit_details = validaded_parsed_data.dict()

        try:
            append_habit(habit_details)
        except Exception as e:

            return f"Couldn't insert habit: {e}"
        return f"Successfully created habit: {habit_details}"


class InsertHabitDataTool(BaseTool):

    name: str = "insert_habit_data"
    description: str = f"""
    Tool used to insert new data point for existing habit.
    Expected input: "habit_name,metric_name,value,timestamp".
    habit_name: Name of the habit.
    metric_name: metric name.
    value: Value to record (depends on habit input_type).
    timestamp: Optional timestamp for the data point (default is current time).
    """
    class InputSchema(BaseModel):
        habit_name: str = Field(..., description="Name of the habit which has the metric to be tracked")
        metric_name: str = Field(..., description="EXACT name of the metric to update (must match exactly)")
        value: Union[float, int] = Field(..., description="Value to record (type depends on habit's input type)")
        timestamp: Optional[str] = Field(default_factory=lambda: datetime.now().isoformat(timespec='seconds'), description="Optional timestamp for the data point")

        @model_validator(mode="after")
        def check_existing_habit(self) -> Self:

            existing_habits = get_habits_map()

            if self.metric_name not in existing_habits.get(self.habit_name, {}):
                raise ValueError(f"metric_name:'{self.metric_name}' in habit_name: '{self.habit_name}' does not exist, check again or 'create_habit' tool")

            input_type = existing_habits.get(self.habit_name, {}).get(self.metric_name,{}).get("input_type",{})

            rules = INPUT_VALIDATION_RULES[input_type]

            if input_type == "Text Box (Text)" or input_type == "Time Input (isoformat(timespec='seconds'))":
                self.value = str(self.value)

            # Type Check
            if not isinstance(self.value, rules["type"]):
                raise ValueError(rules["error"])

            # Constraint Check
            if not rules["constraint"](self.value):
                raise ValueError(rules["error"])

            return self

    def _run(self, input_string: str):
        validaded_parsed_data = wrapper_parse_function(input_string, self.InputSchema)
        if isinstance(validaded_parsed_data, str):
            return validaded_parsed_data  # Return validation error message
        try:
            append_metric_data(validaded_parsed_data.dict())
        except Exception as e:

            return f"Couldn't insert habit: {e}"

        return f"Successfully inserted habit {validaded_parsed_data.dict()['metric_name']} data point"

class GetHabitsTool(BaseTool):
    name: str = "get_habits"
    description: str = """
    Tool to get the current state of the habit database (habits and metrics).
    Expected input: None.
    """
    def _run(self):
        """
        Retrieve the habit data from the database.
        """
        return get_json_from_db()