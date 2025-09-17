"""Configuration file for the Sphinx documentation builder."""

# -- Project information

project = "HPC Handbook"
copyright = "2025, The Hong Kong University of Science and Technology"

release = "0.1"
version = "0.1.0"

# -- General configuration

extensions = [
    "sphinx.ext.duration",
    "sphinx.ext.doctest",
    "sphinx.ext.autodoc",
    "sphinx.ext.autosummary",
    "sphinx.ext.intersphinx",
    "sphinx_copybutton",
]

intersphinx_mapping = {
    "python": ("https://docs.python.org/3/", None),
    "sphinx": ("https://www.sphinx-doc.org/en/master/", None),
}
intersphinx_disabled_domains = ["std"]

# -- Options for HTML output

html_theme = "sphinx_rtd_theme"
html_last_updated_fmt = "%b %d, %Y"

# -- Options for EPUB output
epub_show_urls = "footnote"

# -- Custom options
exclude_patterns = [
    'kb/template.rst',
]
