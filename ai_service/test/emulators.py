import json
from typing import List

# Constants
DB_FILE = r"habits_db.txt"


def save_to_db(data: List[dict]):
    """Save complete dataset to file"""
    merge_habit_data(get_json_from_db(), data)


def get_json_from_db():
    with open(DB_FILE, 'r') as f:
        data = json.load(f)
    return data


def summarize_habits_structure(data):
    summary = []
    habits = data.get("habits", [])
    for habit in habits:
        habit_name = habit.get("habit_name", "Unnamed")
        habit_desc = habit.get("habit_description", "No description")
        summary.append(f"Habit: {habit_name} — {habit_desc} \n")
        summary.append(f"Metrics: \n")
        for metric in habit.get("metrics", []):
            metric_name = metric.get("metric_name") or metric.get("name", "Unnamed")
            input_type = metric.get("input", "unknown")
            config = metric.get("config", {})
            value_type = config.get("type", "unknown")

            summary.append(f"  - {metric_name}: {input_type} ({value_type}) \n")

    return summary

def confirm_input():
    # Save the current state of the JSON to the database
    save_to_db()
    return f"Data saved successfully"


from datetime import datetime

def merge_habit_data(original_data, new_data, user_id="user_id_123456"):
    def normalize_metric(metric):
        # Convert input format into unified metric format
        return {
            "metric_name": metric.get("metric_name") or metric.get("name"),
            "metric_description": metric.get("metric_description") or metric.get("description", ""),
            "input": metric.get("input"),
            "config": metric.get("config", {})
        }

    user_data = original_data["users"].setdefault(user_id, {"habits": []})
    existing_habits = user_data["habits"]

    # Step 1: Add new habits from creation
    for new_habit in new_data.get("creation", []):
        habit_names = [h["habit_name"].lower() for h in existing_habits]
        if new_habit["habit_name"].lower() in habit_names:
            continue  # Skip if habit already exists

        habit_entry = {
            "habit_name": new_habit["habit_name"],
            "habit_description": new_habit["habit_description"],
            "habit_goal": new_habit["habit_goal"],
            "metrics": [normalize_metric(m) for m in new_habit["metrics"]],
            "history": []
        }
        existing_habits.append(habit_entry)

    # Step 2: Add logs to habit history
    for log in new_data.get("logging", []):
        habit_name = log["habit-name"]
        timestamp = format_timestamp(log["timestamp"])
        metrics = log["metrics"]

        for habit in existing_habits:
            if habit["habit_name"].lower() == habit_name.lower():
                habit.setdefault("history", []).append({
                    "timestamp": timestamp,
                    "metrics": metrics
                })
                break

    return original_data
