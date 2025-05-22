from firebase_admin import initialize_app

from ai.ai_functions import process_speech, generate_report
from db.db_functions import create_habit, delete_habit, create_submission, delete_submission, update_name, update_bio, delete_report

initialize_app()

__all__ = ["process_speech", "generate_report", "create_habit", "delete_habit", "create_submission", "delete_submission", "update_name", "update_bio", "delete_report"]