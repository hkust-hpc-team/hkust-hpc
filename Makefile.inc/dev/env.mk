
# If not in CI, then allow interactive commands.
# For contributors to the project, this Makefile is for automating installations

UV_PATH          = $(shell which uv 2>/dev/null)
VIRTUAL_ENV      = .venv
VENV             = $(VIRTUAL_ENV)/bin/activate

install: $(VENV) .install_check_impl
	uv run pre-commit install --hook-type pre-commit --hook-type commit-msg

$(VENV): pyproject.toml uv.lock .install_check_impl
	uv sync --dev

.install_check_impl:
	if [ -z "$(UV_PATH)" ]; then \
		echo "A version of uv is required. Please run 'wget -qO- https://astral.sh/uv/install.sh | sh'"; \
		exit 1; \
	fi

.PHONY_TARGETS += install .install_check_impl
.FILE_TARGETS  += $(VENV)
