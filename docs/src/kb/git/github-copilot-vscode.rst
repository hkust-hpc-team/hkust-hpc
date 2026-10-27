Using GitHub Copilot in VS Code
===============================

.. meta::
    :description: Short guide to installing and signing in to GitHub Copilot in Visual Studio Code
    :keywords: GitHub, Copilot, VS Code, installation, AI assistant, coding, setup
    :author: HKUST HPC Team <hpc@ust.hk>

.. container::
    :name: header

    | Last updated: 2025-07-02
    | *Solution verified: 2025-07-02*

Prerequisites
-------------

- **GitHub Copilot access**: An active subscription or free student access through the `GitHub Student Developer Pack <https://education.github.com/pack>`_ (available to users with an HKUST email address). See `GitHub Copilot pricing <https://github.com/features/copilot#pricing>`_ for plan details.
- **Visual Studio Code**: Version 1.74.0 or later (1.99.0+ required for Agent mode). Download from the `VS Code website <https://code.visualstudio.com/>`_.
- **Internet connection**: Required to download the extension and fetch completions.

Installation
------------

1. Open VS Code and open the Extensions view (``Ctrl+Shift+X`` on Windows/Linux, ``Cmd+Shift+X`` on macOS).
2. Search for **GitHub Copilot** and click **Install** on the extension published by GitHub.
3. Optional: install **GitHub Copilot Chat** for inline and sidebar chat (``Ctrl+I`` / ``Cmd+I``).

Sign In and Configure
---------------------

1. When prompted after installation, click **Sign in to GitHub** and complete authentication in your browser.
2. Open a source file and start typing to verify that gray inline completions appear. Press ``Tab`` to accept a suggestion, ``Alt+]`` / ``Alt+[`` to cycle alternatives, or ``Esc`` to dismiss.
3. Optional: restrict which file types trigger completions in your VS Code settings (``Ctrl+,`` or ``Cmd+,``):

   .. code-block:: json

       {
           "github.copilot.enable": {
               "*": true,
               "yaml": false,
               "plaintext": false
           },
           "github.copilot.inlineSuggest.enable": true,
           "github.copilot.editor.enableAutoCompletions": true
       }

Resource and Privacy Notes
--------------------------

- **Resource usage**: Copilot adds roughly 100-200 MB of memory overhead to the VS Code process and requires an active internet connection.
- **Code privacy**: Code snippets are transmitted to GitHub servers to generate completions. Review generated code and verify licensing or data-sensitivity constraints before using it in research software.

Troubleshooting
---------------

- **No completions appearing**: Confirm your Copilot subscription is active, check that you are signed in to the right GitHub account, and restart VS Code.
- **Authentication errors**: Open the Command Palette (``Ctrl+Shift+P`` / ``Cmd+Shift+P``), run ``GitHub Copilot: Sign Out``, then run ``GitHub Copilot: Sign In``. If that fails, run ``Developer: Reload Window``.
- **Extension conflicts**: Disable other completion extensions or test with ``code --disable-extensions``.
- **Agent mode unavailable**: Update VS Code to 1.99.0 or later and update the GitHub Copilot extensions.

See the `GitHub Copilot documentation <https://docs.github.com/en/copilot>`_ for full feature details.
