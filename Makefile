# --- Variables ---
FILENAME = main
TEX_DIR = sections
# Find all .tex files in the sections directory
TEX_FILES := $(wildcard $(TEX_DIR)/*.tex)

# Spellcheck settings
SPELLCHECK = aspell
SPELLCHECK_DICT = mywords.txt
# --mode=tex ensures aspell ignores LaTeX commands
SPELLCHECK_FLAGS = list -t --home-dir=. --personal=$(SPELLCHECK_DICT) --mode=tex
SPELLCHECK_OUT = spell_check

# --- Phony Targets ---
.PHONY: all pdf clean spell embed_font_check

# Default target: builds everything
all: pdf spell embed_font_check

# Build PDF using latexmk
# -pdf: generate pdf via pdflatex
# -pdflatex="...": specify the engine and flags
# latexmk automatically handles bibtex and necessary re-runs
pdf:
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" $(FILENAME)
	# Embed fonts using Ghostscript (via ps2pdf)
	# /prepress is the industry standard for high-quality, fully embedded fonts
	ps2pdf -dColorConversionStrategy=/LeaveColorUnchanged -dPDFSETTINGS=/prepress $(FILENAME).pdf $(FILENAME)_font_embedded.pdf

# Clean up temporary files
# latexmk -C: removes all generated files including the final PDF
# latexmk -c: (lowercase) removes only temporary files, keeping the PDF
clean:
	latexmk -C
	$(RM) $(FILENAME)_font_embedded.pdf $(SPELLCHECK_OUT)
	$(RM) *.run.xml *.bcf

# Run spell check on all files in $(TEX_DIR)
spell:
	@$(RM) $(SPELLCHECK_OUT)
	@for file in $(TEX_FILES); do \
		echo "Checking typos in: $$file"; \
		echo "--- $$file ---" >> $(SPELLCHECK_OUT); \
		$(SPELLCHECK) $(SPELLCHECK_FLAGS) < $$file >> $(SPELLCHECK_OUT); \
	done

# Check and compare font embedding status
embed_font_check:
	@echo "Checking fonts for original PDF:"
	pdffonts $(FILENAME).pdf
	@echo ""
	@echo "Checking fonts for embedded PDF:"
	pdffonts $(FILENAME)_font_embedded.pdf
