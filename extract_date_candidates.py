import os

import re

import json

import sys

from pathlib import Path

 

# ============================================================

# PATH CONFIG (FIX)

# ============================================================

 

BASE_DIR = Path(__file__).resolve().parent

OUTPUT_DIR = BASE_DIR / "Output"

OUTPUT_DIR.mkdir(exist_ok=True)

 

DEFAULT_OUTPUT_PATH = OUTPUT_DIR / "date_candidates.jsonl"

 

# ============================================================

# DATE REGEX (EXTENDABLE)

# ============================================================

 

DATE_PATTERN = re.compile(

    r'('

    r'\d{1,2}[/-]\d{1,2}[/-]\d{4}|'

    r'[A-Z][a-z]+ \d{1,2}, \d{4}|'

    r'\d{1,2}-[A-Za-z]{3}-\d{4}|'

    r'\d{1,2}[/-]\d{1,2}[/-]\d{2}'

    r')',

    re.IGNORECASE

)

 

# ============================================================

# KEYWORD FEATURES

# ============================================================

 

KEYWORDS = {

    "contains_recorded": re.compile(r"\brecorded\b", re.IGNORECASE),

    "contains_filed": re.compile(r"\bfiled\b", re.IGNORECASE),

    "contains_official": re.compile(r"\bofficial\b", re.IGNORECASE),

    "contains_clerk": re.compile(r"\bclerk\b", re.IGNORECASE),

}

 

# ============================================================

# CORE EXTRACTION FUNCTION

# ============================================================

 

def extract_date_candidates_from_text(text, document_id):

    lines = [line.strip() for line in text.splitlines() if line.strip()]

    total_lines = len(lines)

    results = []

 

    if total_lines == 0:

        return results

 

    for idx, line in enumerate(lines):

        matches = DATE_PATTERN.findall(line)

 

        for date_str in matches:

            record = {

                "document_id": document_id,

                "date_string": date_str,

                "line_text": line,

                "line_index": idx,

                "relative_line_position": round(idx / total_lines, 4),

            }

 

            # keyword-based features

            for name, pattern in KEYWORDS.items():

                record[name] = bool(pattern.search(line))

 

            results.append(record)

 

    return results

 

# ============================================================

# FILE HANDLING

# ============================================================

 

def process_ocr_txt_file(path):

    document_id = Path(path).stem

 

    with open(path, "r", encoding="utf-8", errors="ignore") as f:

        text = f.read()

 

    return extract_date_candidates_from_text(text, document_id)

 

# ============================================================

# MAIN

# ============================================================

 

def main(input_dir, output_path=DEFAULT_OUTPUT_PATH):

    input_dir = Path(input_dir)

 

    if not input_dir.exists():

        raise FileNotFoundError(f"OCR text directory not found: {input_dir}")

 

    all_records = []

 

    for txt_path in input_dir.iterdir():

        if txt_path.suffix.lower() != ".txt":

            continue

 

        records = process_ocr_txt_file(txt_path)

        all_records.extend(records)

 

    # Write JSON Lines

    with open(output_path, "w", encoding="utf-8") as out:

        for record in all_records:

            out.write(json.dumps(record) + "\n")

 

    print(f"Extracted {len(all_records)} date candidates")

    print(f"Wrote output to: {output_path}")

 

# ============================================================

# CLI

# ============================================================

 

if __name__ == "__main__":

    if len(sys.argv) < 2:

        print("Usage: python extract_date_candidates.py <ocr_txt_dir> [output.jsonl]")

        sys.exit(1)

 

    input_dir = sys.argv[1]

    output_path = (

        Path(sys.argv[2])

        if len(sys.argv) > 2

        else DEFAULT_OUTPUT_PATH

    )

 

    main(input_dir, output_path)
