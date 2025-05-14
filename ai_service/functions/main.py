import json
from typing import Union

from firebase_functions import https_fn
from flask import Response

from ai_setup.graph_logic import run_graph


import logging
from vertexai.language_models import TextEmbeddingModel





@https_fn.on_request()
def process_speech(request: https_fn.Request) -> Union[Response, tuple[Response, int]]:
    try:
        data = request.get_json()

        if not data or 'speech' not in data:
            return https_fn.Response(json.dumps({"error": "Missing 'input' in request"}), status=400,
                                     mimetype='application/json')

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


        #response = run_graph(llm, data)
        #print("final output:" + json.dumps(response.get('out', {})))
        return https_fn.Response(json.dumps(response.get('out', {})), mimetype='application/json')

    except Exception as e:
        logging.exception("Error in generate_report")
        error_payload = {"error": f"An internal error occurred: {str(e)}"}
        return https_fn.Response(json.dumps(error_payload), status=500, mimetype='application/json')
