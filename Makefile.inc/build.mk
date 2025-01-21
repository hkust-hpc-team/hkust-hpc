SOURCEDIR            = docs/src
BUILDDIR             = build
SPHINXOUTPUT         = html epub latexpdf text
SPHINXBUILDS 				 = $(addprefix $(BUILDDIR)/,$(SPHINXOUTPUT))
.SOURCE_FILES_SPHINX = $(shell (find docs -type f && find . -type f -name '*.rst') | sort -u)


$(SPHINXBUILDS): $(.SOURCE_FILES_PYPROJECT) $(.SOURCE_FILES_MK) $(.SOURCE_FILES_SPHINX_CONFIG) $(.SOURCE_FILES_SPHINX)
$(BUILDDIR)/%:
	$(SPHINXBUILD) -b $* "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	@[ "$*" == "clean" ] || touch $(BUILDDIR)/$*

clean:
	rm -rf $(BUILDDIR)

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.FILE_TARGETS += $(SPHINXBUILDS)
.PHONY_TARGETS += clean help
