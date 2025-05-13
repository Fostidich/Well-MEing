from uuid import uuid4

from langchain_core.messages import SystemMessage, HumanMessage
from langgraph.constants import START, END
from langgraph.graph import StateGraph

from ai_setup.graph_components import MessagesState, tool_node, should_use_tools, memory
from ai_setup.llm_setup import llm
from auxiliary.json_keys import ActionKeys
from auxiliary.utils import ContextInfoManager


def call_model(state: MessagesState):
    print(state["messages"][-1])
    response = llm.invoke(state["messages"])
    print(response)
    return {"messages": [response]}


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


def run_graph(data: dict):
    out = {key.value: {} for key in ActionKeys}

    context = {"habits": data.get("habits", {})}
    user_input = data.get("speech", [])

    context_manager = ContextInfoManager.from_context(context)
    print("Context Manager Initialized")

    innit_prompt = SystemMessage(f"""
    If instructions or parameters are not clear feel free to generate them yourself.
    Currently available habits, choose from these to insert data:
    {context_manager.habits_descriptions}
    """)

    response = graph.invoke(
        {"messages": [innit_prompt, HumanMessage(user_input)],
         "context": context_manager.model_dump(), "out": out},
        config={"configurable": {"thread_id": uuid4()}, "recursion_limit": 20})

    return response
