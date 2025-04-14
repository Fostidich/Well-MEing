
from test.emulators import get_context_json_from_db
from enum import Enum

def generate_enum_docs(enum_cls) -> str:
    return "\n".join(
        f"{member.value}: {member.description}"
        for member in enum_cls
    )

class TestEnum(Enum):
    SLIDER = ("slider", "Range selector between min and max")
    TEXT = ("text", "Text input field")
    FORM = ("form", "Form input field with multiple fields")
    TIME = ("time", "Time input field hh:mm:ss")
    RATING = ("rating", "Rating input using presets")

    def __init__(self, value, description):
        self._value_ = value
        self.description = description

