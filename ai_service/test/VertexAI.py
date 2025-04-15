from langchain_google_vertexai.chat_models import ChatVertexAI
from dotenv import load_dotenv
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph.message import add_messages
from langgraph.graph import START, StateGraph, END
from langgraph.prebuilt import tools_condition, ToolNode

from langchain_core.messages import SystemMessage, AnyMessage
from typing import Annotated, TypedDict

from ai_tools.habit_tools import CreateHabitTool, InsertHabitDataTool
from ai_tools.json_tools import get_context_tools
from test.emulators import send_to_db

load_dotenv()
# To use model
llm = ChatVertexAI(model_name="gemini-2.0-flash-001")
toolkit = [CreateHabitTool, InsertHabitDataTool]
llm_w_tools = llm.bind_tools(toolkit)
llm_output = llm_w_tools.invoke('call the Insert habit tool with random arguments, decide all arguments by yourself')

print(llm_output)