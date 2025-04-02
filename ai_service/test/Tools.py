# %%
from ai_service.AI_tools.habit import CreateHabitTool, InsertHabitDataTool
from langchain.agents import initialize_agent, AgentType
from langchain_openai import ChatOpenAI
from ai_service.auxiliary.misc import generate_enum_docs
from ai_service.auxiliary.habit_validation import InputType, INPUT_VALIDATION_RULES

tool = CreateHabitTool()
tool._run("Physical Well-being,Steps Walked,+N Button (Numeric),,0,10,km")
#print(tool)
# %%
tool = InsertHabitDataTool()
tool._run("Physical Well-being,Steps Walked,5,2022-10-10")
#print(tool.description)
#%%
print(generate_enum_docs(InputType))
