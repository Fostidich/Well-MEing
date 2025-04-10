import json
from typing import List

# Constants
DB_FILE = r"../habits_db.txt"


def get_context_json_from_db():
    with open(DB_FILE, 'r') as f:
        data = json.load(f)
    return data
