from enum import Enum
from typing import List, Dict


class ActionKeys(Enum):
    """
    Enum class for Action Keys.
    """
    CREATE = 'creation'
    LOGGING = 'logging'


class JsonKeys(Enum):
    """
    Enum class for Context Keys.
    """
    HABITS = 'habits'
    METRICS = 'metrics'
    INPUT_TYPE = 'input'
    HABIT_NAME = 'name'
    METRIC_NAME = 'name'
    CONFIG = 'config'
    CONFIG_TYPE = 'type'
    CONFIG_MIN = 'min'
    CONFIG_MAX = 'max'
    HABIT_DESCRIPTION = 'description'
    METRIC_DESCRIPTION = 'description'
    GOAL = 'goal'
    TIMESTAMP = 'timestamp'

def build_input_map(context_json: List[Dict]):
    # TODO Use parser to get habit-metric-input_type triplets from context_json
    valid_inputs = []
    habits = context_json.get(JsonKeys.HABITS.value, [])
    for habit in habits:
        metrics = habit.get(JsonKeys.METRICS.value, [])
        habit_desc = habit.get(JsonKeys.HABIT_DESCRIPTION.value)
        habit_goal = habit.get(JsonKeys.GOAL.value)
        for metric in metrics:
            input_type = metric.get(JsonKeys.INPUT_TYPE.value)
            config_type = metric.get(JsonKeys.CONFIG.value).get(JsonKeys.CONFIG_TYPE.value)
            metric_desc = metric.get(JsonKeys.METRIC_DESCRIPTION.value)
            # Used for logging validation
            valid_inputs.append(
                {
                "address": (habit.get(JsonKeys.HABIT_NAME.value),
                             metric.get(JsonKeys.METRIC_NAME.value)),
                "input": (input_type,config_type)
                 })
    return valid_inputs


