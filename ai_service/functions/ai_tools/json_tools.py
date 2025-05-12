from typing import Annotated, Dict

from langchain.tools import tool
from langgraph.prebuilt import InjectedState

from auxiliary.utils import ContextInfoManager

print("json_tools.py loaded")


@tool("get_available_habits",
      description="Tool returns currently available habit and metrics names.")
def AvailableHabitsTool(state: Annotated[Dict, InjectedState]) -> str:
    context_manager = ContextInfoManager(state.get("context"))
    return context_manager.habits_descriptions
