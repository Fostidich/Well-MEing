from datetime import datetime
from enum import Enum


class InputType(Enum):
    PLUS_N = "+N Button (Numeric)"
    """Custom numeric additive input button"""

    SLIDER = "Slider Input (Numeric)"
    """Range selector between min and max"""

    TEXT_BOX = "Text Box (Text)"
    """text input field"""

    TIME = "Time Input (isoformat(timespec='seconds'))"
    """Time input field hh:mm:ss"""

    RATING = "Rate buttons (Numeric[1;5])"
    """Rating input using presets"""


def is_valid_time(value: str) -> bool:
    try:
        datetime.strptime(value, "%H:%M:%S")
        return True
    except ValueError:
        return False


INPUT_VALIDATION_RULES = {
    InputType.PLUS_N.value: {
        "type": (int, float),
        "constraint": lambda x: x >= 0,
        "error": "PLUS_N requires value >= 0"
    },
    InputType.SLIDER.value: {
        "type": (int, float),
        "constraint": lambda x: x >= 0,
        "error": "SLIDER requires value >= 0"
    },
    InputType.TEXT_BOX.value: {
        "type": str,
        "constraint": lambda x: True,
        "error": "TEXT_BOX requires a string"
    },
    InputType.RATING.value: {
        "type": int,
        "constraint": lambda x: 1 <= x <= 5,
        "error": "RATING must be an integer (1–5)"
    },
    InputType.TIME.value: {
        "type": str,
        "constraint": lambda x: True,#is_valid_time,
        "error": "TIME input must follow the format HH:MM:SS"
    }
}


class JsonMap(str, Enum):
    """
    Map the input string to the correct keys in the JSON structure.
    """
    HABIT_NAME = HabitKeys.NAME
    METRIC_NAME = MetricKeys.NAME
    INPUT_TYPE = MetricKeys.INPUT
    VALUE_TYPE = ConfigKeys.TYPE
    HABIT_DESCRIPTION = HabitKeys.DESCRIPTION
    METRIC_DESCRIPTION = MetricKeys.DESCRIPTION
    HABIT_GOAL = HabitKeys.GOAL
    MAX_VALUE = ConfigKeys.MAX
    MIN_VALUE = ConfigKeys.MIN
    UNIT = ConfigKeys.UNIT