import json
import logging
from typing import Union

from firebase_admin import auth, db
from firebase_functions import https_fn
from flask import Response
from pydantic import ValidationError

from ai.ai_setup.graph_logic import run_graph
from ai.dto.speech_client_to_server import HabitInputDTO
from ai.dto.speech_server_to_client import HabitOutputDTO
from ai.report.report_llm import generate_structured_report
from db.db_functions import get_authenticated_user_id

TOKEN_USAGE_LIMIT = 100000

@https_fn.on_request()
def process_speech(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        input_data: dict = request.get_json()
        if input_data is None:
            return Response(json.dumps({"error": "Missing JSON body"}), status=400,
                            mimetype='application/json; charset=utf-8')
        input_data['user_id'] = get_authenticated_user_id(request)

        print(input_data)

        token_count_ref = db.reference(f'users/{input_data['user_id']}/usage/tokens')
        token_count = token_count_ref.get()

        if token_count and token_count > TOKEN_USAGE_LIMIT:
            return Response(json.dumps({"error": "Exceeded token limit"}), status=429,
                            mimetype='application/json; charset=utf-8')
        # Validate input
        try:
            dto_input = HabitInputDTO(**input_data)
        except ValidationError as e:
            return Response(json.dumps({"error": "Invalid input format"}), status=400,
                            mimetype='application/json; charset=utf-8')

        # Run your graph logic
        response = run_graph(dto_input.model_dump())

        # Validate output
        out = response.get('out', {})
        print(out)
        try:
            dto_out = HabitOutputDTO(**out)
        except ValidationError as e:
            return Response(json.dumps({"error": "Invalid output format"}), status=400,
                            mimetype='application/json; charset=utf-8')

        return Response(dto_out.model_dump_json(), mimetype='application/json; charset=utf-8')

    except Exception as e:
        error_payload = {"error": "An internal error occurred. Please try again later."}
        return Response(json.dumps(error_payload), status=500,
                        mimetype='application/json; charset=utf-8')


@https_fn.on_request()
def generate_report(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        # Get and verify the Firebase ID token
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return https_fn.Response(
                json.dumps({"error": "Missing or invalid Authorization header."}),
                status=401,
                mimetype='application/json'
            )

        id_token = auth_header.split("Bearer ")[1]
        decoded_token = auth.verify_id_token(id_token)
        user_id = decoded_token['uid']
        print("User ID:", user_id)

        data = request.get_json()
        print("Received data:", data)

        structured_report = generate_structured_report(data, user_id)

        print("final report: " + json.dumps(structured_report))

        return https_fn.Response(json.dumps(structured_report), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in generate_report")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')
