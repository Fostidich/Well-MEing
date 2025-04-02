from langchain.agents import initialize_agent, AgentType
from langchain_google_genai import ChatGoogleGenerativeAI  # Gemini LLM
from ai_service.AI_tools.habit import CreateHabitTool, InsertHabitDataTool
from dotenv import load_dotenv
import os

load_dotenv()  # Load environment variables (for API keys)

def setup_habit_tracking_agent(initial_prompt: str):
    # Initialize Gemini LLM
    llm = ChatGoogleGenerativeAI(
        model="gemini-2.0-flash-exp-image-generation",  # Or "gemini-1.5-pro-latest" for newer models
        google_api_key=os.getenv("GEMINI_API_KEY"),  # Set your API key in .env
        temperature=0.3,
    )

    # Tools for habit tracking
    create_habit_tool = CreateHabitTool()
    insert_habit_tool = InsertHabitDataTool()

    # Initialize the agent
    agent = initialize_agent(
        tools=[create_habit_tool, insert_habit_tool],
        llm=llm,
        agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
        verbose=True,  # Print agent's thought process
        handle_parsing_errors=True,  # Better error handling
    )
    return agent

# Demo
def main():
    print("\n INITIAL SETUP AGENT \n")
    initial_prompt = "You are a habit tracking assistant. Help the user track their habits."
    agent = setup_habit_tracking_agent(initial_prompt)

    print("\n RUNNING AGENT \n")
    agent.run("I go to the gym and I need to track my main upper body exercises weights, could you create a group to track some upper body exercises?")

if __name__ == "__main__":
    main()