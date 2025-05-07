import time
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
from uuid import uuid4

load_dotenv()

start_total = time.perf_counter()

t0 = time.perf_counter()
llm = ChatVertexAI(model_name="gemini-2.0-flash-lite-001")
t1 = time.perf_counter()
print(f"[Init LLM] {t1 - t0:.4f} seconds")

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

t2 = time.perf_counter()
llm_w_tools = llm.bind_tools(tools)
t3 = time.perf_counter()
print(f"[Bind Tools] {t3 - t2:.4f} seconds")

def assistant(state: MessagesState):
    t_start = time.perf_counter()
    max_retries = 2
    retries = 0
    state['messages'] = [innit_prompt] + state["messages"]

    while retries < max_retries:
        try:
            print(state["messages"][-1])
            t_llm_start = time.perf_counter()
            response = llm_w_tools.invoke(state["messages"])
            t_llm_end = time.perf_counter()
            print(f"[LLM Call] {t_llm_end - t_llm_start:.4f} seconds")
            print(response)

            if getattr(response, 'content', None):
                clarification_message = SystemMessage(
                    content="YOU MAY ONLY CALL TOOLS. DO NOT REPLY WITH TEXT PLEASE!"
                )
                state["messages"].append(clarification_message)
                retries += 1
                continue

            return {"messages": [response]}

        except ValueError as e:
            error_message = SystemMessage(content=f"Error: {str(e)}")
            print(error_message)
            state["messages"].append(error_message)
            retries += 1

    state["messages"].append(SystemMessage(content="Max retries reached. Unable to get a valid tool call."))
    return state

t4 = time.perf_counter()
workflow = StateGraph(MessagesState)
workflow.add_node("assistant", assistant)
workflow.add_node("tools", ToolNode(tools))
workflow.add_edge(START, "assistant")
workflow.add_conditional_edges("assistant", tools_condition, ["tools", END])
workflow.add_edge("tools", "assistant")
t5 = time.perf_counter()
print(f"[Workflow Graph Setup] {t5 - t4:.4f} seconds")

t6 = time.perf_counter()
memory = MemorySaver()
graph = workflow.compile(checkpointer=memory)
t7 = time.perf_counter()
print(f"[Graph Compile + Checkpointing] {t7 - t6:.4f} seconds")

# Simulazione di una richiesta
config = {"configurable": {"thread_id": uuid4()}}
user_input = "Create running habit"

t8 = time.perf_counter()
graph.invoke({"messages": [{"role": "user", "content": user_input}]}, config=config)
t9 = time.perf_counter()
print(f"[Graph Invoke] {t9 - t8:.4f} seconds")

end_total = time.perf_counter()
print(f"[Total Time Elapsed] {end_total - start_total:.4f} seconds")
