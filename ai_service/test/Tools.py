from ai_tools.habit_tools import InsertHabitDataTool, CreateHabitTool
from test.emulators import send_to_db
CreateHabitTool.invoke({"creation": [{"name": "Sleep", "description": "Habit to track sleep", "goal": "Improve sleep quality", "metrics": [{"input": "time", "description": "Time spent sleeping", "name": "Sleep duration"}, {"input": "rating", "description": "How well you slept", "name": "Sleep quality"}]}]})
InsertHabitDataTool.invoke({"logging": [{'notes': 'Really good sleep.', 'name': 'Sleep', 'timestamp': 'today', 'metrics': {'Sleep Duration': '08:30:00'}}]})
