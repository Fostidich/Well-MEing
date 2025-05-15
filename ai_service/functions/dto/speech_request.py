from pydantic import BaseModel, Field, RootModel
from typing import Dict, Optional, Union, Annotated, Set, Literal
from datetime import datetime


# --- Metrics configuration
class Config(BaseModel):
    type: Optional[Literal['int', 'float']] = None
    min: Optional[int] = None
    max: Optional[int] = None
    boxes: Optional[Set[str]] = None


class MetricDetail(BaseModel):
    description: Optional[str] = ''
    input: str  # e.g., "slider", "time", etc.
    config: Optional[Config] = None


# --- Metrics in history
class HistoryMetrics(RootModel):
    root: Dict[str, Union[int, float, str]]  # values like 12, "01:30:00", etc.


# --- Habit entry (historical log)
class HabitHistoryEntry(BaseModel):
    timestamp: datetime
    notes: Optional[str] = None
    metrics: HistoryMetrics


# --- Full habit definition
class HabitDefinition(BaseModel):
    description: str
    goal: str
    metrics: Dict[str, MetricDetail]
    #history: Dict[str, HabitHistoryEntry]


# --- Root DTO
class HabitInputDTO(BaseModel):
    speech: str
    habits: Dict[str, HabitDefinition]

data = {'habits': {'Running': {'description': 'Track running metrics', 'metrics': {'Notes': {'description': 'Any additional notes', 'input': 'text'}, 'Time': {'input': 'slider', 'config': {'type': 'int', 'max': 3600, 'min': 0}, 'description': 'Seconds'}, 'Distance': {'input': 'slider', 'description': 'Meters', 'config': {'max': 10000, 'type': 'int', 'min': 0}}, 'Difficulty': {'input': 'rating', 'description': 'Rate the difficulty of the run'}, 'Heart Rate': {'input': 'slider', 'config': {'type': 'int', 'min': 60, 'max': 200}, 'description': 'BPM'}}, 'goal': 'Be consistent with running'}}, 'speech': 'Today i ran 10 km bpm 100'}
HabitInputDTO(**data)