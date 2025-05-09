from typing import Dict, Any

from report.metric_preprocessing import extract_metrics, extract_metrics_features
from report.report_building import report_llm
from test.emulators import get_report_json

report_json = get_report_json()

from dotenv import load_dotenv
from langchain_core.messages import SystemMessage
from langchain_google_vertexai.chat_models import ChatVertexAI

load_dotenv()

llm = ChatVertexAI(model_name="gemini-2.0-flash-001")

innit_prompt = SystemMessage(
    content=("""
You are a AI assistant which give analysis of data regarding habits of user.
"""))


def generate_report(report_json: Dict[str, Any]) -> str:
    metrics_data = extract_metrics(report_json)
    metrics_features = extract_metrics_features(metrics_data)
    report = report_llm(metrics_features)
    return report


metrics_data = extract_metrics(report_json)

print(metrics_data)
