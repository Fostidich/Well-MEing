from enum import Enum
from typing import List, Dict
from test.emulators import get_context_json_from_db

class Action_Keys(Enum):
    """
    Enum class for Action Keys.
    """
    CREATE = 'creation'
    LOGGING = 'logging'


class ContextKeys(Enum):
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
    HABIT_DESCRIPTION = 'description'
    METRIC_DESCRIPTION = 'description'
    GOAL = 'goal'

def build_input_map(context_json: List[Dict]):
    # TODO Use parser to get habit-metric-input_type triplets from context_json
    valid_inputs = []
    tracked_summary = []
    habits = context_json.get(ContextKeys.HABITS.value, [])
    for habit in habits:
        metrics = habit.get(ContextKeys.METRICS.value, [])
        habit_desc = habit.get(ContextKeys.HABIT_DESCRIPTION.value)
        habit_goal = habit.get(ContextKeys.GOAL.value)
        for metric in metrics:
            input_type = metric.get(ContextKeys.INPUT_TYPE.value)
            config_type = metric.get(ContextKeys.CONFIG.value).get(ContextKeys.CONFIG_TYPE.value)
            metric_desc = metric.get(ContextKeys.METRIC_DESCRIPTION.value)
            # Used for logging validattion
            valid_inputs.append(
                {
                "address": (habit.get(ContextKeys.HABIT_NAME.value),
                             metric.get(ContextKeys.METRIC_NAME.value)),
                "input": (input_type,config_type)
                 })
    return valid_inputs
