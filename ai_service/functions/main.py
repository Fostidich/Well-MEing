import json
from typing import Union

from firebase_functions import https_fn
from flask import Response
from pydantic import ValidationError

from ai_setup.graph_logic import run_graph, run_report_graph

import logging
from vertexai.language_models import TextEmbeddingModel

from ai_setup.llm_setup import llm
from dto.speech_client_to_server import HabitInputDTO
from dto.speech_server_to_client import HabitOutputDTO
from report.embeddings import extract_habit_chunks, embed_chunks, get_top_chunks

logging.basicConfig(
    level=logging.DEBUG,  # or INFO if you want less verbosity
    format='%(asctime)s [%(levelname)s] %(message)s',
)

@https_fn.on_request()
def process_speech(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        input_data: dict = request.get_json()
        if input_data is None:
            return Response(json.dumps({"error": "Missing JSON body"}), status=400,
                            mimetype='application/json; charset=utf-8')

        logging.info("Received input JSON")
        print(input_data)
        # Validate input
        try:
            dto_input = HabitInputDTO(**input_data)
        except ValidationError as e:
            logging.exception("Input validation error")
            return Response(json.dumps({"error": "Invalid input format"}), status=400,
                            mimetype='application/json; charset=utf-8')

        logging.info("Input JSON validated successfully")

        # Run your graph logic
        response = run_graph(dto_input.model_dump())

        # Validate output
        out = response.get('out', {})
        print(out)
        try:
            dto_out = HabitOutputDTO(**out)
        except ValidationError as e:
            logging.exception("Output validation error")
            return Response(json.dumps({"error": "Invalid output format"}), status=400,
                            mimetype='application/json; charset=utf-8')

        logging.info("Output JSON validated successfully")
        logging.debug("Final output: %s", dto_out.model_dump_json())

        return Response(dto_out.model_dump_json(), mimetype='application/json; charset=utf-8')

    except Exception as e:
        logging.exception("Unhandled error in process_speech")
        error_payload = {"error": "An internal error occurred. Please try again later."}
        return Response(json.dumps(error_payload), status=500,
                        mimetype='application/json; charset=utf-8')


@https_fn.on_request()
def generate_report(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        data = request.get_json()

        print("Received data:", data)

        chunks = extract_habit_chunks(data)
        embed_model = TextEmbeddingModel.from_pretrained("text-embedding-004")
        chunk_embeddings = embed_chunks(chunks)

        query = "Generate a weekly lifestyle report with suggestions."
        top_chunks = get_top_chunks(query, chunks, chunk_embeddings, embed_model)
        history_summary = "\n\n".join(top_chunks)

        context = {"history_summary": history_summary}

        user_prompt = "Generate my weekly report."
        response = run_report_graph(llm, context, user_prompt)

        print("response of the report request: " + json.dumps(response.get('out', {})))

        # response = run_graph(llm, data)
        # print("final output:" + json.dumps(response.get('out', {})))
        return https_fn.Response(json.dumps(response.get('out', {})), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in generate_report")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')
