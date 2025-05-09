import json

from firebase_functions import https_fn
from flask import Response

from ai_setup.graph_logic import run_graph
from ai_setup.llm_setup import initialize_llm

llm = initialize_llm()

@https_fn.on_request()
def langgraph_handler(request: https_fn.Request) -> tuple[Response, int] | Response:

    try:
        data = request.get_json()

        # Run the LangGraph logic
        response = run_graph(llm, data)

        return https_fn.Response(json.dumps(response['out']), mimetype='application/json')
    except Exception as e:
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')