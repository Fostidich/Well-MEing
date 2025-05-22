from typing import List, Dict, Annotated

from langchain.tools import tool
from langchain_core.messages import ToolMessage
from langchain_core.tools import InjectedToolCallId
from langgraph.prebuilt import InjectedState
from langgraph.types import Command

from ai.ai_tools.creation_schema import HabitCreation, Habit
from ai.ai_tools.logging_schema import LoggingData, LogEntry
from ai.auxiliary.json_building import process_creation, process_logging


@tool("create_habit",
      description="Use this tool to create new habit(s) and their metric(s).",
      args_schema=HabitCreation)
def create_habit_tool(tool_call_id: Annotated[str, InjectedToolCallId], creation: List[Habit],
                      state: Annotated[Dict, InjectedState]) -> Command:
    creation_dict = [habit.model_dump(mode='json') for habit in creation]
    creation_out, updated_context = process_creation(creation_dict, state.get("out"), state.get("context"))

    return Command(
        update={
            "context": updated_context,
            "out": creation_out,
            "messages": [ToolMessage(content="Successfully Created Habit", tool_call_id=tool_call_id)],
        }
    )


@tool("insert_habit_data",
      description="Use tool to insert habits data among the available habits. "
                  "If the habit is not present in the context create it first using create_habit tool",
      args_schema=LoggingData)
def insert_habit_tool(tool_call_id: Annotated[str, InjectedToolCallId], logging: List[LogEntry],
                      state: Annotated[Dict, InjectedState]) -> Command:
    logging_dict = [data_point.model_dump() for data_point in logging]
    logging_out, _ = process_logging(logging_dict, state.get("out"), state.get("context"))

    return Command(
        update={
            "out": logging_out,
            "messages": [ToolMessage(content="Successfully Logged Habit metrics", tool_call_id=tool_call_id)],
        }
    )
