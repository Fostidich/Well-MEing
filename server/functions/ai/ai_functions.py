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

# Define a constant for the token usage limit per user.
TOKEN_USAGE_LIMIT = 100000

# This decorator registers the function as an HTTP-triggered Cloud Function.
# It will execute whenever a request is made to its public URL.
@https_fn.on_request()
def process_speech(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    """
    Handles speech processing requests. It validates user input, checks token usage,
    runs the core AI logic, and returns a structured response.
    """
    try:
        # Retrieve the JSON payload from the incoming request.
        input_data: dict = request.get_json()
        if input_data is None:
            return Response(json.dumps({"error": "Missing JSON body"}), status=400,
                            mimetype='application/json; charset=utf-8')
        
        # Authenticate the user and add their ID to the input data.
        input_data['user_id'] = get_authenticated_user_id(request)

        print(input_data)

        # --- Usage Limit Check ---
        # Get a reference to the user's token count in the Firebase database.
        token_count_ref = db.reference(f'users/{input_data['user_id']}/usage/tokens')
        token_count = token_count_ref.get()

        if token_count and token_count > TOKEN_USAGE_LIMIT:
            return Response(json.dumps({"error": "Exceeded token limit"}), status=429,
                            mimetype='application/json; charset=utf-8')
        
        # --- Data Validation using Pydantic ---
        # Validate the structure and types of the input data against the DTO.
        try:
            dto_input = HabitInputDTO(**input_data)
        except ValidationError as e:
            return Response(json.dumps({"error": "Invalid input format"}), status=400,
                            mimetype='application/json; charset=utf-8')

        # --- Core Logic ---
        # Execute the main application logic (e.g., an AI graph) with the validated data.
        response = run_graph(dto_input.model_dump())

        # --- Output Validation ---
        # Extract the primary output from the response.
        out = response.get('out', {})
        print(out)

        # Validate the structure of the output from the core logic.
        try:
            dto_out = HabitOutputDTO(**out)
        except ValidationError as e:
            return Response(json.dumps({"error": "Invalid output format"}), status=400,
                            mimetype='application/json; charset=utf-8')

        # --- Success Response ---
        # On success, return the validated output as a JSON response.
        return Response(dto_out.model_dump_json(), mimetype='application/json; charset=utf-8')

    except Exception as e:
        error_payload = {"error": "An internal error occurred. Please try again later."}
        return Response(json.dumps(error_payload), status=500,
                        mimetype='application/json; charset=utf-8')


# This decorator registers the function as an HTTP-triggered Cloud Function.
# It will execute whenever a request is made to its public URL.
@https_fn.on_request()
def generate_report(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    """
    Generates a structured wellness report for an authenticated user based on their data.
    """
    try:
        # --- Authentication ---
        # Get the 'Authorization' header from the request.
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return https_fn.Response(
                json.dumps({"error": "Missing or invalid Authorization header."}),
                status=401,
                mimetype='application/json'
            )

        # Extract the token from the "Bearer <token>" string.
        id_token = auth_header.split("Bearer ")[1]
        # Verify the Firebase ID token to authenticate the user.
        decoded_token = auth.verify_id_token(id_token)
        # Get the user's unique ID from the decoded token.
        user_id = decoded_token['uid']
        print("User ID:", user_id)

        # Get the user data payload from the request body.
        data = request.get_json()
        print("Received data:", data)

        # Call the function to generate the report, passing the user data and ID.
        structured_report = generate_structured_report(data, user_id)

        print("final report: " + json.dumps(structured_report))

        # --- Success Response ---
        # Return the generated report as a JSON response.
        return https_fn.Response(json.dumps(structured_report), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in generate_report")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')
