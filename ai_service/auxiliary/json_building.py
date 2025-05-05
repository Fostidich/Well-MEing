from typing import Dict

from auxiliary.json_keys import ActionKeys, JsonKeys
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

    def remove_null_values(self):
        """
        Recursively removes keys with null values from the OUT dictionary.
        """

        def _remove_null_values(data):
            if isinstance(data, dict):
                return {k: _remove_null_values(v) for k, v in data.items() if v is not None}
            elif isinstance(data, list):
                return [_remove_null_values(item) for item in data]
            else:
                return data

        self.out = _remove_null_values(self.out)

out_manager = OutManager()


# extends the data entry from a tool call into the OUT dict which will be dumped as json
def process_out(data: Dict):
    action_key = next(iter(data))
    if action_key == ActionKeys.CREATE.value:
        process_creation(data[action_key])
    elif action_key == ActionKeys.LOGGING.value:
        process_logging(data[action_key])
    out_manager.remove_null_values()
    send_to_db(out_manager.out)
    #print(f"Extended out: {out_manager.out}")


# Helper function to process the creation data
def process_creation(creation_data):
    for habit in creation_data:

        habit_name = habit[JsonKeys.HABIT_NAME.value]
        habit_dict = {
            JsonKeys.HABIT_DESCRIPTION.value: habit.get(JsonKeys.HABIT_DESCRIPTION.value),
            JsonKeys.GOAL.value: habit.get(JsonKeys.GOAL.value),
            JsonKeys.METRICS.value: {}
        }

        # Process metrics for each habit
        for metric in habit[JsonKeys.METRICS.value]:
            metric_name = metric[JsonKeys.METRIC_NAME.value]
            habit_dict[JsonKeys.METRICS.value][metric_name] = {
                JsonKeys.METRIC_DESCRIPTION.value: metric.get(JsonKeys.METRIC_DESCRIPTION.value),
                JsonKeys.INPUT_TYPE.value: metric[JsonKeys.INPUT_TYPE.value],
                JsonKeys.CONFIG.value: metric.get(JsonKeys.CONFIG.value, {})
            }

        out_manager.out[ActionKeys.CREATE.value][habit_name] = habit_dict


# Helper function to process the logging data
def process_logging(logging_data):
    for log in logging_data:
        habit_name = log[JsonKeys.HABIT_NAME.value]
        timestamp = log[JsonKeys.TIMESTAMP.value]
        notes = log.get(JsonKeys.NOTES.value)
        metrics = log[JsonKeys.METRICS.value]

        # Add log entry into the appropriate habit section
        if habit_name not in out_manager.out[ActionKeys.LOGGING.value]:
            out_manager.out[ActionKeys.LOGGING.value][habit_name] = []

        out_manager.out[ActionKeys.LOGGING.value][habit_name].append({
            JsonKeys.TIMESTAMP.value: timestamp,
            JsonKeys.NOTES.value: notes,
            JsonKeys.METRICS.value: metrics
        })



