import json
from typing import List, Dict
import os
import uuid


# TODO DTO

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

    print(f"Data sent to db: {data}")


def update_db(data: Dict):
    data = convert_to_db_structure(data)
    with open(DB_FILE, 'w') as f:
        json.dump(data, f, indent=4)

    print(f"Data updated in db: {data}")


def convert_to_db_structure(data):
    habits = {}

    # First, process the "creation" part
    for habit_name, habit_info in data.get("creation", {}).items():
        habits[habit_name] = {
            "description": habit_info.get("description", ""),
            "goal": habit_info.get("goal", ""),
            "metrics": habit_info.get("metrics", {}),
            "history": {}
        }

    # Then, process the "logging" part
    for habit_name, entries in data.get("logging", {}).items():
        # If habit not created before (e.g., "Drink" habit), create a minimal entry
        if habit_name not in habits:
            habits[habit_name] = {
                "description": "",
                "goal": "",
                "metrics": {},
                "history": {}
            }

        for entry in entries:
            # Generate a unique ID for each history entry
            entry_id = str(uuid.uuid4())
            # Build history entry
            history_entry = {
                "timestamp": entry["timestamp"],
                "metrics": entry["metrics"]
            }
            # Add notes if present
            if "notes" in entry:
                history_entry["notes"] = entry["notes"]

            habits[habit_name]["history"][entry_id] = history_entry

    return {"habits": habits}
