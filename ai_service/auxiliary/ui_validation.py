from datetime import datetime
from enum import Enum
from typing import List, Union, Dict
from auxiliary.json_validation import JsonKeys, ActionKeys

class InputTypeKeys(Enum):
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


INPUT_VALIDATION_RULES = {
    ActionKeys.CREATE.value: {
        InputTypeKeys.PLUS_N.value: {
            "type": ["int", "float"],
            "min": lambda x: x >= 0,
            "max": lambda x: x > 0,
            "error": "plus_n requires value >= 0 with int or float type"
        },
        InputTypeKeys.SLIDER.value: {
            "type": ("int", "float"),
            "min": lambda x: x >= 0,
            "max": lambda x: x > 0,
            "error": "slider requires value >= 0 with int or float type"
        },
        InputTypeKeys.TEXT.value: {
            "type": ("str"),
            "constraint": lambda x: True,
            "error": "text requires a string"
        },
        InputTypeKeys.RATING.value: {
            "type": ("List[int]"),

            "error": "rating must be an int list in ascending order"
        },
        InputTypeKeys.TIME.value: {
            "type": str,
            "constraint": lambda x: True,
            "error": "TIME input must"
        }
    },
    ActionKeys.LOGGING.value: {
        InputTypeKeys.PLUS_N.value: {
            "type": (int, float),
            "constraint": lambda x, **kwargs: x >= kwargs.get(JsonKeys.CONFIG_MIN.value, 0),
            "error": lambda
                **kwargs: f"{InputTypeKeys.PLUS_N.value} requires value >= {kwargs.get(JsonKeys.CONFIG_MIN.value, 0)}"
        },
        InputTypeKeys.SLIDER.value: {
            "type": (int, float),
            "constraint": lambda x, **kwargs: kwargs.get(JsonKeys.CONFIG_MIN.value, 0) <= x <= kwargs.get(JsonKeys.CONFIG_MAX.value, float("inf")),
            "error": lambda
                **kwargs: f"{InputTypeKeys.SLIDER.value} requires value between {kwargs.get(JsonKeys.CONFIG_MIN.value, 0)} and {kwargs.get(JsonKeys.CONFIG_MAX.value, float('inf'))}"
        },
        InputTypeKeys.RATING.value: {
            "type": int,
            "constraint": lambda x, **kwargs: kwargs.get(JsonKeys.CONFIG_MIN.value, 0) <= x <= kwargs.get(JsonKeys.CONFIG_MAX.value, 5),
            "error": lambda
                **kwargs: f"{InputTypeKeys.RATING.value} must be an integer between {kwargs.get(JsonKeys.CONFIG_MIN.value, 0)} and {kwargs.get(JsonKeys.CONFIG_MAX.value, 5)}"
        },
        InputTypeKeys.TEXT.value: {
            "type": str,
            "constraint": lambda x, **kwargs: True,  # No additional constraints
            "error": lambda **kwargs: f"{InputTypeKeys.TEXT.value} requires a string"
        },
        InputTypeKeys.TIME.value: {
            "type": str,
            "constraint": lambda x, **kwargs: True,  # No additional constraints
            "error": lambda **kwargs: f"{InputTypeKeys.TIME.value} requires a comprehensive time string"
        }
    }
}



def validate_metric_input_value(input_type: str, input_value: Union[str, int, float], config: Dict) -> bool:
    input_rules = INPUT_VALIDATION_RULES.get(ActionKeys.LOGGING.value, {}).get(input_type, {})
    valid_types = input_rules.get("type", ())
    constraint = input_rules.get("constraint", lambda x, **kwargs: True)
    error_message = input_rules.get("error", lambda **kwargs: "Invalid input")

    # Input value type checking
    if not isinstance(input_value, valid_types):
        raise ValueError(
            f"Invalid input type: {type(input_value).__name__}. Expected one of: {valid_types}. "
            f"{error_message()}"
        )

    # Input value constraint checking
    if not constraint(input_value, **config):
        raise ValueError(
            f"Input value {input_value} does not satisfy the constraint. "
            f"{error_message(**config)}"
        )
    return True
