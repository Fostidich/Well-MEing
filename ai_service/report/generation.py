from typing import Dict, Any

from test.emulators import get_report_json
from report.metric_preprocessing import extract_metrics, extract_metrics_features
from report.report_building import report_llm

report_json = get_report_json()


def generate_report(report_json: Dict[str, Any]) -> str:
    metrics_data = extract_metrics(report_json)
    metrics_features = extract_metrics_features(metrics_data)
    report = report_llm(metrics_features)
    return report
metrics_data = extract_metrics(report_json)

print(metrics_data)