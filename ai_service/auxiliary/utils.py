from auxiliary.json_keys import JsonKeys
from test.emulators import get_context_json_from_db


def generate_enum_docs(enum_cls) -> str:
    """
    Used to generate a comprehensive description of Enum class to be fed into the LLM
    """
    return "\n".join(
        f"{member.value}: {member.description}"
        for member in enum_cls
    )


def generate_habit_descriptions():
    """
    Fetches habit data from the database and generates a token-efficient description
    for each habit in the format:
    habit_name[desc]: metric_name1(input_type)[desc], metric_name2(input_type)[desc]
    """
    habits_data = get_context_json_from_db()
    descriptions = []

    for habit in habits_data.get(JsonKeys.HABITS.value, []):
        habit_name = habit.get(JsonKeys.HABIT_NAME.value)
        habit_desc = habit.get(JsonKeys.HABIT_DESCRIPTION.value)
        if habit_desc == "Null": habit_desc = ""
        metrics = habit.get(JsonKeys.METRICS.value)

        metrics_desc = []
        for metric in metrics:
            metric_name = metric.get(JsonKeys.METRIC_NAME.value)
            input_type = metric.get(JsonKeys.INPUT_TYPE.value)
            metric_desc = metric.get(JsonKeys.METRIC_DESCRIPTION.value)
            if metric_desc == "Null": metric_desc = ""
            metrics_desc.append(f"{metric_name}({input_type})[{metric_desc}]")

        habit_description = f"\n Habit:{habit_name}[{habit_desc}] has Metrics: " + ", ".join(metrics_desc)
        descriptions.append(habit_description)

    return descriptions
