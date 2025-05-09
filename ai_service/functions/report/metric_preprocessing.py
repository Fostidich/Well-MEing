from collections import defaultdict
from typing import Dict, List, Tuple, Any

from auxiliary.json_keys import JsonKeys


def extract_metrics(report_json: Dict[str, Any]) -> Dict[str, Dict[str, List[Tuple[str, Any]]]]:
    """
    Extracts time-stamped metric data points from a report JSON and categorizes them by input type.

    Args:
        report_json (dict): Report containing history with timestamped metrics.

    Returns:
        dict: Dictionary categorizing metrics by input type (Numeric, str, form).
    """
    habits = report_json.get(JsonKeys.HABITS.value, [])

    categorized_metrics = {
        "Numeric": defaultdict(list),
        "str": defaultdict(list),
        "form": defaultdict(list),
        "time": defaultdict(list),
    }

    # Precompute sets for "form" and "time" input types
    form_metrics_set = {
        metric["name"]
        for habit in habits
        for metric in habit.get(JsonKeys.METRICS.value, [])
        if metric.get("input") == "form"
    }
    time_metrics_set = {
        metric["name"]
        for habit in habits
        for metric in habit.get(JsonKeys.METRICS.value, [])
        if metric.get("input") == "time"
    }

    for habit in habits:
        history = habit.get(JsonKeys.HISTORY.value, [])
        for record in history:
            timestamp = record.get("timestamp")
            metrics = record.get("metrics", {})
            for metric_name, value in metrics.items():
                if metric_name in form_metrics_set:
                    categorized_metrics["form"].setdefault(metric_name, []).append((timestamp, value))
                elif metric_name in time_metrics_set:
                    categorized_metrics["time"].setdefault(metric_name, []).append((timestamp, value))
                elif isinstance(value, (int, float)):
                    categorized_metrics["Numeric"].setdefault(metric_name, []).append((timestamp, value))
                elif isinstance(value, str):
                    categorized_metrics["str"].setdefault(metric_name, []).append((timestamp, value))

    # Convert defaultdicts to regular dicts
    return {key: dict(value) for key, value in categorized_metrics.items()}


def extract_metrics_features(metrics_data: Dict[str, Dict[str, List[Tuple[str, Any]]]]):
    return
