.PHONY: all build generate pdf clean

all: build generate pdf

# Build the Haskell template renderer
build:
	cabal build cv-builder

# Generate .tex section files from YAML + Mustache templates
generate: build
	cabal run cv-builder

# Compile the CV PDF (two passes for cross-references)
pdf: generate
	lualatex -interaction=nonstopmode main.tex
	lualatex -interaction=nonstopmode main.tex

# Clean build artefacts
clean:
	cabal clean
	latexmk -C 2>/dev/null || true
	rm -f sections/header.tex sections/summary.tex sections/education.tex \
	      sections/experience.tex sections/publications.tex sections/volunteering.tex \
	      sections/awards.tex sections/certifications.tex
