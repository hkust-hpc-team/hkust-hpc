SOURCEDIR            = docs/src
BUILDDIR             = build
SPHINXOUTPUT         = html
SPHINXBUILDS        = $(SPHINXOUTPUT:%=$(BUILDDIR)/%)
.SOURCE_FILES_SPHINX = $(shell (find docs -type f && find . -type f -name '*.rst') | sort -u)

build: $(SPHINXBUILDS)
	@true

$(SPHINXBUILDS): $(.SOURCE_FILES_PYPROJECT) $(.SOURCE_FILES_MK) $(.SOURCE_FILES_SPHINX_CONFIG) $(.SOURCE_FILES_SPHINX)
$(BUILDDIR)/%:
	$(SPHINXBUILD) -M $* "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	@[ "$*" == "clean" ] || touch $(BUILDDIR)/$*

clean:
	rm -rf $(BUILDDIR)

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.FILE_TARGETS += $(SPHINXBUILDS)
.PHONY_TARGETS += clean help build
