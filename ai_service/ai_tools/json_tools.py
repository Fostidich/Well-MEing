from langchain_core.tools import Tool
from langchain_community.agent_toolkits import JsonToolkit
from langchain_community.tools.json.tool import JsonSpec
from langchain_community.agent_toolkits import JsonToolkit, create_json_agent
from langchain_community.tools.json.tool import JsonSpec

from test.emulators import get_context_json_from_db

print()
def get_context_tools():
    json = get_context_json_from_db()
    json_spec = JsonSpec(dict_=json, max_value_length=4000)
    json_toolkit = JsonToolkit(spec=json_spec)
    json_tools = json_toolkit.get_tools()
    context_tools = json_tools

    return context_tools
