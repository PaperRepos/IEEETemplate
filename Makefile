filename=main

SPELLCHECK_DICT = mywords.txt
SPELLCHECK = aspell
SPELLCHECK_FLAGS = list -t --home-dir=. --personal=$(SPELLCHECK_DICT)
SPELLCHECK_OUT = spell_check
TEX_DIR=sections
TEX_FILES := $(wildcard $(TEX_DIR)/*.tex)

all: pdf spell

pdf:
	pdflatex-dev ${filename}
	- bibtex ${filename}
	pdflatex-dev ${filename}
	pdflatex-dev ${filename}
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' ${filename}.log) \
	  do pdflatex-dev ${filename}; done
	ps2pdf -dColorConversionStrategy=/LeaveColorUnchanged -dPDFSETTINGS=/default ${filename}.pdf ${filename}_font_embedded.pdf

clean:
	$(RM)  *.log *.aux \
	*.cfg *.glo *.idx *.toc \
	*.ilg *.ind *.out *.lof \
	*.lot *.bbl *.blg *.gls *.cut *.hd \
	*.dvi *.ps *.thm *.tgz *.zip *.rpi *.pdf \
	*.fls *.fdb_latexmk *.synctex.gz

spell:
	$(RM) $(SPELLCHECK_OUT)
	@for file in $(TEX_FILES); do \
		echo "Checking typos in: $$file"; \
		echo "Checking typos in: $$file" >> $(SPELLCHECK_OUT); \
		cat $$file | $(SPELLCHECK) $(SPELLCHECK_FLAGS); \
		cat $$file | $(SPELLCHECK) $(SPELLCHECK_FLAGS) >> $(SPELLCHECK_OUT); \
		done
