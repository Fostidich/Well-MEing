from uuid import uuid4

from langchain_core.messages import SystemMessage, HumanMessage
from langgraph.constants import START, END
from langgraph.graph import StateGraph

from ai.ai_setup.graph_components import tool_node, should_use_tools, memory, MessagesState
from ai.ai_setup.llm_setup import llm
from ai.auxiliary.json_keys import ActionKeys
from ai.auxiliary.utils import ContextInfoManager

import json
import datetime

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

def run_report_only(llm, context: dict, user_prompt: str) -> dict:
    """
    Generates a structured weekly report using the LLM and returns a dictionary:
    { "date": ..., "title": ..., "content": ... }
    """
    init_prompt = SystemMessage(f"""
        Generate a detailed weekly wellness report with advices based on user's habits and goals.
        If information is missing, make reasonable assumptions.
        Use Apple emojis in order to enhance the report visually and make it more engaging.
        **IMPORTANT**: Format everything in Markdown.
        No emojis in titles, use '-' for pointed lists.
        The report should have these sections, with no extra wrapping text: "Overview", "Analysis", "Suggestions".
        Prefer plain text paragraphs rather than pointed lists.
        Use the following context:
        {context.get("history_summary", "No detailed context provided.")},
        {context.get("user_info", "No user info provided.")}
    """)
#Focus on finding correlations between habits, rather than listing them one by one separately.


    messages = [init_prompt, HumanMessage(user_prompt)]
    llm_response = llm.invoke(messages)

    # Extract the content
    report_content = ""

    if hasattr(llm_response, 'content') and llm_response.content:
        report_content = llm_response.content
    elif hasattr(llm_response, 'additional_kwargs') and 'function_call' in llm_response.additional_kwargs:
        try:
            function_call = llm_response.additional_kwargs['function_call']
            if function_call.get('name') == 'final_answer' and 'arguments' in function_call:
                args = json.loads(function_call['arguments'])
                report_content = args.get('answer', '')
        except Exception as e:
            print(f"Error parsing function_call: {e}")
    elif isinstance(llm_response, str):
        report_content = llm_response

    if not report_content:
        return {
            "date": datetime.datetime.now().replace(microsecond=0).isoformat(),
            "title": "Weekly Wellness Report",
            "content": "Error: Could not extract report content from LLM response."
        }

    return {
        "date": datetime.datetime.now().replace(microsecond=0).isoformat(),
        "title": "Weekly Wellness Report",
        "content": report_content
    }