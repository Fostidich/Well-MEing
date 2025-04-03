import json
import os
from typing import List, Dict
from ai_service.auxiliary.misc import build_habit_map
# Constants
DB_FILE = r"C:\Users\white\OneDrive - Politecnico di Milano\Desktop\Well-MEing\ai_service\test\habits_db.txt"


def get_habits_map() -> List[dict]:
    with open(DB_FILE, 'r') as f:
        data = json.load(f)

    return build_habit_map(data)


def save_to_db(data: List[dict]):
    """Save complete dataset to file"""
    with open(DB_FILE, 'w') as f:
        json.dump(data, f, indent=2)


def append_habit(new_habit: Dict):
    """
    Append a new habit to the database file
    Format expected:
    {
        'group_name': 'Fitness',
        'habit_name': 'Running Distance',
        'input_type': 'Slider Input (Numeric)',
        'description': 'Track daily running distance',
        'min_value': 0.0,
        'max_value': 10.0,
        'unit': 'km'
    }
    """
    # Load existing data
    if os.path.exists(DB_FILE):
        with open(DB_FILE, 'r') as f:
            data = json.load(f)

    # Find the group or create it
    group_exists = False
    for group in data:
        if group['group_name'] == new_habit['group_name']:
            group['metrics'].append({
                'habit_name': new_habit['habit_name'],
                'input_type': new_habit['input_type'],
                'note': new_habit.get('description', ''),
                # Add additional fields if needed
                'min_value': new_habit.get('min_value'),
                'max_value': new_habit.get('max_value'),
                'unit': new_habit.get('unit')
            })
            group_exists = True
            break

    # If group didn't exist, create it
    if not group_exists:
        data.append({
            'group_name': new_habit['group_name'],
            'metrics': [{
                'habit_name': new_habit['habit_name'],
                'input_type': new_habit['input_type'],
                'note': new_habit.get('description', ''),
                'min_value': new_habit.get('min_value'),
                'max_value': new_habit.get('max_value'),
                'unit': new_habit.get('unit')
            }]
        })

    # Save back to file
    save_to_db(data)
    print(f"[DB] Added new habit: {new_habit['habit_name']} to group {new_habit['group_name']}")


# Example usage
if __name__ == "__main__":
    # Initialize database file with default data if it doesn't exist
    habits = get_habits_map()
    print("Current habits:", json.dumps(habits, indent=2))

    # Add a new habit
    new_habit = {
        'group_name': 'Fitness',
        'habit_name': 'Running Distance',
        'input_type': 'Slider Input (Numeric)',
        'description': 'Track daily running distance',
        'min_value': 0.0,
        'max_value': 10.0,
        'unit': 'km'
    }
    append_habit(new_habit)

    # Verify it was added
    updated_habits = get_habits_map()
    print("Updated habits:", json.dumps(updated_habits, indent=2))