.PHONY: all generate pdf clean

all: generate pdf

generate:
	bash generate.sh

pdf: generate
	lualatex -interaction=nonstopmode main.tex
	lualatex -interaction=nonstopmode main.tex

clean:
	latexmk -C
	rm -f sections/summary.tex sections/education.tex sections/experience.tex \
	      sections/publications.tex sections/volunteering.tex \
	      sections/awards.tex sections/certifications.tex
