from typing import Union, Optional, List, Self
from langchain.tools import BaseTool, tool
from pydantic import BaseModel, Field, model_validator
from auxiliary.utils import generate_enum_docs
from auxiliary.json_building import extend_out_dict
from test.emulators import get_context_json_from_db
from datetime import datetime
import json
from ai_tools.creation_schema import HabitCreation, Habit
from ai_tools.logging_schema import LoggingData, LogEntry
from auxiliary.json_keys import ActionKeys
from auxiliary.ui_rules import InputTypeKeys


@tool("create_habit",
      description="Tool used to create new habit(s) and its associated metric(s).",
      args_schema=HabitCreation)
def CreateHabitTool(creation: List[Habit]) -> str:
    model_dict = [habit.model_dump() for habit in creation]
    extend_out_dict({ActionKeys.CREATE.value: model_dict})
    return f"Successfully created habit"


@tool("insert_habit_data",
      description="Tool used to insert new data point for existing habit.",
      args_schema=LoggingData)
def InsertHabitDataTool(logging: List[LogEntry]) -> str:
    logging_dict = [data_point.model_dump() for data_point in logging]
    extend_out_dict({ActionKeys.LOGGING.value: logging_dict})
    return f"Successfully inserted habit data"
