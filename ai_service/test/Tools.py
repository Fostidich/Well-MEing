# %%
from ai_tools.habit import CreateHabitTool, InsertHabitDataTool
from auxiliary.misc import generate_enum_docs
from auxiliary.habit_validation import InputType
from test.emulators import get_json_from_db, save_to_db
from auxiliary.json_building import get_habits_map
tool = CreateHabitTool()
tool._run("Physical Well-being,Steps Walked,+N Button (Numeric),,0,10,km")
#print(tool)
# %%
tool = InsertHabitDataTool()
tool._run("Physical Well-being,Steps Walked,5,2022-10-10")
#print(tool.description)
# %%
print(generate_enum_docs(InputType))
# %%
def summarize_habits_structure(data):
    summary = []
    habits = data.get("users", {}).get("user_id_123456", {}).get("habits", [])
    for habit in habits:
        habit_name = habit.get("habit_name", "Unnamed")
        habit_desc = habit.get("habit_description", "No description")
        summary.append(f"Habit: {habit_name} — {habit_desc}")

        for metric in habit.get("metrics", []):
            metric_name = metric.get("metric_name") or metric.get("name", "Unnamed")
            input_type = metric.get("input", "unknown")
            config = metric.get("config", {})
            value_type = config.get("type", "unknown")

            summary.append(f"  - {metric_name}: {input_type} ({value_type})")

    return summary


print(summarize_habits_structure(get_json_from_db()))

# %%
from datetime import datetime
print(datetime.now().isoformat(timespec='seconds'))