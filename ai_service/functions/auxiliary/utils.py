from typing import Dict, List, Any

from auxiliary.json_keys import JsonKeys
from ui_schema.schemas import InputTypeKeys


def generate_enum_docs(enum_cls) -> str:
    """
    Used to generate a comprehensive description of Enum class to be fed into the LLM
    """
    return "\n".join(
        f"{member.value}: {member.description}"
        for member in enum_cls
    )


class ContextInfoManager:
    def __init__(self, context):
        self.habits_descriptions = []
        self.names_set = set()
        self.input_config_map = {}
        self._update_context_info(context)

    def _update_context_info(self, context: dict):

        descriptions = ["Format: \n habit_name[habit_desc]: [metric_name[metric_desc](input_type),...]"]
        names_set = set()
        input_config_map = {}

        habits_dict = context.get(JsonKeys.HABITS.value, [])

        for habit_name, habit_data in habits_dict.items():
            habit_desc = habit_data.get(JsonKeys.HABIT_DESCRIPTION.value, "")
            metrics_dict = habit_data.get(JsonKeys.METRICS.value, {})

            metrics_desc = []

            for metric_name, metric_data in metrics_dict.items():
                input_type = metric_data.get(JsonKeys.INPUT_TYPE.value)
                metric_desc = metric_data.get(JsonKeys.METRIC_DESCRIPTION.value, "")

                if input_type == InputTypeKeys.FORM.value:
                    input_type += f"(Options: {metric_data.get(JsonKeys.CONFIG.value).get(JsonKeys.CONFIG_BOXES.value)})"
                metrics_desc.append(f"{metric_name}[{metric_desc}]({input_type})")

                names_set.add((habit_name, metric_name))
                input_config_map[(habit_name, metric_name)] = {
                    'input_type': input_type,
                    'config': metric_data.get(JsonKeys.CONFIG.value, {})
                }

            # Compose habit description string
            habit_description = f"\n {habit_name}[{habit_desc}]: " + ", ".join(metrics_desc) + ";"
            descriptions.append(habit_description)

        # Update internal state
        self.habits_descriptions = descriptions
        self.names_set = names_set
        self.input_config_map = input_config_map

    def add_context_from_creation(self, creation: List[Dict]):
        # This method correctly processes a list of creation dictionaries.
        # It only updates the names_set and input_config_map based on *new* creations.
        # It does NOT modify the stored _raw_habits_data which represents existing state.
        for habit_dict in creation:
            # Ensure habit_dict is a dict and has a name
            if not isinstance(habit_dict, dict):
                print(f"Warning: Expected creation item to be a dict, but got {type(habit_dict)}")
                continue

            habit_name = habit_dict.get(JsonKeys.HABIT_NAME.value)
            if not habit_name:
                print(f"Warning: Skipping creation entry due to missing habit name: {habit_dict}")
                continue

            metrics_list = habit_dict.get(JsonKeys.METRICS.value, [])
            if not isinstance(metrics_list, list):
                print(
                    f"Warning: Expected 'metrics' in creation for habit '{habit_name}' to be a list, but got {type(metrics_list)}")
                metrics_list = []

            for metric_dict in metrics_list:
                if not isinstance(metric_dict, dict):
                    print(
                        f"Warning: Expected metric item in creation list for habit '{habit_name}' to be a dict, but got {type(metric_dict)}")
                    continue

                metric_name = metric_dict.get(JsonKeys.METRIC_NAME.value)
                if not metric_name:
                    print(
                        f"Warning: Skipping metric entry in creation for habit '{habit_name}' due to missing name: {metric_dict}")
                    continue

                input_type = metric_dict.get(JsonKeys.INPUT_TYPE.value)  # Get input type (required in creation schema)
                config = metric_dict.get(JsonKeys.CONFIG.value, {})

                # Add the newly created habit/metric to the set/map
                self.names_set.add((habit_name, metric_name))
                self.input_config_map[(habit_name, metric_name)] = {
                    'input_type': input_type,  # Use the type from creation data
                    'config': config
                }
                self.habits_descriptions.append("Added:" + habit_name + " with " + metric_name)
