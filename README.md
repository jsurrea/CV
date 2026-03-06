# CV

Professional LaTeX CV built from a YAML profile using Haskell.

## Structure

```
.
├── data/
│   └── profile.yaml          # Single source of truth for all CV data
├── sections/
│   ├── *.tex.mustache        # Mustache section templates
│   └── *.tex                 # Generated LaTeX sections (git-ignored)
├── app/
│   └── Main.hs               # Haskell template renderer
├── cv-builder.cabal          # Cabal build configuration
├── cabal.project             # Cabal project settings
├── main.tex                  # Root LaTeX document
├── index.html                # GitHub Pages PDF viewer
└── Makefile                  # Build automation
```

## Workflow

1. Edit `data/profile.yaml` to update CV content.
2. Run `make` to build the PDF locally.
3. Push to `main` — GitHub Actions will compile and deploy automatically.

## GitHub Pages

| URL | Content |
|-----|---------|
| `jsurrea.github.io/CV` | PDF viewer |
| `jsurrea.github.io/CV/resume.pdf` | Raw PDF |
| `jsurrea.github.io/CV/profile.yaml` | Profile YAML |

## Local build

Requires:
- [GHC + Cabal](https://www.haskell.org/ghcup/)
- LuaLaTeX (TeX Live)

```bash
make
```
