SOURCEDIR           ?= docs/src
BUILDDIR            ?= build
SPHINXOUTPUT        ?= html
SPHINXSTRICT        ?= -W --keep-going
SPHINXBUILDS        = $(SPHINXOUTPUT:%=$(BUILDDIR)/%)
.SOURCE_FILES_SPHINX = $(shell find $(SOURCEDIR) -type f -name '*.rst')

build: clean
	@for output in $(SPHINXOUTPUT); do \
		$(MAKE) --no-print-directory SPHINXOUTPUT="$$output" SPHINXOPTS="$(SPHINXOPTS)" SPHINXBUILD="$(SPHINXBUILD)" SOURCEDIR="$(SOURCEDIR)" BUILDDIR="$(BUILDDIR)" O="$(O)" "$(BUILDDIR)/$$output" || exit $$?; \
	done

strict: SPHINXOPTS += $(SPHINXSTRICT)
strict: build

html dirhtml singlehtml:
	$(MAKE) --no-print-directory SPHINXOUTPUT=$@ build

$(SPHINXBUILDS): $(.SOURCE_FILES_PYPROJECT) $(.SOURCE_FILES_MK) $(.SOURCE_FILES_SPHINX_CONFIG) $(.SOURCE_FILES_SPHINX)
$(BUILDDIR)/%:
	$(SPHINXBUILD) -M $* "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	@if [ "$*" != "clean" ]; then touch "$(BUILDDIR)/$*"; fi

clean:
	rm -rf $(BUILDDIR)

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.FILE_TARGETS += $(SPHINXBUILDS)
.PHONY_TARGETS += clean help build strict html dirhtml singlehtml
