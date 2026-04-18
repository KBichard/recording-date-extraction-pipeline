import argparse
from pathlib import Path

import joblib
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report

VITAL_KEYWORDS = (
    "birth",
    "death",
    "certificate",
    "issued",
    "decedent",
    "sex:",
    "age:",
    "state file",
)

FEATURE_COLS = [
    "relative_line_position",
    "contains_recorded",
    "contains_filed",
    "contains_official",
    "contains_clerk",
    "contains_time",
    "contains_vital_record_terms",
]


def add_features(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["contains_time"] = df["line_text"].str.contains(
        r"\b\d{1,2}:\d{2}\b", regex=True, na=False
    )
    df["contains_vital_record_terms"] = df["line_text"].str.contains(
        "|".join(VITAL_KEYWORDS), case=False, na=False
    )
    return df


def main(data_path: str, model_path: str) -> None:
    print("Loading training data...")
    df = pd.read_json(data_path, lines=True)
    df = add_features(df)

    X = df[FEATURE_COLS]
    y = df["is_recording_date"]

    print(f"Training samples: {len(X)}")
    print(f"Positive labels: {int(y.sum())}")

    print("Training logistic regression model (balanced)...")
    model = LogisticRegression(max_iter=1000, class_weight="balanced")
    model.fit(X, y)

    print("\nTraining set performance (diagnostic only):")
    y_pred = model.predict(X)
    print(classification_report(y, y_pred, zero_division=0))

    output_path = Path(model_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(model, output_path)
    print(f"\nModel saved to: {output_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Train a lightweight classifier to score candidate recording dates."
    )
    parser.add_argument("data_path", help="Labeled JSONL data path")
    parser.add_argument("model_path", help="Output path for the trained model")
    args = parser.parse_args()
    main(args.data_path, args.model_path)
