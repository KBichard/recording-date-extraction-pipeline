# Recording Date Extraction Pipeline

An end-to-end OCR + machine learning pipeline for extracting recording dates from document images, scoring likely candidates, and merging results into a structured county-level dashboard.

This project combines OCR, regex-based feature extraction, logistic regression, and rule-based validation to process noisy document data and generate reliable recording date predictions for downstream review and reporting.

## Project Overview

This project was built to solve a real-world document analysis problem: identifying the correct recording date from noisy document images.

The workflow combines:

- OCR to extract text from document headers
- Regex and contextual feature engineering to identify date-like candidates
- Logistic regression to score likely recording dates
- Rule-based validation to improve reliability
- Dashboard merging logic to combine predictions with processed-date tracking and metadata

Rather than relying purely on machine learning, this pipeline uses a hybrid approach where ML handles ambiguity and deterministic rules improve consistency and trust.

## Pipeline Architecture

Input Documents → OCR Extraction → Date Candidate Extraction → Feature Engineering → ML Scoring → Rule-Based Validation → Dashboard Merge → Final Output

```mermaid
flowchart LR
    A["Input Documents (PDF / Images)"]
    B["OCR Processing (Tesseract)"]
    C["Header Text Extraction"]
    D["Date Candidate Extraction"]
    E["Feature Engineering"]
    F["ML Scoring (Logistic Regression)"]
    G["Rule-Based Validation"]
    H["Dashboard Merge / County Metadata Join"]
    I["Final Output (Excel / Dashboard)"]

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    H --> I
