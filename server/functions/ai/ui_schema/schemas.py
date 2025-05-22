from enum import Enum
from typing import Union, Literal, Set, List, Optional

from pydantic import BaseModel, Field, model_validator

VALUE_CAP = 10000000
MAX_OPTIONS = 10


# -------------------- SLIDER --------------------

class SliderConfig(BaseModel):
    min: Optional[int] = None
    max: Optional[int] = None
    type: Optional[Literal["int", "float"]] = None

    @model_validator(mode="after")
    def validate_config(self):
        if self.max is not None:
            if self.max > VALUE_CAP:
                raise ValueError(f"Max value cannot exceed {VALUE_CAP}")
        if self.max is not None and self.min is not None:
            if self.min > self.max:
                self.min, self.max = self.max, self.min
            if self.min == self.max:
                raise ValueError("Min and Max values in slider config cannot be equal.")
        return self


class SliderInputValue(BaseModel):
    value: Union[int, float]
    config: Optional[SliderConfig] = None

    @model_validator(mode="after")
    def validate_value(self):
        if self.config is not None:
            if self.config.type is not None:
                try:
                    self.value = int(self.value) if self.config.type == "int" else float(self.value)
                except ValueError:
                    raise ValueError(f"Value must be a {self.config.type}.")
        return self


# -------------------- TEXT --------------------

class TextInputValue(BaseModel):
    value: str


# -------------------- FORM --------------------

class FormConfig(BaseModel):
    boxes: List[str]  # Accept set or list as input

    @model_validator(mode="after")
    def validate_boxes(self):
        if len(self.boxes) > MAX_OPTIONS:
            raise ValueError("Form input can have up to 10 options.")

        return self


class FormInputValue(BaseModel):
    value: str = Field(..., format=f"^([^;]+)(;[^;]+)*$")
    config: FormConfig

    @model_validator(mode="after")
    def validate_value(self):
        allowed = set(self.config.boxes)
        selected = set([v.strip() for v in self.value.split(";")])
        if not selected.issubset(allowed):
            raise ValueError(f"Values {selected} must be among allowed options: {allowed}")
        return self


# -------------------- TIME --------------------

class TimeInputValue(BaseModel):
    value: str = Field(..., format="^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$")


# -------------------- RATING --------------------

class RatingInputValue(BaseModel):
    value: int

    @model_validator(mode="after")
    def validate_rating(self):
        if not (1 <= self.value <= 5):
            raise ValueError(f"Rating must be between 1 and 5")
        return self


class InputTypeKeys(Enum):
    SLIDER = ("slider", "Number")
    TEXT = ("text", "Text string")
    FORM = ("form", "expected 'option1;option2;...' from the same form")
    TIME = ("time", "time/duration in format HH:MM:SS")
    RATING = ("rating", "From 1 to 5 numerical input")

    def __init__(self, value, description):
        self._value_ = value
        self.description = description
