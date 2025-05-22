import json
import os
import uuid
from typing import Dict

from auxiliary.json_keys import JsonKeys, ActionKeys

# TODO dto

# Always resolve path relative to the current file
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

ACTION_FILE = os.path.join(BASE_DIR, "..", "action_json.txt")
DB_FILE = os.path.join(BASE_DIR, "..", "habits_db.txt")
REPORT_FILE = os.path.join(BASE_DIR, "..", "report_json.txt")


def get_report_json():
    with open(REPORT_FILE, 'r') as f:
        data = json.load(f)
    return data


def get_context_json_from_db():
    with open(DB_FILE, 'r') as f:
        data = json.load(f)
    return data


def send_to_db(data: Dict):
    with open(ACTION_FILE, 'w') as f:
        json.dump(data, f, indent=4)

    # Emulate db saving action file
    update_db(data)

    # print(f"Data sent to db: {data}")


def update_db(data: Dict):
    data = convert_to_db_structure(data)
    with open(DB_FILE, 'w') as f:
        json.dump(data, f, indent=4)

    # print(f"Data updated in db: {data}")


def convert_to_db_structure(data):
    habits = get_context_json_from_db()
    habits = habits.get(JsonKeys.HABITS.value, {})
    # First, process the "creation" part
    for habit_name, habit_info in data.get(ActionKeys.CREATE.value, {}).items():
        habits[habit_name] = {
            JsonKeys.HABIT_DESCRIPTION.value: habit_info.get(JsonKeys.HABIT_DESCRIPTION.value),
            JsonKeys.GOAL.value: habit_info.get(JsonKeys.GOAL.value),
            JsonKeys.METRICS.value: habit_info.get(JsonKeys.METRICS.value),
            JsonKeys.HISTORY.value: {}
        }

    # Then, process the "logging" part
    for habit_name, entries in data.get(ActionKeys.LOGGING.value, {}).items():
        for entry in entries:
            # Generate a unique ID for each history entry
            entry_id = str(uuid.uuid4())
            # Build history entry
            history_entry = {
                JsonKeys.TIMESTAMP.value: entry[JsonKeys.TIMESTAMP.value],
                JsonKeys.METRICS.value: entry[JsonKeys.METRICS.value]
            }
            # Add notes if present
            if JsonKeys.NOTES.value in entry:
                history_entry[JsonKeys.NOTES.value] = entry[JsonKeys.NOTES.value]

            habits[habit_name][JsonKeys.HISTORY.value][entry_id] = history_entry

    return {JsonKeys.HABITS.value: habits}
