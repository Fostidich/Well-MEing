from ai.ai_setup.graph_logic import run_graph
from ai.dto.speech_client_to_server import HabitInputDTO
from ai.dto.speech_server_to_client import HabitOutputDTO

data = {
    "speech":
        "Create a habit to track how I'm feeling with options hungry, happy, angry, curious, currently i'm feeling happy and curious",
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


data = {'speech': 'track how many beers I drink daily', 'habits': {'New habit 1': {'metrics': {'New metric 1': {'input': 'slider'}}}, 'New habit 4': {'history': [{'timestamp': '2025-05-15T18:20:58'}]}}}
dto_input = HabitInputDTO(**data)
print(dto_input.model_dump())
response = run_graph(dto_input.model_dump())
out = response.get('out', {})
print(response.get('context'))
dto_out = HabitOutputDTO(**out)
print(dto_out)
for message in response['messages']:
    message.pretty_print()
print(response['out'])
print(response['context'])
