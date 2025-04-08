import json
from typing import List

# Constants
DB_FILE = r"C:\Users\white\PycharmProjects\Well-Meing\ai_service\test\habits_db.txt"


def save_to_db(data: List[dict]):
    """Save complete dataset to file"""
    with open(DB_FILE, 'w') as f:
        json.dump(data, f, indent=2)


def get_json_from_db():
    """Get complete dataset from file"""
    with open(DB_FILE, 'r') as f:
        data = json.load(f)
    return data

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