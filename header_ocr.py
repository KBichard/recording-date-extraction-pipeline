import argparse
import os
import re
from pathlib import Path

import cv2
import numpy as np
import pytesseract
from pdf2image import convert_from_path
from PIL import Image

PDF_DPI = 200
CROP_PERCENT = 0.65


def load_first_page(path: str, poppler_path: str | None = None) -> Image.Image | None:
    ext = os.path.splitext(path.lower())[1]
    if ext == ".pdf":
        pages = convert_from_path(
            path,
            dpi=PDF_DPI,
            poppler_path=poppler_path,
            first_page=1,
            last_page=1,
        )
        return pages[0] if pages else None
    return Image.open(path)


def preprocess_fast(img: Image.Image) -> Image.Image:
    gray = np.array(img.convert("L"))
    gray = cv2.GaussianBlur(gray, (3, 3), 0)
    return Image.fromarray(gray)


def ocr_fast(pil_img: Image.Image, tesseract_cmd: str | None = None) -> str:
    if tesseract_cmd:
        pytesseract.pytesseract.tesseract_cmd = tesseract_cmd

    img = preprocess_fast(pil_img)
    text = pytesseract.image_to_string(img, config="--psm 6")
    text = re.sub(r"(\d{4})(\d)", r"\1 \2", text)
    return text.strip()


def extract_document_text(
    path: str,
    crop_percent: float = CROP_PERCENT,
    poppler_path: str | None = None,
    tesseract_cmd: str | None = None,
) -> str:
    page = load_first_page(path, poppler_path=poppler_path)
    if page is None:
        return ""

    w, h = page.size
    header_crop = page.crop((0, 0, w, int(h * crop_percent)))
    text = ocr_fast(header_crop, tesseract_cmd=tesseract_cmd)
    return f"=== HEADER_REGION ===\n{text}" if text else ""


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="OCR the top section of the first page of a PDF or image."
    )
    parser.add_argument("file", help="Path to the PDF/image file")
    parser.add_argument("--crop-percent", type=float, default=CROP_PERCENT)
    parser.add_argument("--poppler-path", default=None)
    parser.add_argument("--tesseract-cmd", default=None)
    args = parser.parse_args()

    text = extract_document_text(
        args.file,
        crop_percent=args.crop_percent,
        poppler_path=args.poppler_path,
        tesseract_cmd=args.tesseract_cmd,
    )
    print(text)
