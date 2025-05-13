import os

import vertexai
from dotenv import load_dotenv
from firebase_functions import options
from langchain_google_vertexai import ChatVertexAI

from ai_setup.graph_components import tools

# Set memory to 512 MiB (adjust as needed)
options.set_global_options(region="europe-west1", memory=options.MemoryOption.GB_1)

load_dotenv()


def initialize_llm():
    print("Initializing LLM and Langgraph workflow...")
    try:
        # Initialize vertexai and LLM inside this function
        # This function will be called from within the handler,
        # so runtime environment variables should be available.
        project_id = os.environ.get("MY_GOOGLE_CLOUD_PROJECT")
        location = "europe-west1"  # **Specify your function's region**

        # It's often good practice to call vertexai.init() explicitly
        # before using Vertex AI models, even if env vars are set.
        vertexai.init(project=project_id, location=location)
        print(f"Vertex AI initialized with project: {project_id}, location: {location}")

        llm = ChatVertexAI(model_name="gemini-2.0-flash-lite", temperature=0.0)
        print("ChatVertexAI initialized.")

        llm = llm.bind_tools(tools, tool_choice="any")

        return llm
    except Exception as e:
        print(f"Error initializing LLM: {e}")
        raise
