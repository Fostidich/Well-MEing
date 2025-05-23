import firebase_admin
from firebase_admin import initialize_app, credentials

from ai.ai_setup.graph_logic import run_graph
from ai.dto.speech_client_to_server import HabitInputDTO
from ai.dto.speech_server_to_client import HabitOutputDTO
from langchain_core.callbacks import UsageMetadataCallbackHandler

callback = UsageMetadataCallbackHandler()
cred = credentials.Certificate(
    r"C:\Users\white\Progetti\On Going\dont_push_these\well-meing-firebase-adminsdk-fbsvc-eb93f60fde.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://well-meing-default-rtdb.europe-west1.firebasedatabase.app/'
})

data = {'speech': 'track how many beers I drink daily',
        'habits': {'New habit 1': {'metrics': {'New metric 1': {'input': 'slider'}}},
                   'New habit 4': {'history': [{'timestamp': '2025-05-15T18:20:58'}]}},
        'user_id': '3fZ8nRv1W4XMWo8KkePWPdFYnJr1'}


dto_input = HabitInputDTO(**data)
# print(dto_input.model_dump())
response = run_graph(dto_input.model_dump())
# print(response.get("messages")[-1])
# (response.get("messages")[-1].usage_metadata.get("total_tokens", 0))
out = response.get('out', {})
# print(response.get('context'))
dto_out = HabitOutputDTO(**out)
# print(dto_out.model_dump())
