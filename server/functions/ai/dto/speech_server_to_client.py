from datetime import datetime
from typing import Dict, List, Optional, Set, Union, Literal

from pydantic import BaseModel, Field, RootModel


# --- Metric configuration (for sliders, forms etc.)
class MetricConfig(BaseModel):
    type: Optional[Literal["int", "float"]] = None
    min: Optional[int] = None
    max: Optional[int] = None
    boxes: Optional[Set[str]] = None


# --- Metric definition within creation
class MetricDefinition(BaseModel):
    description: Optional[str] = ''
    input: Literal["slider", "time", "rating", "form", "text"]
    config: Optional[MetricConfig] = Field(default_factory=lambda: MetricConfig())


# --- Habit definition within "creation"
class HabitCreation(BaseModel):
    description: Optional[str] = ''
    goal: Optional[str] = ''
    metrics: Dict[str, MetricDefinition]


# --- Metrics log per habit entry (HistoryMetrics)
class MetricsLog(RootModel):
    root: Dict[str, Union[int, float, str]]


# --- A single habit log entry
class HabitLogEntry(BaseModel):
    timestamp: datetime
    notes: Optional[str] = ''
    metrics: Optional[MetricsLog] = Field(default_factory=lambda: MetricsLog(root={}))


# --- DTO combining creation and logging
class HabitOutputDTO(BaseModel):
    creation: Dict[str, HabitCreation]
    logging: Dict[str, List[HabitLogEntry]]
