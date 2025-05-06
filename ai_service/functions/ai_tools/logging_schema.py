import json
from typing import Optional, Union, List, Dict

from datetime import datetime
import dateparser
import pytz

from pydantic import BaseModel, Field, field_validator, model_validator, ConfigDict

from auxiliary.json_keys import JsonKeys, ActionKeys
from auxiliary.ui_rules import INPUT_VALIDATION_RULES, InputTypeKeys
from auxiliary.utils import context_manager, generate_enum_docs

TIMEZONE = pytz.timezone('Europe/Rome')


class LogEntry(BaseModel):
    timestamp: str = Field(
        ...,
        description="Time reference of the input (e.g. this afternoon, last week), If not specified by user input leave empty to insert the current time"
    )
    name: str = Field(
        ...,
        description="Name of the habit being logged"
    )
    notes: Optional[str] = Field(
        None,
        description="Notes or additional information or comments about the log entry"
    )
    metrics: Dict[str, Union[int, float, str]] = Field(
        ...,
        description=f"Dict[Key-value: metric_name-value] \ninput: expected_value\n {generate_enum_docs(InputTypeKeys)} "
    )

    @field_validator(JsonKeys.METRICS.value, mode='before')
    def parse_metrics(cls, metrics):
        if isinstance(metrics, str):
            try:
                # Attempt to parse the string into a dictionary
                metrics = json.loads(metrics)
            except json.JSONDecodeError:
                raise ValueError("Metrics string must be a valid JSON object")

            if not isinstance(metrics, dict):
                raise ValueError("Metrics must be a dictionary.")
        return metrics

    @field_validator(JsonKeys.TIMESTAMP.value, mode='after')
    @classmethod
    def validate_timestamp(cls, time):
        if not time:
            # Set current time in the desired timezone
            return datetime.now(TIMEZONE).strftime("%Y-%m-%dT%H:%M:%S")

        # parse the natural language expression
        parsed_date = dateparser.parse(time, settings={'TIMEZONE': 'Europe/Rome', 'RETURN_AS_TIMEZONE_AWARE': True})
        if parsed_date:
            return parsed_date.astimezone(TIMEZONE).strftime("%Y-%m-%dT%H:%M:%S")
        else:
            return datetime.now(TIMEZONE).strftime("%Y-%m-%dT%H:%M:%S")

    @model_validator(mode='after')
    def validate_metrics(self):
        self.metrics = validate_metric_input(self.metrics, self.name)
        return self


class LoggingData(BaseModel):
    model_config = ConfigDict(extra='forbid')
    logging: List[LogEntry] = Field(
        ...,
        description="List of logs"
    )


def validate_metric_input(input_metrics: Dict[str, Union[int, float, str]], habit_name: str) -> Dict[
    str, Union[int, float, str]]:

    validated_metrics = {}
    for metric_name, input_value in input_metrics.items():

        if (habit_name, metric_name) not in context_manager.names_set:
            raise ValueError(f"Metric '{metric_name}' not found for habit '{habit_name}'.")

        input_type = context_manager.input_config_map[(habit_name, metric_name)]['input_type']
        config = context_manager.input_config_map[(habit_name, metric_name)]['config']

        # Validate the input value against the metric's configuration
        validated_value = validate_metric_input_value(
            input_type,
            input_value,
            config
        )
        validated_metrics[metric_name] = validated_value
    return validated_metrics


def validate_metric_input_value(input_type: str, input_value: Union[str, int, float], config) -> Union[str, int, float, List[str]]:
    input_rules = INPUT_VALIDATION_RULES.get(ActionKeys.LOGGING.value, {}).get(input_type, {})
    valid_types = input_rules.get("type", ())
    constraint = input_rules.get("constraint", lambda x, **kwargs: True)
    error_message = input_rules.get("error", lambda **kwargs: "Invalid input")

    # Input value type checking
    if not isinstance(input_value, valid_types):
        raise ValueError(
            f"Invalid input type: {type(input_value).__name__}. Expected one of: {valid_types}. "
            f"input: {input_value}"
        )

    # Input value constraint checking
    if config:
        if not constraint(input_value, **config):
            raise ValueError(
                f"Input value {input_value} does not satisfy the constraint. "
                f"{error_message(**config)}"
            )

        # Post-process values based on input type
    input_value = post_process_values(input_value, input_type)

    return input_value


def post_process_values(input_value: Union[str, int, float, List[str]], input_type):
    post_process_rules = INPUT_VALIDATION_RULES.get('post_process').get(input_type)
    parse_function = post_process_rules.get("parse")
    input_value = parse_function(input_value)
    return input_value