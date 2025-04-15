from ai_tools.habit_tools import InsertHabitDataTool, CreateHabitTool
CreateHabitTool.invoke({
    "creation": [
        {
            "name": "Running",
            "description": "Track my running habits.",
            "goal": "Run 5 km every day.",
            "metrics": [
                {
                    "name": "Distance",
                    "description": "Distance covered in kilometers.",
                    "input": "slider",
                    "config": {
                        "type": "float",
                        "min": 0,
                        "max": 10
                    }
                }
            ]
        }
    ]
})

InsertHabitDataTool.invoke({
    "logging": [
        {
            "timestamp": "2023-10-01T07:30:00",
            "name": "Running",
            "notes": "Morning run felt great!",
            "metrics": {
                "Distance": 5.2  # Distance in kilometers
            }
        }
    ]
})