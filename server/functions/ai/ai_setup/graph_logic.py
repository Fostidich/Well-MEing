import datetime
import json
from typing import TypedDict, Dict, Any
from uuid import uuid4

from langchain_core.callbacks import UsageMetadataCallbackHandler
from langchain_core.messages import SystemMessage, HumanMessage
from langgraph.constants import START, END
from langgraph.graph import StateGraph

from ai.ai_setup.graph_components import tool_node, should_use_tools, memory, MessagesState, update_db_token_count
from ai.ai_setup.llm_setup import llm
from ai.auxiliary.json_keys import ActionKeys
from ai.auxiliary.utils import ContextInfoManager
from ai.dto.speech_client_to_server import HabitInputDTO

token_callback = UsageMetadataCallbackHandler()


def call_model(state: MessagesState):
    # print(state["messages"][-1])
    response = llm.invoke(state["messages"], config={"callbacks": [token_callback]})
    # print(response)
    return {"messages": [response], "usage_metadata": token_callback.usage_metadata}


def innit_graph():
    workflow = StateGraph(MessagesState)

    # NODES
    workflow.add_node("assistant", call_model)
    workflow.add_node("tools", tool_node)

    # EDGES
    workflow.add_edge(START, "assistant")
    workflow.add_conditional_edges("assistant", should_use_tools, ["assistant", "tools", END])
    workflow.add_edge("tools", "assistant")

    graph = workflow.compile(checkpointer=memory)
    return graph


graph = innit_graph()


def run_graph(data: Dict[str, Any]):
    out = {key.value: {} for key in ActionKeys}

    context = {"habits": data.get("habits", {})}
    user_input = data.get("speech", [])
    user_id = data['user_id']

    context_manager = ContextInfoManager.from_context(context)
    print("Context Manager Initialized")

    innit_prompt = SystemMessage(f"""
    If instructions or parameters are not clear feel free to generate them yourself.
    Currently available habits, choose from these to insert data:
    {context_manager.habits_descriptions}
    """)

    response = graph.invoke(
        {"messages": [innit_prompt, HumanMessage(user_input)],
         "context": context_manager.model_dump(), "out": out, "usage_metadata": {}},
        config={"configurable": {"thread_id": uuid4()}, "recursion_limit": 10})

    metadata = response.get('usage_metadata', {})
    model_key = next(iter(metadata), None)
    token_usage = metadata.get(model_key, {})
    total_tokens = token_usage.get("total_tokens", 0)
    update_db_token_count(total_tokens, user_id)

    return response

