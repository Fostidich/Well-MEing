from langchain.tools import tool


@tool(description="Use this tool when no more actions are needed")
def final_answer(answer: str) -> str:
    """Use this to return a direct answer and exit the loop."""
    return answer
