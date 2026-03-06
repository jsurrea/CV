# jsurrea/CV

[![Build & Publish CV](https://github.com/jsurrea/CV/actions/workflows/build.yml/badge.svg)](https://github.com/jsurrea/CV/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/jsurrea/CV)](https://github.com/jsurrea/CV/releases/latest)

LaTeX CV driven by `profile.json`. GitHub Actions builds a versioned PDF on demand.

## Public URLs

| Resource | URL |
|---|---|
| Latest PDF | https://jsurrea.github.io/CV/cv.pdf |
| Latest JSON | https://jsurrea.github.io/CV/profile.json |
| All versions | https://github.com/jsurrea/CV/releases |

## Repository Structure

```
jsurrea/CV/
├── profile.json                 # Single source of truth — all CV content
├── main.tex                     # Master LaTeX file — \inputs generated snippets
├── sections/                    # Static or generated .tex fragments
│   ├── header.tex               # Name + contact links (static, small edits only)
│   ├── summary.tex              # Generated from JSON
│   ├── education.tex            # Generated from JSON
│   ├── experience.tex           # Generated from JSON
│   ├── publications.tex         # Generated from JSON
│   ├── volunteering.tex         # Generated from JSON
│   ├── awards.tex               # Generated from JSON
│   └── certifications.tex       # Generated from JSON
├── generate.sh                  # Runs jq → writes sections/*.tex locally
├── Makefile                     # Targets: generate, pdf, clean, all
├── .github/
│   └── workflows/
│       └── build.yml            # Manual trigger: generate → compile → Release + Pages
├── .gitignore
└── README.md
```

## Prerequisites

- **TeX Live** (Full or Extras) with LuaLaTeX:
  ```bash
  # Ubuntu/Debian
  sudo apt install texlive-full fonts-roboto
  # macOS (Homebrew)
  brew install --cask mactex && brew install font-roboto
  ```
- **jq** — `sudo apt install jq` / `brew install jq`

## Local Build

```bash
git clone https://github.com/jsurrea/CV.git && cd CV

make all        # generate sections/*.tex + compile main.pdf
make generate   # only regenerate .tex (no compile)
make pdf        # only compile (assumes sections already generated)
make clean      # remove all generated/compiled files
```

## Editing Your CV

1. Open `profile.json` — every section is documented and self-explanatory.
2. Run `make all` to regenerate and recompile.
3. Open `main.pdf` to review.
4. Commit `profile.json` (and optionally `main.tex`) and push to `main`.

## Publishing a New Version

Go to **Actions → Build & Publish CV → Run workflow** in the GitHub UI.
Optionally specify a tag (e.g. `v2026.06.01`); defaults to today's date.

A new **GitHub Release** will be created with `main.pdf` attached,
and the Pages deployment will be updated with the latest PDF and JSON.
