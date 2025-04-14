from typing import Union, Optional, List, Self
from langchain.tools import BaseTool, tool
from pydantic import BaseModel, Field, model_validator
from auxiliary.misc import generate_enum_docs
from auxiliary.json_building import append_json
from test.emulators import get_context_json_from_db
from datetime import datetime
import json
from ai_tools.creation_schema import HabitCreation
from ai_tools.logging_schema import LoggingData
from auxiliary.json_validation import ActionKeys, InputTypeKeys


@tool("create_habit",
      description="Tool used to create new habit(s) and its associated metric(s).",
      args_schema=HabitCreation)
def CreateHabitTool(creation: HabitCreation) -> str:
    creation_json = [json.dumps(habit.model_dump()) for habit in creation]
    print(creation)
    append_json({ActionKeys.CREATE.value: creation_json})
    return f"Successfully created habit"

@tool("insert_habit_data",
      description="Tool used to insert new data point for existing habit.",
      args_schema=LoggingData)
def InsertHabitDataTool(logging: LoggingData) -> str:
    print(logging)
    logging_json = [json.dumps(data_point.model_dump()) for data_point in logging]
    append_json({ActionKeys.LOGGING.value: logging_json})
    return f"Successfully inserted habit data"
