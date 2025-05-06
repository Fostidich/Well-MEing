from typing import Dict, List, Any

from auxiliary.json_keys import JsonKeys


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
        # Store the raw habits data dictionary (will store the full incoming request data)
        self._raw_habits_data: Dict[str, Any] = {}

    def update_context_info(self, request_data: dict):
        """
        Fetches habit data from the request_data dictionary and updates the context information.
        Assumes request_data has a structure like {"speech": "...", "habits": [{...}, {...}, ...]}
        where "habits" is a list of habit dictionaries.
        """
        # Store the raw data (the full request dictionary)
        self._raw_habits_data = request_data

        descriptions = []
        names_set = set() # Re-initialize sets/maps for the new context
        input_config_map = {}

        # Get the habits dictionary (instead of list) from incoming data
        habits_dict = request_data.get(JsonKeys.HABITS.value, {})
        if not isinstance(habits_dict, dict):
            print(f"Warning: Expected 'habits' to be a dict, but got {type(habits_dict)}")
            habits_dict = {}  # Reset to empty dict if format is unexpected

        for habit_name, habit_data in habits_dict.items():
            if not isinstance(habit_data, dict):
                print(f"Warning: Expected habit data for '{habit_name}' to be a dict, but got {type(habit_data)}")
                continue

            habit_desc = habit_data.get(JsonKeys.HABIT_DESCRIPTION.value, "") or habit_data.get("description", "") or ""
            metrics_dict = habit_data.get(JsonKeys.METRICS.value, {}) or habit_data.get("metrics", {})

            if not isinstance(metrics_dict, dict):
                print(f"Warning: Expected 'metrics' for habit '{habit_name}' to be a dict, but got {type(metrics_dict)}")
                metrics_dict = {}

            metrics_desc = []

            for metric_name, metric_data in metrics_dict.items():
                if not isinstance(metric_data, dict):
                    print(f"Warning: Expected metric data for '{metric_name}' in habit '{habit_name}' to be a dict, but got {type(metric_data)}")
                    continue

                input_type = metric_data.get(JsonKeys.INPUT_TYPE.value, "") or metric_data.get("input", "unknown")
                metric_desc = metric_data.get(JsonKeys.METRIC_DESCRIPTION.value, "") or metric_data.get("description", "") or ""

                metrics_desc.append(f"{metric_name}({input_type})[{metric_desc}]")

                names_set.add((habit_name, metric_name))
                input_config_map[(habit_name, metric_name)] = {
                    'input_type': input_type,
                    'config': metric_data.get(JsonKeys.CONFIG.value, {}) or metric_data.get("config", {})
                }

            habit_description = f"\nHabit: {habit_name}[{habit_desc}] has Metrics: " + ", ".join(metrics_desc)
            descriptions.append(habit_description)

        # Update the manager's state variables with the collected data
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
                 print(f"Warning: Expected 'metrics' in creation for habit '{habit_name}' to be a list, but got {type(metrics_list)}")
                 metrics_list = []

            for metric_dict in metrics_list:
                 if not isinstance(metric_dict, dict):
                     print(f"Warning: Expected metric item in creation list for habit '{habit_name}' to be a dict, but got {type(metric_dict)}")
                     continue

                 metric_name = metric_dict.get(JsonKeys.METRIC_NAME.value)
                 if not metric_name:
                     print(f"Warning: Skipping metric entry in creation for habit '{habit_name}' due to missing name: {metric_dict}")
                     continue

                 input_type = metric_dict.get(JsonKeys.INPUT_TYPE.value) # Get input type (required in creation schema)
                 config = metric_dict.get(JsonKeys.CONFIG.value, {})

                 # Add the newly created habit/metric to the set/map
                 self.names_set.add((habit_name, metric_name))
                 self.input_config_map[(habit_name, metric_name)] = {
                     'input_type': input_type, # Use the type from creation data
                     'config': config
                 }


    def get_habits_descriptions(self):
        return self.habits_descriptions

    # Returns the raw data from the last request, which includes "speech", "habits" list, etc.
    def get_raw_habits_data(self) -> Dict[str, Any]:
        return self._raw_habits_data

context_manager = ContextInfoManager()