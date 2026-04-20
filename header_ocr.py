import os

import sys

import re

import time

import shutil

import tempfile


import numpy as np

import cv2

from PIL import Image

from pdf2image import convert_from_path

import pytesseract

 

# ============================================================

# PIL SAFETY

# ============================================================

 

Image.MAX_IMAGE_PIXELS = None

 

# ============================================================

# OCR ENGINE CONFIGURATION

# ============================================================

 

# ============================================================
# OCR ENGINE CONFIGURATION
# ============================================================

TESSERACT_CMD = os.getenv("TESSERACT_CMD", None)
POPLER_BIN = os.getenv("POPLER_BIN", None)

PDF_DPI = 125
CROP_PERCENT = 0.65

if TESSERACT_CMD:
    pytesseract.pytesseract.tesseract_cmd = TESSERACT_CMD

 

# ============================================================

# FILE SAFETY HELPERS

# ============================================================

 

def copy_to_temp(path):

    """

    Copy file to a unique local temp directory to avoid

    SMB locks, Defender scans, and partially-written files.

    """

    temp_dir = tempfile.mkdtemp(prefix="ocr_")

    local_path = os.path.join(temp_dir, os.path.basename(path))

    shutil.copy2(path, local_path)

    return local_path

 

 

def load_first_page(path):

    """

    Load first page of PDF or image.

    Image is fully loaded into memory to release file handle.

    """

    ext = os.path.splitext(path.lower())[1]

 

    if ext == ".pdf":

        pages = convert_from_path(

            path,

            dpi=PDF_DPI,

            poppler_path=POPLER_BIN,

            first_page=1,

            last_page=1,

        )

        return pages[0] if pages else None

 

    img = Image.open(path)

    img.load() 

    return img

 

 

def load_first_page_with_retry(path, retries=3, delay=1):

    """

    Simple retry to survive transient file system issues.

    """

    last_error = None

    for _ in range(retries):

        try:

            return load_first_page(path)

        except Exception as e:

            last_error = e

            time.sleep(delay)

    raise last_error

 

 

# ============================================================

# FAST PREPROCESSING

# ============================================================

 

def preprocess_fast(img):

    gray = np.array(img.convert("L"))

    gray = cv2.GaussianBlur(gray, (3, 3), 0)

    return Image.fromarray(gray)

 

# ============================================================

# OCR CORE (SINGLE PASS)

# ============================================================

 

def ocr_fast(pil_img):

    img = preprocess_fast(pil_img)

    try:

        text = pytesseract.image_to_string(

            img,

            config="--psm 6"

        )

    finally:

        img.close()

 

   

    text = re.sub(r'(\d{4})(\d)', r'\1 \2', text)

 

    return text.strip()

 

# ============================================================

# EXTRACT OCR TEXT (HEADER ONLY)

# ============================================================

 

def extract_document_text(path):

    local_path = None

    page = None

    header_crop = None

 

    try:

        local_path = copy_to_temp(path)

        page = load_first_page_with_retry(local_path)

 

        if page is None:

            return ""

 

        w, h = page.size

        header_crop = page.crop((0, 0, w, int(h * CROP_PERCENT)))

 

        text = ocr_fast(header_crop)

 

        if text:

            return "=== HEADER_REGION ===\n" + text

 

        return ""

 

    except Exception as e:

        return f"OCR_ERROR: {e}"

 

    finally:

        if header_crop:

            header_crop.close()

        if page:

            page.close()

 

# ============================================================

# CLI

# ============================================================

 

if __name__ == "__main__":

    if len(sys.argv) < 2:

        print("Usage: python header_ocr.py <file>")

        sys.exit(1)

 

    result = extract_document_text(sys.argv[1])

    print(result)
