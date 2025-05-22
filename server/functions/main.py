from firebase_admin import initialize_app

from ai.ai_functions import process_speech, generate_report

initialize_app()

__all__ = ["process_speech", "generate_report"]
