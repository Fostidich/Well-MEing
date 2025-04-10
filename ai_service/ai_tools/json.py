from langchain_core.tools import Tool
from langchain_community.agent_toolkits import JsonToolkit
from langchain_community.tools.json.tool import JsonSpec
from langchain_community.agent_toolkits import JsonToolkit, create_json_agent
from langchain_community.tools.json.tool import JsonSpec

from test.emulators import get_context_json_from_db


def get_context_tools():
    json = get_context_json_from_db()
    json_spec = JsonSpec(dict_=json, max_value_length=4000)
    json_toolkit = JsonToolkit(spec=json_spec)
    json_tools = json_toolkit.get_tools()
    context_tools = []
    for tool in json_tools:
        if tool.name == "json_list_values":
            tool.description = (
                "List all habits/metrics you are tracking by retrieving the values under a key in the JSON file."
            )
        elif tool.name == "json_get_value":
            tool.description = (
                "Get specific data (like metrics or descriptions) for a given habit or metric by using the JSON path."
            )
        elif tool.name == "json_list_keys":
            tool.description = (
                "List available keys in the habit-tracking context (such as 'creation' or 'logging')."
            )
        context_tools.append(tool)
    return context_tools
