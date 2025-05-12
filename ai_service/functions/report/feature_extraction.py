from typing import Dict, Any

from report.metric_preprocessing import HabitManager


def extract_metric_features_by_habit(habit_manager: HabitManager) -> Dict[str, Dict[str, Dict[str, Any]]]:
    habit_features = {}

    for habit_name, habit in habit_manager.habits.items():
        metric_features = {}
        for metric_name, metric_info in habit.metrics_config.items():
            input_type = metric_info["input_type"]
            config = metric_info.get("config", {})

            # Basic default feature extraction logic by input type
            if input_type == "Slider":
                features = {"type": "numerical"}
            elif input_type == "Time duration":
                features = {
                    "type": "duration",
                    "unit": config.get("unit", "minutes")
                }
            elif input_type in {"+1 button", "+5 button", "+N button"}:
                features = {
                    "type": "incremental",
                    "step": int(input_type.strip("+ buttonN")) if "N" not in input_type else "custom"
                }
            elif input_type == "Text Box":
                features = {
                    "type": "text"
                }
            elif input_type == "Rating":
                features = {
                    "type": "categorical",
                    "levels": config.get("levels", ["bad", "mid", "good"])
                }
            else:
                features = {
                    "type": "unknown"
                }

            metric_features[metric_name] = {
                "input_type": input_type,
                "features": features
            }

        habit_features[habit_name] = metric_features

    return habit_features
