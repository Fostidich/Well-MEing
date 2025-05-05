from typing import TypedDict, Annotated

from dotenv import load_dotenv
from langchain_core.messages import SystemMessage, AnyMessage
from langchain_google_vertexai.chat_models import ChatVertexAI
from langgraph.checkpoint.memory import MemorySaver
from langgraph.constants import START, END
from langgraph.graph import add_messages, StateGraph
from langgraph.prebuilt import ToolNode, tools_condition

from ai_tools.habit_tools import CreateHabitTool, InsertHabitDataTool
from ai_tools.json_tools import AvailableHabitsTool
from auxiliary.utils import context_manager

load_dotenv()

llm = ChatVertexAI(model_name="gemini-2.0-flash-001")

innit_prompt = SystemMessage(
    content=(f"""\
You are an AI assistant that manages habit tracking using predefined tools. 
You MUST only respond by invoking one or more tools from the available list. 
You are strictly forbidden from replying with text messages or natural language explanations.

If instructions or parameters are missing or ambiguous:
- Generate reasonable values yourself.
- Immediately call the appropriate tool with those values.
Current habits[{context_manager.habits_descriptions}]
Now, process this user input:
""")
)


class MessagesState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]

tools = [CreateHabitTool, InsertHabitDataTool, AvailableHabitsTool]
llm_w_tools = llm.bind_tools(tools)


def assistant(state: MessagesState):
    max_retries = 2  # Limit the number of retries to avoid infinite loops
    retries = 0
    state['messages'] = [innit_prompt] + state["messages"]
    while retries < max_retries:
        try:
            print(state["messages"][-1])
            response = llm_w_tools.invoke(state["messages"])
            print(response)
            if getattr(response, 'content', None):
                # Append a system message to clarify the rules and reprompt
                clarification_message = SystemMessage(
                    content="YOU MAY ONLY CALL TOOLS. DO NOT REPLY WITH TEXT PLEASE!"
                )
                state["messages"].append(clarification_message)
                retries += 1
                continue  # Reprompt the AI

            # Return the valid tool call response
            return {"messages": [response]}

        except ValueError as e:
            # Append the error as a system message and continue
            error_message = SystemMessage(content=f"Error: {str(e)}")
            print(error_message)
            state["messages"].append(error_message)
            retries += 1

    # If retries are exhausted, return the state with an error message
    state["messages"].append(SystemMessage(content="Max retries reached. Unable to get a valid tool call."))
    return state


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

user_input = ("Mi sego tutte le mattine alle 7:15 voglio tracciare come mi sego")
graph.invoke({"messages": [{"role": "user", "content": user_input}]}, config=config)
