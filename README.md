## Pipeline Architecture

OCR → Text Extraction → Regex Feature Engineering → ML Classification → Rule-Based Validation → Final Prediction

## Pipeline Architecture

```mermaid
flowchart LR
    A[Input Documents\n(PDF / Images)]
    B[OCR Processing\n(Tesseract)]
    C[Text Extraction\n(Header Region)]
    D[Regex Candidate Extraction\n(Date Strings)]
    E[Feature Engineering\n(Position, Keywords, Time)]
    F[ML Model\n(Logistic Regression)]
    G[Rule-Based Validation\n(Date Window, Consensus)]
    H[Final Output\n(Excel Predictions)]

    A --> B --> C --> D --> E --> F --> G --> H

# Recording Date Extraction Pipeline

This portfolio project demonstrates a lightweight OCR + feature engineering + classification workflow for extracting likely recording dates from document images and OCR text.

## What the pipeline does

1. **OCR the top section of each document** using `header_ocr.py`
2. **Extract date candidates** and contextual signals into JSONL using `extract_date_candidates.py`
3. **Train a classifier** that scores likely recording dates using `train_recording_date_model.py`
4. **Combine rule-based logic with ML scoring** to predict the most likely date per document group using `predict_recording_dates.py`

## Why this is portfolio-worthy

- Shows practical OCR preprocessing and document parsing
- Demonstrates structured feature engineering from unstructured text
- Uses a simple, explainable logistic regression model
- Combines deterministic business rules with ML probabilities
- Represents a realistic automation workflow for operational document data

## Repo structure

- `header_ocr.py` — OCR helper for first-page header extraction
- `extract_date_candidates.py` — candidate date extraction and feature creation
- `train_recording_date_model.py` — supervised model training
- `predict_recording_dates.py` — hybrid prediction workflow
- `collect_ocr_samples.ps1` — optional PowerShell pipeline to batch OCR document samples

## Example workflow

```bash
python header_ocr.py sample.pdf > sample.txt
python extract_date_candidates.py data/ocr_txt data/date_candidates.jsonl
python train_recording_date_model.py data/date_candidates_labeled.jsonl models/recording_date_model.joblib
python predict_recording_dates.py data/date_candidates.jsonl models/recording_date_model.joblib output/predictions.csv
```

## Dependencies

```bash
pip install pandas scikit-learn joblib pillow pytesseract numpy opencv-python pdf2image openpyxl
```

You will also need:

- **Tesseract OCR** installed and available on your system path, or passed via `--tesseract-cmd`
- **Poppler** installed if you are OCR-ing PDFs with `pdf2image`

## Notes for public sharing

This version has been sanitized for portfolio use:

- Removed hardcoded internal network paths
- Removed machine-specific usernames and install locations
- Replaced organization-specific folder names with generic parameters
- Kept the core logic intact while making the scripts reusable

## Suggested GitHub description

> OCR + ML pipeline for extracting likely recording dates from document headers using feature engineering, logistic regression, and rule-based consensus logic.
