import json
from typing import List, Dict
from auxiliary.json_keys import ActionKeys, JsonKeys
# Constants
DB_FILE = r"../habits_db.txt"


def get_context_json_from_db():
    with open(DB_FILE, 'r') as f:
        data = json.load(f)
    return data


def send_to_db(out: dict):
    json_params = convert_out_to_habits(out)

    with open(DB_FILE, 'w') as f:
        json.dump(json_params, f, indent=4)


def convert_out_to_habits(out: Dict) -> Dict:
    out_habits = []
    for action, habits in out.items():  # entries is a list of habits dicts

        if action == "creation":
            new_habits = _process_creation_habit_data(habits)
        elif action == "logging":
            new_datapoints, habit_name = _process_logging_habit_data(habits)
        else:
            raise ValueError(f"Unknown action: {action}")

        if new_habits:
            out_habits.extend(new_habits)

    return {"habits": out_habits}


def _process_creation_habit_data(habits: List[Dict]):
    new_habits = []
    for habit in habits:
        new_habit = {
            "name": habit.get(JsonKeys.HABIT_NAME.value),
            "description": habit.get(JsonKeys.HABIT_DESCRIPTION.value, ""),
            "goal": habit.get(JsonKeys.GOAL.value, ""),
            "metrics": habit.get(JsonKeys.METRICS.value, []),
            "history": []
        }
        new_habits.append(new_habit)
        return new_habits


def _process_logging_habit_data(data_points: List[Dict]):
    for data_point in data_points:
        habit_name = data_point.get(JsonKeys.HABIT_NAME.value)
        history_entry = {
            "timestamp": data_point.get(JsonKeys.TIMESTAMP.value, ""),
            "notes": data_point.get(JsonKeys.NOTES.value, ""),
            "metrics": data_point.get(JsonKeys.METRICS.value, {})
        }


        existing_habit["history"].append(history_entry)
    return existing_habit
