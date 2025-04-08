from enum import Enum

class HabitKeys(str, Enum):
    CREATION = "creation"
    NAME = "name"
    DESCRIPTION = "description"
    GOAL = "goal"
    METRICS = "metrics"

class MetricKeys(str, Enum):
    NAME = "name"
    DESCRIPTION = "description"
    INPUT = "input"
    CONFIG = "config"

class LogKeys(str, Enum):
    LOGGING = "logging"
    TIMESTAMP = "timestamp"
    NAME = "name"
    NOTES = "notes"
    METRICS = "metrics"

class ConfigKeys(str, Enum):
    UNIT = "unit"
    TYPE = "type"
    MIN = "min"
    MAX = "max"