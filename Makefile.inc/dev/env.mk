
# If not in CI, then allow interactive commands.
# For contributors to the project, this Makefile is for automating installations

PYTHON_PATH      = $(shell (which python3.12 || which python3.11 || which python3.10) 2>/dev/null)
PDM_PATH         = $(shell which pdm 2>/dev/null)
FD_CMD           = $(shell which fd 2>/dev/null)
VIRTUAL_ENV      = .venv
VENV             = $(VIRTUAL_ENV)/bin/activate
PYTHON_VERSIONS  = $(shell grep requires-python pyproject.toml | cut -d '"' -f 2)

ifndef FD_CMD # FD_CMD: fd not found
FIND_RM_VENV_CMD = find $(VIRTUAL_ENV) -type d -print0 | xargs -r0 -P $(shell nproc) -n 32 rm -rf
else # FD_CMD: fd found
FIND_RM_VENV_CMD = fd -uu0 -t d . $(VIRTUAL_ENV) | xargs -r0 -P $(shell nproc) -n 32 rm -rf
endif # end FD_CMD

install: $(VENV) .install_check_impl
	git config core.hooksPath .githooks/

$(VENV): pyproject.toml pdm.lock .install_check_impl
	$(FIND_RM_VENV_CMD); rm -rf $(VIRTUAL_ENV)
	pdm venv create $(PYTHON_PATH)
	pdm sync --dev

pdm-update: $(VENV) .install_check_impl
	. $(VENV) && pdm update --dev --unconstrained --save-exact --update-eager
	touch $(VENV)

.install_check_impl:
	if [ -n "$(VIRTUAL_ENV_PROMPT)" ]; then \
		echo "Please deactivate the current virtual environment"; \
		exit 1; \
	fi
	if [ -z "$(PYTHON_PATH)"]; then \
		echo "Unable to find Python 3.10 or higher"; \
		echo "Python >=3.10,<3.13 is required"; \
		exit 1; \
	fi
	if [ -z "$(PDM_PATH)"]; then \
		echo "A version of PDM is required, please run `pip3 install --user pdm` to install"; \
		exit 1; \
	fi

.PHONY_TARGETS += install pdm-update .install_check_impl
.FILE_TARGETS  += $(VENV)
