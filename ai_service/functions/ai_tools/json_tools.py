from typing import List

from langchain.tools import tool
from auxiliary.utils import context_manager
@tool("get_available_habits",
      description="Returns a string summary of currently available habits and their metrics. Call only if needed.")
def AvailableHabitsTool() -> str:
    return context_manager.get_habits_descriptions()
