from typing import Annotated, Dict, TypedDict

from langchain_core.messages import AnyMessage
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import add_messages
from langgraph.prebuilt import ToolNode

from ai_tools.habit_tools import create_habit_tool, insert_habit_tool
from ai_tools.utils import final_answer

tools = [create_habit_tool, insert_habit_tool, final_answer]
tool_node = ToolNode(tools)
memory = MemorySaver()


class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    context: Dict
    out: Dict


def should_use_tools(state: MessagesState) -> str:
    last_message = state["messages"][-1]

    # Case 1: Check if the last message is a tool call for "final_answer"
    if hasattr(last_message, "tool_calls"):
        for call in last_message.tool_calls:
            if call["name"] == "final_answer":
                return "__end__"

    # Case 2: If there are tool calls, route to "tools" node
    if hasattr(last_message, "tool_calls") and len(last_message.tool_calls) > 0:
        for call in last_message.tool_calls:
            tool_node.inject_tool_args(call, state, store=None)
        return "tools"

    return "agent"
