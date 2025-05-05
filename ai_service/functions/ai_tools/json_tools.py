from langchain_community.agent_toolkits import JsonToolkit
from langchain_community.tools.json.tool import JsonSpec

from test.emulators import get_context_json_from_db
from typing import List

from langchain.tools import tool
from auxiliary.json_building import process_out
from auxiliary.json_keys import ActionKeys
from auxiliary.utils import context_manager

def get_context_tools():
    json = get_context_json_from_db()
    json_spec = JsonSpec(dict_=json, max_value_length=4000)
    json_toolkit = JsonToolkit(spec=json_spec)
    json_tools = json_toolkit.get_tools()
    return json_tools



@tool("get_available_habits",
      description="Tool returns currently available habit and metrics names.")
def AvailableHabitsTool() -> str:
    context_manager.update_context_info()
    return context_manager.habits_descriptions
