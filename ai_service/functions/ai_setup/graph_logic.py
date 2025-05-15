from uuid import uuid4

from langchain_core.messages import SystemMessage, HumanMessage
from langgraph.constants import START, END
from langgraph.graph import StateGraph

from ai_setup.graph_components import tool_node, should_use_tools, memory, MessagesState
from ai_setup.llm_setup import llm
from auxiliary.json_keys import ActionKeys
from auxiliary.utils import ContextInfoManager

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


def run_report_graph(llm, context: dict, user_prompt: str) -> dict:
    """
    Specialized graph for generating structured weekly reports.
    The 'out' key in the returned state will contain the report
    with 'date', 'title', and 'content' fields.
    """
    # Corrected typo: innit_prompt -> init_prompt
    init_prompt = SystemMessage(f"""
    You are a health assistant. Generate a detailed weekly wellness report with advices based on user's habits and goals.
    If information is missing, make reasonable assumptions. The report should be comprehensive.
    Use the following context:
    {context.get("history_summary", "No detailed context provided.")}
    """)

    print(f"REPORT PROMPT CONTEXT:\n{context.get('history_summary')}")

    # This node will be responsible for calling the LLM and structuring its response.
    def call_model(state: MessagesState):
        print("Calling LLM for report...")
        llm_response = llm.invoke(state["messages"])
        print("LLM raw response object:", llm_response)

        report_content = ""

        # Check for direct content first
        if hasattr(llm_response, 'content') and llm_response.content:
            report_content = llm_response.content
            print("Extracted content directly from llm_response.content")
        # Check for function call in additional_kwargs if no direct content
        elif hasattr(llm_response, 'additional_kwargs') and 'function_call' in llm_response.additional_kwargs:
            try:
                function_call = llm_response.additional_kwargs['function_call']
                # Assuming the function name is 'final_answer' and arguments is a JSON string
                if function_call.get('name') == 'final_answer' and 'arguments' in function_call:
                    # Attempt to parse the JSON arguments string
                    args = json.loads(function_call['arguments'])
                    # Assuming the actual report content is under the 'answer' key
                    if 'answer' in args:
                        report_content = args['answer']
                        print("Extracted content from function_call arguments['answer']")
                    else:
                        print("Warning: Function call arguments parsed but no 'answer' key found.")
                else:
                    print(f"Warning: LLM returned a function call ({function_call.get('name')}) but not the expected 'final_answer'.")
            except json.JSONDecodeError:
                print("Warning: Failed to parse function_call arguments as JSON.")
            except Exception as e:
                print(f"Warning: An error occurred processing function_call: {e}")

        # Fallback for simple string responses (less likely with LangGraph/complex LLMs)
        elif isinstance(llm_response, str):
            report_content = llm_response
            print("Extracted content from string response")

        # Final fallback if nothing worked
        if not report_content:
            print("Warning: LLM response format not recognized or content is missing.")
            # Optionally, include raw response details for debugging
            report_content = f"Error: Could not generate report content. Raw response format not understood. {str(llm_response)}"


        # Structure the report as required
        structured_report_output = {
            "date": datetime.datetime.now().replace(microsecond=0).isoformat(),
            "title": "Weekly Wellness Report", # As per requirement
            "content": report_content # Use the extracted content
        }

        # Return the new message from the assistant and update the 'out' field in the state.
        # The llm_response object itself should probably be part of the message history
        return {"messages": [llm_response], "out": structured_report_output}


    # This node initializes parts of the state.
    def init_node(state: MessagesState):
        # These assignments directly modify the state dictionary LangGraph uses.
        state["context"] = context
        state["out"] = {} # Initialize 'out'; 'call_model' will populate it.
        return state # Explicitly returning state is good practice, though LangGraph often infers.

    workflow = StateGraph(MessagesState) # Use the defined MessagesState
    workflow.add_node("init", init_node)
    workflow.add_node("assistant", call_model)

    workflow.add_edge(START, "init")
    workflow.add_edge("init", "assistant")
    workflow.add_edge("assistant", END)

    # Assuming 'memory' is a pre-configured checkpointer instance
    graph = workflow.compile(checkpointer=None) # Remove checkpointer=memory if 'memory' is not defined in this scope, or ensure it is.
                                               # For simplicity here, I'll remove it if it's causing issues without full context.
                                               # If checkpointing is essential, 'memory' must be correctly initialized.

    # Invoke the graph with initial messages
    # The graph execution starts with the "messages" provided here.
    # The 'init' node doesn't receive these messages directly as an argument,
    # but they become part of the initial state['messages'].
    final_state = graph.invoke(
        {"messages": [init_prompt, HumanMessage(user_prompt)]}, # Initial messages for the graph
        config={"configurable": {"thread_id": str(uuid4())}, "recursion_limit": 10}
    )
    
    # The 'final_state' dictionary will contain 'messages', 'context', and 'out'.
    # The 'out' key will hold the structured report.
    return final_state