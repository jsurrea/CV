#!/usr/bin/env python3
"""
Reads data.json, renders template/cv.tex.j2 → cv.tex, then compiles PDF.

Usage:
  python generate.py              # Full build: generate .tex + compile .pdf
  python generate.py --tex-only  # Generate cv.tex only (no PDF compilation)
  python generate.py --pdf-only  # Compile pre-existing cv.tex to PDF only
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

import jinja2

ROOT = Path(__file__).parent


def load_data():
    with open(ROOT / "data.json") as f:
        return json.load(f)


def latex_escape(text):
    if not isinstance(text, str):
        return text
    replacements = [
        ("\\", r"\textbackslash{}"),
        ("&", r"\&"),
        ("%", r"\%"),
        ("$", r"\$"),
        ("#", r"\#"),
        ("_", r"\_"),
        ("{", r"\{"),
        ("}", r"\}"),
        ("~", r"\textasciitilde{}"),
        ("^", r"\textasciicircum{}"),
    ]
    for old, new in replacements:
        text = text.replace(old, new)
    return text


def format_date(date_str):
    if not date_str or date_str.lower() == "present":
        return "Present"
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    parts = date_str.split("-")
    if len(parts) < 2:
        return parts[0]
    try:
        month_abbr = months[int(parts[1]) - 1]
        return f"{month_abbr} {parts[0]}"
    except (ValueError, IndexError):
        return date_str


def generate_tex():
    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(ROOT / "template"),
        block_start_string="<<%",
        block_end_string="%>>",
        variable_start_string="<<",
        variable_end_string=">>",
        comment_start_string="<<#",
        comment_end_string="#>>",
        autoescape=False,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    env.filters["latex"] = latex_escape
    env.filters["format_date"] = format_date

    template = env.get_template("cv.tex.j2")
    data = load_data()
    output = template.render(**data)

    out_path = ROOT / "cv.tex"
    out_path.write_text(output, encoding="utf-8")
    print(f"Generated: {out_path}")


def compile_pdf():
    result = subprocess.run(
        ["latexmk", "-pdf", "-interaction=nonstopmode", "cv.tex"],
        cwd=ROOT,
    )
    if result.returncode != 0:
        print("ERROR: latexmk failed.", file=sys.stderr)
        sys.exit(result.returncode)
    subprocess.run(["latexmk", "-c"], cwd=ROOT)
    print("Compiled: cv.pdf")


def main():
    parser = argparse.ArgumentParser(description="Generate and/or compile CV.")
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--tex-only",
        action="store_true",
        help="Generate cv.tex only (no PDF compilation)",
    )
    group.add_argument(
        "--pdf-only",
        action="store_true",
        help="Compile pre-existing cv.tex to PDF only",
    )
    args = parser.parse_args()

    if args.tex_only:
        generate_tex()
    elif args.pdf_only:
        compile_pdf()
    else:
        generate_tex()
        compile_pdf()


if __name__ == "__main__":
    main()
