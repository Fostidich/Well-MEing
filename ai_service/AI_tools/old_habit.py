from typing import Union, Optional, List
from langchain.tools import BaseTool
from pydantic import BaseModel, Field, ConfigDict, field_validator
from ai_service.auxiliary.habit_validation import InputType
from ai_service.auxiliary.misc import generate_enum_docs
from ai_service.test.emulators import get_habits_from_DB, save_to_db
from datetime import datetime


def parsing_create_habit(input_string: str):
    """
    Parse a comma-separated string for creating a habit.

    Expected input format:
    "habit_name,input_type[,description,min_value,max_value,unit]"

    Example inputs:
    - "Water Intake,PLUS_N,Tracking daily water,0,10,glasses"
    - "Reading,TEXTBOX,Daily reading log"
    """
    # Split the input string
    parts = input_string.split(",")

    # Ensure at least the minimum required parts are present
    if len(parts) < 2:
        raise ValueError("Insufficient arguments. Provide at least habit name and input type.")

    # Parse required arguments
    habit_name = parts[0]
    input_type = InputType[parts[1]]  # Convert string to enum

    # Optional arguments with default None
    description = parts[2] if len(parts) > 2 else None

    # Parse numeric values, handling potential None or empty string
    min_value = float(parts[3]) if len(parts) > 3 and parts[3] else None
    max_value = float(parts[4]) if len(parts) > 4 and parts[4] else None

    # Unit as optional last argument
    unit = parts[5] if len(parts) > 5 else None

    return {
        "habit_name": habit_name,
        "input_type": input_type,
        "description": description,
        "min_value": min_value,
        "max_value": max_value,
        "unit": unit
    }


class CreateHabitTool(BaseTool):
    """
    Tool for creating a new habit with specific tracking parameters.
    """
    name: str = "create_habit"
    description: str = "Create a new habit to track with a specific input method"

    class InputSchema(BaseModel):
        habit_name: str = Field(..., description="Name of the habit to track")
        input_type: InputType = Field(
            ...,
            description=f"Tracking method. Options:\n{generate_enum_docs(InputType)}"
        )
        description: Optional[str] = Field(default=None, description="Optional description of the habit")
        min_value: Optional[Union[float, int]] = Field(
            default=None,
            description="Required for SLIDER/PLUS_N. Minimum allowed value"
        )
        max_value: Optional[Union[float, int]] = Field(
            default=None,
            description="Required for SLIDER/PLUS_N. Maximum allowed value"
        )
        unit: Optional[str] = Field(
            default=None,
            description="Unit of measurement (e.g., 'glasses', 'hours', km) for numeric types"
        )
        # Pydantic V2 config
        model_config = ConfigDict(use_enum_values=True)

    def _run(self,
             habit_name: str,
             input_type: InputType,
             description: Optional[str] = None,
             min_value: Optional[Union[float, int]] = None,
             max_value: Optional[Union[float, int]] = None,
             unit: Optional[str] = None):
        """
        Create a new habit in the tracking system.

        Args:
            habit_name: Name of the habit
            input_type: How the habit will be tracked
            description: Optional description of the habit
            min_value: Minimum value for slider or +N inputs
            max_value: Maximum value for slider or +N inputs
            unit: Unit of measurement

        Returns:
            Confirmation of habit creation
        """
        # In a real implementation, this would interact with a database or tracking system
        habit_details = {
            "name": habit_name,
            "input_type": input_type.value,
            "description": description,
            "min_value": min_value,
            "max_value": max_value,
            "unit": unit
        }
        # DB insertion
        print(f"Habit Created: {habit_details}")
        return f"Successfully created habit: {habit_name}"


def parsing_insert_habit_data(input_string: str):
    """
    Parse a comma-separated string for inserting habit data.

    Expected input format:
    "habit_name,value[,evaluation]"

    Example inputs:
    - "Water Intake,3"
    - "Reading,Finished chapter 5"
    - "Mood,Positive,Good day overall"
    """
    # Split the input string
    parts = input_string.split(",")

    # Ensure at least the minimum required parts are present
    if len(parts) < 2:
        raise ValueError("Insufficient arguments. Provide at least habit name and value.")

    # Parse required arguments
    habit_name = parts[0]
    value = parts[1]

    # Optional evaluation argument
    evaluation = parts[2] if len(parts) > 2 else None

    # Attempt to convert value to number if possible
    try:
        value = float(value)
    except ValueError:
        # Keep as string if not a number
        pass

    return {
        "habit_name": habit_name,
        "value": value,
        "evaluation": evaluation
    }

class InsertHabitDataTool(BaseTool):
    """
    Tool for inserting data into an existing habit.

    Available habits are dynamically loaded from the database.
    The LLM should first list habits if uncertain which to update.
    """
    name: str = "insert_habit_data"
    description: str = "Insert data for an existing habit"
    valid_habits: List[str] = Field(default_factory=list)
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.refresh_habits()  # Initialize with current habits

    def refresh_habits(self):
        """Update the list of valid habits from database"""
        self.valid_habits = get_habits_from_DB()
        # Format the habits into a description string
        habits_description = "\n".join(
            [f"- {habit['habit_name']} (Input type: {habit['input_type']})" for habit in self.valid_habits]
        )
        # Update tool description with current habits
        self.description = f"""Insert a data point for an existing habit.
    
        Current available habits:
        {habits_description}
        
        Usage:
        - First verify the habit exists
        - Provide value matching the habit's input type:
          - Numbers for +1/+5/slider
          - Text for textbox
          - Evaluation levels for evaluation type
        """

    class InputSchema(BaseModel):
        habit_name: str = Field(...,
                                description="EXACT name of the habit to update (must match exactly)")
        value: Union[float, int, str] = Field(...,
                                              description="Value to record (type depends on habit's input type)")
        evaluation: Optional[str] = Field(None,
                                          description="Required if habit uses EVALUATION input type")

        @field_validator("habit_name")
        def validate_habit_name(cls, v, values):
            # Note: This accesses the tool instance through values.context
            #tool = values.data.get("_tool")
            #if v not in tool.valid_habits:
               # raise ValueError(
                 #   f"Invalid habit. Current habits: {', '.join(tool.valid_habits)}"
                #)
            return v

        @field_validator("value")
        def validate_value(cls, v, values):
            # Add type validation based on habit's input type
            # (Would need access to habit metadata)
            return v

        model_config = {
            "extra": "allow"  # Permits adding the _tool reference
        }

    def _run(self, habit_name: str, value: Union[float, int, str],
             evaluation: Optional[str] = None, **kwargs):
        """Insert data for a specific habit with validation"""
        # Refresh habits in case of recent changes
        self.refresh_habits()

        if habit_name not in self.valid_habits:
            return f"Error: Habit '{habit_name}' not found. Available: {', '.join(self.valid_habits)}"

        # Get habit metadata for additional validation
        habit_meta = self.get_habit_metadata(habit_name)

        # Type-specific validation
        if habit_meta["input_type"] == InputType.EVALUATION and not evaluation:
            return "Error: Evaluation type requires an evaluation value"

        # Insert data
        data_point = {
            "habit": habit_name,
            "value": value,
            "timestamp": datetime.now(),
            **({"evaluation": evaluation} if evaluation else {})
        }

        save_to_db(data_point)
        return f"Data recorded for {habit_name}: {value}"




