from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional, Union, List, Dict
from datetime import datetime
import dateparser
import json
from auxiliary.json_validation import JsonKeys

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


def validate_metric_input(metrics: Dict[str, Union[int, float, str]], habit_name: str) -> Dict[str, Union[int, float, str]]:
    """
    Validates the metrics dictionary for a given habit.

    Args:
        metrics: A dictionary of metric names and their values.
        habit_name: The name of the habit being logged.

    Returns:
        The validated metrics dictionary.

    Raises:
        ValueError: If any metric value is invalid.
    """
    for metric_name, value in metrics.items():
        if not isinstance(value, (int, float, str)):
            raise ValueError(f"Invalid value for metric '{metric_name}' in habit '{habit_name}'. Must be int, float, or str.")
    return metrics