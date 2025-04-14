from datetime import datetime
from typing import Union
from auxiliary.json_validation import JsonKeys, ActionKeys, InputTypeKeys

# Slider max_value cap
VALUE_CAP = 10000000

INPUT_VALIDATION_RULES = {
    ActionKeys.CREATE.value: {
        InputTypeKeys.SLIDER.value: {
            "required_params": [JsonKeys.CONFIG_MIN.value, JsonKeys.CONFIG_MAX.value, JsonKeys.CONFIG_TYPE.value],
            "constraint": lambda **kwargs: (
                    kwargs.get(JsonKeys.CONFIG_MIN.value, 0) < kwargs.get(JsonKeys.CONFIG_MAX.value, VALUE_CAP)),
            "error": lambda
                **kwargs: f"{InputTypeKeys.SLIDER.value} requires {JsonKeys.CONFIG_MIN.value} < {JsonKeys.CONFIG_MAX.value}"
        },
        InputTypeKeys.TEXT.value: {
            "required_params": [],
            "constraint": lambda **kwargs: True,  # no config required
            "error": lambda **kwargs: f"{InputTypeKeys.TEXT.value} requires no config params"
        },
        InputTypeKeys.FORM.value: {
            "required_params": [JsonKeys.CONFIG_BOXES.value],
            "constraint": lambda **kwargs: len(kwargs.get(JsonKeys.CONFIG_BOXES.value, [])) >= 2 and len(
                kwargs.get(JsonKeys.CONFIG_BOXES.value, [])) <= 10,
            "error": lambda **kwargs: f"{InputTypeKeys.FORM.value} must have from 2 up to 10 options in a string list"
        },
        InputTypeKeys.TIME.value: {
            "required_params": [],
            "constraint": lambda **kwargs: True,  # no config required
            "error": lambda **kwargs: f"{InputTypeKeys.TIME.value} requires no config params"
        },
        InputTypeKeys.RATING.value: {
            "required_params": [],
            "constraint": lambda **kwargs: True,  # no config required
            "error": lambda **kwargs: f"{InputTypeKeys.RATING.value} requires no config params"
        }
    },
    ActionKeys.LOGGING.value: {
        InputTypeKeys.SLIDER.value: {
            "type": (int, float),
            "constraint": lambda x, **kwargs: kwargs.get(JsonKeys.CONFIG_MIN.value, 0) <= x <= kwargs.get(
                JsonKeys.CONFIG_MAX.value, VALUE_CAP),
            "error": lambda
                **kwargs: f"{InputTypeKeys.SLIDER.value} requires value between {kwargs.get(JsonKeys.CONFIG_MIN.value, 0)} and {kwargs.get(JsonKeys.CONFIG_MAX.value, VALUE_CAP)}"
        },
        InputTypeKeys.TEXT.value: {
            "type": str,
            "constraint": lambda x, **kwargs: True,  # No additional constraints
            "error": lambda **kwargs: f"{InputTypeKeys.TEXT.value} requires valid a string"
        },
        InputTypeKeys.FORM.value: {
            "type": str,
            "constraint": lambda x, **kwargs: x in kwargs.get(JsonKeys.CONFIG_BOXES.value),
            "error": lambda
                **kwargs: f"{InputTypeKeys.FORM.value} requires one of {kwargs.get(JsonKeys.CONFIG_BOXES.value)}"
        },
        InputTypeKeys.TIME.value: {
            "type": str,
            "constraint": lambda x, **kwargs: datetime.strptime(x, "%H:%M:%S"),
            "error": lambda **kwargs: f"{InputTypeKeys.TIME.value} requires a time in format HH:MM:SS"
        },
        InputTypeKeys.RATING.value: {
            "type": int,
            "constraint": lambda x, **kwargs: kwargs.get(JsonKeys.CONFIG_MIN.value, 1) <= x <= kwargs.get(
                JsonKeys.CONFIG_MAX.value, 5),
            "error": lambda
                **kwargs: f"{InputTypeKeys.RATING.value} must be an integer between {kwargs.get(JsonKeys.CONFIG_MIN.value, 1)} and {kwargs.get(JsonKeys.CONFIG_MAX.value, 5)}"
        }
    }
}


def validate_input_type_config(input_type: str, config):
    input_rules = INPUT_VALIDATION_RULES.get(ActionKeys.CREATE.value, {}).get(input_type, {})
    required_params = input_rules.get("required_params", [])
    constraint = input_rules.get("constraint", lambda **kwargs: True)
    error_message = input_rules.get("error", lambda **kwargs: "Invalid input")
    config_dict = config.dict()
    # Config required params checking

    missing_params = [param for param in required_params if param not in config_dict]
    if missing_params:
        raise ValueError(
            f"Missing required parameters for input type {input_type}: {', '.join(missing_params)}"
        )

    # Config-Input_type constraing checking
    if not constraint(**config_dict):
        raise ValueError(
            f"Config does not satisfy constraints for input type {input_type}."
            f"Config: {config_dict}, "
            f"{error_message()}"
        )

    filtered_config_dict = {param: config_dict[param] for param in required_params}

    return filtered_config_dict


def validate_metric_input_value(input_type: str, input_value: Union[str, int, float], config) -> bool:
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
