import json
from typing import Dict, List, Set, Tuple

from pydantic import BaseModel, Field

from ai.auxiliary.json_keys import JsonKeys
from ai.ui_schema.schemas import InputTypeKeys


def generate_enum_docs(enum_cls) -> str:
    """
    Used to generate a comprehensive description of Enum class to be fed into the LLM
    """
    return "\n".join(
        f"{member.value}: {member.description}"
        for member in enum_cls
    )


class ContextInfoManager(BaseModel):
    habits_descriptions: List[str] = Field(default_factory=list)
    habits_names_set: Set[str] = Field(default_factory=set)
    metrics_names_set: Set[Tuple[str, str]] = Field(default_factory=set)
    input_config_map: Dict[Tuple[str, str], Dict] = Field(default_factory=dict)

    @staticmethod
    def format_metric(metric_name: str, metric_desc: str, input_type: str) -> dict[str, str]:
        """Metric desc format"""
        return {
            "metric_name": metric_name,
            "desc": metric_desc,
            "input": input_type
        }

    @staticmethod
    def format_habit_description(habit_name: str, habit_desc: str, formatted_metrics: List[str]) -> str:
        """Habit desc format"""
        return json.dumps({
            "habit_name": habit_name,
            "description": habit_desc,
            "metrics": formatted_metrics
        }, ensure_ascii=False)

    @classmethod
    def from_context(cls, context: dict) -> "ContextInfoManager":
        descriptions = []
        habits_names_set = set()
        metrics_names_set = set()
        input_config_map = {}
        habits_dict = context.get(JsonKeys.HABITS.value, {})

        for habit_name, habit_data in habits_dict.items():
            habit_desc = habit_data.get(JsonKeys.HABIT_DESCRIPTION.value, "")
            metrics_dict = habit_data.get(JsonKeys.METRICS.value, {})

            formatted_metrics = []
            habits_names_set.add(habit_name)

            for metric_name, metric_data in metrics_dict.items():
                input_type = metric_data.get(JsonKeys.INPUT_TYPE.value)
                metric_desc = metric_data.get(JsonKeys.METRIC_DESCRIPTION.value, "")

                if input_type == InputTypeKeys.FORM.value:
                    boxes = metric_data.get(JsonKeys.CONFIG.value, {}).get(JsonKeys.CONFIG_BOXES.value, [])
                    formatted_metrics.append(cls.format_metric(metric_name, metric_desc, input_type+f"(Options: {boxes})"))
                else:
                    formatted_metrics.append(cls.format_metric(metric_name, metric_desc, input_type))
                metrics_names_set.add((habit_name, metric_name))

                input_config_map[(habit_name, metric_name)] = {
                    'input_type': input_type,
                    'config': metric_data.get(JsonKeys.CONFIG.value, {})
                }

            habit_description = cls.format_habit_description(habit_name, habit_desc, formatted_metrics)
            descriptions.append(habit_description)

        return cls(
            habits_descriptions=descriptions,
            habits_names_set=habits_names_set,
            metrics_names_set=metrics_names_set,
            input_config_map=input_config_map
        )

    def add_created_habit(self, habit_name: str, habit_data: dict):
        habit_desc = habit_data.get("description", "")
        metrics_dict = habit_data.get("metrics", {})
        formatted_metrics = []
        self.habits_names_set.add(habit_name)

        for metric_name, metric_data in metrics_dict.items():
            input_type = metric_data.get("input")
            metric_desc = metric_data.get("description", "")
            config = metric_data.get("config", {})

            if input_type == InputTypeKeys.FORM.value:
                boxes = metric_data.get(JsonKeys.CONFIG.value, {}).get(JsonKeys.CONFIG_BOXES.value, [])
                formatted_metrics.append(
                    self.format_metric(metric_name, metric_desc, input_type + f"(Options: {boxes})"))
            else:
                formatted_metrics.append(self.format_metric(metric_name, metric_desc, input_type))

            self.metrics_names_set.add((habit_name, metric_name))
            self.input_config_map[(habit_name, metric_name)] = {
                'input_type': input_type,
                'config': config or {}
            }

        habit_description = self.format_habit_description(habit_name, habit_desc, formatted_metrics)
        self.habits_descriptions.append(habit_description)


