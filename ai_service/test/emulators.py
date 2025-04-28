import json
from typing import List, Dict

from auxiliary.json_keys import JsonKeys

# TODO DTO

# Constants
DB_FILE = r"../habits_db.txt"
REPORT_FILE = f"../report_json.txt"
def get_report_json():
    with open(REPORT_FILE, 'r') as f:
        data = json.load(f)
    return data

def get_context_json_from_db():
    with open(DB_FILE, 'r') as f:
        data = json.load(f)
    return data


def send_to_db(out: dict):
    for action, habits in out.items():  # entries is a list of habits dicts

        if action == "creation":

            with open(DB_FILE, 'r') as f:
                existing_data = json.load(f)

            new_habits = _process_creation_habit_data(habits)
            print(new_habits)
            for new_habit in new_habits:
                found = False
                for existing_habit in existing_data.get("habits"):
                    if existing_habit.get("name") == new_habit.get("name"):
                        existing_habit.get("metrics").extend(new_habit.get("metrics"))
                        found = True
                        break
                if not found:
                    existing_data["habits"].append(new_habit)

            with open(DB_FILE, 'w') as f:
                json.dump(existing_data, f, indent=4)

        elif action == "logging":
            json_params = _process_logging_habit_data(habits)

            # Open the DB file to write the updated habits list to it
            with open(DB_FILE, 'w') as f:
                json.dump(json_params, f, indent=4)


def _process_creation_habit_data(habits: List[Dict]):
    # Read the current database from the file
    with open(DB_FILE, 'r') as f:
        context_json = json.load(f)

    # Extract existing habits
    existing_habits = context_json.get(JsonKeys.HABITS.value, [])

    # Process new habits and append to the existing ones
    for habit in habits:
        new_habit = {
            "name": habit.get(JsonKeys.HABIT_NAME.value),
            "description": habit.get(JsonKeys.HABIT_DESCRIPTION.value, ""),
            "goal": habit.get(JsonKeys.GOAL.value, ""),
            "metrics": habit.get(JsonKeys.METRICS.value, []),
            "history": []  # Empty history initially
        }

        # Append the new habit to the existing habits list
        existing_habits.append(new_habit)

    # Prepare the updated JSON data to return
    updated_data = {JsonKeys.HABITS.value: existing_habits}

    return updated_data


def _process_logging_habit_data(data_points: List[Dict]):
    # Read the current database from the file
    with open(DB_FILE, 'r') as f:
        context_json = json.load(f)

    # Extract existing habits
    habits = context_json.get(JsonKeys.HABITS.value, [])

    # Process logging data points
    for data_point in data_points:
        habit_name = data_point.get(JsonKeys.HABIT_NAME.value)
        history_entry = {
            "timestamp": data_point.get(JsonKeys.TIMESTAMP.value, ""),
            "notes": data_point.get(JsonKeys.NOTES.value, ""),
            "metrics": data_point.get(JsonKeys.METRICS.value, {})
        }

        # Search for the corresponding habit by name
        for habit in habits:
            if habit.get(JsonKeys.HABIT_NAME.value) == habit_name:
                history = habit.get(JsonKeys.HISTORY.value, [])
                # Append the new history entry to the habit's history
                history.append(history_entry)
                habit[JsonKeys.HISTORY.value] = history

    # Prepare the updated JSON data to return
    updated_data = {JsonKeys.HABITS.value: habits}

    return updated_data


