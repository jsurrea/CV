# Implementation Plan: `jsurrea/CV` Repository

> A LaTeX-based, JSON-driven CV for Computer Science, AI, and Software Engineering roles.
> Generated PDF is published as a versioned GitHub Release. JSON data is publicly accessible for portfolio reuse.

---

## Table of Contents

1. [Repository Structure](#1-repository-structure)
2. [ATS & Design Decisions](#2-ats--design-decisions)
3. [LaTeX Template Design](#3-latex-template-design)
4. [JSON Data File (`data.json`)](#4-json-data-file-datajson)
5. [Python Generation Script (`generate.py`)](#5-python-generation-script-generatepy)
6. [GitHub Actions Workflow](#6-github-actions-workflow)
7. [README (Local Dev Instructions)](#7-readme-local-dev-instructions)
8. [CV Section Order & Layout Notes](#8-cv-section-order--layout-notes)

---

## 1. Repository Structure

```
jsurrea/CV
├── data.json              # Single source of truth — all CV content
├── template/
│   └── cv.tex.j2          # Jinja2 LaTeX template (the visual design)
├── generate.py            # Reads data.json + renders template → cv.tex, then compiles PDF
├── .github/
│   └── workflows/
│       └── build.yml      # Manual-trigger workflow: generate → compile → release
├── output/
│   └── cv.pdf             # (gitignored locally; produced by CI and attached to Release)
└── README.md
```

**Key decisions:**
- `data.json` is committed and always current — it's the source of truth and publicly readable at `https://raw.githubusercontent.com/jsurrea/CV/main/data.json`.
- `cv.tex` is **generated** (not hand-written) and is also committed so it's diffable and useful on its own.
- The compiled `cv.pdf` is **not committed** to `main` — it is attached as an asset to a GitHub Release for clean version history.
- GitHub Releases are the publication mechanism: each run creates a new release tagged with the ISO date (e.g., `v2026.03.05`), attaching `cv.pdf`. This gives a full, browsable revision history of the CV over time.

---

## 2. ATS & Design Decisions

Based on industry best practices for CS/AI/SWE resumes:

| Principle | Decision |
|---|---|
| Single-column layout | ✅ ATS parsers read left-to-right; two columns cause scrambled parsing |
| No images/icons | ✅ Icons via `fontawesome5` in header only (name + links), never inside body sections |
| Machine-readable PDF | ✅ `\pdfgentounicode=1` and `\input{glyphtounicode}` included |
| Standard fonts | ✅ Latin Modern or Lato (not custom/embedded display fonts) |
| `article` document class | ✅ Widest ATS compatibility; no custom `.cls` file required |
| Hyperlinks hidden from print | ✅ `[hidelinks]` on `hyperref` |
| 1–2 pages | ✅ Given experience level with publications + master's, 2 pages is acceptable |
| Section names standard | ✅ "Education", "Experience", "Publications", "Projects", "Certifications" — exact keywords ATS scans for |
| Bullet points with action verbs | ✅ Strong past-tense action verbs (Architected, Led, Built, Applied) |
| Quantified achievements | ✅ Numbers wherever possible (100K+ users, $10K credits, 8K visits/week, 30K records) |

---

## 3. LaTeX Template Design

### Packages to use

```latex
\documentclass[letterpaper,11pt]{article}
\usepackage[empty]{fullpage}
\usepackage{geometry}           % margin control
\usepackage{enumitem}           % compact bullet lists
\usepackage{titlesec}           % section header formatting
\usepackage[hidelinks]{hyperref}% clickable links, no colored boxes
\usepackage{fontawesome5}       % icons for header links
\usepackage{tabularx}           % aligned header row
\usepackage{lato}               % clean, modern sans-serif (or [default]{lato})
\input{glyphtounicode}
\pdfgentounicode=1
```

### Section header command

```latex
\titleformat{\section}
  {\vspace{-4pt}\scshape\raggedright\large\bfseries}
  {}{0em}{}[\color{black}\titlerule\vspace{-5pt}]
```

### Entry command (experience/education/project items)

```latex
% \cvEntry{Title}{Org \hfill Location}{Date}{[Optional subtitle/tech]}
% followed by \begin{itemize}...\end{itemize}
```

### Margins

```
top: 0.5in, bottom: 0.5in, left: 0.6in, right: 0.6in
```

### Spacing hacks to prevent overflow

- `\vspace{-2pt}` between items
- `\itemsep=-2pt` on itemize lists
- Certifications section: render as a compact comma-separated list, not individual bullets
- Publication entries: single dense paragraph line (author, title, venue, year, doi link)

---

## 4. JSON Data File (`data.json`)

> Schema follows [JSON Resume](https://jsonresume.org/schema/) (a well-established open standard inspired by LinkedIn's data model), with minor extensions for publications and awards.

Below is the **complete, ready-to-implement content** for `data.json`:

```json
{
  "$schema": "https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json",
  "meta": {
    "version": "v1.0.0",
    "lastModified": "2026-03-05"
  },
  "basics": {
    "name": "Juan Sebastian Urrea Lopez",
    "label": "Software Engineer & AI Researcher",
    "email": "jurrea5518@gmail.com",
    "phone": "(+57) 315-260-8311",
    "url": "https://jsurrea.github.io/",
    "summary": "Software engineer and AI researcher with dual degrees (Magna Cum Laude, 4.69/5.0 GPA) and an ongoing Master's from Universidad de los Andes. Author of 2 IEEE publications in computer vision and simulation. Production experience building cloud-native systems for 100K+ users at YC-backed companies using AWS, Go, and Flutter. Founder of open-source tools serving 8K+ university students. Research experience at Cornell University and Universidad de los Andes. Strong background in deep learning, distributed systems, and full-stack development.",
    "location": {
      "city": "Bogotá",
      "countryCode": "CO",
      "region": "Colombia"
    },
    "profiles": [
      {
        "network": "LinkedIn",
        "username": "js-urrea",
        "url": "https://www.linkedin.com/in/js-urrea/"
      },
      {
        "network": "GitHub",
        "username": "jsurrea",
        "url": "https://github.com/jsurrea"
      },
      {
        "network": "ORCID",
        "username": "0009-0006-9814-7765",
        "url": "https://orcid.org/0009-0006-9814-7765"
      }
    ]
  },
  "education": [
    {
      "institution": "Universidad de los Andes",
      "url": "https://uniandes.edu.co/",
      "area": "Systems & Computing Engineering (M.Sc.) | Systems & Computing Engineering + Industrial Engineering (B.Sc. × 2) | Minor in Biomedical Engineering — AI & Computer Vision",
      "studyType": "M.Sc. + dual B.Sc. + Minor",
      "startDate": "2019-01-19",
      "endDate": "present",
      "score": "4.69/5.0 — Magna Cum Laude",
      "courses": [],
      "highlights": [
        "Dual B.Sc. in Systems & Computing Engineering and Industrial Engineering — Magna Cum Laude (4.69/5.0), 2025.",
        "Minor in Biomedical Engineering (AI & Computer Vision) — research under Prof. Pablo Arbeláez, Biomedical Computer Vision Group.",
        "M.Sc. in Systems & Computing Engineering (in progress, 2026–). Coursework in reinforcement learning, advanced vision systems, and graduate-level ML.",
        "Full-tuition merit-based scholarship maintained for 6 years.",
        "11th best national score on Saber Pro exit exam (≈200,000 test-takers)."
      ],
      "gpa_numeric": 4.69,
      "gpa_scale": 5.0,
      "honor": "Magna Cum Laude"
    }
  ],
  "work": [
    {
      "name": "Truora Inc.",
      "position": "Software Engineer",
      "url": "https://www.truora.com/",
      "startDate": "2025-08-31",
      "endDate": "present",
      "location": "Bogotá, Colombia",
      "note": "YC W19",
      "highlights": [
        "Architected serverless AWS integration (EventBridge, Lambda/Go, API Gateway) syncing HubSpot opportunity data with internal systems via idempotent processing, Redis caching, and Secrets Manager — delivering $10K in AWS credits upon validation.",
        "Implemented webhook signature validation and secure API key rotation to guarantee end-to-end data integrity across systems."
      ]
    },
    {
      "name": "Caseware International",
      "position": "Software Developer",
      "url": "https://www.caseware.com/",
      "startDate": "2024-01-14",
      "endDate": "2025-08-30",
      "location": "Bogotá, Colombia",
      "highlights": [
        "Led zero-downtime migration from RDS to S3 Parquet for 100K+ users, owning a dual-layer validation system that continuously compared legacy and new implementations to guarantee identical responses.",
        "Built Java GraphQL client and New Relic dashboards for anomaly detection; contributed accessibility improvements (focus traps, screen readers) and ag-grid components."
      ]
    },
    {
      "name": "Multiaservi Ltda.",
      "position": "Application Developer",
      "url": "https://multiaservi.com.co/",
      "startDate": "2024-12-01",
      "endDate": "2025-06-29",
      "location": "Bogotá, Colombia",
      "highlights": [
        "Built offline-first Flutter mobile app with automatic data/image sync and a Nest.js backend (Auth0, RBAC) for a tax auditing platform serving low-connectivity rural areas of Colombia.",
        "Designed real-time location tracking dashboards optimized for low-spec Android devices."
      ]
    },
    {
      "name": "Cornell University — Department of Computer Science",
      "position": "Research Engineer (SURF Fellow)",
      "url": "https://www.cs.cornell.edu/~legunsen/",
      "startDate": "2023-06-05",
      "endDate": "2023-08-05",
      "location": "Ithaca, NY, USA",
      "highlights": [
        "Conducted 10-week research fellowship under Prof. Owolabi Legunsen studying inline test co-evolution across 30+ open-source Java projects; curated a dataset of 200+ statement-level breaking changes.",
        "Developed automated pipeline simulating project Git history, generating inline tests via the ExLi framework and recording pass/fail results at each commit."
      ]
    },
    {
      "name": "Kimberly-Clark Corporation",
      "position": "Data Scientist",
      "url": "https://www.kimberly-clark.com/",
      "startDate": "2022-07-04",
      "endDate": "2023-01-04",
      "location": "Bogotá, Colombia",
      "highlights": [
        "Applied NLP embeddings to deduplicate 30K client records in SQL Server; automated Power BI documentation with Python (100+ hours saved) and implemented version control for 32 reports.",
        "Built production monitoring pipeline for churn prediction model to detect data drift and ensure reliability."
      ]
    }
  ],
  "publications": [
    {
      "name": "ANTARES: A Software-Based Tool for Simulating Naval Radar Operations",
      "publisher": "IEEE International Conference on Military Technologies (ICMT)",
      "releaseDate": "2025",
      "url": "https://ieeexplore.ieee.org/document/11061265",
      "summary": "Open-source naval radar simulator built in Rust supporting real-time TCP integration, standalone GUI operation, and extensible vessel movement strategies. Validated with 12 Colombian Navy officers and enlisted personnel.",
      "authors": "J. S. Urrea-Lopez, C. Barreto-Reyes, M. Linares-Vásquez",
      "codeUrl": "https://github.com/TheSoftwareDesignLab/ANTARES",
      "demoUrl": "https://thesoftwaredesignlab.github.io/ANTARES"
    },
    {
      "name": "Real-Time Face Mask Detection with SSD",
      "publisher": "IEEE 2nd International Congress of Biomedical Engineering and Bioengineering (CI-IB&BI)",
      "releaseDate": "2021",
      "url": "https://ieeexplore.ieee.org/document/9626095",
      "summary": "Trained SSD architecture on 853-image dataset for 3-class real-time face mask detection. Fine-tuned from Pascal VOC pretrained weights, achieving 66.7% mAP on the test set.",
      "authors": "E. S. Lozano Roa, J. S. Urrea López, I. D. Chacón Silva",
      "codeUrl": "https://github.com/jsurrea/face-mask-detection-SSD"
    }
  ],
  "projects": [
    {
      "name": "Open Source Uniandes",
      "description": "Founded and led open-source student organization at Universidad de los Andes, shipping two production tools: Mi-Horario-Uniandes (course scheduler with real-time notifications, peak 8K visits/2 weeks, official university API integration) and Aula-Finder (real-time campus classroom finder). Both deployed at institutional scale.",
      "highlights": [
        "8K+ peak weekly users; official university endorsement and API integration",
        "27 GitHub stars on Mi-Horario; 11 on Aula-Finder"
      ],
      "keywords": ["TypeScript", "Next.js", "Tailwind CSS"],
      "startDate": "2022-12-20",
      "endDate": "2023-12-18",
      "url": "https://github.com/Open-Source-Uniandes",
      "roles": ["Founder", "Lead Developer"],
      "type": "Open Source"
    },
    {
      "name": "LatamGPT — Document Extraction Pipeline",
      "description": "Designed and implemented the data pipeline for LatamGPT, the first collaborative Latin American LLM (50B parameters, 33+ institutional partners across 12 countries). Extracted and de-identified thousands of academic PDFs from Universidad de los Andes' institutional repository using Apache Tika; managed processed datasets in GCP for LLM training.",
      "highlights": [
        "50B parameter model; 33 institutional partners across 12 countries"
      ],
      "keywords": ["Python", "Apache Tika", "GCP", "ETL", "NLP"],
      "startDate": "2024-06-03",
      "endDate": "2024-08-10",
      "url": "https://github.com/jsurrea/LLM-Latino",
      "roles": ["Data Engineer"],
      "type": "Research"
    },
    {
      "name": "Paquito",
      "description": "NLP-powered search engine (React + FastAPI) improving Colombia's public contracting database (SECOP II) using word embeddings for semantic matching instead of exact keyword search. Winner of DataJam for Transparency Colombia 2022.",
      "highlights": [
        "Winner — DataJam for Transparency Colombia 2022"
      ],
      "keywords": ["Python", "React", "FastAPI", "NLP", "Vector Search"],
      "startDate": "2022-01-01",
      "endDate": "2022-12-31",
      "url": "https://github.com/jsurrea/Paquito",
      "roles": ["Full-Stack Developer"],
      "type": "Competition"
    }
  ],
  "volunteer": [
    {
      "organization": "Ego4D (Meta AI Research)",
      "position": "Data Contributor",
      "url": "https://ego4d-data.org/",
      "startDate": "2021-06-07",
      "endDate": "2021-08-07",
      "summary": "Contributed egocentric video footage to Ego4D, the world's largest publicly available first-person video dataset, supporting computer vision research on embodied AI and egocentric perception.",
      "highlights": []
    }
  ],
  "awards": [
    {
      "title": "Saber Pro — 11th Best National Score",
      "date": "2024-12-04",
      "awarder": "Ministry of Education of Colombia",
      "summary": "Ranked 11th nationally on the Saber Pro exit examination among approximately 200,000 undergraduate test-takers, evaluating critical reading, quantitative reasoning, civic competence, scientific reasoning, and English proficiency."
    },
    {
      "title": "Full-Tuition Merit-Based Scholarship",
      "date": "2018-12-20",
      "awarder": "Universidad de los Andes",
      "summary": "Received and maintained full-tuition merit scholarship throughout a 6-year dual-degree program based on exceptional academic achievement."
    },
    {
      "title": "Hackathon & Competition Wins (6+)",
      "date": "2022-2024",
      "awarder": "Various",
      "summary": "3× Codefest Ad Astra winner (2022, 2023, 2024); 1st Place Extreme Programming Competition (2022); Sabana Hack 2022; DataJam for Transparency 2022. Domains: full-stack development, competitive programming, and data science."
    }
  ],
  "certificates": [
    {
      "name": "Building LLM Applications with Prompt Engineering",
      "date": "2025-04-01",
      "issuer": "NVIDIA Deep Learning Institute",
      "url": ""
    },
    {
      "name": "Building Transformer-Based NLP Applications",
      "date": "2024-05-11",
      "issuer": "NVIDIA Deep Learning Institute",
      "url": ""
    },
    {
      "name": "Fundamentals of Deep Learning",
      "date": "2024-04-20",
      "issuer": "NVIDIA Deep Learning Institute",
      "url": ""
    },
    {
      "name": "Data Science for All: Colombia 5.0 — Honors",
      "date": "2021-09-10",
      "issuer": "Correlation One (3% acceptance rate)",
      "url": ""
    },
    {
      "name": "Applied Data Science with Python Specialization (5 courses)",
      "date": "2021-01-08",
      "issuer": "University of Michigan / Coursera",
      "url": ""
    },
    {
      "name": "Deep Learning Specialization (5 courses)",
      "date": "2020-07-09",
      "issuer": "DeepLearning.AI / Coursera",
      "url": ""
    }
  ]
}
```

---

## 5. Python Generation Script (`generate.py`)

The script reads `data.json`, renders `template/cv.tex.j2` with Jinja2, writes `cv.tex`, then calls `latexmk` to compile.

### Key behaviors

- Escapes all JSON strings for LaTeX special characters: `& % $ # _ { } ~ ^ \`
- Formats dates as `Month Year` from ISO strings
- Supports `"present"` as a valid `endDate` value
- Passes the full JSON data dict as the Jinja2 context
- Writes `cv.tex` to repo root, then runs: `latexmk -pdf -interaction=nonstopmode cv.tex`
- Cleans up auxiliary files: `latexmk -c`

### CLI usage

```bash
# Full build (generate .tex + compile .pdf)
python generate.py

# Generate .tex only (for inspection/debugging)
python generate.py --tex-only

# Compile pre-existing .tex only
python generate.py --pdf-only
```

### Dependencies

```
jinja2>=3.1
```

Install: `pip install jinja2`

---

## 6. GitHub Actions Workflow

**File:** `.github/workflows/build.yml`

### Trigger

```yaml
on:
  workflow_dispatch:    # Manual trigger only (as requested)
    inputs:
      version_tag:
        description: 'Release tag (e.g. v2026.03.05). Defaults to current date.'
        required: false
        type: string
```

### Steps

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write   # needed to create Releases

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install Python dependencies
        run: pip install jinja2

      - name: Install TeX Live
        run: |
          sudo apt-get update
          sudo apt-get install -y texlive-latex-extra texlive-fonts-extra \
            texlive-fonts-recommended latexmk

      - name: Generate cv.tex from data.json
        run: python generate.py --tex-only

      - name: Compile PDF
        run: |
          latexmk -pdf -interaction=nonstopmode cv.tex
          latexmk -c

      - name: Determine release tag
        id: tag
        run: |
          if [ -n "${{ github.event.inputs.version_tag }}" ]; then
            echo "tag=${{ github.event.inputs.version_tag }}" >> $GITHUB_OUTPUT
          else
            echo "tag=v$(date +'%Y.%m.%d')" >> $GITHUB_OUTPUT
          fi

      - name: Create GitHub Release and upload PDF
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.tag.outputs.tag }}
          name: "CV — ${{ steps.tag.outputs.tag }}"
          body: "Automated build from data.json"
          files: cv.pdf
```

### Why GitHub Releases (not Pages or Packages)?

- **Version history**: Every Release is a named, browsable, permanent snapshot with the PDF as a downloadable asset — this directly satisfies the "track different history versions" requirement.
- **Direct PDF link**: GitHub Releases provide stable asset URLs, e.g. `https://github.com/jsurrea/CV/releases/latest/download/cv.pdf` for the latest version.
- **No git bloat**: Binary PDFs are not committed to the repository tree.
- GitHub Packages is better suited for software packages, not document assets. GitHub Pages would only serve the latest HTML/PDF, without built-in version tracking.

---

## 7. README (Local Dev Instructions)

The README should include:

### Prerequisites

- Python 3.9+
- TeX Live (Full or Extras) — or MiKTeX on Windows
  - Required packages: `latexmk`, `texlive-latex-extra`, `texlive-fonts-extra`
- `pip install jinja2`

### Local build

```bash
git clone https://github.com/jsurrea/CV.git
cd CV

# Install Python dep
pip install jinja2

# Full build (generates cv.tex then cv.pdf)
python generate.py

# Open the result
open cv.pdf          # macOS
xdg-open cv.pdf      # Linux
```

### Editing your CV

1. Open `data.json` and modify the relevant section (work, education, projects, etc.)
2. Run `python generate.py` to regenerate the PDF
3. Commit changes to `data.json` (and optionally `cv.tex`)
4. Trigger the GitHub Actions workflow to publish a new versioned Release

### Publishing a new version

Go to **Actions → Build CV → Run workflow** in the GitHub repository UI, optionally specifying a version tag (defaults to today's date).

### Data file public URL

```
https://raw.githubusercontent.com/jsurrea/CV/main/data.json
```

This URL is always the latest version of the structured data — suitable for use in a portfolio website or other projects.

---

## 8. CV Section Order & Layout Notes

The rendered CV should have sections in this order:

```
┌─────────────────────────────────────────┐
│  Juan Sebastian Urrea Lopez             │
│  email | phone | LinkedIn | GitHub | web │
├─────────────────────────────────────────┤
│  EDUCATION                              │
├─────────────────────────────────────────┤
│  EXPERIENCE                             │
├─────────────────────────────────────────┤
│  PUBLICATIONS                           │
├─────────────────────────────────────────┤
│  VOLUNTEERING                           │
├─────────────────────────────────────────┤
│  HONORS & AWARDS                        │
├─────────────────────────────────────────┤
│  CERTIFICATIONS                         │
├─────────────────────────────────────────┤
│  SELECTED PROJECTS                      │
└─────────────────────────────────────────┘
```

### Section-specific rendering notes

**Education:** Single merged entry. Show degree names in a compact combined format. Show GPA, honor, date range. Include minor and master's as sub-bullets.

**Experience:** 5 entries, each with 1–2 bullet points. Use `\textbf{Company}` for company name, right-aligned dates via `\hfill`. Stack role + company on one line, location + dates on another (or combined).

**Publications:** Render as a numbered list. Format: `[1] Authors. \textit{Title}. \textbf{Venue}, Year. \href{url}{[PDF]} \href{codeUrl}{[Code]}`. No per-entry description to save space.

**Certifications:** Render as a single compact block, one certificate per line:
```
NVIDIA DLI · Building LLM Applications with Prompt Engineering (Apr 2025)
NVIDIA DLI · Transformer-Based NLP Applications (May 2024)
...
```
No descriptions, no bullets — just `issuer · name (date)`.

**Projects:** 3 entries with 1 tight bullet each. Show name, date, tech stack inline, hyperlink to GitHub. Highlight the key metric or award.

**Awards:** 3 entries; keep descriptions to one line each.

---

## Implementation Checklist

- [ ] Create `data.json` with the content above
- [ ] Create `template/cv.tex.j2` — Jinja2 template rendering each section
- [ ] Create `generate.py` — reads JSON, renders template, compiles PDF
- [ ] Test locally: `python generate.py` → verify `cv.pdf` fits within 2 pages and has no overflows
- [ ] Create `.github/workflows/build.yml` with manual trigger + Release publishing
- [ ] Write `README.md` with local dev instructions and public JSON URL
- [ ] Add `.gitignore` entries: `*.aux *.log *.fls *.fdb_latexmk *.out cv.pdf`
- [ ] Push to GitHub, run workflow, verify Release is created with `cv.pdf` attached
- [ ] Verify JSON at `https://raw.githubusercontent.com/jsurrea/CV/main/data.json` is accessible
