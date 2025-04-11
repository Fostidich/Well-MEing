from dotenv import load_dotenv
from langchain_google_genai import ChatGoogleGenerativeAI
import os
from ai_tools.habit_tools import CreateHabitTool
from ai_tools.creation_schema import HabitCreation
load_dotenv()
llm = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash-exp-image-generation",
    google_api_key=os.getenv("GEMINI_API_KEY"),
    temperature=0.2,
).bind_tools([CreateHabitTool])

llm.invoke("You are a habit tracking assistant. Help the user track their habits.\n"
           "I need to track my runnning habits")


from langchain_core.messages import HumanMessage

query = "You are a habit tracking assistant. Help the user track their habits.\n I need to track my runnning habits, decide it all for me"

messages = [HumanMessage(query)]

ai_msg = llm.invoke(messages)

#print(ai_msg.tool_calls)

messages.append(ai_msg)

for tool_call in ai_msg.tool_calls:
    selected_tool = {"create_habit": CreateHabitTool}[tool_call["name"].lower()]
    tool_msg = selected_tool.invoke(tool_call)
    messages.append(tool_msg)

print(messages)
