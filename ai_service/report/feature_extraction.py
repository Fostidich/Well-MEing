import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from collections import Counter
from scipy.stats import linregress, entropy
import re


def extract_cadence_features(timestamps):
    deltas = [(t2 - t1).total_seconds() / 3600 for t1, t2 in zip(timestamps[:-1], timestamps[1:])]
    if len(deltas) < 2:
        return "irregular"
    median_delta = np.median(deltas)
    std_delta = np.std(deltas)

    if std_delta < 12:
        if median_delta < 12:
            return "multi-daily"
        elif median_delta < 36:
            return "daily"
        elif median_delta < 216:
            return "weekly"
    return "irregular"


def extract_numeric_features(data, cadence):
    values = [v for _, v in data]
    timestamps = [datetime.fromisoformat(t) for t, _ in data]
    times = np.array([t.timestamp() for t in timestamps])

    trend = linregress(times, values).slope if len(values) > 1 else 0

    return {
        "mean": np.mean(values),
        "std": np.std(values),
        "min": np.min(values),
        "max": np.max(values),
        "range": np.ptp(values),
        "trend": trend,
        "count": len(values)
    }


def extract_str_features(data):
    texts = [v for _, v in data]
    word_counts = [len(re.findall(r'\w+', text)) for text in texts]
    unique_words = len(set(" ".join(texts).split()))
    total_words = sum(word_counts)

    return {
        "avg_text_length": np.mean(word_counts),
        "text_std": np.std(word_counts),
        "lexical_richness": unique_words / total_words if total_words > 0 else 0
    }


def extract_form_features(data):
    entries = [v.split(', ') for _, v in data]
    flat_entries = [e for sublist in entries for e in sublist]
    counts = Counter(flat_entries)
    most_common = counts.most_common(3)
    switches = sum(1 for i in range(1, len(entries)) if entries[i] != entries[i-1])

    return {
        "top_categories": most_common,
        "category_entropy": entropy(list(counts.values())),
        "switch_rate": switches / len(entries) if len(entries) > 1 else 0
    }


def extract_time_features(data, cadence):
    durations = [sum(x * int(t) for x, t in zip([3600, 60, 1], v.split(':'))) for _, v in data]
    timestamps = [datetime.fromisoformat(t) for t, _ in data]
    times = np.array([t.timestamp() for t in timestamps])

    trend = linregress(times, durations).slope if len(durations) > 1 else 0

    return {
        "mean_duration": np.mean(durations),
        "std_duration": np.std(durations),
        "min_duration": np.min(durations),
        "max_duration": np.max(durations),
        "trend": trend,
        "count": len(durations)
    }


def analyze_metrics(dataset):
    results = {}
    for dtype, metrics in dataset.items():
        for metric_name, entries in metrics.items():
            timestamps = [datetime.fromisoformat(t) for t, _ in entries]
            cadence = extract_cadence_features(sorted(timestamps))

            if dtype == "Numeric":
                features = extract_numeric_features(entries, cadence)
            elif dtype == "str":
                features = extract_str_features(entries)
            elif dtype == "form":
                features = extract_form_features(entries)
            elif dtype == "time":
                features = extract_time_features(entries, cadence)
            else:
                features = {}

            results[metric_name] = {
                "cadence": cadence,
                "features": features
            }
    return results
