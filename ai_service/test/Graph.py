# This file is a test file for the graph.py file in the ai_service directory

from dotenv import load_dotenv
import os
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph.message import add_messages
from langgraph.graph import START, StateGraph, END
from langgraph.prebuilt import tools_condition, ToolNode
from langchain_google_vertexai.chat_models import ChatVertexAI
from langchain_core.messages import SystemMessage, AnyMessage

from typing import Annotated, TypedDict

from ai_tools.habit_tools import CreateHabitTool, InsertHabitDataTool
from ai_tools.json_tools import get_context_tools
from test.emulators import send_to_db
# Load .env variables
load_dotenv()
JsonTools = get_context_tools()
# Initialize the LLM
llm = ChatVertexAI(model_name="gemini-2.0-flash-001")

tools = [CreateHabitTool, InsertHabitDataTool] + JsonTools
# Bind tools to the LLM
llm_with_tools = llm.bind_tools(tools)

# Initial system message
sys_msg = SystemMessage(
    content=("""
    ### Your behavior rules:
    - You must answer **any question** related to the user's habits or tracked metrics.
    - If the user does **not** provide some parameters values, and it's not reasonable to ask, you may **intelligently generate** appropriate names and values based on context.
    - You should call:
      - `CreateHabit` if the user asks to track a new habit.
      - `InsertHabitData` if the user wants to log or record a value into an existing habit.
    - Do **not hallucinate** data about existing habits unless the user has already mentioned them.
    - You must ensure the structure passed to the tools is valid and complete.
    You do **not** need to confirm tool outputs; just focus on selecting the correct tool and parameters.
    Begin!    
    Question: {input}  
    Thought: I should determine whether the user wants to create a new habit or log a data point.  
    {agent_scratchpad}
    """

             )
)


class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    unsent_tool_calls: list[dict]  # To track unsent tool calls



# Assistant node logic
def assistant(state: MessagesState):
    response = llm_with_tools.invoke([sys_msg] + state["messages"])
    # Check if no tools are called and there are unsent tool calls
    if not tools_condition(response) and state["unsent_tool_calls"]:

        state["unsent_tool_calls"].clear()  # Clear the list of unsent tool calls
    return {"messages": [response]}


def tool_node(state: MessagesState, tool_input: dict):
    # Append the tool call to the unsent tool calls list
    state["unsent_tool_calls"].append(tool_input)
    return ToolNode(tools)(state)


# Graph builder
builder = StateGraph(MessagesState)

# Define nodes
builder.add_node("assistant", assistant)
builder.add_node("tools", tool_node)

# Define edges and control flow
builder.add_edge(START, "assistant")
builder.add_conditional_edges("assistant", tools_condition, "tools", END)

builder.add_edge("tools", "assistant")  # tools always lead back to assistant
builder.add_edge("assistant", END)

# Build graph with memory checkpointing
memory = MemorySaver()
graph = builder.compile(checkpointer=memory)

# Visualize the graph
image_data = graph.get_graph(xray=True).draw_mermaid_png()
with open("graph.png", "wb") as f:
    f.write(image_data)

# Thread
config = {"configurable": {"thread_id": "1"}}


def stream_graph_updates(user_input: str):
    for event in graph.stream({"messages": [{"role": "user", "content": user_input}]}, config=config):
        for value in event.values():
            if "tool_input" in value:
                print("Tool Input:", value["tool_input"])
            print("Assistant:", value["messages"][-1].content)


while True:
    try:
        user_input = input("User: ")
        if user_input.lower() in ["quit", "exit", "q"]:
            print("Goodbye!")
            break
        stream_graph_updates(user_input)
    except:
        # fallback if input() is not available
        user_input = "What do you know about LangGraph?"
        print("User: " + user_input)
        stream_graph_updates(user_input)
        break
