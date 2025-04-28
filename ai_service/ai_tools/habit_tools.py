from typing import List

from langchain.tools import tool

from ai_tools.creation_schema import HabitCreation, Habit
from ai_tools.logging_schema import LoggingData, LogEntry
from auxiliary.json_building import extend_out_dict
from auxiliary.json_keys import ActionKeys

"""
This module defines tools for managing habits, including creating new habits and logging data for existing habits.

Functions:
- CreateHabitTool: A tool for creating new habits and their associated metrics. It validates the input schema using creation_schema module and updates the database with the new habit data.
- InsertHabitDataTool: A tool for logging data points for existing habits. It validates the input schema using logging_schema module and updates the database with the logged data.

Purpose:
This module provides the functionality to interact with the habit tracking system, ensuring that all habit creation and logging operations adhere to the defined schemas and constraints.
"""
@tool("create_habit",
      description="Tool used to create new habit(s) and its associated metric(s)."
                  "When creating multiple habits, ALWAYS batch them into a single call using a list of Habit.",
      args_schema=HabitCreation)
def CreateHabitTool(creation: List[Habit]) -> str:
    model_dict = [habit.model_dump() for habit in creation]
    extend_out_dict({ActionKeys.CREATE.value: model_dict})
    return f"Successfully created habit"


@tool("insert_habit_data",
      description="Tool used to insert new data point for existing habit."
                  "When logging multiple entries, ALWAYS batch them into a single call using a list of LogEntry."
                  "If the user selects multiple options in a form, combine them into a single list and log them together.",
      args_schema=LoggingData)
def InsertHabitDataTool(logging: List[LogEntry]) -> str:
    logging_dict = [data_point.model_dump() for data_point in logging]
    extend_out_dict({ActionKeys.LOGGING.value: logging_dict})
    return f"Successfully inserted habit data"
