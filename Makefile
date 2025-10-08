# For development
# ``export CI=0``

CI            ?= 1
SPHINXOPTS    ?= -j auto
SPHINXBUILD   ?= uv run sphinx-build

.PHONY_TARGETS              =
.FILE_TARGETS               =
.SOURCE_FILES_MK            = Makefile $(shell find Makefile.inc -type f -name '*.mk')
.SOURCE_FILES_SPHINX_CONFIG = .readthedocs.yaml docs/src/conf.py docs/requirements.txt
.SOURCE_FILES_PYPROJECT     = pyproject.toml uv.lock
ifeq ($(CI),0)
	.SOURCE_FILES_PYPROJECT  += .venv .python-version
endif

ifeq ($(CI),0)
default: install
else
default: build
endif

.PHONY: $(.PHONY_TARGETS)

# Main Sphinx build
include Makefile.inc/build.mk
# For installing all dev dependencies and setup required
include Makefile.inc/dev/env.mk
# For renaming kb articles into consistent URL slug
include Makefile.inc/dev/kb-rename.mk
include Makefile.inc/dev/debug-targets.mk
