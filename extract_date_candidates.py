import argparse
import json
import os
import re
from pathlib import Path

DATE_PATTERN = re.compile(
    r'('
    r'\d{1,2}[/-]\d{1,2}[/-]\d{4}|'
    r'[A-Z][a-z]+ \d{1,2}, \d{4}|'
    r'\d{1,2}-[A-Za-z]{3}-\d{4}|'
    r'\d{1,2}[/-]\d{1,2}[/-]\d{2}'
    r')',
    re.IGNORECASE,
)

KEYWORDS = {
    "contains_recorded": re.compile(r"\brecorded\b", re.IGNORECASE),
    "contains_filed": re.compile(r"\bfiled\b", re.IGNORECASE),
    "contains_official": re.compile(r"\bofficial\b", re.IGNORECASE),
    "contains_clerk": re.compile(r"\bclerk\b", re.IGNORECASE),
}


def extract_date_candidates_from_text(text: str, document_id: str) -> list[dict]:
    """Extract date candidates and lightweight contextual features from OCR text."""
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    total_lines = len(lines)
    results: list[dict] = []

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
            for name, pattern in KEYWORDS.items():
                record[name] = bool(pattern.search(line))
            results.append(record)

    return results


def process_ocr_txt_file(path: Path) -> list[dict]:
    document_id = path.stem
    text = path.read_text(encoding="utf-8", errors="ignore")
    return extract_date_candidates_from_text(text, document_id)


def main(input_dir: str, output_path: str) -> None:
    input_path = Path(input_dir)
    output_file = Path(output_path)

    all_records: list[dict] = []
    for path in sorted(input_path.glob("*.txt")):
        all_records.extend(process_ocr_txt_file(path))

    output_file.parent.mkdir(parents=True, exist_ok=True)
    with output_file.open("w", encoding="utf-8") as out:
        for record in all_records:
            out.write(json.dumps(record) + "\n")

    print(f"Extracted {len(all_records)} date candidates to {output_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Extract OCR date candidates and contextual features into JSONL."
    )
    parser.add_argument("input_dir", help="Directory containing OCR text files")
    parser.add_argument("output_path", help="Output JSONL path")
    args = parser.parse_args()
    main(args.input_dir, args.output_path)
