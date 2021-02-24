
LATEX_ITR_MODE ?= errorstopmode
LATEXMK_OPTS = -pdflatex="xelatex -synctex=1 -interaction=$(LATEX_ITR_MODE) -file-line-error" -pdf

TEX_SOURCES := $(shell find . -name '*.tex')

.PHONY: all

all: Thesis.pdf

Thesis.pdf: Thesis.tex $(TEX_SOURCES)
	latexmk $(LATEXMK_OPTS) -jobname=$(@:.pdf=) $<

clean:
	rm -f Thesis.pdf
	@rm -f *.bbl *.aux *.fls *.out *.synctex *.synctex.gz *.log *.fdb_latexmk *.blg bundle.tar.gz
