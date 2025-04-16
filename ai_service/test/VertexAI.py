from typing import TypedDict, Annotated

from dotenv import load_dotenv
from langchain_core.messages import SystemMessage, AnyMessage
from langchain_google_vertexai.chat_models import ChatVertexAI
from langgraph.checkpoint.memory import MemorySaver
from langgraph.constants import START, END
from langgraph.graph import add_messages, StateGraph
from langgraph.prebuilt import ToolNode, tools_condition

from ai_tools.habit_tools import CreateHabitTool, InsertHabitDataTool
from ai_tools.json_tools import get_context_tools
from auxiliary.utils import generate_habit_descriptions

load_dotenv()

llm = ChatVertexAI(model_name="gemini-2.0-flash-001")

innit_prompt = SystemMessage(
    content=("""\
### AI Assistant Behavior Rules:
You are an AI assistant that manages habit tracking using predefined tools. 
You MUST only respond by invoking one or more tools from the available list. 
You are strictly forbidden from replying with text messages or natural language explanations.

If instructions or parameters are missing or ambiguous:
- Generate reasonable values yourself.
- Immediately call the appropriate tool with those values.

If no tool applies, call a 'noop' tool or return no tool call (as per workflow config), but NEVER reply with a message.
""" + f"""
Currently tracked and **ALREADY CREATED** habits and metrics:
{generate_habit_descriptions()}
Now, process this user input:
""")
)


class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    unsent_tool_calls: list[dict]


JsonTools = get_context_tools()

tools = [CreateHabitTool, InsertHabitDataTool] + JsonTools
llm_w_tools = llm.bind_tools(tools)


def assistant(state: MessagesState):
    response = llm_w_tools.invoke([innit_prompt] + state["messages"])

    # Enforce: if response contains content, raise error or skip
    if getattr(response, 'content', None):
        raise ValueError(f"AI responded with text. It should only call tools. If parameters are missing generate intelligent and reasonable values.")

    return {"messages": [response]}


workflow = StateGraph(MessagesState)

# Define the two nodes we will cycle between
workflow.add_node("assistant", assistant)
workflow.add_node("tools", ToolNode(tools))

workflow.add_edge(START, "assistant")
workflow.add_conditional_edges("assistant", tools_condition, ["tools", END])
workflow.add_edge("tools", "assistant")

app = workflow.compile()

# Build graph with memory checkpointing
memory = MemorySaver()
graph = workflow.compile(checkpointer=memory)

# Thread
config = {"configurable": {"thread_id": "2"}}

user_input = ("I need to start meditating more often, create a habit for it and today I did 30 minutes of meditation")
result = graph.invoke({"messages": [{"role": "user", "content": user_input}]}, config=config)

for message in result["messages"]:
    message.pretty_print()
