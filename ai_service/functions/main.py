from typing import Annotated, TypedDict

from dotenv import load_dotenv
import os # Import os

from firebase_functions import https_fn, options

from langchain_core.messages import SystemMessage, AnyMessage

from langchain_google_vertexai.chat_models import ChatVertexAI
import vertexai # Import vertexai library

import json

from uuid import uuid4

from langgraph.graph import START, END, StateGraph
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.checkpoint.memory import MemorySaver

from ai_tools.habit_tools import CreateHabitTool, InsertHabitDataTool
from ai_tools.json_tools import AvailableHabitsTool


from auxiliary.utils import context_manager
from auxiliary.json_building import out_manager

import copy

# Set memory to 512 MiB (adjust as needed)
options.set_global_options(region="europe-west1", memory=options.MemoryOption.MB_512)


# --- Initialization components at the global scope (only things that are safe) ---
load_dotenv() # Load environment variables once

# Define tools globally as they don't require credentials to define
tools = [CreateHabitTool, InsertHabitDataTool]

class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    unsent_tool_calls: list[dict]

# Declare global variables for LLM and graph, but don't initialize
llm = None
llm_w_tools = None
workflow = None
graph = None
memory = MemorySaver() # Memory saver can potentially be global


# --- End of safe global initialization ---


def get_or_initialize_llm_and_graph():
    """Initializes LLM and Langgraph workflow if they haven't been already."""
    global llm, llm_w_tools, workflow, graph, memory

    if graph is None: # Check if the graph is compiled
        print("Initializing LLM and Langgraph workflow...")
        try:
            # Initialize vertexai and LLM inside this function
            # This function will be called from within the handler,
            # so runtime environment variables should be available.
            project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
            location = "europe-west1" # **Specify your function's region**

            # It's often good practice to call vertexai.init() explicitly
            # before using Vertex AI models, even if env vars are set.
            vertexai.init(project=project_id, location=location)
            print(f"Vertex AI initialized with project: {project_id}, location: {location}")

            llm = ChatVertexAI(model_name="gemini-2.0-flash-001")
            print("ChatVertexAI initialized.")

            # Bind tools to the LLM
            llm_w_tools = llm.bind_tools(tools)
            print("LLM tools bound.")

            # Define and compile the workflow
            workflow = StateGraph(MessagesState)
            workflow.add_node("assistant", assistant_factory(llm_w_tools, innit_prompt)) # Use a factory pattern
            workflow.add_node("tools", ToolNode(tools))
            workflow.add_edge(START, "assistant")
            workflow.add_conditional_edges("assistant", tools_condition, ["tools", END])
            workflow.add_edge("tools", "assistant")

            # Compile the graph with checkpointer
            graph = workflow.compile(checkpointer=memory)
            print("Langgraph workflow compiled.")

        except Exception as e:
            print(f"FATAL ERROR during LLM/Graph initialization: {e}")
            # In a real scenario, you might want to log this and crash the instance
            # or return an error response from the main handler.
            llm = None
            llm_w_tools = None
            workflow = None
            graph = None
            raise # Re-raise the exception to indicate initialization failure


def assistant_factory(llm_w_tools_instance, innit_prompt_instance):
    """Creates the assistant function closure with bound LLM and prompt."""
    def assistant(state: MessagesState):
        max_retries = 2
        retries = 0

        # Check if llm_w_tools was successfully initialized
        if llm_w_tools_instance is None:
             error_message = SystemMessage(content="ERROR: LLM not initialized in assistant.")
             state["messages"].append(error_message)
             print("CRITICAL ERROR: llm_w_tools_instance is None in assistant function.")
             return state


        while retries < max_retries:
            try:
                # Use the passed in llm_w_tools_instance
                response = llm_w_tools_instance.invoke(state["messages"])
                print(response)

                if getattr(response, 'content', None):
                    clarification_message = SystemMessage(
                        content="AI must only call tools. Please follow the behavior rules strictly."
                    )
                    state["messages"].append(clarification_message)
                    retries += 1
                    continue

                return {"messages": [response]}

            except ValueError as e:
                error_message = SystemMessage(content=f"Error: {str(e)}")
                state["messages"].append(error_message)
                retries += 1

        state["messages"].append(SystemMessage(content="Max retries reached. Unable to get a valid tool call."))
        return state
    return assistant

@https_fn.on_request()
def process_speech(request: https_fn.Request) -> https_fn.Response:
    try:
        # Ensure LLM and Graph are initialized (will only run on cold start)
        get_or_initialize_llm_and_graph()

        # Check if the graph was successfully initialized
        if graph is None:
             print("ERROR: Langgraph graph not initialized after attempt.")
             return https_fn.Response("Internal Server Error: Function initialization failed.", status=500)


        data = request.get_json()
        if not data or "speech" not in data:
            return https_fn.Response("Missing 'speech' in the request body.", status=400)
        
        print("Received data:", data)

        context_manager.update_context_info(data)

        innit_prompt = SystemMessage(
            content=(f"""
        You are an AI assistant that manages habit tracking using predefined tools. 
        You MUST only respond by invoking one or more tools from the available list. 
        You are strictly forbidden from replying with text messages or natural language explanations.
        If instructions or parameters are missing or ambiguous:
        - Generate reasonable values yourself.
        - Immediately call the appropriate tool with those values.
        **ALREADY CREATED** habits and metrics:\n
        {context_manager.habits_descriptions}
        """)
        )

        user_input = data["speech"]
        graph.invoke(
            {"messages": [innit_prompt, {"role": "user", "content": user_input}]},
            config={"configurable": {"thread_id": uuid4()}}
        )
        print("Function output:", out_manager.out)

        output_copy = copy.deepcopy(out_manager.out)
        out_manager.reset_out_dict()

        return https_fn.Response(json.dumps(output_copy), mimetype='application/json')
    except Exception as e:
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')