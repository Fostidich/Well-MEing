from typing import Dict, List

from auxiliary.json_keys import JsonKeys
from auxiliary.ui_rules import InputTypeKeys
from test.emulators import get_context_json_from_db

def generate_enum_docs(enum_cls) -> str:
    """
    Used to generate a comprehensive description of Enum class to be fed into the LLM
    """
    return "\n".join(
        f"{member.value}: {member.description}"
        for member in enum_cls
    )


class ContextInfoManager:
    def __init__(self):
        self.habits_descriptions = []
        self.names_set = set()
        self.input_config_map = {}

    def update_context_info(self):
        """
        Fetches habit data from the database and updates the context information.
        """
        habits_data = get_context_json_from_db()
        descriptions = []
        names_set = set()
        input_config_map = {}

        for habit_name, habit_info in habits_data.get(JsonKeys.HABITS.value, {}).items():
            habit_desc = habit_info.get(JsonKeys.HABIT_DESCRIPTION.value, "") or ""
            metrics = habit_info.get(JsonKeys.METRICS.value, {})
            metrics_desc = []

            for metric_name, metric_info in metrics.items():
                input_type = metric_info.get(JsonKeys.INPUT_TYPE.value, "unknown")

                metric_desc = metric_info.get(JsonKeys.METRIC_DESCRIPTION.value, "") or ""

                metrics_desc.append(f"'{metric_name}'({input_type})|{metric_desc}|")
                names_set.add((habit_name, metric_name))
                input_config_map[(habit_name, metric_name)] = {
                    'input_type': input_type,
                    'config': metric_info.get(JsonKeys.CONFIG.value, {})
                }
                if input_type == 'form':
                    boxes = metric_info.get(JsonKeys.CONFIG.value, {}).get(JsonKeys.CONFIG_BOXES.value, [])
                    if boxes:
                        metrics_desc[-1] = metrics_desc[-1] + f"Options: {', '.join(boxes)}"

            habit_description = f"\n'{habit_name}'|{habit_desc}|" + ";".join(metrics_desc)
            descriptions.append(habit_description)
        descriptions = "FORMAT='habit_name'|habit_desc|['metric_name'(input_type)|metric_desc|,...];" + "".join(descriptions)
        self.habits_descriptions = descriptions
        self.names_set = names_set
        self.input_config_map = input_config_map

    def add_context_from_creation(self, creation: List[Dict]):

        for habit in creation:
            habit_name = habit.get(JsonKeys.HABIT_NAME.value)
            for metric in habit.get(JsonKeys.METRICS.value, []):
                metric_name = metric.get(JsonKeys.METRIC_NAME.value)
                input_type = metric.get(JsonKeys.INPUT_TYPE.value)
                config = metric.get(JsonKeys.CONFIG.value, {})

                self.names_set.add((habit_name, metric_name))
                self.input_config_map[(habit_name, metric_name)] = {
                    'input_type': input_type,
                    'config': config
                }


context_manager = ContextInfoManager()
context_manager.update_context_info()