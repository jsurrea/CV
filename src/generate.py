#!/usr/bin/env python3
"""
Renders src/template.tex.j2 + data/profile.json -> resume.tex
"""

import json
import jinja2
from pathlib import Path

ROOT = Path(__file__).parent.parent


def load_data():
    with open(ROOT / "data" / "profile.json") as f:
        return json.load(f)


def render():
    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(ROOT / "src"),
        block_start_string="<<%",
        block_end_string="%>>",
        variable_start_string="<<",
        variable_end_string=">>",
        comment_start_string="<<#",
        comment_end_string="#>>",
        autoescape=False,           # LaTeX, not HTML
        trim_blocks=True,
        lstrip_blocks=True,
    )

    # Helper: escape LaTeX special characters
    def latex_escape(text):
        if not isinstance(text, str):
            return text
        replacements = [
            ("\\", r"\textbackslash{}"),
            ("&", r"\&"), ("%", r"\%"), ("$", r"\$"),
            ("#", r"\#"), ("_", r"\_"), ("{", r"\{"),
            ("}", r"\}"), ("~", r"\textasciitilde{}"),
            ("^", r"\textasciicircum{}"),
        ]
        for old, new in replacements:
            text = text.replace(old, new)
        return text

    # Helper: format ISO date string (YYYY-MM-DD) to "Mon YYYY" or "Present" if None
    def format_date(date_str):
        if not date_str:
            return "Present"
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        parts = date_str.split("-")
        month_abbr = months[int(parts[1]) - 1]
        return f"{month_abbr} {parts[0]}"

    env.filters["latex"] = latex_escape
    env.filters["format_date"] = format_date

    template = env.get_template("template.tex.j2")
    data = load_data()
    output = template.render(**data)

    out_path = ROOT / "resume.tex"
    out_path.write_text(output, encoding="utf-8")
    print(f"Generated: {out_path}")


if __name__ == "__main__":
    render()
