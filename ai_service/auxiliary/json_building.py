from typing import Dict, List
from auxiliary.json_validation import Action_Keys
from enum import Enum
from test.emulators import get_context_json_from_db

# Variabile locale che simula il contenuto del database
out = {key.value: [] for key in Action_Keys}



def append_json(data: Dict):
    """Append new data to outing JSON file."""
    action_key = next(iter(data))  # Get the first key of the input dictionary
    out[action_key].append(data[action_key])


