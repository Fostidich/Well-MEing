from typing import List

from langchain.tools import tool

from ai_tools.creation_schema import HabitCreation, Habit
from ai_tools.logging_schema import LoggingData, LogEntry
from auxiliary.json_building import process_out
from auxiliary.json_keys import ActionKeys
from auxiliary.utils import context_manager


@tool("create_habit",
      description="Use tool to create new habit(s) and its metric(s).",
      args_schema=HabitCreation)
def CreateHabitTool(creation: List[Habit]) -> str:
    model_dict = [habit.model_dump() for habit in creation]
    context_manager.add_context_from_creation(model_dict)
    process_out({ActionKeys.CREATE.value: model_dict})
    return f"Habit(s) created"


@tool("insert_habit_data",
      description="Use tool to insert log(s) for existing habit(s).",
      args_schema=LoggingData)
def InsertHabitDataTool(logging: List[LogEntry]) -> str:
    logging_dict = [data_point.model_dump() for data_point in logging]
    process_out({ActionKeys.LOGGING.value: logging_dict})
    return f"Log(s) inserted"
