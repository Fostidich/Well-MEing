from typing import Dict

from ai.ui_schema.schemas import SliderConfig, FormConfig, SliderInputValue, TextInputValue, FormInputValue, \
    TimeInputValue, RatingInputValue, InputTypeKeys


# ---- Functional handlers ----
# creation handler required only for inputs which require config

def handle_slider_create(config: dict):
    return SliderConfig(**config)


def handle_slider_log(value, config: dict):
    return SliderInputValue(value=value, config=config)


def handle_text_log(value, config: dict):
    return TextInputValue(value=value)


def handle_form_create(config: dict):
    return FormConfig(**config)


def handle_form_log(value, config: dict):
    return FormInputValue(value=value, config=config)


def handle_time_log(value, config: dict):
    return TimeInputValue(value=value)


def handle_rating_log(value, config: dict):
    return RatingInputValue(value=value)


create_dispatcher = {
    InputTypeKeys.SLIDER.value: handle_slider_create,
    InputTypeKeys.FORM.value: handle_form_create,
    InputTypeKeys.TEXT.value: lambda config: {},
    InputTypeKeys.TIME.value: lambda config: {},
    InputTypeKeys.RATING.value: lambda config: {}
}

log_dispatcher = {
    InputTypeKeys.SLIDER.value: handle_slider_log,
    InputTypeKeys.FORM.value: handle_form_log,
    InputTypeKeys.TEXT.value: handle_text_log,
    InputTypeKeys.TIME.value: handle_time_log,
    InputTypeKeys.RATING.value: handle_rating_log
}


# ---- Validation function ----


def validate_input(input_type: InputTypeKeys, config: Dict, input_value=None):
    if input_type is None and not config:
        raise ValueError("Missing required fields: 'input_type' and 'config' must be provided.")

    if input_value is not None:
        handler = log_dispatcher.get(input_type)
        if handler is None:
            raise ValueError(f"Unsupported input_type for LOGGING: {input_type}")
        return handler(input_value, config).value

    if config:
        handler = create_dispatcher.get(input_type)
        if handler is None:
            raise ValueError(f"Unsupported input_type for CREATION: {input_type}")
        return handler(config)
