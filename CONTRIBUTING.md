# Contributing to HKUST HPC Documentation

Thank you for your interest in improving our documentation! This guide covers
the setup, workflow, and conventions for contributing.

For the full contributor's guide rendered with Sphinx, see the
[online version](https://hkust-hpc-docs.readthedocs.io/en/latest/contrib/index.html).

## Quick Start

### Prerequisites

- Python >= 3.11
- [uv](https://docs.astral.sh/uv/) (Python package manager)

### Setup

```bash
# Install uv (if you don't have it)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Clone and set up
git clone https://github.com/hkust-hpc-team/hkust-hpc.git
cd hkust-hpc
make install        # creates .venv, installs deps + pre-commit hooks
```

### Build

```bash
make build          # build HTML docs to build/html/
```

### Lint

Pre-commit hooks run automatically on `git commit`. To run manually:

```bash
uv run pre-commit run --all-files
```

## Contribution Workflow

1. **Fork** the repository on GitHub
2. **Create a branch** from `main`: `git checkout -b docs/my-topic`
3. **Write** your changes in `docs/src/` using reStructuredText
4. **Build locally** with `make build` to verify
5. **Commit** -- pre-commit hooks will check style and syntax
6. **Push** and open a **Pull Request** against `main`

## Project Structure

```
hkust-hpc/
├── docs/src/              # RST source files (this is what you edit)
│   ├── index.rst          # Root table of contents
│   ├── kb/                # Knowledge base articles
│   ├── compile-guides/    # Software compilation guides
│   ├── sysadmin/          # System administration docs
│   └── contrib/           # Contributor's guide (Sphinx version)
├── examples/              # Example scripts and code
├── workshops/             # Workshop materials
├── pyproject.toml         # Dependencies and tool config
├── .pre-commit-config.yaml
├── .readthedocs.yaml
└── Makefile               # Build automation
```

## Tool Versions

All linter and formatter versions are managed through `pyproject.toml` + `uv.lock`.
Pre-commit hooks use `language: system` with `uv run`, so local, CI, and RTD
environments all use the same pinned versions.

| Tool           | Purpose                                       |
| -------------- | --------------------------------------------- |
| `doc8`         | RST style checking (whitespace, indentation)  |
| `rstcheck`     | RST syntax validation                         |
| `ruff`         | Python linting and formatting (for `conf.py`) |
| `prettier`     | YAML and Markdown formatting                  |
| `sphinx-build` | Full documentation build                      |

## Editor Setup

Open the project in VS Code and accept the recommended extensions when prompted.
The repository includes `.vscode/extensions.json` and `.vscode/settings.json`
that configure all tools to use the same versions from `.venv/`.

## Writing RST

- No hard line-length limit enforced. RST has no auto-formatter, so `doc8`'s
  line-length check (D001) is disabled. Aim for ~120 characters as a guideline.
- Use 3-space indentation for directives
- Add cross-references with `:doc:` and `:ref:` roles
- Test code blocks compile/run before including them

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE).
