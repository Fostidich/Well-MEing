from uuid import uuid4

from ai_tools.habit_tools import create_habit_tool, insert_habit_tool
from auxiliary.json_keys import ActionKeys
from auxiliary.utils import ContextInfoManager

data = {
    "speech":
        "I want to track sleeping parameters",
    "habits": {
        "Gym": {
            "description": "Go for a run in your free time",
            "goal": "I want to run 3 times a week in order to train for PolimiRun",
            "metrics": {
                "Series": {
                    "description": "Kilometers run",
                    "input": "slider",
                    "config": {
                        "type": "int",
                        "min": 0,
                        "max": 100
                    }
                },
                "Duration": {
                    "description": "Minutes of running",
                    "input": "time"
                }
            },
            "history": {
                "id-1234": {
                    "timestamp": "2025-03-27T14:30:00",
                    "notes": "Today the run was on a 20% street",
                    "metrics": {
                        "Distance": 12,
                        "Duration": "01:30:00"
                    }
                },
                "id-2345": {
                    "timestamp": "2025-03-24T16:30:00",
                    "metrics": {
                        "Distance": 10,
                        "Duration": "01:10:00"
                    }
                }
            }
        }
    }
}

out = {key.value: {} for key in ActionKeys}

context = {"habits": data.get("habits", {})}
user_input = data.get("speech", [])
context_manager = ContextInfoManager.from_context(context)
state = {"messages": [user_input],
         "context": context_manager.model_dump(), "out": out}

#create_habit_tool.invoke({"tool_call_id": "uhfuah!", "state": state, "creation": [{"name": "Sleep", "description": "Track your sleeping time", "goal": "Have a good sleep", "metrics": [{"description": "How long you slept", "input": "time", "name": "Sleep duration"}]}]})
insert_habit_tool.invoke({"tool_call_id": "uhfuah!", "state": state, "logging": [{'name': 'Gym', 'notes': 'Workout done', 'timestamp': 'today', 'metrics': [{'value': '01:00:00', 'metric_name': 'Duration'}, {'value': '10', 'metric_name': 'Series'}]}]})
