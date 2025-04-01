from enum import Enum
from typing import Union

from pydantic import field_validator, BaseModel


class InputType(Enum):
    PLUS_N = "+N Button (Numeric)"
    """Custom numeric additive input button"""

    SLIDER = "Slider Input (Numeric)"
    """Range selector between min and max"""

    TEXT_BOX = "Text Box (Text)"
    """text input field"""

    RATING = "Rate buttons (Numeric[1;5])"
    """Rating input using presets"""


INPUT_VALIDATION_RULES = {
    InputType.PLUS_N.value: {
        "type": (int, float),
        "constraint": lambda x: x >= 0,
        "error": "PLUS_N requires value >=0"
    },
    InputType.SLIDER.value: {
        "type": (int, float),
        "constraint": lambda x: x >= 0,  # Example range
        "error": "SLIDER requires value >=0"
    },
    InputType.TEXT_BOX.value: {
        "type": str,
        "constraint": lambda x: True,  # No additional checks
        "error": "TEXT_BOX requires a string"
    },
    InputType.RATING.value: {
        "type": int,
        "constraint": lambda x: 1 <= x <= 5,
        "error": "RATING must be an integer (1-5)"
    }
}
