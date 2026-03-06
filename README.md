# CV

[![Build CV](https://github.com/jsurrea/CV/actions/workflows/build.yml/badge.svg)](https://github.com/jsurrea/CV/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/jsurrea/CV)](https://github.com/jsurrea/CV/releases/latest)

📄 [Download Latest PDF](https://github.com/jsurrea/CV/releases/latest/download/juan_sebastian_urrea_resume.pdf)
🗃️ [Download profile.json](https://github.com/jsurrea/CV/releases/latest/download/profile.json)

---

## Overview

LaTeX-based, JSON-driven, version-tracked, ATS-friendly CV for Computer Science / AI / Software Engineering roles, with automated GitHub Actions build and public release publishing.

All CV content lives in `data/profile.json` (following the [JSON Resume schema](https://jsonresume.org/schema/)). A Python + Jinja2 renderer generates `resume.tex` from the JSON, which is then compiled to PDF by `pdflatex` in CI.

## Repository Structure

```
jsurrea/CV/
│
├── data/
│   └── profile.json            # ← Single source of truth for all CV content
│
├── src/
│   ├── template.tex.j2         # Jinja2 LaTeX template (Jake's Resume structure)
│   └── generate.py             # Renders profile.json → resume.tex
│
├── resume.tex                  # ← Git-ignored; generated locally or by CI
├── resume.pdf                  # ← Git-ignored; compiled locally or by CI
│
├── .github/
│   └── workflows/
│       └── build.yml           # Manual-trigger: compile PDF + publish GitHub Release
│
├── .gitignore
└── README.md
```

## Modifying the CV

To update your CV, edit `data/profile.json`. The file follows the
[JSON Resume schema](https://jsonresume.org/schema/). Each section maps
directly to a CV section. Then rebuild locally or trigger the GitHub
Actions workflow.

## Local Development

### Prerequisites

#### Option A: Full TeX Live (recommended)

```bash
# Ubuntu / Debian
sudo apt-get install texlive-full

# macOS (via Homebrew)
brew install --cask mactex

# Windows
# Install MiKTeX from https://miktex.org/download
```

#### Option B: Docker (no local TeX installation needed)

```bash
docker pull texlive/texlive
```

#### Python dependency

```bash
pip install jinja2
```

### Build Steps

```bash
# 1. Clone the repository
git clone https://github.com/jsurrea/CV.git
cd CV

# 2. Edit your data
nano data/profile.json   # or open in any editor

# 3. Generate resume.tex from JSON
python src/generate.py

# 4a. Compile with pdflatex (recommended)
pdflatex resume.tex
pdflatex resume.tex      # run twice to resolve references

# 4b. Or with latexmk (handles reruns automatically)
latexmk -pdf resume.tex

# 4c. Or with Docker
docker run --rm -v $(pwd):/workdir texlive/texlive \
  latexmk -pdf -cd /workdir/resume.tex

# 5. Open the result
open resume.pdf          # macOS
xdg-open resume.pdf      # Linux
```

## Releasing a New Version

1. Commit your changes to `data/profile.json`
2. Go to: GitHub → Actions → "Build & Release CV" → Run workflow
3. Optionally enter a version tag (defaults to today's date: `YYYY.MM.DD`)
4. The workflow compiles the PDF and publishes a new GitHub Release
5. Download links auto-update at the `/releases/latest/download/` permalink

## Overleaf (Alternative Local Editing)

Upload `resume.tex` (after running `generate.py`) to Overleaf for
browser-based editing. Note: content changes should still be made in
`profile.json` to keep the JSON as the source of truth.

## Public Asset URLs

```
# Always points to latest version:
https://github.com/jsurrea/CV/releases/latest/download/juan_sebastian_urrea_resume.pdf
https://github.com/jsurrea/CV/releases/latest/download/profile.json
```