from typing import Dict, List
from auxiliary.json_validation import ActionKeys
from enum import Enum
from test.emulators import get_context_json_from_db, save_out_to_db

# Variabile locale che simula il contenuto del database
out = {key.value: [] for key in ActionKeys}



def append_json(data: Dict):
    """Append new data to outing JSON file."""
    action_key = next(iter(data))  # Get the first key of the input dictionary
    out[action_key].append(data[action_key])
    print(out)
    # Simulate sending it to DB
    save_out_to_db(out)



