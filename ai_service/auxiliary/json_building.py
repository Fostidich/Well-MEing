import json
from typing import Dict
from test.emulators import get_json_from_db, save_to_db

# Variabile locale che simula il contenuto del database
out = {
    "creation": [],
    "logging": []
}

def get_habits_map():
    data = out#get_json_from_db()
    return build_habit_map(data.get("creation", []))

def build_habit_map(creation_data):
    habit_map = {}
    for habit in creation_data:
        habit_name = habit["habit_name"]
        habit_map[habit_name] = {
            metric.get("metric_name"): {
                "input_type": metric["input"],
                "description": metric.get("metric_description", ''),
            } for metric in habit["metrics"]
        }
    return habit_map

def append_habit(new_habit: Dict):
    creation_data = out.get("creation", [])

    for habit in creation_data:
        if habit['habit_name'] == new_habit['habit_name']:
            habit['metrics'].append({
                'metric_name': new_habit['metric_name'],
                'metric_description': new_habit.get('description', ''),
                'input': new_habit['input_type'],
                'config': {
                    'type': new_habit.get('value_type', 'int'),
                    'min': new_habit.get('min_value'),
                    'max': new_habit.get('max_value')
                }
            })
            break
    else:
        creation_data.append({
            'habit_name': new_habit['habit_name'],
            'habit_description': new_habit.get('habit_description', ''),
            'habit_goal': new_habit.get('habit_goal', ''),
            'metrics': [{
                'metric_name': new_habit['metric_name'],
                'metric_description': new_habit.get('metric_description', ''),
                'input': new_habit['input_type'],
                'config': {
                    'type': new_habit.get('value_type', 'int'),
                    'min': new_habit.get('min_value'),
                    'max': new_habit.get('max_value')
                }
            }]
        })

    out["creation"] = creation_data
    print(f"[DB] Added new habit: {new_habit['habit_name']}")

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

def Confirmation():
    print_db()
    save_to_db(out)

# Optional: funzione per stampare il contenuto corrente del "db"
def print_db():
    print(json.dumps(out, indent=2))
