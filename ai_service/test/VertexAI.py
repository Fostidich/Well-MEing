from langchain_google_vertexai.chat_models import ChatVertexAI
from dotenv import load_dotenv

from langchain_core.messages import SystemMessage, HumanMessage

from ai_tools.habit_tools import CreateHabitTool, InsertHabitDataTool
from ai_tools.json_tools import get_context_tools

load_dotenv()

llm = ChatVertexAI(model_name="gemini-2.0-flash-001")

innit_prompt = SystemMessage(
    content=("""
    ### AI Assistant Behavior Rules:
    
    You are an AI assistant that manages habit tracking. You will receive user input related to creating habits or logging habit data.
    
    Your task is to call one of the following tools:
    - `CreateHabit`: to create a new habit.
    - `InsertHabitData`: to log data for an existing habit.
    - `JsonTools`: to retrieve context on current habits.
    
    If parameters are missing:
    - **Generate** reasonable values for them.
    - Always **call the tool** relevant to the user’s request.
    
    Parameter Guidelines:
    - **habit_name**: Create a short, clear name (e.g., "Morning Walk").
    - **habit_description**: Briefly explain the habit (e.g., "Walk for health").
    - **metrics**: Pick common ones like "Duration" or "Repetitions" with sensible values (e.g., 10, 30 minutes).
    - **timestamp**: Use the current time (ISO 8601).
    - **notes**: Optional; leave empty if not specified.
    
    ### Examples:
    1. User input: `"Create a new habit"`  
       → `CreateHabit`: `{"habit_name": "Morning Stretch", "habit_description": "Stretch for 5 minutes", "metrics": [{"name": "Duration", "input_type": "Slider", "config": {"min": 1, "max": 10}}]}`
       
    2. User input: `"Log my water intake"`  
       → `InsertHabitData`: `{"name": "Water Intake", "timestamp": "current_time", "metrics": {"Amount (ml)": 250}}`
    
    If you need to check the existing habits, call `JsonTools` to retrieve them.
    
    Now, process this user input:
    """)
)

JsonTools = get_context_tools()
user_input = "Create a random habit for me"
tools = [CreateHabitTool, InsertHabitDataTool] + JsonTools
llm_w_tools = llm.bind_tools(tools)
response = llm_w_tools.invoke([innit_prompt] + [HumanMessage(user_input)])
print(response)

