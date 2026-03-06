#!/usr/bin/env bash
set -euo pipefail

JSON="profile.json"

# ── summary.tex ────────────────────────────────────────────────────────────────
jq -r '.basics.summary' "$JSON" > sections/summary.tex

# ── education.tex ──────────────────────────────────────────────────────────────
{
  echo '\begin{itemize}[leftmargin=*,itemsep=0pt,topsep=2pt]'
  jq -r '.education[0].degrees[] | "  \\item " + .' "$JSON"
  echo ''
  jq -r '.education[0].highlights[] | "  \\item " + .' "$JSON"
  echo '\end{itemize}'
} > sections/education.tex

# ── experience.tex ─────────────────────────────────────────────────────────────
{
  jq -r '.work[] |
    "\\expEntry{" + .position + "}{\\href{" + .url + "}{" + .name + "}" +
    (if .note then " ({\\footnotesize " + .note + "})" else "" end) +
    "}{" + .location + "}{" + .startDate + " -- " + .endDate + "}" +
    "\n\\begin{itemize}[leftmargin=*,itemsep=0pt,topsep=1pt]" +
    "\n" + (.highlights | map("  \\item " + .) | join("\n")) +
    "\n\\end{itemize}\n\\vspace{2pt}"
  ' "$JSON"
} > sections/experience.tex

# ── publications.tex ───────────────────────────────────────────────────────────
{
  echo '\begin{enumerate}[leftmargin=*,itemsep=2pt,topsep=2pt]'
  jq -r '.publications[] |
    "  \\item " + .authors + ". \\textit{" + .title + "}. \\textbf{" + .venue + "}, " + .year + "." +
    " \\href{" + .paperUrl + "}{[Paper]}" +
    (if .codeUrl != "" then " \\href{" + .codeUrl + "}{[Code]}" else "" end) +
    (if .demoUrl != "" then " \\href{" + .demoUrl + "}{[Demo]}" else "" end)
  ' "$JSON"
  echo '\end{enumerate}'
} > sections/publications.tex

# ── volunteering.tex ───────────────────────────────────────────────────────────
{
  jq -r '.volunteer[] |
    "\\textbf{\\href{" + .url + "}{" + .organization + "}} \\hfill " + .startDate + " -- " + .endDate +
    "\\\\\n\\textit{" + .role + "}\\\\\n" + .summary + "\n"
  ' "$JSON"
} > sections/volunteering.tex

# ── awards.tex ─────────────────────────────────────────────────────────────────
{
  echo '\begin{itemize}[leftmargin=*,itemsep=0pt,topsep=2pt]'
  jq -r '.awards[] |
    "  \\item \\textbf{" + .title + "} (" + .date + ") --- " + .awarder + ". " + .summary
  ' "$JSON"
  echo '\end{itemize}'
} > sections/awards.tex

# ── certifications.tex ─────────────────────────────────────────────────────────
{
  jq -r '.certificates[] |
    .issuer + " $\\cdot$ " + .name + " (" + .date + ")\\\\"
  ' "$JSON"
} > sections/certifications.tex

echo "✓ All sections generated."
