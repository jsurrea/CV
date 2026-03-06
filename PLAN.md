# Implementation Plan: `jsurrea/CV` Repository

> **Purpose:** LaTeX-based, JSON-driven, version-tracked, ATS-friendly CV for
> Computer Science / AI / Software Engineering roles, with automated GitHub
> Actions build and public release publishing.

---

## Table of Contents

1. [Template Selection & Rationale](#1-template-selection--rationale)
2. [Repository Structure](#2-repository-structure)
3. [JSON Data File — Full Content](#3-json-data-file--full-content)
4. [LaTeX Template Architecture](#4-latex-template-architecture)
5. [Python Renderer (`generate.py`)](#5-python-renderer-generatepy)
6. [GitHub Actions Workflow](#6-github-actions-workflow)
7. [Publishing Strategy & Version History](#7-publishing-strategy--version-history)
8. [ATS Best Practices Applied](#8-ats-best-practices-applied)
9. [README & Local Development](#9-readme--local-development)

---

## 1. Template Selection & Rationale

### ✅ Chosen: **Jake's Resume** (`jakegut/resume`)

| Property | Detail |
|---|---|
| GitHub | https://github.com/jakegut/resume |
| Overleaf | https://www.overleaf.com/latex/templates/jakes-resume/syzfjbzwjncs |
| License | MIT |
| ATS Score | ~98% (single-column, no tables, no icons) |
| Popularity | 50,000+ engineers; de-facto standard on r/cscareerquestions |
| Base class | `article` (standard LaTeX — no exotic dependencies) |

**Why Jake's Resume over alternatives:**

- **Deedy CV** — two-column layout breaks some ATS parsers (Taleo, Workday). Rejected.
- **moderncv** — uses icons and color blocks that confuse older ATS systems. Rejected.
- **Rover Resume** — clean but less battle-tested at FAANG-level screening. Not chosen.
- **Jake's** — single-column, Computer Modern fonts, `glyphtounicode` for text extraction,
  `hyperref` with `hidelinks`, proven at Google / Meta / Amazon / Microsoft level filtering.
  Parses cleanly through Lever, Greenhouse, Workday, Taleo.

**ATS-critical features already in Jake's template:**
- `\input{glyphtounicode}` + `\pdfgentounicode=1` — ensures copy-paste from PDF works correctly
- No images, no sidebars, no tables
- `hyperref` with `hidelinks` — clickable links without colored boxes
- Standard `\section{}` headings that all parsers recognize

---

## 2. Repository Structure

```
jsurrea/CV/
│
├── data/
│   └── profile.json            # ← Single source of truth for all CV content
│                               #   Also published as a release asset (for portfolio use)
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

**Key decisions:**
- `data/profile.json` is committed and publicly accessible at the raw GitHub URL.
  This allows the portfolio project to consume it directly.
- Generated `resume.tex` and `resume.pdf` are **not** committed — they live in GitHub
  Releases, preserving clean version history without binary bloat.
- The Jinja2 approach keeps template logic in `.j2` and data in `.json`, cleanly separated.

---

## 3. JSON Data File — Full Content

Save as `data/profile.json`. Follows the [JSON Resume schema](https://jsonresume.org/schema/)
(the most LinkedIn-compatible open standard), with minor extensions for `institution` and
`category` fields needed by the template.

```json
{
  "$schema": "https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json",
  "meta": {
    "version": "v1.0.0",
    "lastModified": "2025-03-05"
  },
  "basics": {
    "name": "Juan Sebastián Urrea López",
    "label": "Software Engineer · AI & Computer Vision Researcher",
    "email": "jurrea5518@gmail.com",
    "phone": "+57 315 260 8311",
    "url": "https://jsurrea.github.io",
    "summary": "Colombian software engineer with dual Magna Cum Laude degrees in Systems & Computing Engineering and Industrial Engineering (GPA 4.69/5.0) from Universidad de los Andes. Specialized in computer vision, deep learning, and cloud-native systems. Published at IEEE conferences (ICMT 2025, CI-IB&BI 2021). Production experience at YC-backed Truora and Caseware International, building serverless architectures on AWS for 100K+ users. Founder of Open Source Uniandes serving 8K+ students. Currently pursuing Master's research in reinforcement learning and advanced vision systems.",
    "location": {
      "city": "Bogotá",
      "countryCode": "CO",
      "region": "Colombia"
    },
    "profiles": [
      {
        "network": "GitHub",
        "username": "jsurrea",
        "url": "https://github.com/jsurrea"
      },
      {
        "network": "LinkedIn",
        "username": "js-urrea",
        "url": "https://www.linkedin.com/in/js-urrea/"
      },
      {
        "network": "Portfolio",
        "username": "jsurrea.github.io",
        "url": "https://jsurrea.github.io"
      }
    ]
  },
  "education": [
    {
      "institution": "Universidad de los Andes",
      "url": "https://sistemas.uniandes.edu.co/",
      "area": "Systems and Computing Engineering",
      "studyType": "Master of Science",
      "startDate": "2026-01-18",
      "endDate": null,
      "score": null,
      "courses": [
        "Reinforcement Learning and Decision-Making",
        "Advanced Computer Vision",
        "Graduate Machine Learning"
      ]
    },
    {
      "institution": "Universidad de los Andes",
      "url": "https://sistemas.uniandes.edu.co/",
      "area": "Systems and Computing Engineering",
      "studyType": "Bachelor of Science",
      "startDate": "2019-01-19",
      "endDate": "2025-09-28",
      "score": "4.69/5.0 — Magna Cum Laude",
      "courses": [
        "Machine Learning & Deep Learning (CNNs, RNNs, Transformers, Diffusion Models)",
        "Computer Vision (SSD, Object Detection, Segmentation)",
        "Natural Language Processing",
        "Cloud-Native Development (AWS, GCP)",
        "Data Structures & Algorithms",
        "Software Architecture"
      ]
    },
    {
      "institution": "Universidad de los Andes",
      "url": "https://industrial.uniandes.edu.co/",
      "area": "Industrial Engineering",
      "studyType": "Bachelor of Science",
      "startDate": "2019-01-18",
      "endDate": "2024-10-12",
      "score": "4.7/5.0 — Magna Cum Laude",
      "courses": [
        "Operations Research & Mathematical Optimization",
        "Stochastic Modeling & Simulation",
        "Data Science & Machine Learning Applications",
        "Decision Support Systems"
      ]
    },
    {
      "institution": "Universidad de los Andes",
      "url": "https://biomedicalcomputervision.uniandes.edu.co/",
      "area": "Biomedical Engineering — AI & Computer Vision",
      "studyType": "Minor",
      "startDate": "2019-01-16",
      "endDate": "2024-10-10",
      "score": null,
      "courses": [
        "Image Analysis & Processing",
        "Advanced Computer Vision with Deep Learning (NeRF, Vision Transformers, GANs)",
        "Self-Supervised Learning & Robustness",
        "Research under Prof. Pablo Arbeláez, Biomedical Computer Vision Research Group"
      ]
    }
  ],
  "work": [
    {
      "name": "Truora Inc.",
      "position": "Software Engineer",
      "url": "https://www.truora.com/",
      "startDate": "2025-08-31",
      "endDate": null,
      "summary": "YC W19-backed identity verification and digital trust platform serving millions of users across Latin America.",
      "highlights": [
        "Architected AWS ACE–HubSpot integration using serverless stack (EventBridge, Lambda in Go, API Gateway), delivering $10K in AWS credits upon validation",
        "Designed idempotent data processing pipeline with Redis caching and webhook signature validation to ensure zero data corruption across systems",
        "Secured API key management via AWS Secrets Manager; implemented structured logging and New Relic dashboards for real-time anomaly detection",
        "Built and maintained scalable microservices handling millions of identity verification requests for banks, fintechs, and gig-economy platforms across LATAM"
      ]
    },
    {
      "name": "Multiaservi Ltda.",
      "position": "Application Developer",
      "url": "https://multiaservi.com.co/",
      "startDate": "2024-12-01",
      "endDate": "2025-06-29",
      "summary": "Full-stack engineer building a tax auditing platform for remote rural areas in Colombia.",
      "highlights": [
        "Architected offline-first Flutter mobile app with automatic data and image sync for low-bandwidth, low-spec Android environments",
        "Built Nest.js backend with Auth0 role-based access control and real-time GPS tracking dashboards for field auditors"
      ]
    },
    {
      "name": "Caseware International",
      "position": "Software Developer",
      "url": "https://www.caseware.com/",
      "startDate": "2024-01-14",
      "endDate": "2025-08-30",
      "summary": "Enterprise audit and financial reporting software used by accounting firms in 130+ countries.",
      "highlights": [
        "Led zero-downtime RDS-to-S3 Parquet migration for 100K+ users, owning a dual-layer validation system that continuously compared legacy and new implementations to guarantee identical outputs",
        "Built Java GraphQL client maintaining legacy service during phased deprecation; created New Relic dashboards that reduced anomaly detection time",
        "Optimized large-dataset rendering with React and ag-grid; implemented accessibility improvements (focus traps, screen reader support) and search enhancements"
      ]
    },
    {
      "name": "Cornell University, Department of Computer Science",
      "position": "Research Engineer (SURF Fellow)",
      "url": "https://www.cs.cornell.edu/~legunsen/",
      "startDate": "2023-06-05",
      "endDate": "2023-08-05",
      "summary": "10-week Summer Undergraduate Research Fellowship under Prof. Owolabi Legunsen (Software Engineering Research Group).",
      "highlights": [
        "Studied inline test co-evolution across 30+ open-source Java projects; curated dataset of 200+ statement-level breaking changes",
        "Developed automated pipeline simulating full project Git history, generating inline tests from unit tests with reproducible Maven builds",
        "Contributed to Ego4D — Meta AI's world-largest egocentric video dataset — advancing computer vision research on first-person perception"
      ]
    },
    {
      "name": "Kimberly-Clark Corporation",
      "position": "Data Scientist",
      "url": "https://www.kimberly-clark.com/",
      "startDate": "2022-07-04",
      "endDate": "2023-01-04",
      "summary": "Applied ML and NLP to manufacturing and supply-chain operations.",
      "highlights": [
        "Applied NLP embeddings to detect and merge 30,000 duplicate client records in SQL Server, improving data quality for downstream analytics",
        "Automated Power BI ecosystem documentation with Python, saving 100+ hours of manual reporting effort",
        "Implemented production monitoring pipeline for churn prediction model to track data drift and maintain reliability"
      ]
    }
  ],
  "publications": [
    {
      "name": "ANTARES: A Software-Based Tool for Simulating Naval Radar Operations",
      "publisher": "IEEE International Conference on Military Technologies (ICMT 2025)",
      "releaseDate": "2025",
      "url": "https://thesoftwaredesignlab.github.io/ANTARES",
      "summary": "Open-source naval radar simulator built in Rust, enabling real-time simulation of maritime environments and multi-target tracking via TCP protocol. Validated with 12 Colombian Navy officers and enlisted personnel.",
      "authors": "J. S. Urrea-Lopez, C. Barreto-Reyes, M. Linares-Vásquez",
      "code": "https://github.com/TheSoftwareDesignLab/ANTARES"
    },
    {
      "name": "Real-Time Face Mask Detection with SSD",
      "publisher": "IEEE 2nd International Congress of Biomedical Engineering and Bioengineering (CI-IB&BI 2021)",
      "releaseDate": "2021",
      "url": "https://github.com/jsurrea/face-mask-detection-SSD",
      "summary": "3-class real-time face mask detection using SSD architecture fine-tuned on Pascal VOC. Achieved mAP 70.2% on validation and 66.7% on test set, demonstrating viability for public-space surveillance at real-time speeds.",
      "authors": "E. S. Lozano Roa, J. S. Urrea López, I. D. Chacón Silva",
      "code": "https://github.com/jsurrea/face-mask-detection-SSD"
    }
  ],
  "projects": [
    {
      "name": "ANTARES — Naval Radar Simulator",
      "description": "Open-source naval radar operations simulator built in Rust. Achieves sub-10ms latency for real-time generation and transmission of radar data via TCP. Features an interactive React/TypeScript GUI and Python SDK. Published at IEEE ICMT 2025 and validated by Colombian Navy personnel.",
      "highlights": [
        "Implemented modular Rust core with concurrent streaming and TCP/WebSocket integration",
        "Designed extensible architecture following open-closed principle for new vessel strategies",
        "Validated with 12 active Colombian Navy officers and enlisted personnel"
      ],
      "keywords": ["Rust", "TCP", "React", "TypeScript", "Python", "Simulation"],
      "startDate": "2024-01-01",
      "endDate": "2025-05-01",
      "url": "https://thesoftwaredesignlab.github.io/ANTARES",
      "roles": ["Lead Developer", "Researcher"],
      "entity": "Universidad de los Andes / Colombian Navy",
      "type": "research",
      "code": "https://github.com/TheSoftwareDesignLab/ANTARES"
    },
    {
      "name": "Mi Horario Uniandes",
      "description": "Open-source course scheduler for Universidad de los Andes. Aggregates all available course sections, detects scheduling conflicts, and lets students build their ideal timetable visually. Received official university endorsement and API integration. Peak traffic of 8,000 visits in two weeks at course registration time.",
      "highlights": [
        "Deployed at institutional scale with university IT infrastructure support",
        "Reached 8,000 visits in 2 weeks during peak registration periods",
        "Received official university endorsement and dedicated API access"
      ],
      "keywords": ["React", "Node.js", "Open Source", "Web"],
      "startDate": "2022-12-20",
      "endDate": "2023-12-18",
      "url": "https://github.com/Open-Source-Uniandes/Mi-Horario-Uniandes",
      "roles": ["Founder", "Lead Developer"],
      "entity": "Open Source Uniandes",
      "type": "application",
      "code": "https://github.com/Open-Source-Uniandes/Mi-Horario-Uniandes"
    },
    {
      "name": "Aula Finder (Sobrecupo)",
      "description": "Real-time classroom availability finder for university students at Universidad de los Andes. Polls live seat data and surfaces open spots in seconds for last-minute registration in open seats. Deployed institutionally alongside Mi Horario Uniandes.",
      "highlights": [
        "Built cross-platform mobile app with Flutter and Nest.js backend",
        "Deployed institutionally with real-time seat data integration"
      ],
      "keywords": ["Flutter", "Nest.js", "Real-time", "Mobile"],
      "startDate": "2023-01-01",
      "endDate": "2023-12-01",
      "url": "https://github.com/Open-Source-Uniandes/Aula-Finder",
      "roles": ["Founder", "Developer"],
      "entity": "Open Source Uniandes",
      "type": "application",
      "code": "https://github.com/Open-Source-Uniandes/Aula-Finder"
    },
    {
      "name": "LatamGPT — LLM Training Data Pipeline",
      "description": "Large-scale ETL pipeline for the first collaborative Latin American LLM (50B parameters, 33+ institutional partners across 12 countries). Extracted and processed thousands of academic PDFs from Universidad de los Andes institutional repository, implemented de-identification pipeline, and managed dataset storage in GCP buckets for LLM training.",
      "highlights": [
        "Processed thousands of academic PDFs using Apache Tika with custom de-identification",
        "Managed multi-terabyte dataset storage in GCP buckets for 50B-parameter LLM training",
        "Pipeline adopted by 33+ institutions across 12 Latin American countries"
      ],
      "keywords": ["Python", "Apache Tika", "GCP", "NLP", "LLM", "ETL"],
      "startDate": "2024-06-03",
      "endDate": "2024-08-10",
      "url": "https://github.com/jsurrea/LLM-Latino",
      "roles": ["Data Engineer"],
      "entity": "LatamGPT Consortium",
      "type": "research",
      "code": "https://github.com/jsurrea/LLM-Latino"
    },
    {
      "name": "Face Mask Detection with SSD",
      "description": "Real-time 3-class face mask detection (mask worn, incorrectly worn, not worn) using SSD architecture fine-tuned from Pascal VOC weights on a custom 853-image dataset. Achieved mAP 70.2% on validation set. Published at IEEE CI-IB&BI 2021.",
      "highlights": [
        "Achieved mAP 70.2% validation and 66.7% test on 853-image custom dataset",
        "Demonstrated MultiBox Loss tuning for small, imbalanced datasets",
        "Published at peer-reviewed IEEE international conference"
      ],
      "keywords": ["PyTorch", "SSD", "Pascal VOC", "Computer Vision", "Object Detection"],
      "startDate": "2021-01-01",
      "endDate": "2021-12-01",
      "url": "https://github.com/jsurrea/face-mask-detection-SSD",
      "roles": ["Researcher", "Developer"],
      "entity": "Universidad de los Andes",
      "type": "research",
      "code": "https://github.com/jsurrea/face-mask-detection-SSD"
    },
    {
      "name": "DAIMO — INVIAS Bridge Intervention Dashboard",
      "description": "Interactive network analysis dashboard for Colombia's National Road Institute (INVIAS). Models road infrastructure as a graph, simulates simultaneous bridge closures, and identifies critical bridges by evaluating connectivity impact across the national network.",
      "highlights": [
        "Modeled national road network as a graph using NetworkX and simulated multi-bridge closure scenarios",
        "Delivered to government agency INVIAS for infrastructure prioritization decisions",
        "Built with Python, Dash, Plotly, pandas, and numpy; designed for cloud deployment"
      ],
      "keywords": ["Python", "Dash", "NetworkX", "Plotly", "Graph Analysis", "Government"],
      "startDate": "2023-08-08",
      "endDate": "2023-12-08",
      "url": "https://github.com/jsurrea/DAIMO",
      "roles": ["Lead Developer"],
      "entity": "INVIAS (National Roads Institute of Colombia)",
      "type": "application",
      "code": "https://github.com/jsurrea/DAIMO"
    },
    {
      "name": "Paquito — Anti-Corruption NLP Tool",
      "description": "Web application using NLP and AI to improve the search experience on SECOP II (Colombia's public procurement platform), enabling citizens and auditors to efficiently detect irregularities. Won DataJam for Transparency Colombia 2022.",
      "highlights": [
        "Won DataJam for Transparency 2022 — national open-data hackathon",
        "Applied NLP embeddings to surface procurement anomalies in public contracting data"
      ],
      "keywords": ["Python", "NLP", "Anti-Corruption", "Public Policy", "Web"],
      "startDate": "2022-01-01",
      "endDate": "2022-12-01",
      "url": "https://github.com/jsurrea/Paquito",
      "roles": ["Developer"],
      "entity": "DataJam for Transparency",
      "type": "application",
      "code": "https://github.com/jsurrea/Paquito"
    },
    {
      "name": "Condor — Amazonian Protection Platform",
      "description": "Aerial, space, and cyber software toolkit for monitoring and protecting the Colombian Amazon. Integrates satellite imagery processing, anomaly detection, and geospatial dashboards to support conservation authorities. Won Codefest Ad Astra 2023 national hackathon.",
      "highlights": [
        "Won Codefest Ad Astra 2023 — Colombia's national aerospace hackathon (2nd consecutive win)",
        "Integrated satellite imagery processing and geospatial anomaly detection for deforestation monitoring"
      ],
      "keywords": ["Python", "Satellite Imagery", "Geospatial", "Anomaly Detection", "Conservation"],
      "startDate": "2023-01-01",
      "endDate": "2023-12-01",
      "url": "https://github.com/jsurrea/Condor",
      "roles": ["Developer"],
      "entity": "Codefest Ad Astra",
      "type": "application",
      "code": "https://github.com/jsurrea/Condor"
    },
    {
      "name": "Satellite Cipher — Embedded Image Encryption",
      "description": "Lightweight satellite image encryption system for resource-constrained embedded hardware. Implements custom cipher algorithms optimized for low-power devices to secure imagery captured by small satellites. Won Codefest Ad Astra 2024 national hackathon.",
      "highlights": [
        "Won Codefest Ad Astra 2024 — Colombia's national aerospace hackathon (3rd consecutive win)",
        "Designed custom cipher optimized for embedded, low-power satellite hardware"
      ],
      "keywords": ["Embedded Systems", "Cryptography", "Satellite", "C", "Security"],
      "startDate": "2024-01-01",
      "endDate": "2024-12-01",
      "url": "https://github.com/jsurrea/Satellite-Cipher",
      "roles": ["Developer"],
      "entity": "Codefest Ad Astra",
      "type": "application",
      "code": "https://github.com/jsurrea/Satellite-Cipher"
    },
    {
      "name": "RF Signal Analyzer Dashboard",
      "description": "Interactive dashboard for characterizing radio-frequency signals in real time. Visualizes FFT spectra, signal strength over time, and anomaly detection overlays for spectrum monitoring and RF engineering workflows. Won Codefest Ad Astra 2024 national hackathon.",
      "highlights": [
        "Won Codefest Ad Astra 2024 alongside Satellite Cipher",
        "Implemented real-time FFT visualization and anomaly detection overlays for spectrum monitoring"
      ],
      "keywords": ["Signal Processing", "FFT", "Dashboard", "Python", "RF"],
      "startDate": "2024-01-01",
      "endDate": "2024-12-01",
      "url": "https://github.com/jsurrea/RF-Signal-Analyzer",
      "roles": ["Developer"],
      "entity": "Codefest Ad Astra",
      "type": "application",
      "code": "https://github.com/jsurrea/RF-Signal-Analyzer"
    },
    {
      "name": "Runtime Verification Research (Cornell SURF)",
      "description": "Empirical study of inline test co-evolution across 30+ open-source Java projects, conducted during Summer Undergraduate Research Fellowship at Cornell's Software Engineering Lab under Prof. Owolabi Legunsen.",
      "highlights": [
        "Curated dataset of 200+ statement-level breaking changes across 30+ Java projects",
        "Developed automated Git-history simulation pipeline for reproducible test co-evolution analysis"
      ],
      "keywords": ["Java", "Software Testing", "Empirical Research", "Maven", "Shell"],
      "startDate": "2023-06-05",
      "endDate": "2023-08-05",
      "url": "https://github.com/jsurrea/Runtime-Verification",
      "roles": ["Research Engineer"],
      "entity": "Cornell University",
      "type": "research",
      "code": "https://github.com/jsurrea/Runtime-Verification"
    },
    {
      "name": "Stellarlib — Aerial & Space Imagery SDK",
      "description": "Python library for processing aerial and satellite imagery, including radiometric correction, band arithmetic, cloud masking, and change-detection algorithms. Built for environmental monitoring workflows with a composable functional API. 3rd place at Codefest Ad Astra 2022.",
      "highlights": [
        "3rd place at Codefest Ad Astra 2022 — Colombia's national aerospace hackathon",
        "Designed clean functional API for composable remote sensing workflows"
      ],
      "keywords": ["Python", "Remote Sensing", "Image Processing", "Satellite", "SDK"],
      "startDate": "2022-01-01",
      "endDate": "2022-12-01",
      "url": "https://github.com/jsurrea/stellarlib",
      "roles": ["Developer"],
      "entity": "Codefest Ad Astra",
      "type": "library",
      "code": "https://github.com/jsurrea/stellarlib"
    }
  ],
  "volunteer": [
    {
      "organization": "Open Source Uniandes",
      "position": "Founder & Lead",
      "url": "https://github.com/Open-Source-Uniandes",
      "startDate": "2022-12-20",
      "endDate": "2023-12-18",
      "summary": "Founded and led open-source student developer community at Universidad de los Andes.",
      "highlights": [
        "Shipped two production applications serving 20,000+ Universidad de los Andes students",
        "Mi Horario Uniandes: course scheduler with 8,000 visits in 2 weeks and official university API endorsement",
        "Aula Finder (Sobrecupo): real-time classroom availability finder deployed at institutional scale"
      ]
    },
    {
      "organization": "Ego4D — Meta AI / CMU",
      "position": "Volunteer Data Contributor",
      "url": "https://ego4d-data.org/",
      "startDate": "2021-06-07",
      "endDate": "2021-08-07",
      "summary": "Contributed egocentric video footage to Ego4D, the world's largest publicly available first-person video dataset, supporting computer vision research on embodied AI.",
      "highlights": [
        "Contributed hours of high-quality egocentric video to Meta AI's large-scale CV research dataset"
      ]
    }
  ],
  "awards": [
    {
      "title": "Saber Pro — 11th Best National Score",
      "date": "2024-12-04",
      "awarder": "Ministry of Education of Colombia",
      "summary": "Achieved 11th best score nationally out of ~200,000 undergraduate test-takers on Colombia's mandatory standardized exit examination, evaluated across critical reading, quantitative reasoning, civic competence, scientific reasoning, and English proficiency."
    },
    {
      "title": "Full-Tuition Merit-Based Scholarship",
      "date": "2018-12-20",
      "awarder": "Universidad de los Andes",
      "summary": "Received and maintained full-tuition scholarship throughout 6-year dual-degree program. Highly competitive merit-based selection requiring exceptional academic achievement and sustained performance."
    },
    {
      "title": "Magna Cum Laude — Systems & Computing Engineering",
      "date": "2025-09-28",
      "awarder": "Universidad de los Andes",
      "summary": "Graduated Magna Cum Laude with GPA 4.69/5.0."
    },
    {
      "title": "Magna Cum Laude — Industrial Engineering",
      "date": "2024-10-12",
      "awarder": "Universidad de los Andes",
      "summary": "Graduated Magna Cum Laude with GPA 4.7/5.0."
    },
    {
      "title": "Codefest Ad Astra — 3× Consecutive National Winner",
      "date": "2024-01-01",
      "awarder": "Colombian Air Force / Codefest",
      "summary": "Won Colombia's national aerospace software hackathon three consecutive years (2022, 2023, 2024) across computer vision, satellite imagery, and embedded systems domains."
    },
    {
      "title": "Extreme Programming Competition — 1st Place",
      "date": "2022-01-01",
      "awarder": "Universidad de los Andes",
      "summary": "First place in competitive programming competition."
    },
    {
      "title": "Sabana Hack 2022 — Winner",
      "date": "2022-01-01",
      "awarder": "Universidad de La Sabana",
      "summary": "Winner of full-stack software development hackathon."
    },
    {
      "title": "DataJam for Transparency — Winner",
      "date": "2022-01-01",
      "awarder": "DataJam Colombia",
      "summary": "Won national data science hackathon with Paquito, an NLP tool for detecting corruption in public procurement."
    },
    {
      "title": "Data Science for All Colombia 5.0 — Honors Graduate",
      "date": "2021-09-10",
      "awarder": "Correlation One",
      "summary": "Completed highly selective 14-week program (3% acceptance rate) taught by Harvard, Columbia, and MIT faculty. Graduated with Honors."
    }
  ],
  "certificates": [
    {
      "name": "Building LLM Applications with Prompt Engineering",
      "date": "2025-04-01",
      "issuer": "NVIDIA Deep Learning Institute",
      "url": "https://www.nvidia.com/en-us/training/"
    },
    {
      "name": "Building Transformer-Based NLP Applications",
      "date": "2024-05-11",
      "issuer": "NVIDIA Deep Learning Institute",
      "url": "https://www.nvidia.com/en-us/training/"
    },
    {
      "name": "Fundamentals of Deep Learning",
      "date": "2024-04-20",
      "issuer": "NVIDIA Deep Learning Institute",
      "url": "https://www.nvidia.com/en-us/training/"
    },
    {
      "name": "Applied Data Science with Python Specialization (5 courses)",
      "date": "2021-01-08",
      "issuer": "University of Michigan / Coursera",
      "url": "https://www.coursera.org/specializations/data-science-python"
    },
    {
      "name": "Deep Learning Specialization (5 courses)",
      "date": "2020-07-09",
      "issuer": "DeepLearning.AI / Coursera",
      "url": "https://www.coursera.org/specializations/deep-learning"
    },
    {
      "name": "Data Science for All: Colombia 5.0",
      "date": "2021-09-10",
      "issuer": "Correlation One",
      "url": "https://www.correlation-one.com/data-science-for-all-colombia"
    },
    {
      "name": "Web Applications Development — Misión TIC",
      "date": "2022-12-15",
      "issuer": "Ministry of ICT of Colombia",
      "url": "https://www.mintic.gov.co/misiontic/"
    }
  ]
}
```

---

## 4. LaTeX Template Architecture

File: `src/template.tex.j2`

The template uses **Jake's Resume** as the base layout, extended with Jinja2 delimiters
(`<<`, `>>` to avoid collision with LaTeX `{`, `}`).

### Section order (optimized for CS/AI/SWE roles):

```
Header          ← name, email, phone, LinkedIn, GitHub, portfolio
Summary         ← 3-sentence professional summary
Experience      ← reverse-chronological, bullet points
Education       ← reverse-chronological; GPA and honors
Projects        ← selected 6-8; with [Code] and [Demo] hyperlinks
Publications    ← both IEEE papers with [Paper] and [Code] links
Certifications  ← grouped by issuer
Honors & Awards ← condensed 1-line entries
Volunteering    ← condensed
```

### Critical ATS elements in the template:

```latex
% At top of file — enables proper text extraction from PDF
\input{glyphtounicode}
\pdfgentounicode=1

% Standard article class — no exotic dependencies
\documentclass[letterpaper,11pt]{article}

% Hyperlinks without colored boxes — ATS-safe
\usepackage[hidelinks]{hyperref}

% Jinja2 delimiters (changed to avoid LaTeX conflicts)
% In generate.py: env = jinja2.Environment(
%   block_start_string='<<%', block_end_string='%>>',
%   variable_start_string='<<', variable_end_string='>>',
%   comment_start_string='<<#', comment_end_string='#>>'
% )
```

### Recommended font choices (add one of these to the template):

- Default Computer Modern (no extra package) — most ATS-safe, classic academic look
- `\usepackage[default]{sourcesanspro}` — modern sans-serif, still ATS-safe
- `\usepackage{charter}` — elegant serif, ATS-safe

---

## 5. Python Renderer (`generate.py`)

File: `src/generate.py`

```python
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
            ("&", r"\&"), ("%", r"\%"), ("$", r"\$"),
            ("#", r"\#"), ("_", r"\_"), ("{", r"\{"),
            ("}", r"\}"), ("~", r"\textasciitilde{}"),
            ("^", r"\textasciicircum{}"), ("\\", r"\textbackslash{}"),
        ]
        for old, new in replacements:
            text = text.replace(old, new)
        return text

    env.filters["latex"] = latex_escape

    template = env.get_template("template.tex.j2")
    data = load_data()
    output = template.render(**data)

    out_path = ROOT / "resume.tex"
    out_path.write_text(output, encoding="utf-8")
    print(f"Generated: {out_path}")

if __name__ == "__main__":
    render()
```

**Dependencies:** `pip install jinja2` (only external dependency)

---

## 6. GitHub Actions Workflow

File: `.github/workflows/build.yml`

```yaml
name: Build & Release CV

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Release tag (e.g. 2025.03.05 or v1.2.0)'
        required: false
        default: ''
      prerelease:
        description: 'Mark as pre-release?'
        required: false
        default: 'false'
        type: choice
        options: ['true', 'false']

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write    # needed to create releases

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install Python dependencies
        run: pip install jinja2

      - name: Determine release version
        id: version
        run: |
          if [ -n "${{ github.event.inputs.version }}" ]; then
            echo "tag=${{ github.event.inputs.version }}" >> $GITHUB_OUTPUT
          else
            echo "tag=$(date +'%Y.%m.%d')" >> $GITHUB_OUTPUT
          fi

      - name: Generate resume.tex from JSON
        run: python src/generate.py

      - name: Compile LaTeX → PDF
        uses: xu-cheng/latex-action@v4
        with:
          root_file: resume.tex
          latexmk_use_lualatex: false    # pdflatex is fastest; switch to true if using XeLaTeX fonts

      - name: Rename output artifacts
        run: |
          cp resume.pdf juan_sebastian_urrea_resume.pdf
          cp data/profile.json profile.json

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.version.outputs.tag }}
          name: "CV — ${{ steps.version.outputs.tag }}"
          body: |
            ## Juan Sebastián Urrea López — CV

            **Version:** `${{ steps.version.outputs.tag }}`
            **Built:** ${{ github.run_id }}

            ### Assets
            - `juan_sebastian_urrea_resume.pdf` — compiled CV (ATS-friendly PDF)
            - `profile.json` — structured data (for portfolio and other integrations)

            ### Direct Links
            - PDF: https://github.com/${{ github.repository }}/releases/latest/download/juan_sebastian_urrea_resume.pdf
            - JSON: https://github.com/${{ github.repository }}/releases/latest/download/profile.json
          prerelease: ${{ github.event.inputs.prerelease == 'true' }}
          files: |
            juan_sebastian_urrea_resume.pdf
            profile.json
          token: ${{ secrets.GITHUB_TOKEN }}
```

---

## 7. Publishing Strategy & Version History

### Why GitHub Releases (not gh-pages, not packages)?

| Option | Version History | PDF Served Directly | Simple URL | Chosen? |
|---|---|---|---|---|
| **GitHub Releases** | ✅ Full tag history | ✅ Direct download | ✅ `/releases/latest/download/...` | ✅ Yes |
| gh-pages | ❌ Only latest | ✅ | ✅ | ❌ No |
| Packages (NPM/Container) | ✅ | ❌ Requires auth | ❌ Complex URL | ❌ No |
| Committed PDF in repo | ❌ Git binary blob | ✅ | ✅ | ❌ No |

### Public asset URLs (permanent, update on every release):

```
# Always points to latest version:
https://github.com/jsurrea/CV/releases/latest/download/juan_sebastian_urrea_resume.pdf
https://github.com/jsurrea/CV/releases/latest/download/profile.json

# Specific version (for historical reference):
https://github.com/jsurrea/CV/releases/download/2025.03.05/juan_sebastian_urrea_resume.pdf
```

### Version tracking workflow:
1. Update `data/profile.json` with new information
2. Trigger workflow manually: GitHub → Actions → "Build & Release CV" → Run workflow
3. Optionally input a version tag (defaults to current date `YYYY.MM.DD`)
4. Release appears under "Releases" in the repository with both assets attached
5. The `/releases/latest/download/` permalink auto-updates

---

## 8. ATS Best Practices Applied

### Content rewriting rules for bullet points:

All bullet points follow this formula:
```
[Strong Action Verb] + [What you did] + [Quantified result or scale]
```

**Action verbs by category:**

| Category | Verbs Used |
|---|---|
| Building | Architected, Built, Developed, Implemented, Designed |
| Leading | Led, Founded, Directed |
| Optimizing | Optimized, Reduced, Improved |
| Publishing | Published, Presented |
| Winning | Won, Achieved |
| Analyzing | Applied, Curated, Modeled |

**Quantified achievements preserved from CV:**
- `$10K` AWS credits on project validation (Truora)
- `100K+` users served (Caseware)
- `30,000` duplicate records merged (Kimberly-Clark)
- `100+ hours` saved via automation (Kimberly-Clark)
- `200+` breaking changes curated (Cornell)
- `30+` open-source projects analyzed (Cornell)
- `8,000` visits in 2 weeks (Mi Horario Uniandes)
- `20,000+` students served (Open Source Uniandes)
- `50B` parameters / `33+` institutions / `12` countries (LatamGPT)
- mAP `70.2%` / mAP `66.7%` (Face Mask Detection)
- `12` naval officers validated ANTARES
- `~200,000` test-takers (Saber Pro ranking)
- `11th` nationally (Saber Pro)

### Structural ATS rules:

- ✅ Single-column layout (no sidebars, no tables for layout)
- ✅ Standard section headers: `Experience`, `Education`, `Projects`, `Publications`, `Certifications`, `Honors & Awards`, `Volunteering`
- ✅ No photos, no icons, no decorative graphics
- ✅ `glyphtounicode` for proper PDF text extraction
- ✅ `hyperref` with `hidelinks` — links work but no colored boxes
- ✅ Computer Modern font (ATS-safe default)
- ✅ 11pt body, standard margins
- ✅ Bullet points using `\item` in `itemize` environment
- ✅ Dates in `Month YYYY – Month YYYY` format
- ✅ Skills section omitted per user request (LinkedIn skills are not CV-optimal anyway)
- ✅ PDF exported (not DOCX) — formatting-safe across all viewers

### Items dropped from the Europass CV (not relevant for CS/AI/SWE):
- Passport number, date of birth, place of birth, nationality, gender (privacy + ATS best practice: never include)
- Europass photo
- Industrial Engineering course details (very granular; replaced with 1-line degree entry)
- Minor in Biomedical Engineering detailed course list (condensed to research note)
- "Misión TIC" certification expanded description

---

## 9. README & Local Development

The `README.md` should include the following sections:

### Badges (top of README):

```markdown
[![Build CV](https://github.com/jsurrea/CV/actions/workflows/build.yml/badge.svg)](https://github.com/jsurrea/CV/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/jsurrea/CV)](https://github.com/jsurrea/CV/releases/latest)
```

### Quick links:

```markdown
📄 [Download Latest PDF](https://github.com/jsurrea/CV/releases/latest/download/juan_sebastian_urrea_resume.pdf)
🗃️ [Download profile.json](https://github.com/jsurrea/CV/releases/latest/download/profile.json)
```

### Repository overview:

Brief explanation of the data-driven LaTeX approach and the Jinja2 rendering pipeline.

### Modifying the CV:

```markdown
To update your CV, edit `data/profile.json`. The file follows the
[JSON Resume schema](https://jsonresume.org/schema/). Each section maps
directly to a CV section. Then rebuild locally or trigger the GitHub
Actions workflow.
```

### Local development (full instructions):

```markdown
## Prerequisites

### Option A: Full TeX Live (recommended)
```bash
# Ubuntu / Debian
sudo apt-get install texlive-full

# macOS (via Homebrew)
brew install --cask mactex

# Windows
# Install MiKTeX from https://miktex.org/download
```

### Option B: Docker (no local TeX installation needed)
```bash
docker pull texlive/texlive
```

### Python dependency
```bash
pip install jinja2
```

## Build steps

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

## Releasing a new version

1. Commit your changes to `data/profile.json`
2. Go to: GitHub → Actions → "Build & Release CV" → Run workflow
3. Optionally enter a version tag (defaults to today's date: `YYYY.MM.DD`)
4. The workflow compiles the PDF and publishes a new GitHub Release
5. Download links auto-update at the `/releases/latest/download/` permalink

## Overleaf (alternative local editing)

Upload `resume.tex` (after running `generate.py`) and `resume.cls` to Overleaf
for browser-based editing. Note: content changes should still be made in
`profile.json` to keep the JSON as the source of truth.
```

---

## Implementation Checklist

Use this checklist when building the repo:

- [ ] Initialize `jsurrea/CV` as a **public** GitHub repository
- [ ] Create `data/profile.json` with full content from Section 3
- [ ] Create `src/template.tex.j2` based on Jake's Resume + Jinja2 delimiters
- [ ] Create `src/generate.py` (Section 5)
- [ ] Test locally: `python src/generate.py && pdflatex resume.tex`
- [ ] Verify PDF parses cleanly (test with https://github.com/affinda/resume-parser or jobscan.co)
- [ ] Create `.github/workflows/build.yml` (Section 6)
- [ ] Add `.gitignore`: `resume.tex`, `resume.pdf`, `*.aux`, `*.log`, `*.out`, `*.fls`, `*.fdb_latexmk`
- [ ] Write `README.md` with content from Section 9
- [ ] Trigger first manual release (`workflow_dispatch`) — verify PDF and JSON are attached
- [ ] Confirm public permalink works: `https://github.com/jsurrea/CV/releases/latest/download/profile.json`
- [ ] Use `profile.json` URL in portfolio project as the data source

---

*Plan prepared March 2026. All project details sourced from jsurrea.github.io, attached Europass CV, and GitHub repositories.*
