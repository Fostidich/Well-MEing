import json
from typing import Union

from firebase_functions import https_fn
from flask import Response

from ai_setup.graph_logic import run_graph
from ai_setup.llm_setup import initialize_llm

import logging
from vertexai.language_models import TextEmbeddingModel
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np




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


# preparing habits in order to be correctly embedded
def extract_habit_chunks(user_data: dict) -> list[str]:
    chunks = []
    for habit_name, habit in user_data.get("habits", {}).items():
        goal = habit.get("goal", "")
        desc = habit.get("description", "")
        history = habit.get("history", {})
        metrics_summary = []

        for record in history:
            timestamp = record.get("timestamp", "")
            notes = record.get("notes", "")
            metrics = ", ".join([f"{k}: {v}" for k, v in record.get("metrics", {}).items()])
            summary = f"Date: {timestamp}, Metrics: {metrics}, Notes: {notes}"
            metrics_summary.append(summary)

        chunk = f"Habit: {habit_name}\nGoal: {goal}\nDescription: {desc}\nHistory:\n" + "\n".join(metrics_summary)
        chunks.append(chunk)
    return chunks

def embed_chunks(chunks: list[str]) -> list[list[float]]:
    model = TextEmbeddingModel.from_pretrained("text-embedding-004")
    embeddings = model.get_embeddings(chunks)
    return [e.values for e in embeddings]  # Extract float vectors

def get_top_chunks(query: str, chunks: list[str], chunk_embeddings: list[list[float]], embed_model) -> list[str]:
    query_embedding = np.array(embed_model.get_embeddings([query])[0].values).reshape(1, -1)
    chunk_embeddings_array = np.array(chunk_embeddings)
    similarities = cosine_similarity(query_embedding, chunk_embeddings_array).flatten()
    top_indices = similarities.argsort()[::-1][:3]
    return [chunks[i] for i in top_indices]

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
