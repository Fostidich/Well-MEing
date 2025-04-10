from pydantic import BaseModel, Field
from typing import Optional, Union, List, Dict
from datetime import datetime


class LogEntry(BaseModel):
    timestamp: datetime = Field(
        ...,
        description="Time in ISO 8601 format to insert the log entry"
    )
    name: str = Field(
        ...,
        description="Name of the habit being logged"
    )
    notes: Optional[str] = Field(
        None,
        description="Notes or comments about the log entry"
    )
    metrics: Dict[str, Union[int, float, str]] = Field(
        ...,
        description="Key-value pairs of metric names and their values"
    )


class LoggingData(BaseModel):
    logging: List[LogEntry] = Field(
        ...,
        description="List of all logged habit entries"
    )
