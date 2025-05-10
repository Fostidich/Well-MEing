from typing import Dict, Any

from report.metric_preprocessing import HabitManager
from report.feature_extraction import extract_metrics_features
from report.report_building import report_llm
from test.emulators import get_report_json
from dotenv import load_dotenv
from langchain_core.messages import SystemMessage
from langchain_google_vertexai.chat_models import ChatVertexAI


def generate_report(report_json: Dict[str, Any]) -> str:
    metrics_data = HabitManager(report_json).habits
    metrics_features = extract_metrics_features(metrics_data)
    report = report_llm(metrics_features)
    return report


report_json = {
    "name": "Leone",
    "bio": "I like going to the gym, and I'd like to hit 100 kg on bench press one day",
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
                },
                "id-3001": {
                    "timestamp": "2025-03-29T08:00:00",
                    "metrics": {
                        "Distance": 8,
                        "Duration": "00:50:00"
                    }
                },
                "id-3002": {
                    "timestamp": "2025-03-30T09:15:00",
                    "notes": "Morning run felt great",
                    "metrics": {
                        "Distance": 15,
                        "Duration": "01:45:00"
                    }
                },
                "id-3003": {
                    "timestamp": "2025-04-01T17:20:00",
                    "metrics": {
                        "Distance": 5,
                        "Duration": "00:35:00"
                    }
                },
                "id-3004": {
                    "timestamp": "2025-04-03T12:30:00",
                    "metrics": {
                        "Distance": 6,
                        "Duration": "00:40:00"
                    }
                },
                "id-3005": {
                    "timestamp": "2025-04-04T07:00:00",
                    "notes": "Ran with a friend",
                    "metrics": {
                        "Distance": 9,
                        "Duration": "01:00:00"
                    }
                },
                "id-3006": {
                    "timestamp": "2025-04-05T18:30:00",
                    "metrics": {
                        "Distance": 11,
                        "Duration": "01:15:00"
                    }
                },
                "id-3007": {
                    "timestamp": "2025-04-06T10:00:00",
                    "metrics": {
                        "Distance": 7,
                        "Duration": "00:48:00"
                    }
                },
                "id-3008": {
                    "timestamp": "2025-04-07T19:00:00",
                    "notes": "Hilly terrain, quite challenging",
                    "metrics": {
                        "Distance": 10,
                        "Duration": "01:10:00"
                    }
                },
                "id-3009": {
                    "timestamp": "2025-04-08T13:00:00",
                    "metrics": {
                        "Distance": 13,
                        "Duration": "01:30:00"
                    }
                }
            }
        },
        "Food": {
            "description": "Log the food you eat",
            "goal": "I want to eat max 2000 kcal per day",
            "metrics": {
                "Calorie intake": {
                    "description": "How many calories did this food have?",
                    "input": "slider",
                    "config": {
                        "type": "int",
                        "min": 0,
                        "max": 5000
                    }
                },
                "Satifisaction": {
                    "description": "Did you enjoy this meal?",
                    "input": "rating"
                }
            },
            "history": {
                "id-1234": {
                    "timestamp": "2025-03-26T15:30:00",
                    "notes": "Today I ate a lot",
                    "metrics": {
                        "Calorie intake": 2200
                    }
                },
                "id-2345": {
                    "timestamp": "2025-03-21T13:30:00",
                    "notes": "The pasta was good",
                    "metrics": {
                        "Calorie intake": 2100
                    }
                },
                "id-4001": {
                    "timestamp": "2025-03-28T12:45:00",
                    "metrics": {
                        "Calorie intake": 1800,
                        "Satifisaction": 4
                    }
                },
                "id-4002": {
                    "timestamp": "2025-03-29T13:00:00",
                    "notes": "Quick lunch with salad and tuna",
                    "metrics": {
                        "Calorie intake": 1500,
                        "Satifisaction": 3
                    }
                },
                "id-4003": {
                    "timestamp": "2025-03-30T14:30:00",
                    "metrics": {
                        "Calorie intake": 2300,
                        "Satifisaction": 5
                    }
                },
                "id-4004": {
                    "timestamp": "2025-03-31T20:00:00",
                    "metrics": {
                        "Calorie intake": 1700
                    }
                },
                "id-4005": {
                    "timestamp": "2025-04-01T19:00:00",
                    "notes": "Felt bloated afterwards",
                    "metrics": {
                        "Calorie intake": 2500,
                        "Satifisaction": 2
                    }
                },
                "id-4006": {
                    "timestamp": "2025-04-02T13:30:00",
                    "metrics": {
                        "Calorie intake": 1950,
                        "Satifisaction": 4
                    }
                },
                "id-4007": {
                    "timestamp": "2025-04-03T14:15:00",
                    "metrics": {
                        "Calorie intake": 2000,
                        "Satifisaction": 5
                    }
                },
                "id-4008": {
                    "timestamp": "2025-04-04T18:45:00",
                    "metrics": {
                        "Calorie intake": 1600,
                        "Satifisaction": 3
                    }
                },
                "id-4009": {
                    "timestamp": "2025-04-05T12:00:00",
                    "notes": "Had fast food, tasted good but felt guilty",
                    "metrics": {
                        "Calorie intake": 2800,
                        "Satifisaction": 5
                    }
                },
                "id-4010": {
                    "timestamp": "2025-04-06T14:00:00",
                    "metrics": {
                        "Calorie intake": 1850,
                        "Satifisaction": 4
                    }
                }
            }
        }
    }
}

metrics_data = HabitManager(report_json).to_dict()

print(metrics_data)
