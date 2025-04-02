from typing import Union, Optional, List, Self
from langchain.tools import BaseTool
from pydantic import BaseModel, Field, ConfigDict, field_validator, ValidationError, model_validator
from ai_service.auxiliary.habit_validation import InputType, INPUT_VALIDATION_RULES
from ai_service.auxiliary.misc import generate_enum_docs, wrapper_parse_function
from ai_service.test.emulators import get_habits_map, save_to_db, append_habit
from datetime import datetime



class CreateHabitTool(BaseTool):
    name: str = "create_habit"
    # Existing groups and habits are passed using a initial prompt to optimize tokens
    # If group names or habit names already exist the full tracked JSON is passed
    description: str = (f"""
    Tool used to create a new habit to track.
    Expected input: "group_name,habit_name,input_type,habit_description,min_value,max_value,unit".  
    group_name: Habit’s category. habit_name: Habit's name. input_type: Tracking method ({generate_enum_docs(InputType)}). min_value, max_value: Allowed range for SLIDER, max for PLUS_N (use natural/pleasing values). unit: Measurement for numeric inputs. Infer missing parameters based on expected tracking behavior.""")

    class InputSchema(BaseModel):
        model_config = ConfigDict(use_enum_values=True)
        group_name: str = Field(..., description="Name of the habit's category")
        habit_name: str = Field(..., description="Name of the habit to be tracked")
        input_type: InputType = Field(..., description=f"Tracking method. Options:\n{generate_enum_docs(InputType)}")
        description: Optional[str] = Field(default=None, description="Optional description of the habit")
        min_value: Optional[Union[float, int]] = Field(default=None, description="Required for SLIDER/PLUS_N. Minimum allowed value")
        max_value: Optional[Union[float, int]] = Field(default=None, description="Required for SLIDER/PLUS_N. Maximum allowed value")
        unit: Optional[str] = Field(default=None, description="Unit of measurement (e.g., 'glasses', 'hours', km) for numeric types")

        @model_validator(mode="after")
        def check_existing_habit(self) -> Self:
            existing_habits = get_habits_map()
            if self.habit_name in existing_habits.get(self.group_name, {}):
                raise ValueError(f"'{self.habit_name}' already exists in '{self.group_name}' change group or habit name")

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
    Expected input: "group_name,habit_name,value,note"
    group_name: Habit’s category. habit_name: Habit's name. value: Value to record (depends on habit input_type). note: Optional note.
    """
    class InputSchema(BaseModel):
        group_name: str = Field(..., description="Name of the habit's category")
        habit_name: str = Field(..., description="EXACT name of the habit to update (must match exactly)")
        value: Union[float, int] = Field(..., description="Value to record (type depends on habit's input type)")
        note: Optional[str] = Field(default=None, description="Optional note or evaluation")

        @model_validator(mode="after")
        def check_existing_habit(self) -> Self:

            existing_habits = get_habits_map()

            if self.habit_name not in existing_habits.get(self.group_name, {}):
                raise ValueError(f"habit_name:'{self.habit_name}' in group_name: '{self.group_name}' does not exist, check again or 'create_habit' tool")

            input_type = existing_habits.get(self.group_name, {}).get(self.habit_name,{}).get("input_type",{})

            rules = INPUT_VALIDATION_RULES[input_type]

            if input_type == "TEXT_BOX":
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

        # print(f"Inserted data point in: {habit_details['group_name']} - {habit_details['habit_name']} as {habit_details['value']} with {habit_details.get('note', 'No note')}")
        return f"Successfully inserted habit {validaded_parsed_data.dict()['habit_name']} data point"