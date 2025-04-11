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

from ai_tools.habit_tools import CreateHabitTool, InsertHabitDataTool
from ai_tools.json_tools import get_context_tools

# Load .env variables
load_dotenv()
JsonTools = get_context_tools()
# Initialize the LLM
llm = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash-exp-image-generation",
    google_api_key=os.getenv("GEMINI_API_KEY"),
    temperature=0.2,
)


tools = [CreateHabitTool, InsertHabitDataTool] + JsonTools
# Bind tools to the LLM
llm_with_tools = llm.bind_tools(tools)

# Initial system message
sys_msg = SystemMessage(
    content=("""
    ### Your behavior rules:
    - You must answer **any question** related to the user's habits or tracked metrics.
    - You may ask the user follow-up questions if critical information is missing (like habit name or metric details).
    - If the user does **not** provide the `habit-name` or `metric` information, and it's not reasonable to ask, you may **intelligently generate** appropriate names and values based on context.
    - You should call:
      - `CreateHabit` if the user asks to track a new habit.
      - `InsertHabitData` if the user wants to log or record a value into an existing habit.
    - Do **not hallucinate** data about existing habits unless the user has already mentioned them.
    - You must ensure the structure passed to the tools is valid and complete.

    You do **not** need to confirm tool outputs; just focus on selecting the correct tool and parameters.
    
    Begin!    
    Question: {input}  
    Thought: I should determine whether the user wants to create a new habit or log a data point. Then, I will check what parameters are missing and whether I can fill them or ask for clarification.  
    {agent_scratchpad}
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
