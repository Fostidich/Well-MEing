import json
from datetime import datetime
from enum import Enum
from typing import List

from auxiliary.json_keys import JsonKeys, ActionKeys

# Slider max_value cap
VALUE_CAP = 10000000



class InputTypeKeys(Enum):
    SLIDER = ("slider", "int or float")
    TEXT = ("text", "Any text string")
    FORM = ("form", "['option1, option2, ...], list ")
    TIME = ("time", "time/duration input in format HH:MM:SS")
    RATING = ("rating", "Inputs from 1 to 5 value")

    def __init__(self, value, description):
        self._value_ = value
        self.description = description

# RULES FUNCTIONS



INPUT_VALIDATION_RULES = {
    ActionKeys.CREATE.value: {
        InputTypeKeys.SLIDER.value: {
            "required_params": [JsonKeys.CONFIG_MIN.value, JsonKeys.CONFIG_MAX.value, JsonKeys.CONFIG_TYPE.value],
            "constraint": lambda **kwargs: (
                    kwargs.get(JsonKeys.CONFIG_MIN.value, 0) < kwargs.get(JsonKeys.CONFIG_MAX.value, VALUE_CAP)),
            "error": lambda
                **kwargs: f" {InputTypeKeys.SLIDER.value} requires {JsonKeys.CONFIG_MIN.value} < {JsonKeys.CONFIG_MAX.value}"
        },
        InputTypeKeys.TEXT.value: {
            "required_params": [],
            "constraint": lambda **kwargs: True,  # no config required
            "error": lambda **kwargs: f" {InputTypeKeys.TEXT.value} requires no config params"
        },
        InputTypeKeys.FORM.value: {
            "required_params": [JsonKeys.CONFIG_BOXES.value],
            "constraint": lambda **kwargs: len(kwargs.get(JsonKeys.CONFIG_BOXES.value, [])) <= 10,
            "error": lambda **kwargs: f" {InputTypeKeys.FORM.value} can have up to 10 options in a string list"
        },
        InputTypeKeys.TIME.value: {
            "required_params": [],
            "constraint": lambda **kwargs: True,  # no config required
            "error": lambda **kwargs: f" {InputTypeKeys.TIME.value} requires no config params"
        },
        InputTypeKeys.RATING.value: {
            "required_params": [],
            "constraint": lambda **kwargs: True,  # no config required
            "error": lambda **kwargs: f" {InputTypeKeys.RATING.value} requires no config params"
        }
    },
    ActionKeys.LOGGING.value: {
        InputTypeKeys.SLIDER.value: {
            "type": (int, float),
            "constraint": lambda x, **kwargs: kwargs.get(JsonKeys.CONFIG_MIN.value, 0) <= x <= kwargs.get(
                JsonKeys.CONFIG_MAX.value, VALUE_CAP),
            "error": lambda
                **kwargs: f" {InputTypeKeys.SLIDER.value} requires value between {kwargs.get(JsonKeys.CONFIG_MIN.value, 0)} and {kwargs.get(JsonKeys.CONFIG_MAX.value, VALUE_CAP)}"
        },
        InputTypeKeys.TEXT.value: {
            "type": str,
            "constraint": lambda x, **kwargs: True,  # No additional constraints
            "error": lambda **kwargs: f" {InputTypeKeys.TEXT.value} requires valid a string"
        },
        InputTypeKeys.FORM.value: {
            "type": list,
            "constraint": lambda x, **kwargs: x,
            "error": ""
        },
        InputTypeKeys.TIME.value: {
            "type": str,
            "constraint": lambda x, **kwargs: datetime.strptime(x, "%H:%M:%S"),
            "error": lambda **kwargs: f" {InputTypeKeys.TIME.value} requires a time in format HH:MM:SS"
        },
        InputTypeKeys.RATING.value: {
            "type": int,
            "constraint": lambda x, **kwargs: kwargs.get(JsonKeys.CONFIG_MIN.value, 1) <= x <= kwargs.get(
                JsonKeys.CONFIG_MAX.value, 5),
            "error": lambda
                **kwargs: f" {InputTypeKeys.RATING.value} must be an integer between {kwargs.get(JsonKeys.CONFIG_MIN.value, 1)} and {kwargs.get(JsonKeys.CONFIG_MAX.value, 5)}"
        }
    },
    'post_process': {
        InputTypeKeys.SLIDER.value: {
            "parse": lambda x, **kwargs: x
        },
        InputTypeKeys.TEXT.value: {
            "parse": lambda x, **kwargs: x
        },
        InputTypeKeys.FORM.value: {
            "parse": lambda x, **kwargs: x
        },
        InputTypeKeys.TIME.value: {
            "parse": lambda x, **kwargs: x
        },
        InputTypeKeys.RATING.value: {
            "parse": lambda x, **kwargs: x
        },
    }
}


