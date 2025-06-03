import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from vertexai.language_models import TextEmbeddingModel


# preparing habits in order to be correctly embedded
def extract_habit_chunks(user_data: dict) -> list[str]:
    chunks = []
    for habit_name, habit in user_data.get("habits", {}).items():
        goal = habit.get("goal", "")
        desc = habit.get("description", "")
        history = habit.get("history", [])

        if not history:
            continue

        # Compute summary values
        metrics_accum = {}
        notes_list = []

        for record in history:
            notes = record.get("notes", "")
            for k, v in record.get("metrics", {}).items():
                metrics_accum.setdefault(k, []).append(v)
            if notes:
                notes_list.append(notes)

        metrics_summary = ", ".join(
            [f"{k}: avg {np.mean(v):.2f}, min {min(v)}, max {max(v)}" for k, v in metrics_accum.items()]
        )
        recent_notes = "; ".join(notes_list[-3:])  # last few notes

        chunk = (
            f"Habit: {habit_name}\n"
            f"Goal: {goal}\n"
            f"Description: {desc}\n"
            f"Summary of metrics: {metrics_summary}\n"
            f"Recent notes: {recent_notes}"
        )
        chunks.append(chunk)
    return chunks


def embed_chunks(chunks: list[str], model=None) -> list[list[float]]:
    if model is None:
        model = TextEmbeddingModel.from_pretrained("text-embedding-004")
    embeddings = model.get_embeddings(chunks)
    return [e.values for e in embeddings]

def get_top_chunks(query: str, chunks: list[str], chunk_embeddings: list[list[float]], embed_model, top_k: int = 3) -> list[str]:
    query_embedding = np.array(embed_model.get_embeddings([query])[0].values).reshape(1, -1)
    chunk_embeddings_array = np.array(chunk_embeddings)
    similarities = cosine_similarity(query_embedding, chunk_embeddings_array).flatten()
    top_indices = similarities.argsort()[::-1][:top_k]
    return [chunks[i] for i in top_indices]