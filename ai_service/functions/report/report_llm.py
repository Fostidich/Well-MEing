import json
from ai_setup.llm_setup import client

from vertexai.language_models import TextEmbeddingModel
from report.embeddings import extract_habit_chunks, embed_chunks, get_top_chunks
from datetime import datetime
from google.genai import types
from pydantic import BaseModel

class ReportStructure(BaseModel):
    title: str
    content: str



def generate_structured_report(data):
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

    response = client.models.generate_content(
        model='gemini-2.5-flash-preview-05-20',
        contents='high',
        config=types.GenerateContentConfig(
            system_instruction=f"""
                Generate a detailed weekly wellness report with advices based on user's habits and goals.
                Title must be personalized based on the progress described in the content.
                Content must not contain the title.
                If information is missing, make reasonable assumptions.
                Use Apple emojis in order to enhance the report visually and make it more engaging.
                **IMPORTANT**: Format the content in Markdown.
                No emojis in titles, use '-' for pointed lists.
                The report should have these sections, with no extra wrapping text: "Overview", "Analysis", "Suggestions".
                Prefer plain text paragraphs rather than pointed lists.
                Use the following context:
                {context.get("history_summary", "No detailed context provided.")},
                {context.get("user_info", "No user info provided.")}
            """,
            max_output_tokens=10000,
            temperature=0.3,
            response_mime_type='application/json',
            response_schema=ReportStructure,
            safety_settings=[
                types.SafetySetting(
                    category='HARM_CATEGORY_UNSPECIFIED',
                    threshold='BLOCK_ONLY_HIGH',
                )
            ]
        ),
    )

    print("response: " + response.text)
    print("response candidate 0: " + response.candidates[0].content.parts[0].text)

    candidate = response.candidates[0]
    report_json_string = candidate.content.parts[0].text
    report_data = json.loads(report_json_string)

    report_title = report_data.get('title', 'Untitled Report')
    report_content = report_data.get('content', 'No content provided.')

    structured_report = {
        "date": datetime.now().replace(microsecond=0).isoformat(),
        "title": report_title,
        "content": report_content
    }

    return structured_report
    