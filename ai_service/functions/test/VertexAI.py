from ai_setup.graph_logic import run_graph


data = {
    "speech":
        "Create a habit to track how I'm feeling with options hungry, happy, angry, curious, currently i'm feeling sad and motivated",
    "habits": {
        "Running": {
            "description": "Go for a run in your free time",
            "goal": "I want to run 3 times a week in order to train for PolimiRun",
            "metrics": {
                "Distance": {
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

#data = {'habits': {'New habit 2': {'goal': 'Goal', 'metrics': {'New metric 1': {'config': {'boxes': ['Culo', 'Gesù']}, 'description': 'N’Djamena', 'input': 'form'}, 'New metric 3': {'input': 'slider'}, 'New metric 2': {'config': {'type': 'float'}, 'input': 'slider'}}, 'description': 'Dead'}, 'New habit 1': {'metrics': ''}}, 'speech': "Hi I'd like to count how many keys on the piano I have tapped today"}
response = run_graph(data)

for message in response['messages']:
    message.pretty_print()
print(response['out'])
print(response['context'])
