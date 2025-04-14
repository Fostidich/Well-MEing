import json
from typing import List, Dict

# Constants
DB_FILE = r"../habits_db.txt"


def get_context_json_from_db():
    with open(DB_FILE, 'r') as f:
        data = json.load(f)
    return data


def save_out_to_db(data: List[dict]):
    data = convert_out_to_habits(data)

    with open(DB_FILE, 'w') as f:
        json.dump(data, f, indent=4)


import json
from typing import Dict, List


def convert_out_to_habits(out: Dict) -> Dict:
    habits = []
    print(out)
    for action, entries in out.items():
        for entry in entries:
            for sub_entry in entry:
                habit_data = sub_entry

                habit_data = json.loads(habit_data)
                if action == "creation":
                    habit = _process_creation_habit_data(habit_data, habits)
                elif action == "logging":
                    habit = _process_logging_habit_data(habit_data, habits)
                else:
                    raise ValueError(f"Unknown action: {action}")

                if habit:
                    habits.append(habit)

    return {"habits": habits}


def _process_creation_habit_data(habit_data: Dict, habits: List[Dict]):
    habit_name = habit_data.get("name")
    existing_habit = next((habit for habit in habits if habit["name"] == habit_name), None)

    if not existing_habit:
        # Create a new habit entry
        new_habit = {
            "name": habit_name,
            "description": habit_data.get("description", ""),
            "goal": habit_data.get("goal", ""),
            "metrics": habit_data.get("metrics", []),
            "history": []
        }
        habits.append(new_habit)
        return new_habit
    return existing_habit


def _process_logging_habit_data(habit_data: Dict, habits: List[Dict]):
    habit_name = habit_data.get("name")
    existing_habit = next((habit for habit in habits if habit["name"] == habit_name), None)

    if not existing_habit:
        raise ValueError(f"Habit '{habit_name}' not found. Please create the habit before logging data.")

    # Add history entry if available
    if "timestamp" in habit_data:
        history_entry = {
            "timestamp": habit_data["timestamp"],
            "notes": habit_data.get("notes", ""),
            "metrics": habit_data.get("metrics", {})
        }
        existing_habit["history"].append(history_entry)
    return existing_habit
