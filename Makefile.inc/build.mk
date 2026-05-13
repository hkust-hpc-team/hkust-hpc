SOURCEDIR           ?= docs/src
BUILDDIR            ?= build
SPHINXOUTPUT        ?= html
SPHINXSTRICT        ?= -W --keep-going
SPHINXBUILDS        = $(SPHINXOUTPUT:%=$(BUILDDIR)/%)
.SOURCE_FILES_SPHINX = $(shell find $(SOURCEDIR) -type f -name '*.rst')

build: $(SPHINXBUILDS)

full-build:
	$(MAKE) clean
	$(MAKE) build

strict: SPHINXOPTS += $(SPHINXSTRICT)
strict: build

html dirhtml singlehtml:
	$(MAKE) SPHINXOUTPUT=$@ SPHINXOPTS="$(SPHINXOPTS)" $(BUILDDIR)/$@

$(SPHINXBUILDS): $(.SOURCE_FILES_PYPROJECT) $(.SOURCE_FILES_MK) $(.SOURCE_FILES_SPHINX_CONFIG) $(.SOURCE_FILES_SPHINX)
$(BUILDDIR)/%:
	$(SPHINXBUILD) -M $* "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	@if [ "$*" != "clean" ]; then touch "$(BUILDDIR)/$*"; fi

clean:
	rm -rf $(BUILDDIR)

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.FILE_TARGETS += $(SPHINXBUILDS)
.PHONY_TARGETS += clean help build full-build strict html dirhtml singlehtml
