from ai_setup.graph_logic import run_graph
from ai_setup.llm_setup import initialize_llm

data = {
    "speech":
        "Voglio tracciare il numero di peli che taglio dela barba, inserisci che oggi ne ho tagliati 12",
    "context": {
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
}

llm = initialize_llm()
response = run_graph(llm, data)

for message in response['messages']:
    message.pretty_print()
print(response['out'])
print(response['context'])
