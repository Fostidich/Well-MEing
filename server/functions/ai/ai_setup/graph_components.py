import operator
from datetime import datetime
from typing import Annotated, Dict, TypedDict

from langchain_core.messages import AnyMessage
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import add_messages
from langgraph.prebuilt import ToolNode

from ai.ai_tools.tools.habit_tools import create_habit_tool, insert_habit_tool
from ai.ai_tools.tools.utils import final_answer
from firebase_admin import db, auth

tools = [create_habit_tool, insert_habit_tool, final_answer]
tool_node = ToolNode(tools)
memory = MemorySaver()


def merge_dicts(current_dict: dict | None, new_dict: dict) -> dict:
    if current_dict is None:
        return new_dict
    return {**current_dict, **new_dict}


class TokenUsage(TypedDict):
    input_tokens: int
    output_tokens: int
    total_tokens: int


class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    context: Annotated[Dict, operator.or_]
    out: Annotated[Dict, operator.or_]
    usage_metadata: Dict[str, TokenUsage]


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

    return "assistant"


def update_db_token_count(total_tokens: int, user_id: str):
    usage_ref = db.reference(f'users/{user_id}/usage')
    usage_data = usage_ref.get()

    now = datetime.now()
    today_str = now.date().isoformat()  # '2025-05-23'
    full_iso = now.isoformat(timespec='seconds')  # '2025-05-23T06:42:00'

    # Check if existing usage is from a different day
    if usage_data:
        stored_today = usage_data.get("today", "")
        stored_date = stored_today[:10]  # Extract 'YYYY-MM-DD'
        if stored_date != today_str:
            usage_ref.delete()
            usage_data = None

    # Initialize if new day or no data
    if usage_data is None:
        usage_ref.set({
            "today": full_iso,  # save full datetime
            "tokens": total_tokens
        })
        return

    # If 'today' is missing, set it with full ISO timestamp
    if "today" not in usage_data:
        usage_ref.update({"today": full_iso})

    # If 'tokens' is missing, initialize it
    if "tokens" not in usage_data:
        usage_ref.update({"tokens": total_tokens})
    else:
        # Otherwise, increment

        current_tokens = usage_data["tokens"]
        usage_ref.update({"tokens": current_tokens + total_tokens})

