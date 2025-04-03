# This file is a test file for the graph.py file in the ai_service directory

from dotenv import load_dotenv
import os

from langgraph.checkpoint.memory import MemorySaver
from langchain_core.messages import SystemMessage, AnyMessage
from langchain_openai import ChatOpenAI

from ai_service.AI_tools.habit import CreateHabitTool, InsertHabitDataTool

load_dotenv()

llm = ChatOpenAI(
    openai_api_key=os.getenv("API_KEY"),
    openai_api_base="https://api.deepseek.com",
    model_name="deepseek-chat"
)

# Tool initialization
create_habit_tool = CreateHabitTool()
insert_habit_tool = InsertHabitDataTool()
tools = [create_habit_tool, insert_habit_tool]

# Bind tools to LLM
llm_with_tools = llm.bind_tools(tools, parallel_tool_calls=False)

# Initial prompt
sys_msg = SystemMessage(content="You are a helpful assistant that can help users track their habits")

# LLM Node

from typing import Annotated, TypedDict
from langgraph.graph.message import add_messages


config = {"configurable": {"thread_id": "1"}}
class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]


def assistant(state: MessagesState):
    return {"messages": [llm_with_tools.invoke([sys_msg] + state["messages"])]}


from langgraph.graph import START, StateGraph
from langgraph.prebuilt import tools_condition
from langgraph.prebuilt import ToolNode

# Graph
builder = StateGraph(MessagesState)

# Define nodes: these do the work
builder.add_node("assistant", assistant)
builder.add_node("tools", ToolNode(tools))

# Define edges: these determine how the control flow moves
builder.add_edge(START, "assistant")
builder.add_conditional_edges(
    "assistant",
    # If the latest message (result) from assistant is a tool call -> tools_condition routes to tools
    # If the latest message (result) from assistant is a not a tool call -> tools_condition routes to END
    tools_condition,
)
builder.add_edge("tools", "assistant")

memory = MemorySaver()
react_graph = builder.compile(checkpointer=memory)

# Save the image to a file
image_data = react_graph.get_graph(xray=True).draw_mermaid_png()
with open("graph.png", "wb") as f:
    f.write(image_data)

# Open the saved image file
import webbrowser

webbrowser.open("graph.png")
