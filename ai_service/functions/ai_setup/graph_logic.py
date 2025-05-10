from uuid import uuid4

from langchain_core.messages import SystemMessage, HumanMessage
from langgraph.constants import START, END
from langgraph.graph import StateGraph

from ai_setup.graph_components import MessagesState, tool_node, should_use_tools, memory
from auxiliary.json_keys import ActionKeys
from auxiliary.utils import ContextInfoManager


def run_graph(llm, data: dict):
    out = {key.value: {} for key in ActionKeys}
    context = data.get("context", {})
    user_input = data.get("speech", [])

    innit_prompt = SystemMessage(f"""
    If instructions or parameters are not clear feel free to generate them yourself.
    Currently available habits, choose from these to insert data:
    {ContextInfoManager(context).habits_descriptions}""")

    def call_model(state: MessagesState):
        print(state["messages"][-1])
        response = llm.invoke(state["messages"])
        print(response)
        return {"messages": [response]}

    def init_node(state: MessagesState):
        state["context"] = context
        state["out"] = out
        return state

    workflow = StateGraph(MessagesState)

    # NODES
    workflow.add_node("init", init_node)
    workflow.add_node("assistant", call_model)
    workflow.add_node("tools", tool_node)

    # EDGES
    workflow.add_edge(START, "init")
    workflow.add_edge("init", "assistant")
    workflow.add_conditional_edges("assistant", should_use_tools, ["tools", END])
    workflow.add_edge("tools", "assistant")

    graph = workflow.compile(checkpointer=memory)

    response = graph.invoke(
        {"messages": [innit_prompt, HumanMessage(user_input)]},
        config={"configurable": {"thread_id": uuid4()}, "recursion_limit": 20})

    return response
