from datetime import datetime

from pathlib import Path

import pandas as pd

import joblib

import re

 

# ============================================================

# PATH CONFIG

# ============================================================

 

BASE_DIR = Path(__file__).resolve().parent

 

OUTPUT_DIR = BASE_DIR / "Output"

OUTPUT_DIR.mkdir(exist_ok=True)

 

DATA_PATH   = OUTPUT_DIR / "date_candidates.jsonl"

MODEL_PATH  = OUTPUT_DIR / "recording_date_model.joblib"

OUTPUT_PATH = OUTPUT_DIR / "recording_dates_predictions.xlsx"

 

LOOKUP_PATH = BASE_DIR / "county_list.csv"

 

# ============================================================

# CONFIG

# ============================================================

 

DATE_WINDOW_DAYS   = 40

MAJORITY_RATIO     = 0.60

MIN_CONSENSUS_DOCS = 2

DOC_CHAR_WINDOW    = 400

 

FEATURE_COLS = [

    "relative_line_position",

    "contains_recorded",

    "contains_filed",

    "contains_official",

    "contains_clerk",

    "contains_time",

    "contains_vital_record_terms",

]

 

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

 

# ============================================================

# LOAD DATA

# ============================================================

 

df = pd.read_json(DATA_PATH, lines=True)

model = joblib.load(MODEL_PATH)

lookup_df = pd.read_csv(LOOKUP_PATH, dtype=str)

 

# ============================================================

# NORMALIZE LOOKUP (ALL CAPS)

# ============================================================

 

lookup_df["SUBCODE"] = lookup_df["SUBCODE"].str.strip().str.upper()

lookup_df["FIPS"] = lookup_df["FIPS"].str.replace(r"\D", "", regex=True)

 

# ============================================================

# FEATURE ENGINEERING

# ============================================================

 

df["contains_time"] = df["line_text"].str.contains(

    r"\b\d{1,2}:\d{2}\b", regex=True, na=False

)

 

VITAL_KEYWORDS = (

    "birth", "death", "certificate", "issued",

    "decedent", "sex:", "age:", "state file"

)

 

df["contains_vital_record_terms"] = df["line_text"].str.contains(

    "|".join(VITAL_KEYWORDS),

    case=False,

    na=False

)

 

X = df[FEATURE_COLS]

df["ml_score"] = model.predict_proba(X)[:, 1]

 

# ============================================================

# REGEX-FIRST DATE EXTRACTION

# ============================================================

 

today = pd.Timestamp(datetime.now().date())

window_start = today - pd.Timedelta(days=DATE_WINDOW_DAYS)

 

doc_dates = []

 

for document_id, group in df.groupby("document_id"):

 

    full_text = "\n".join(group["line_text"].dropna())

 

    doc_match = re.search(

        r"\bDOC[\s\-#]?\d+", full_text, flags=re.IGNORECASE

    )

 

    search_text = (

        full_text[doc_match.end():doc_match.end() + DOC_CHAR_WINDOW]

        if doc_match else full_text

    )

 

    for match in re.findall(

        DATE_REGEX, search_text, flags=re.IGNORECASE | re.VERBOSE

    ):

 

        parsed = pd.to_datetime(match, errors="coerce")

 

        if pd.notna(parsed):

            parsed = parsed.normalize()

            if window_start <= parsed <= today:

                doc_dates.append({

                    "DOCUMENT_ID": document_id,

                    "CALENDAR_DATE": parsed,

                    "DATE_STRING": match

                })

 

doc_df = pd.DataFrame(doc_dates)

 

if doc_df.empty:

    doc_df = pd.DataFrame(

        columns=["DOCUMENT_ID", "CALENDAR_DATE", "DATE_STRING"]

    )

 

doc_df["SUBCODE"] = (

    doc_df["DOCUMENT_ID"].str.split("-").str[0].str.upper()

)

 

# ============================================================

# COUNTY-LEVEL DECISION LOGIC

# ============================================================

 

results = []

 

for subcode, group in doc_df.groupby("SUBCODE"):

 

    counts = group["CALENDAR_DATE"].value_counts()

 

    if counts.empty:

        results.append({

            "SUBCODE": subcode,

            "DECISION_STATUS": "needs_review",

            "DATE_STRING": None,

            "RECORDING_DATE_SCORE": 0.0,

        })

        continue

 

    top_date = counts.index[0]

    dominance = counts.iloc[0] / counts.sum()

 

    if dominance >= MAJORITY_RATIO or counts.iloc[0] >= MIN_CONSENSUS_DOCS:

        results.append({

            "SUBCODE": subcode,

            "DECISION_STATUS": "auto_accept_doc_anchor",

            "DATE_STRING": top_date.strftime("%m/%d/%Y"),

            "RECORDING_DATE_SCORE": round(float(dominance), 3),

        })

        continue

 

    county_docs = df[df["document_id"].str.startswith(subcode)]

    best_ml = county_docs.sort_values("ml_score", ascending=False).head(1)

 

    if not best_ml.empty:

        results.append({

            "SUBCODE": subcode,

            "DECISION_STATUS": "auto_accept_ml",

            "DATE_STRING": best_ml.iloc[0]["date_string"],

            "RECORDING_DATE_SCORE": round(float(best_ml.iloc[0]["ml_score"]), 3),

        })

    else:

        results.append({

            "SUBCODE": subcode,

            "DECISION_STATUS": "needs_review",

            "DATE_STRING": None,

            "RECORDING_DATE_SCORE": 0.0,

        })

 

# ============================================================

# BUILD OUTPUT + ATTACH FIPS

# ============================================================

 

output = pd.DataFrame(results)

 

output = output.merge(

    lookup_df[["FIPS", "SUBCODE", "STATE", "COUNTY"]],

    on="SUBCODE",

    how="left"

)

 

output = output[

    [

        "FIPS",

        "STATE",

        "COUNTY",

        "SUBCODE",

        "DATE_STRING",

        "RECORDING_DATE_SCORE",

        "DECISION_STATUS",

    ]

]

 

# ============================================================

# SAVE RESULTS

# ============================================================

 

output.to_excel(OUTPUT_PATH, index=False)

 

print("County-level recording dates written to:")

print(OUTPUT_PATH)
