import json
from typing import Union

from firebase_functions import https_fn
from flask import Response

from ai_setup.graph_logic import run_graph

import logging

from dto.speech_request import HabitInputDTO



from report.report_llm import generate_structured_report

import firebase_admin
from firebase_admin import auth

if not firebase_admin._apps:
    firebase_admin.initialize_app()



@https_fn.on_request()
def process_speech(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        data = request.get_json()

        if not data or 'speech' not in data:
            return https_fn.Response(json.dumps({"error": "Missing 'input' in request"}), status=400,
                                     mimetype='application/json')
        try:
            dto = HabitInputDTO(**data)
        except Exception as e:
            return https_fn.Response(json.dumps({"error": f"Invalid input: {str(e)}"}), status=400,
                                     mimetype='application/json')

        print("Received dto:", dto)
        print("Received data:", data)

        response = run_graph(data)

        print("final output:" + json.dumps(response.get('out', {})))

        return https_fn.Response(json.dumps(response.get('out', {})), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in process_speech")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')

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



'''
@https_fn.on_request()
def process_speech(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        data = request.get_json()

        if not data or 'speech' not in data:
            return https_fn.Response(json.dumps({"error": "Missing 'input' in request"}), status=400,
                                     mimetype='application/json')
        try:
            dto = HabitInputDTO(**data)
        except Exception as e:
            return https_fn.Response(json.dumps({"error": f"Invalid input: {str(e)}"}), status=400,
                                     mimetype='application/json')

        print("Received dto:", dto)
        print("Received data:", data)

        response = run_graph(data)

        print("final output:" + json.dumps(response.get('out', {})))

        return https_fn.Response(json.dumps(response.get('out', {})), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in process_speech")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')

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

        user_name = data.get("name", "User")
        user_bio = data.get("bio", "No bio provided")

        # Generate context from historical chunks
        chunks = extract_habit_chunks(data)
        embed_model = TextEmbeddingModel.from_pretrained("text-embedding-004")
        chunk_embeddings = embed_chunks(chunks)

        query = "Generate a weekly lifestyle report with suggestions."
        top_chunks = get_top_chunks(query, chunks, chunk_embeddings, embed_model)
        history_summary = "\n\n".join(top_chunks)

        context = {
            "history_summary": history_summary,
            "user_info": f"Name: {user_name}\nBio: {user_bio}"
        }

        user_prompt = "Generate my weekly report."
        structured_report = run_report_only(llm, context, user_prompt)

        print("response of the report request: " + json.dumps(structured_report))

        return https_fn.Response(json.dumps(structured_report), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in generate_report")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')
'''