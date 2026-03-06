# jsurrea/CV

[![Build & Publish CV](https://github.com/jsurrea/CV/actions/workflows/build.yml/badge.svg)](https://github.com/jsurrea/CV/actions/workflows/build.yml)

LaTeX CV driven by `profile.json`. GitHub Actions builds a versioned PDF on demand.

## Public URLs

| Resource | URL |
|---|---|
| Latest PDF | https://jsurrea.github.io/CV |
| Latest JSON | https://jsurrea.github.io/CV/profile.json |

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

