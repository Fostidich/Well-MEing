from pydantic import BaseModel, Field, RootModel
from typing import Dict, Optional, Union, Annotated, Set, Literal, List
from datetime import datetime

from pydantic import BaseModel, Field, RootModel
from typing import Dict, Optional, Union, Annotated, Set, Literal, List
from datetime import datetime

from pydantic import BaseModel, Field, RootModel
from typing import Dict, Optional, Union, Set, Literal, List
from datetime import datetime


# --- Metrics configuration
class Config(BaseModel):
    type: Optional[Literal['int', 'float']] = None
    min: Optional[int] = None
    max: Optional[int] = None
    boxes: Optional[List[str]] = None


class MetricDetail(BaseModel):
    description: Optional[str] = ''
    input: str  # e.g., "slider", "time", etc.
    config: Optional[Config] = Field(default_factory=lambda: Config())


# --- Metrics in history
class HistoryMetrics(RootModel):
    root: Dict[str, Union[int, float, str]]


# --- Habit entry (historical log)
class HabitHistoryEntry(BaseModel):
    timestamp: datetime
    notes: Optional[str] = ''
    metrics: Optional[HistoryMetrics] = Field(default_factory=lambda: HistoryMetrics(root={}))


# --- Full habit definition
class HabitDefinition(BaseModel):
    description: Optional[str] = ''
    goal: Optional[str] = ''
    metrics: Optional[Dict[str, MetricDetail]] = {}
    history: Optional[List[HabitHistoryEntry]] = []


# --- Root DTO
class HabitInputDTO(BaseModel):
    speech: str
    habits: Optional[Dict[str, HabitDefinition]] = {}
