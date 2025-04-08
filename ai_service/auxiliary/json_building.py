import json
from typing import Dict
from test.emulators import get_json_from_db, save_to_db
from auxiliary.json_validation import HabitKeys, MetricKeys, LogKeys, ConfigKeys

# Variabile locale che simula il contenuto del database
out = {
    HabitKeys.CREATION: [],
    LogKeys.LOGGING: []
}

def get_habits_map():
    data = out
    return build_habit_map(data.get(HabitKeys.CREATION, []))

def build_habit_map(creation_data):
    habit_map = {}
    for habit in creation_data:
        habit_name = habit[HabitKeys.NAME]
        habit_map[habit_name] = {
            metric.get(MetricKeys.NAME): {
                "input_type": metric.get[MetricKeys.INPUT],
                "description": metric.get(MetricKeys.DESCRIPTION, '')
            }
            for metric in habit[HabitKeys.METRICS]
        }
    return habit_map

# Assume `out` is your global or external structure being updated
def append_habit(new_habit: Dict):
    creation_data = out.get(HabitKeys.CREATION, [])

    for habit in creation_data:
        if habit[HabitKeys.NAME] == new_habit[HabitKeys.NAME]:
            habit[HabitKeys.METRICS].append({
                MetricKeys.NAME: new_habit[MetricKeys.NAME],
                MetricKeys.DESCRIPTION: new_habit.get(MetricKeys.DESCRIPTION, ''),
                MetricKeys.INPUT: new_habit["input_type"],
                MetricKeys.CONFIG: {
                    'type': new_habit.get(ConfigKeys.TYPE, 'int'),
                    'min': new_habit.get(ConfigKeys.MIN),
                    'max': new_habit.get(ConfigKeys.MAX)
                }
            })
            break
    else:
        creation_data.append({
            HabitKeys.NAME: new_habit[HabitKeys.NAME],
            HabitKeys.DESCRIPTION: new_habit.get(HabitKeys.DESCRIPTION, ''),
            HabitKeys.GOAL: new_habit.get(HabitKeys.GOAL, ''),
            HabitKeys.METRICS: [{
                MetricKeys.NAME: new_habit[MetricKeys.NAME],
                MetricKeys.DESCRIPTION: new_habit.get(MetricKeys.DESCRIPTION, ''),
                MetricKeys.INPUT: new_habit["input_type"],
                MetricKeys.CONFIG: {
                    'type': new_habit.get('value_type', 'int'),
                    'min': new_habit.get('min_value'),
                    'max': new_habit.get('max_value')
                }
            }]
        })

    out[HabitKeys.CREATION] = creation_data
    print(f"[DB] Added new habit: {new_habit[HabitKeys.NAME]}")


def append_metric_data(new_metric_data: Dict):
    logging_data = out.get("logging", [])
    timestamp = new_metric_data["timestamp"]
    habit_name = new_metric_data["habit_name"]
    metric_name = new_metric_data["metric_name"]
    value = new_metric_data["value"]

    # Trova un log esistente con stesso habit e timestamp
    existing_entry = next((
        entry for entry in logging_data
        if entry["timestamp"] == timestamp and entry["habit-name"] == habit_name
    ), None)

    if existing_entry:
        # Se metrica già esiste, ignoriamo
        if metric_name in existing_entry["metrics"]:
            print(f"[DB] Metric '{metric_name}' already exists for '{habit_name}' at {timestamp}. Skipping.")
            return

        existing_entry["metrics"][metric_name] = value

        print(f"[DB] Appended metric '{metric_name}' to existing entry for '{habit_name}' at {timestamp}")
    else:
        # Se non esiste nessun log, creiamone uno nuovo
        log_entry = {
            "timestamp": timestamp,
            "habit-name": habit_name,
            "metrics": {
                metric_name: value
            }
        }

        logging_data.append(log_entry)
        print(f"[DB] Created new log for habit '{habit_name}' at {timestamp}")

    # Salviamo nel DB
    out["logging"] = logging_data

def confirmation():
    print(json.dumps(out, indent=2))
    save_to_db(out)


