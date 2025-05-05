
from langchain.tools import tool
from auxiliary.utils import context_manager



@tool("get_available_habits",
      description="Tool returns currently available habit and metrics names.")
def AvailableHabitsTool() -> str:
    context_manager.update_context_info()
    return context_manager.habits_descriptions
