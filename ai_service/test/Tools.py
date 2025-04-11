# %%
from ai_tools.habit_tools import CreateHabitTool, InsertHabitDataTool
from auxiliary.misc import generate_enum_docs
from auxiliary.ui_validation import InputTypeKeys
from test.emulators import get_context_json_from_db, save_to_db

tool = CreateHabitTool()
tool._run("Physical Well-being,Steps Walked,+N Button (Numeric),,0,10,km")
#print(tool)
# %%
tool = InsertHabitDataTool()
tool._run("Physical Well-being,Steps Walked,5,2022-10-10")
#print(tool.description)
# %%
print(generate_enum_docs(InputTypeKeys))
# %%
from test.emulators import get_context_json_from_db, summarize_habits_structure

print(summarize_habits_structure(get_context_json_from_db()))

# %%
from datetime import datetime
print(datetime.now().isoformat(timespec='seconds'))