import json
from typing import Union

from firebase_functions import https_fn
from flask import Response

from ai_setup.graph_logic import run_graph
from ai_setup.llm_setup import initialize_llm

import logging

llm = initialize_llm()


@https_fn.on_request()
def process_speech(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        data = request.get_json()

        if not data or 'speech' not in data:
            return https_fn.Response(json.dumps({"error": "Missing 'input' in request"}), status=400,
                                     mimetype='application/json')

        print("Received data:", data)

        response = run_graph(llm, data)

        print("final output:" + json.dumps(response.get('out', {})))

        return https_fn.Response(json.dumps(response.get('out', {})), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in process_speech")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')

@https_fn.on_request()
def generate_report(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        data = request.get_json()

        print("Received data:", data)

        response_data = {
            "date": "2025-04-30T14:30:30",
            "title": "TEST",
            "content": "laurem ipsum etcetera etcetera..."
        }
        # Convert the Python dictionary to a JSON string
        json_response_body = json.dumps(response_data)

        # Return the JSON response with the correct mimetype
        return https_fn.Response(json_response_body, mimetype='application/json')
    
        #response = run_graph(llm, data)
        #print("final output:" + json.dumps(response.get('out', {})))
        #return https_fn.Response(json.dumps(response.get('out', {})), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in process_speech")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')
