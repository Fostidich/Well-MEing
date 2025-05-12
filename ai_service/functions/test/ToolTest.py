from uuid import uuid4

from ai_tools.habit_tools import create_habit_tool

state = {"context": {"habits": {"Running": {"description": "Go for a run in your free time"}}}}
create_habit_tool.invoke({"tool_call_id": uuid4(), "state": state, "creation": [{"metrics": [
    {"description": "Kilometers", "input": "slider", "config": {"type": "float", "min": 0.0, "max": 10.0},
     "name": "Distance"}, {"input": "time", "description": "Time spent running", "name": "Duration"}],
                                                                                 "description": "Training for PolimiRun",
                                                                                 "goal": "Run 3 times a week",
                                                                                 "name": "Running"}]})
