import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from vertexai.language_models import TextEmbeddingModel


# --- Embedding and Helper Functions ---

import numpy as np
import datetime

def parse_time_string(time_str):
    """
    Helper to parse a time string 'HH:MM:SS' into total seconds.
    """
    try:
        h, m, s = map(int, time_str.split(":"))
        return h * 3600 + m * 60 + s
    except Exception:
        return None

def format_seconds_to_hms(seconds):
    """
    Helper to convert total seconds back to 'HH:MM:SS'.
    """
    return str(datetime.timedelta(seconds=int(seconds)))

# This function processes raw user data to create summarized, structured text chunks for each habit.
# These chunks are optimized for embedding and later retrieval.
def extract_habit_chunks(user_data: dict) -> list[str]:
    """
    Takes user data, extracts habit information, and converts it into
    descriptive text chunks suitable for embedding.

    Args:
        user_data: A dictionary containing user habits and their history.

    Returns:
        A list of strings, where each string is a summarized chunk of a habit's data.
    """

    chunks = []
    # Loop through each habit in the user's data.
    for habit_name, habit in user_data.get("habits", {}).items():
        goal = habit.get("goal", "")
        desc = habit.get("description", "")
        history = habit.get("history", [])

        # Skip habits that have no recorded history.
        if not history:
            continue

        # Prepare to accumulate metrics and notes from the history.
        metrics_accum = {}
        notes_list = []

        # Iterate through each historical record of the habit.
        for record in history:
            notes = record.get("notes", "")
            for k, v in record.get("metrics", {}).items():
                metrics_accum.setdefault(k, []).append(v)
            if notes:
                notes_list.append(notes)

        # Calculate summary statistics (average, min, max) for each metric.
        metric_summaries = []
        for k, v_list in metrics_accum.items():
            v_list = [v for v in v_list if v is not None]

            numeric_values = []
            time_values = []
            non_numeric_values = []

            for v in v_list:
                # Try to parse as float
                try:
                    numeric_values.append(float(v))
                    continue
                except (ValueError, TypeError):
                    pass

                # Try to parse as time string
                seconds = parse_time_string(str(v))
                if seconds is not None:
                    time_values.append(seconds)
                else:
                    non_numeric_values.append(v)

            if numeric_values:
                metric_summaries.append(
                    f"{k}: avg {np.mean(numeric_values):.2f}, min {min(numeric_values)}, max {max(numeric_values)}"
                )
            elif time_values:
                avg_sec = np.mean(time_values)
                min_sec = min(time_values)
                max_sec = max(time_values)
                metric_summaries.append(
                    f"{k}: avg {format_seconds_to_hms(avg_sec)}, min {format_seconds_to_hms(min_sec)}, max {format_seconds_to_hms(max_sec)}"
                )
            elif non_numeric_values:
                unique_values = list(dict.fromkeys(non_numeric_values))
                metric_summaries.append(
                    f"{k}: recent values: {', '.join(unique_values[-3:])}"
                )

        metrics_summary = ", ".join(metric_summaries)

        # Get the last few notes to provide recent context.
        recent_notes = "; ".join(notes_list[-3:])  # last few notes

        # Assemble the final text chunk with all the relevant information.
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
    """
    Converts a list of text chunks into numerical embeddings using a pre-trained model.

    Args:
        chunks: The list of text chunks to embed.
        model: An optional pre-initialized embedding model.

    Returns:
        A list of embedding vectors, where each vector corresponds to a chunk.
    """
    # Initialize the embedding model if one isn't provided.
    if model is None:
        model = TextEmbeddingModel.from_pretrained("text-embedding-004")

    # Generate embeddings for the provided text chunks.
    embeddings = model.get_embeddings(chunks)

    # Return the numerical values of the embeddings.
    return [e.values for e in embeddings]

def get_top_chunks(query: str, chunks: list[str], chunk_embeddings: list[list[float]], embed_model, top_k: int = 3) -> list[str]:
    """
    Finds the most relevant text chunks for a given query using cosine similarity.

    Args:
        query: The input query string to find relevant chunks for.
        chunks: The original list of text chunks.
        chunk_embeddings: The pre-computed embeddings for the chunks.
        embed_model: The embedding model to use for the query.
        top_k: The number of top chunks to return.

    Returns:
        A list containing the top_k most relevant chunks.
    """
    # Embed the query to get its vector representation.
    query_embedding = np.array(embed_model.get_embeddings([query])[0].values).reshape(1, -1)

    # Convert the list of chunk embeddings into a NumPy array for efficient computation.
    chunk_embeddings_array = np.array(chunk_embeddings)

    # Calculate the cosine similarity between the query embedding and all chunk embeddings.
    similarities = cosine_similarity(query_embedding, chunk_embeddings_array).flatten()

    # Get the indices of the chunks with the highest similarity scores.
    top_indices = similarities.argsort()[::-1][:top_k]

    # Return the original text chunks corresponding to the top indices.
    return [chunks[i] for i in top_indices]