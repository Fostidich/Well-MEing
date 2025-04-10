from datetime import datetime
from enum import Enum
from typing import List

class InputType(Enum):
    PLUS_N = "plus_n"
    """Custom numeric additive input button"""

    SLIDER = "slider"
    """Range selector between min and max"""

    TEXT = "text"
    """text input field"""

    TIME = "time"
    """Time input field hh:mm:ss"""

    RATING = "rating"
    """Rating input using presets"""


def is_valid_time(value: str) -> bool:
    try:
        datetime.strptime(value, "%H:%M:%S")
        return True
    except ValueError:
        return False


INPUT_VALIDATION_RULES = {
    "Creation": {
        InputType.PLUS_N.value: {
            "type": ["int", "float"],
            "min": lambda x: x >= 0,
            "max": lambda x: x > 0,
            "error": "plus_n requires value >= 0 with int or float type"
        },
        InputType.SLIDER.value: {
            "type": ("int", "float"),
            "min": lambda x: x >= 0,
            "max": lambda x: x > 0,
            "error": "slider requires value >= 0 with int or float type"
        },
        InputType.TEXT.value: {
            "type": ("str"),
            "constraint": lambda x: True,
            "error": "text requires a string"
        },
        InputType.RATING.value: {
            "type": ("List[int]"),

            "error": "rating must be an int list in ascending order"
        },
        InputType.TIME.value: {
            "type": str,
            "constraint": lambda x: is_valid_time,  # is_valid_time,
            "error": "TIME input must follow the format HH:MM:SS"
        }
    },
    "Logging": {
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
        InputType.TEXT.value: {
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
}

