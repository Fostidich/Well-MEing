from datetime import datetime
from typing import Optional, Union, List, Dict, Annotated

import dateparser
import pytz
from langchain_core.tools import InjectedToolCallId
from langgraph.prebuilt import InjectedState
from pydantic import BaseModel, Field, field_validator, model_validator

from auxiliary.utils import generate_enum_docs, ContextInfoManager
from ui_schema.dispacher import validate_input
from ui_schema.schemas import InputTypeKeys

TIMEZONE = pytz.timezone('Europe/Rome')


class Metric(BaseModel):
    metric_name: str = Field(...)
    value: Union[int, float, str] = Field(...,
                                          description=f"\nInputType: ExpectedInput\n{generate_enum_docs(InputTypeKeys)}")


class LogEntry(BaseModel):
    timestamp: str = Field(
        ...,
        description="Time reference of the input (e.g. this afternoon, last week), leave empty to insert the current time"
    )
    name: str = Field(
        ...,
        description="Name of the habit being logged (must exist from available habits)"
    )
    notes: Optional[str] = Field(
        None,
        description="About the log entry"
    )
    metrics: List[Metric] = Field(
        ...,
        description=(
            f"List of metrics in the habit to log"
        ))

    @model_validator(mode='after')
    def validate_log_entry(self) -> 'LogEntry':

        # Process timestamp
        if not self.timestamp:
            # Set current time in the desired timezone
            self.timestamp = datetime.now(TIMEZONE).isoformat()
        else:
            # Parse the natural language expression
            parsed_date = dateparser.parse(
                self.timestamp,
                settings={'TIMEZONE': 'Europe/Rome', 'RETURN_AS_TIMEZONE_AWARE': True}
            )
            if parsed_date:
                self.timestamp = parsed_date.astimezone(TIMEZONE).isoformat()
            else:
                self.timestamp = datetime.now(TIMEZONE).isoformat()

        seen_names = set()
        for metric in self.metrics:
            name = metric.metric_name
            if name in seen_names:
                raise ValueError(f"Duplicate metric name found in List of metrics: '{name}', divide the log into multiple entries for the same habit please")
            seen_names.add(name)

        return self


class LoggingData(BaseModel):
    logging: List[LogEntry] = Field(..., description="List of logs")
    state: Annotated[Dict, InjectedState] = Field(..., description="Context for the tool")
    tool_call_id: Annotated[str, InjectedToolCallId]

    @model_validator(mode='after')
    def validate_metrics(self):
        context = self.state.get("context")
        context_manager = ContextInfoManager.construct(**context)

        for i, log in enumerate(self.logging):
            if log.name not in context_manager.habits_names_set:
                raise ValueError(
                    f"Habit '{log.name}' not found in context. Available habits: {context_manager.habits_names_set}")
            validated_metrics = self.validate_metric_input(log.metrics, log.name, context_manager)

            self.logging[i] = log.copy(update={"metrics": validated_metrics})

        return self

    @staticmethod
    def validate_metric_input(input_metrics: List[Metric], habit_name: str,
                              context_manager: ContextInfoManager) -> list[Metric]:
        validated_metrics = []

        for metric in input_metrics:
            metric_name = metric.metric_name
            input_value = metric.value
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
            validated_metric = {'metric_name': metric_name, 'value': validated_value}
            validated_metrics.append(Metric.construct(**validated_metric))
        return validated_metrics
