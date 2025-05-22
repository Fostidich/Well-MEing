from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
from vertexai.language_models import TextEmbeddingModel


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
