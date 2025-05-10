from datetime import datetime
from typing import Dict, Any, List


class HabitHistoryEntry:
    def __init__(self, timestamp: str, metrics: Dict[str, Any], notes: str = None):
        self.timestamp = datetime.fromisoformat(timestamp)
        self.metrics = metrics
        self.notes = notes

    def __repr__(self):
        return f"{self.timestamp.isoformat()} | {self.metrics} | Notes: {self.notes}"

    def to_dict(self):
        return {
            "timestamp": self.timestamp.isoformat(),
            "metrics": self.metrics,
            "notes": self.notes
        }


class Habit:
    def __init__(self, name: str, data: Dict[str, Any]):
        self.name = name
        self.description = data.get("description")
        self.goal = data.get("goal")
        self.metrics_config = self._parse_metrics(data["metrics"])
        self.history = self._parse_and_sort_history(data["history"])

    def _parse_metrics(self, metrics: Dict[str, Any]) -> Dict[str, Dict[str, Any]]:
        parsed = {}
        for metric_name, config in metrics.items():
            input_type = config.get("input")
            parsed[metric_name] = {
                "description": config.get("description"),
                "input_type": input_type,
                "config": config.get("config", {}),
            }
        return parsed

    def _parse_and_sort_history(self, history: Dict[str, Any]) -> List[HabitHistoryEntry]:
        entries = []
        for entry in history.values():
            entries.append(HabitHistoryEntry(
                timestamp=entry["timestamp"],
                metrics=entry["metrics"],
                notes=entry.get("notes")
            ))
        return sorted(entries, key=lambda e: e.timestamp)

    def get_history(self) -> List[HabitHistoryEntry]:
        return self.history

    def get_metric_types(self) -> Dict[str, str]:
        return {k: v["input_type"] for k, v in self.metrics_config.items()}

    def to_dict(self):
        return {
            "description": self.description,
            "goal": self.goal,
            "history": [entry.to_dict() for entry in self.history]
        }


class HabitManager:
    def __init__(self, report: Dict[str, Any]):
        self.name = report["name"]
        self.bio = report["bio"]
        self.habits = self._parse_habits(report["habits"])

    def _parse_habits(self, habits_data: Dict[str, Any]) -> Dict[str, Habit]:
        return {name: Habit(name, data) for name, data in habits_data.items()}

    def get_habit(self, name: str) -> Habit:
        return self.habits[name]

    def list_habits(self) -> List[str]:
        return list(self.habits.keys())

    def to_dict(self):
        return {habit_name: habit.to_dict() for habit_name, habit in self.habits.items()}
