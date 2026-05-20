SOURCEDIR            ?= docs/src
BUILDDIR             ?= build
SPHINXOUTPUT         ?= html
SPHINXSTRICT         ?= -W --keep-going
SPHINX_STAMPS         = $(SPHINXOUTPUT:%=$(BUILDDIR)/.stamp-%)
.SOURCE_FILES_SPHINX  = $(shell find $(SOURCEDIR) -type f)
.SPHINX_DEPS          = $(.SOURCE_FILES_PYPROJECT) $(.SOURCE_FILES_MK) $(.SOURCE_FILES_SPHINX_CONFIG) $(.SOURCE_FILES_SPHINX)

# Sphinx builders share $(BUILDDIR)/.doctrees, so keep multi-output builds sequential.
build:
	@set -e; \
	for output in $(SPHINXOUTPUT); do \
		$(MAKE) --no-print-directory \
			SPHINXBUILD="$(SPHINXBUILD)" \
			SPHINXOPTS="$(SPHINXOPTS)" \
			SOURCEDIR="$(SOURCEDIR)" \
			BUILDDIR="$(BUILDDIR)" \
			O="$(O)" \
			"$(BUILDDIR)/.stamp-$$output"; \
	done

full-build:
	$(MAKE) clean
	$(MAKE) build

strict: SPHINXOPTS += $(SPHINXSTRICT)
strict: build

html dirhtml singlehtml:
	@$(MAKE) --no-print-directory \
		SPHINXBUILD="$(SPHINXBUILD)" \
		SPHINXOPTS="$(SPHINXOPTS)" \
		SOURCEDIR="$(SOURCEDIR)" \
		BUILDDIR="$(BUILDDIR)" \
		O="$(O)" \
		"$(BUILDDIR)/.stamp-$@"


$(BUILDDIR)/.stamp-%: $(.SPHINX_DEPS)
	@mkdir -p "$(BUILDDIR)"
	$(SPHINXBUILD) -M $* "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	@touch "$@"

clean:
	rm -rf "$(BUILDDIR)"

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.FILE_TARGETS += $(SPHINX_STAMPS)
.PHONY_TARGETS += clean help build full-build strict html dirhtml singlehtml
