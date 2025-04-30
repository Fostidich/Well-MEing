from enum import Enum

# Keys used to identify the tool action in the output json.
# There should be a Action Key for each output json interaction tool
class ActionKeys(Enum):
    """
    Enum class for Action Keys.
    """
    CREATE = 'creation'
    LOGGING = 'logging'

# Keys that mirror db and output json keys
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
    CONFIG_BOXES = 'boxes'
    HABIT_DESCRIPTION = 'description'
    METRIC_DESCRIPTION = 'description'
    GOAL = 'goal'
    TIMESTAMP = 'timestamp'
    NOTES = 'notes'
    HISTORY = 'history'
    METRICS_LOG = 'metrics'
