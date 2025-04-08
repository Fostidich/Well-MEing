from typing import Union, Optional, List, Self
from langchain.tools import BaseTool
from pydantic import BaseModel, Field, ConfigDict, field_validator, ValidationError, model_validator
from auxiliary.habit_validation import InputType, INPUT_VALIDATION_RULES
from auxiliary.misc import generate_enum_docs, wrapper_parse_function
from auxiliary.json_building import get_habits_map, append_habit, append_metric_data
from test.emulators import save_to_db
from datetime import datetime



class CreateHabitTool(BaseTool):
    name: str = "create_habit"
    description: str = (f"""
    Tool used to create a new habit to and the metrics to track, Use the same habit name to insert more than 1 metric per habit.
    Expected input: "habit_name,metric_name,input_type,habit_description,metric_description,habit_goal,type,min_value,max_value,unit".  
    habit_name: Name of the habit.
    metric_name: metric name. 
    input_type: Tracking method ({generate_enum_docs(InputType)}). 
    habit_description: Optional description of the habit.
    metric_description: Optional description of the metric.
    habit_goal: Optional goal for the habit.
    value_type: Type of the metric value (int, float, str, time_duration). Default is int.
    min_value, max_value: Allowed range for Slider Input (Numeric), max for +N Button (Numeric) (use natural/pleasing values). 
    unit: Measurement for numeric inputs. 
    Infer missing parameters based on expected tracking behavior.""")

    class InputSchema(BaseModel):
        model_config = ConfigDict(use_enum_values=True)
        habit_name: str = Field(..., description="Name of the habit")
        metric_name: str = Field(..., description="Name of the metric to be tracked")
        input_type: InputType = Field(..., description=f"Tracking method. Options:\n{generate_enum_docs(InputType)}")
        value_type: str = Field(..., description="Type of the metric (int, float, str, time_duration). Default is int")
        habit_description: Optional[str] = Field(default=None, description="Optional description of the habit")
        metric_description: Optional[str] = Field(default=None, description="Optional description of the metric")
        habit_goal: Optional[str] = Field(default=None, description="Optional goal for the habit")
        min_value: Optional[Union[float, int]] = Field(default=None, description="Required for Slider Input (Numeric). Minimum allowed value")
        max_value: Optional[Union[float, int]] = Field(default=None, description="Required for +N Button (Numeric)/Slider Input (Numeric). Maximum allowed value")
        unit: Optional[str] = Field(default=None, description="Unit of measurement (e.g., 'glasses', 'hours', km) for numeric types")

        @model_validator(mode="after")
        def check_existing_habit(self) -> Self:
            existing_habits = get_habits_map()
            if self.metric_name in existing_habits.get(self.habit_name, {}):
                raise ValueError(f"'{self.metric_name}' already exists in '{self.habit_name}' change metric or habit name")

            # TODO Add value_type validation
            return self


    def _run(self, input_string: str):
        validaded_parsed_data = wrapper_parse_function(input_string, self.InputSchema)

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

            if input_type == "TEXT_BOX" or input_type == "TIME":
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

class ConfirmActions(BaseTool):
    name: str = "confirm_actions"
    description: str = "Tool used to confirm created/inserted data/habits. USE when no other actions are needed"

    def _run(self):
        # Save the current state of the JSON to the database
        save_to_db()
        return f"Data saved successfully at {datetime.now()}"