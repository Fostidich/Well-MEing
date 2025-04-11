from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional, Union, List, Dict
from datetime import datetime
import dateparser
import json
from auxiliary.json_validation import JsonKeys
from auxiliary.ui_validation import validate_metric_input_value
from test.emulators import get_context_json_from_db
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
        description="Key-value pairs of metric names and their values"
    )

    @field_validator(JsonKeys.METRICS.value, mode='before')
    def validate_metrics(cls, metrics):
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
            # If timestamp is empty, set it to the current time
            return datetime.now().isoformat()

        # parse the natural language expression
        parsed_date = dateparser.parse(time)
        if parsed_date:
            return parsed_date.isoformat()
        else:
            return datetime.now().isoformat()

    @model_validator(mode='after')
    def validate_metrics(self):
        validate_metric_input(self.metrics, self.name)
        return self


class LoggingData(BaseModel):
    logging: List[LogEntry] = Field(
        ...,
        description="List of all logged habit entries"
    )


def validate_metric_input(input_metrics: Dict[str, Union[int, float, str]], habit_name: str) -> Dict[str, Union[int, float, str]]:
    context_json = get_context_json_from_db()
    habits = {habit[JsonKeys.HABIT_NAME.value]: habit for habit in context_json.get(JsonKeys.HABITS.value, [])}

    # Check if the habit exists
    if habit_name not in habits:
        raise ValueError(f"Habit '{habit_name}' not found in the database.")

    # Check if metrics exist for the habit
    db_metrics = {metric[JsonKeys.METRIC_NAME.value]: metric for metric in habits[habit_name].get(JsonKeys.METRICS.value, [])}
    for metric_name, input_value in input_metrics.items():
        if metric_name not in db_metrics:
            raise ValueError(f"Metric '{metric_name}' not found for habit '{habit_name}'.")
        metric = db_metrics[metric_name]

        # Validate the input value against the metric's configuration
        validate_metric_input_value(
            metric[JsonKeys.INPUT_TYPE.value],
            input_value,
            metric[JsonKeys.CONFIG.value]
        )
    return input_metrics

