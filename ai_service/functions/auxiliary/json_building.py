from typing import Dict, Any

from auxiliary.json_keys import ActionKeys, JsonKeys

def process_creation(creation_data: list[dict[str, Any]], state_out: Dict, state_context: Dict) -> (Dict, Dict):
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

        state_out[ActionKeys.CREATE.value][habit_name] = habit_dict
        state_context[JsonKeys.HABITS.value][habit_name] = habit_dict

    return state_out, state_context

# Helper function to process the logging data
def process_logging(logging_data: list[dict[str, Any]], state_out: Dict, state_context: Dict) -> (Dict, Dict):
    for log in logging_data:
        habit_name = log[JsonKeys.HABIT_NAME.value]
        timestamp = log[JsonKeys.TIMESTAMP.value]
        notes = log.get(JsonKeys.NOTES.value)
        metrics = log[JsonKeys.METRICS.value]

        # Add log entry into the appropriate habit section
        if habit_name not in state_out[ActionKeys.LOGGING.value]:
            state_out[ActionKeys.LOGGING.value][habit_name] = {}

        state_out[ActionKeys.LOGGING.value][habit_name] = {
            JsonKeys.TIMESTAMP.value: timestamp,
            JsonKeys.NOTES.value: notes,
            JsonKeys.METRICS.value: metrics
        }
        state_context[JsonKeys.HABITS.value][habit_name][JsonKeys.HISTORY.value] = {
            JsonKeys.TIMESTAMP.value: timestamp,
            JsonKeys.NOTES.value: notes,
            JsonKeys.METRICS.value: metrics
        }
    return state_out, state_context



