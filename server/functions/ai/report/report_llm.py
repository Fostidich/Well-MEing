import json
from datetime import datetime, timedelta

from firebase_admin import db
from google.genai import types
from pydantic import BaseModel
from vertexai.language_models import TextEmbeddingModel

from google import genai

from ai.report.embeddings import extract_habit_chunks, embed_chunks, get_top_chunks

# Initialize the Generative AI client with project and location details.
client = genai.Client(vertexai=True, project='well-meing', location='us-central1')

# Defines the expected structure of the generated report using Pydantic for validation.
class ReportStructure(BaseModel):
    title: str
    content: str


def save_report_to_db(timestamp, report, user_id):
    """
    Saves the generated report to the Firebase Realtime Database and updates the next report date.

    Args:
        timestamp: The ISO format timestamp for the report.
        report: The structured report data (title and content).
        user_id: The ID of the user to save the report for.

    Returns:
        A dictionary indicating success or failure.
    """
    try:
        # Create a database reference to the specific path for the new report.
        report_ref = db.reference(f'users/{user_id}/reports/{timestamp}')

        # Save the report data at that location.
        report_ref.set(report)

        # Calculate the date for the next report (7 days from now, at midnight).
        next_week = (datetime.now() + timedelta(days=7)).replace(hour=0, minute=0, second=0, microsecond=0)
        next_report_date_str = next_week.isoformat()

        # Update the 'newReportDate' field
        user_ref = db.reference(f'users/{user_id}')
        user_ref.update({"newReportDate": next_report_date_str})

        return {"success": True, "report_id": timestamp}
    except Exception as e:
        print("Error saving report to DB:", e)
        return {"success": False, "error": str(e)}

def generate_structured_report(data, user_id):
    """
    Main function to generate a personalized wellness report for a user.
    It extracts data, finds relevant context using embeddings, calls the Gemini API,
    and saves the result to the database.

    Args:
        data: A dictionary containing the user's name, bio, and habits data.
        user_id: The unique identifier for the user.

    Returns:
        A dictionary containing the structured report (date, title, content).
    
    Raises:
        RuntimeError: If saving the report to the database fails.
    """
    print("Received data:", data)

    # Extract basic user information.
    user_name = data.get("name", "User")
    user_bio = data.get("bio", "No bio provided")

    # Process user data into summarized chunks.
    chunks = extract_habit_chunks(data)
    embed_model = TextEmbeddingModel.from_pretrained("text-embedding-004")
    chunk_embeddings = embed_chunks(chunks)

    # Define a query to find the most relevant habit data from the past week.
    query = (
                "Identify recent habit records that reflect key behavioral patterns "
                "(improvement, decline, or consistency) in the past week across all tracked metrics."
                " Prioritize habits with user notes or significant metric changes."
            )
    top_chunks = get_top_chunks(query, chunks, chunk_embeddings, embed_model)
    history_summary = "\n\n".join(top_chunks)

    context = {
        "history_summary": history_summary,
        "user_info": f"Name: {user_name}\nBio: {user_bio}"
    }

    # Make a request to the Gemini model to generate the report.
    response = client.models.generate_content(
        model='gemini-2.5-flash-preview-05-20',
        contents='high',
        config=types.GenerateContentConfig(
            system_instruction = f"""
                Generate a concise, engaging wellness report based on the user's recent habits and goals.

                ### Format and Style Guidelines:

                - **Title**:
                - Must summarize the main insight or change.
                - Max 50 characters.
                - Avoid generic phrases like "wellness journey", "progress", or "snapshot".
                - Do **not** include the user's name.
                - Be specific (e.g., "Sleep Hours Improved by 20%", "High Water Intake But Low Activity").

                - **Sections (Use Markdown and Apple Emojis for better readability)**:
                - **Overview**: A DETAILED summary of key trends using also bullet points.
                - **Insights**:
                    - Use 4-8 bullet points.
                - **Suggestions**:
                    - 4-8 actionable tips.
                    - Use simple sentences or bullet format.

                - **Tone**:
                - Friendly, professional, and supportive.
                - Use **bold** for important metrics or alerts.
                - Prefer short paragraphs or bullets over long text.
                - Important points should be bolded.

                - If data is missing, make helpful assumptions but mention them gently.
                - Don't repeat the title in the content.

                Use the following context:
                {context.get("history_summary", "No detailed context provided.")},
                {context.get("user_info", "No user info provided.")}
                """,
            max_output_tokens=10000,
            temperature=0.3, # A lower temperature for more predictable and less creative output.
            response_mime_type='application/json', # Instruct the model to return a JSON object.
            response_schema=ReportStructure, # Enforce the Pydantic schema on the output.
            safety_settings=[
                types.SafetySetting(
                    category='HARM_CATEGORY_UNSPECIFIED',
                    threshold='BLOCK_ONLY_HIGH',
                )
            ]
        ),
    )

    print("response candidate 0: " + response.candidates[0].content.parts[0].text)

    # Extract the JSON string from the model's response.
    candidate = response.candidates[0]
    report_json_string = candidate.content.parts[0].text
    report_data = json.loads(report_json_string)

    # Get title and content from the parsed JSON.
    report_title = report_data.get('title', 'Untitled Report')
    report_content = report_data.get('content', 'No content provided.')

    # Create a timestamp for the report.
    timestamp = datetime.now().replace(microsecond=0).isoformat()

    # Structure the report for saving to the database.
    structured_report = {
        "title": report_title,
        "content": report_content
    }

    # Save the report to Firebase.
    save_result = save_report_to_db(timestamp, structured_report, user_id)

    # Prepare the final report object to be returned to the client.
    structured_report = {
        "date": timestamp,
        "title": report_title,
        "content": report_content
    }

    if not save_result["success"]:
        # Handle DB error here (log, raise, etc.)
        # You can choose to raise an exception or return it up the stack
        raise RuntimeError(f"Failed to save report: {save_result['error']}")

    # Optionally attach report ID to the return value
    # structured_report["report_id"] = save_result["report_id"]

    return structured_report