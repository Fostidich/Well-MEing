# This file is a test file for the graph.py file in the ai_service directory

from dotenv import load_dotenv
import os
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph.message import add_messages
from langgraph.graph import START, StateGraph, END
from langgraph.prebuilt import tools_condition, ToolNode

from langchain_core.messages import SystemMessage, AnyMessage
from langchain_google_genai import ChatGoogleGenerativeAI
from typing import Annotated, TypedDict

from ai_tools.habit import CreateHabitTool, InsertHabitDataTool
from ai_tools.json import get_context_tools


# Load .env variables
load_dotenv()
json_tools = get_context_tools()
# Initialize the LLM
llm = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash-exp-image-generation",
    google_api_key=os.getenv("GEMINI_API_KEY"),
    temperature=0.5,
)
tools = [CreateHabitTool, InsertHabitDataTool] + json_tools
# Bind tools to the LLM
llm_with_tools = llm.bind_tools(tools)

# Initial system message
sys_msg = SystemMessage(
    content=("""
    You are a habit tracker assistant. 
    You have the power to generate by yourself all parameters for habit creation and logging.
    You can also use the tools you have to create and log habits.
    You can use the json tools to get information about the habits you are tracking.
    """

    )
)

# Define message state
class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]

# Assistant node logic
def assistant(state: MessagesState):
    return {"messages": [llm_with_tools.invoke([sys_msg] + state["messages"])]}

# Graph builder
builder = StateGraph(MessagesState)

# Define nodes
builder.add_node("assistant", assistant)
builder.add_node("tools", ToolNode(tools))

# Define edges and control flow
builder.add_edge(START, "assistant")
builder.add_conditional_edges(
    "assistant",
    tools_condition
)
builder.add_edge("tools", "assistant")  # tools always lead back to assistant
builder.add_edge("assistant", END)

# Build graph with memory checkpointing
memory = MemorySaver()
react_graph = builder.compile(checkpointer=memory)

# Visualize the graph
image_data = react_graph.get_graph(xray=True).draw_mermaid_png()
with open("graph.png", "wb") as f:
    f.write(image_data)

#webbrowser.open("graph.png")

initial_input = {"messages": "Look in the JSON file and tell me what habits I am tracking."}

# Thread
thread = {"configurable": {"thread_id": "1"}}

# Run the graph until the first interruption
for event in react_graph.stream(initial_input, thread, stream_mode="values"):
    event['messages'][-1].pretty_print()