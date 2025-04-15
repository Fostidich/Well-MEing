import json
from typing import Dict, List
from auxiliary.json_keys import ActionKeys
from enum import Enum
from test.emulators import get_context_json_from_db, send_to_db


def initialize_out_dict():
    global OUT
    OUT = {key.value: [] for key in ActionKeys}


initialize_out_dict()


def extend_out_dict(data: Dict):
    action_key = next(iter(data))
    OUT[action_key].extend(data[action_key])
    print(f"Extended out: {OUT}")
