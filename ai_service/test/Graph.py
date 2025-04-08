# This file is a test file for the graph.py file in the ai_service directory

from dotenv import load_dotenv
import os
import webbrowser

from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph.message import add_messages
from langgraph.graph import START, StateGraph, END
from langgraph.prebuilt import tools_condition, ToolNode

from langchain_core.messages import SystemMessage, AnyMessage
from langchain_google_genai import ChatGoogleGenerativeAI
from typing import Annotated, TypedDict
from auxiliary.json_building import confirmation
from ai_tools.habit import CreateHabitTool, InsertHabitDataTool, GetHabitsTool
from test.emulators import summarize_habits_structure
# Optional: If you want to dynamically summarize habit structure
from test.emulators import get_json_from_db

# Load .env variables
load_dotenv()

# Initialize the LLM
llm = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash-exp-image-generation",
    google_api_key=os.getenv("GEMINI_API_KEY"),
    temperature=0.2,
)

# Initialize tools
create_habit_tool = CreateHabitTool()
insert_habit_tool = InsertHabitDataTool()
get_habits_tool = GetHabitsTool()
tools = [create_habit_tool, insert_habit_tool, get_habits_tool]

# Bind tools to the LLM
llm_with_tools = llm.bind_tools(tools)

# Initial system message
sys_msg = SystemMessage(
    content=(
        "You are a habit tracking assistant. Help the user track their habits.\n"
    )
)

# Define message state
class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]

# Assistant node logic
def assistant(state: MessagesState):
    return {"messages": [llm_with_tools.invoke([sys_msg] + state["messages"])]}

# Confirm input node logic (called when no more tool calls are needed)
def confirm_input(state: MessagesState):
    print("Confirm_input")
    confirmation()
    # You could also add a follow-up here asking the user if they want to continue
    return {"messages": state["messages"]}

# Graph builder
builder = StateGraph(MessagesState)

# Define nodes
builder.add_node("assistant", assistant)
builder.add_node("tools", ToolNode(tools))
builder.add_node("confirm_input", confirm_input)

# Define edges and control flow
builder.add_edge(START, "assistant")
builder.add_conditional_edges(
    "assistant",
    tools_condition
)
builder.add_edge("tools", "assistant")  # tools always lead back to assistant
builder.add_edge("assistant", "confirm_input")  # assistant can lead to confirm_input if no tool calls are made
builder.add_edge("confirm_input", END)  # confirm_input leads to end

# Build graph with memory checkpointing
memory = MemorySaver()
react_graph = builder.compile(checkpointer=memory)

# Visualize the graph
image_data = react_graph.get_graph(xray=True).draw_mermaid_png()
with open("graph.png", "wb") as f:
    f.write(image_data)

webbrowser.open("graph.png")


from langchain_core.messages import HumanMessage

initial_input = {"messages": "Track my diet calories intake and weight. Today I ate 2000 calories and weighed 70kg."}

# Thread
thread = {"configurable": {"thread_id": "1"}}

# Run the graph until the first interruption
for event in react_graph.stream(initial_input, thread, stream_mode="values"):
    event['messages'][-1].pretty_print()