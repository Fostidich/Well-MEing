import json
from datetime import datetime
from typing import Optional, Union, List, Dict, Annotated

import dateparser
import pytz
from langchain_core.tools import InjectedToolCallId
from langgraph.prebuilt import InjectedState
from pydantic import BaseModel, Field, field_validator, model_validator

from auxiliary.json_keys import JsonKeys
from auxiliary.utils import generate_enum_docs, ContextInfoManager
from ui_schema.dispacher import validate_input
from ui_schema.schemas import InputTypeKeys

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
    metrics: Dict[str, Union[str, int, float]] = Field(
        ...,
        description=f"Dict[Key:value=metric_name:value] \ninput: expected_value\n {generate_enum_docs(InputTypeKeys)} "
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
            return datetime.now(TIMEZONE).isoformat()

        # parse the natural language expression
        parsed_date = dateparser.parse(time, settings={'TIMEZONE': 'Europe/Rome', 'RETURN_AS_TIMEZONE_AWARE': True})
        if parsed_date:
            return parsed_date.astimezone(TIMEZONE).isoformat()
        else:
            return datetime.now(TIMEZONE).isoformat()


class LoggingData(BaseModel):
    logging: List[LogEntry] = Field(..., description="List of logs")
    state: Annotated[Dict, InjectedState] = Field(..., description="Context for the tool")
    tool_call_id: Annotated[str, InjectedToolCallId]

    @model_validator(mode='after')
    def validate_metrics(self):
        context = self.state.get("context")
        context_manager = ContextInfoManager(context)

        for i, log in enumerate(self.logging):
            if log.name not in context_manager.habits_names_set:
                raise ValueError(
                    f"Habit '{log.name}' not found in context. Available habits: {context_manager.habits_names_set}")
            validated_metrics = validate_metric_input(log.metrics, log.name, context_manager)
            self.logging[i] = log.copy(update={"metrics": validated_metrics})

        return self


def validate_metric_input(input_metrics: Dict[str, Union[int, float, str]], habit_name: str,
                          context_manager: ContextInfoManager) -> Dict[str, Union[int, float, str]]:
    validated_metrics = {}
    for metric_name, input_value in input_metrics.items():
        print(metric_name, input_value)
        if (habit_name, metric_name) not in context_manager.metrics_names_set:
            raise ValueError(
                f"Metric '{metric_name}' not found for habit '{habit_name}'. Available habit-metric names: {context_manager.metrics_names_set}")

        input_type = context_manager.input_config_map[(habit_name, metric_name)]['input_type']
        config = context_manager.input_config_map[(habit_name, metric_name)]['config']

        # Validate the input value against the metric's configuration
        validated_value = validate_input(
            input_type=input_type,
            input_value=input_value,
            config=config if config else None
        )
        validated_metrics[metric_name] = validated_value
    return validated_metrics
