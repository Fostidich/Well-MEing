from typing import Dict

from auxiliary.json_keys import ActionKeys
from test.emulators import send_to_db


# Empty OUT dict initializer
# OUT dict is a dictionary which has the output JSON structure.
# Starts with "create" and "logging" action_keys and habits and history data points are added respectively



class OutManager():
    def __init__(self):
        # Initialize the OUT dictionary
        self.out = {key.value: {} for key in ActionKeys}

    def reset_out_dict(self):
        self.out = {key.value: {} for key in ActionKeys}
out_manager = OutManager()

# extends the data entry from a tool call into the OUT dict which will be dumped as json
def process_out(data: Dict):
    action_key = next(iter(data))
    if action_key == ActionKeys.CREATE.value:
        process_creation(data[action_key])
    elif action_key == ActionKeys.LOGGING.value:
        process_logging(data[action_key])
    send_to_db(out_manager.out)
    print(f"Extended out: {out_manager.out}")



# Helper function to process the creation data
def process_creation(creation_data):
    for habit in creation_data:

        habit_name = habit['name']
        habit_dict = {
            "description": habit.get("description", ""),
            "goal": habit.get("goal", ""),
            "metrics": {}
        }

        # Process metrics for each habit
        for metric in habit['metrics']:
            metric_name = metric['name']
            habit_dict["metrics"][metric_name] = {
                "description": metric.get("description", ""),
                "input": metric['input'],
                "config": metric.get("config", {})
            }

        out_manager.out['creation'][habit_name] = habit_dict


# Helper function to process the logging data
def process_logging(logging_data):
    for log in logging_data:
        habit_name = log['name']
        timestamp = log['timestamp']
        notes = log.get('notes', "")
        metrics = log['metrics']

        # Add log entry into the appropriate habit section
        if habit_name not in out_manager.out['logging']:
            out_manager.out['logging'][habit_name] = []

        out_manager.out['logging'][habit_name].append({
            "timestamp": timestamp,
            "notes": notes,
            "metrics": metrics
        })
