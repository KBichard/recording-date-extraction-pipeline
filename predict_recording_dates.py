import argparse
import re
from datetime import datetime
from pathlib import Path

import joblib
import pandas as pd

DATE_WINDOW_DAYS = 40
MAJORITY_RATIO = 0.60
MIN_CONSENSUS_DOCS = 2
DOC_CHAR_WINDOW = 400

FEATURE_COLS = [
    "relative_line_position",
    "contains_recorded",
    "contains_filed",
    "contains_official",
    "contains_clerk",
    "contains_time",
    "contains_vital_record_terms",
]

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

DATE_REGEX = r"""
(
    \b\d{1,2}/\d{1,2}/\d{4}\b |
    \b\d{4}-\d{2}-\d{2}\b |
    \b(?:Mon|Tues|Wednes|Thurs|Fri|Satur|Sun)day,?\s*
      (?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-z]*\s+
      \d{1,2},\s+\d{4} |
    \b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-z]*\s+
      \d{1,2},\s+\d{4}
)
"""


def add_features(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["contains_time"] = df["line_text"].str.contains(
        r"\b\d{1,2}:\d{2}\b", regex=True, na=False
    )
    df["contains_vital_record_terms"] = df["line_text"].str.contains(
        "|".join(VITAL_KEYWORDS), case=False, na=False
    )
    return df


def infer_county_from_document_id(document_id: str) -> str:
    return document_id.split("-")[0]


def main(data_path: str, model_path: str, output_path: str) -> None:
    df = pd.read_json(data_path, lines=True)
    df = add_features(df)
    model = joblib.load(model_path)

    X = df[FEATURE_COLS]
    df["ml_score"] = model.predict_proba(X)[:, 1]

    today = pd.Timestamp(datetime.now().date())
    window_start = today - pd.Timedelta(days=DATE_WINDOW_DAYS)

    doc_dates: list[dict] = []

    for doc_id, group in df.groupby("document_id"):
        full_text = "\n".join(group["line_text"].dropna())
        doc_match = re.search(r"\bDOC[\s\-#]?\d+", full_text, flags=re.IGNORECASE)
        search_text = full_text
        if doc_match:
            search_text = full_text[doc_match.end() : doc_match.end() + DOC_CHAR_WINDOW]

        matches = re.findall(DATE_REGEX, search_text, flags=re.IGNORECASE | re.VERBOSE)
        for match_text in matches:
            parsed = pd.to_datetime(match_text, errors="coerce")
            if pd.notna(parsed):
                parsed = parsed.normalize()
                if window_start <= parsed <= today:
                    doc_dates.append(
                        {
                            "document_id": doc_id,
                            "calendar_date": parsed,
                            "date_string": match_text,
                            "group_key": infer_county_from_document_id(doc_id),
                        }
                    )

    doc_df = pd.DataFrame(doc_dates)
    if doc_df.empty:
        doc_df = pd.DataFrame(columns=["document_id", "calendar_date", "date_string", "group_key"])

    results: list[dict] = []

    for group_key, group in doc_df.groupby("group_key"):
        counts = group["calendar_date"].value_counts()
        if counts.empty:
            results.append(
                {
                    "group_key": group_key,
                    "decision_status": "needs_review",
                    "date_string": None,
                    "recording_date_score": 0.0,
                }
            )
            continue

        top_date = counts.index[0]
        dominance = counts.iloc[0] / counts.sum()
        if dominance >= MAJORITY_RATIO or counts.iloc[0] >= MIN_CONSENSUS_DOCS:
            results.append(
                {
                    "group_key": group_key,
                    "decision_status": "auto_accept_doc_anchor",
                    "date_string": top_date.strftime("%m/%d/%Y"),
                    "recording_date_score": round(float(dominance), 3),
                }
            )
            continue

        group_docs = df[df["document_id"].str.startswith(group_key)]
        best_ml = group_docs.sort_values("ml_score", ascending=False).head(1)
        if not best_ml.empty:
            results.append(
                {
                    "group_key": group_key,
                    "decision_status": "auto_accept_ml",
                    "date_string": best_ml.iloc[0]["date_string"],
                    "recording_date_score": round(float(best_ml.iloc[0]["ml_score"]), 3),
                }
            )
        else:
            results.append(
                {
                    "group_key": group_key,
                    "decision_status": "needs_review",
                    "date_string": None,
                    "recording_date_score": 0.0,
                }
            )

    output = pd.DataFrame(results)
    output_file = Path(output_path)
    output_file.parent.mkdir(parents=True, exist_ok=True)

    if output_file.suffix.lower() == ".xlsx":
        output.to_excel(output_file, index=False)
    else:
        output.to_csv(output_file, index=False)

    print(f"Predictions written to: {output_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Predict the most likely recording date per document group using a hybrid rule + ML workflow."
    )
    parser.add_argument("data_path", help="JSONL path containing candidate date rows")
    parser.add_argument("model_path", help="Path to trained model (.joblib)")
    parser.add_argument("output_path", help="Output .csv or .xlsx path")
    args = parser.parse_args()
    main(args.data_path, args.model_path, args.output_path)
