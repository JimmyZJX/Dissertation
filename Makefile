SHELL = /bin/bash

# pdflatex/xelatex
LATEX_COMPILER = xelatex
# main .tex file without extension
MAIN_LATEX_FILENAME = Thesis

# specify "nonstopmode" to LaTeX Workshop (VSCode)
LATEX_ITR_MODE ?= errorstopmode
LATEXMK_OPTS = -pdflatex="$(LATEX_COMPILER) -synctex=-1 -interaction=$(LATEX_ITR_MODE) -file-line-error" -pdf

TEX_SOURCES := $(shell find . -name '*.tex')

.PHONY: all

all: $(MAIN_LATEX_FILENAME).pdf

TEMPWSL2 = /dev/shm/LaTeX_TEMP_WSL2
RSYNC_OPS = -av --exclude='.git/'
# --include='*/' --include='*.tex' --include='*.cls' --include='*.sty' --include='*.bib' --include='*.pdf' --exclude='*'
SED_FIX_SYNCTEX = -i -E "s<^(Input:[0-9]+:).+LaTeX_TEMP_WSL2/(.+)$$<\1$(CURDIR)/\2<g"

$(MAIN_LATEX_FILENAME).pdf: $(MAIN_LATEX_FILENAME).tex $(TEX_SOURCES) FORCE
ifdef WSLENV
	mkdir -p $(TEMPWSL2)
	rsync $(RSYNC_OPS) ./ $(TEMPWSL2)
	cd $(TEMPWSL2); latexmk $(LATEXMK_OPTS) -jobname=$(@:.pdf=) $<;\
		sed $(SED_FIX_SYNCTEX) $(@:.pdf=.synctex) || true
	cp -t ./ $(TEMPWSL2)/$(@:.pdf=).synctex $(TEMPWSL2)/$(@:.pdf=).pdf $(TEMPWSL2)/$(@:.pdf=).log
else
	latexmk $(LATEXMK_OPTS) -jobname=$(@:.pdf=) $<
endif

LATEX_CLEAN_FILES = *.bbl *.aux *.fls *.out *.synctex *.synctex.gz *.log *.fdb_latexmk *.blg bundle.tar.gz *.toc

clean:
	rm -f $(MAIN_LATEX_FILENAME).pdf
	rm -f $(LATEX_CLEAN_FILES)
ifdef WSLENV
	cd $(TEMPWSL2); rm -f $(LATEX_CLEAN_FILES)
endif

FORCE:;

init:
	texliveonfly $(MAIN_LATEX_FILENAME).tex
