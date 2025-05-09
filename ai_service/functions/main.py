import json
from typing import Union

from firebase_functions import https_fn
from flask import Response

from ai_setup.graph_logic import run_graph
from ai_setup.llm_setup import initialize_llm

llm = initialize_llm()


@https_fn.on_request()
def langgraph_handler(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        data = request.get_json()

        if not data or 'input' not in data:
            return https_fn.Response(json.dumps({"error": "Missing 'input' in request"}), status=400,
                                     mimetype='application/json')

        response = run_graph(llm, data)

        return https_fn.Response(json.dumps(response.get('out', {})), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in langgraph_handler")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')
