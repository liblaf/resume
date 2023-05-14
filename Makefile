AWESOME_CV      := $(CURDIR)/Awesome-CV
DOCS            := $(CURDIR)/docs
INSTALL_OPTIONS := -D --mode="u=rw,go=r" --no-target-directory --verbose
LATEXMK         := env TEXINPUTS="$(AWESOME_CV):" latexmk
LATEXMK_OPTIONS := -xelatex -file-line-error -interaction=nonstopmode -shell-escape
SRC_LIST        += $(shell find $(CURDIR)/chinese -name "*.tex" -type f)
SRC_LIST        += $(shell find $(CURDIR)/english -name "*.tex" -type f)
TARGETS         += $(DOCS)/resume-en.pdf
TARGETS         += $(DOCS)/resume-zh.pdf
TEXMFHOME       != kpsewhich -var-value=TEXMFHOME
TMP             := /tmp

all: $(TARGETS)

clean:
	cd $(CURDIR)/chinese && $(LATEXMK) -C
	cd $(CURDIR)/english && $(LATEXMK) -C
	$(RM) $(TARGETS)

docs: $(TARGETS) $(DOCS)/index.md

docs-gh-deploy: docs
	mkdocs gh-deploy --force --no-history

docs-serve: docs
	mkdocs serve

install: $(TEXMFHOME)/tex/latex/awesome-cv.cls
	texhash

pretty: pretty-latex pretty-markdown

pretty-latex: $(SRC_LIST)
	$(foreach src, $^, latexindent --overwrite --local --cruft=$(TMP) --modifylinebreaks --GCString $(src);)

pretty-markdown:
	prettier --write $(CURDIR)

ALWAYS:

%.pdf: %.tex ALWAYS
	cd $(@D) && $(LATEXMK) $(LATEXMK_OPTIONS) $<

$(DOCS)/resume-zh.pdf: $(CURDIR)/chinese/main.pdf
$(DOCS)/resume-en.pdf: $(CURDIR)/english/main.pdf
$(TARGETS):
	install $(INSTALL_OPTIONS) $< $@

$(TEXMFHOME)/tex/latex/awesome-cv.cls: $(AWESOME_CV)/awesome-cv.cls
	install $(INSTALL_OPTIONS) $< $@
