
# If not in CI, then allow interactive commands.
# For contributors to the project, this Makefile is for automating installations

UV_PATH       ?= $(shell command -v uv 2>/dev/null)
VIRTUAL_ENV   ?= .venv
VENV          ?= $(VIRTUAL_ENV)/bin/activate
VENV_STAMP    ?= $(VIRTUAL_ENV)/.uv-sync.stamp

install: $(VENV_STAMP) | check-uv
	uv run pre-commit install --hook-type pre-commit --hook-type commit-msg

$(VENV_STAMP): pyproject.toml uv.lock | check-uv
	uv sync --dev
	@mkdir -p "$(VIRTUAL_ENV)"
	@touch "$@"

check-uv:
	@if [ -z "$(UV_PATH)" ]; then \
		echo "A version of uv is required. Please run 'wget -qO- https://astral.sh/uv/install.sh | sh'"; \
		exit 1; \
	fi

.PHONY_TARGETS += install check-uv
.FILE_TARGETS  += $(VENV_STAMP)
