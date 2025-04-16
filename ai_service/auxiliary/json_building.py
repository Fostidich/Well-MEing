from typing import Dict

from auxiliary.json_keys import ActionKeys
from test.emulators import send_to_db


# Empty OUT dict initializer
# OUT dict is a dictionary which has the output JSON structure.
# Starts with "create" and "logging" action_keys and habits and history data points are added respectively
def initialize_out_dict():
    global OUT
    OUT = {key.value: [] for key in ActionKeys}


initialize_out_dict()


# extends the data entry from a tool call into the OUT dict which will be dumped as json
def extend_out_dict(data: Dict):
    action_key = next(iter(data))
    OUT[action_key].extend(data[action_key])
    print(f"Extended out: {OUT}")
    send_to_db(OUT)
    initialize_out_dict()
