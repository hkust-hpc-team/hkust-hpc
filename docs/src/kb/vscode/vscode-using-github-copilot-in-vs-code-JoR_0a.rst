Using GitHub Copilot in VS Code
===============================

.. meta::
    :description: A comprehensive guide to installing and configuring GitHub Copilot in Visual Studio Code
    :keywords: GitHub, Copilot, VS Code, installation, AI assistant, coding, setup
    :author: HKUST HPC Team <hpc@ust.hk>

.. container::
    :name: header

    | Last updated: 2025-07-02
    | *Solution verified: 2025-07-02*

Environment
-----------

This guide applies to:

    - **Visual Studio Code**: Version 1.74.0 or later (Version 1.99+ for Agent mode
      features)
    - **GitHub Copilot**: Latest extension version
    - **Operating Systems**: Windows, macOS, Linux
    - **GitHub Account**: Active subscription to GitHub Copilot

Issue
-----

    - How can I use GitHub Copilot into Visual Studio Code?

Prerequisites
-------------

Before installing GitHub Copilot, ensure you have:

1. **Active GitHub Copilot Subscription**

   - Individual subscription (pricing varies by region, check GitHub's current rates)
   - GitHub Copilot for Business (for organizations)
   - GitHub Pro, Team, or Enterprise Cloud subscription
   - Student access through GitHub Student Developer Pack
   - Free trial (if available)

   .. note::

       Pricing may vary by region and is subject to change. Visit `GitHub Copilot
       pricing page <https://github.com/features/copilot#pricing>`_ for current rates.

2. **Visual Studio Code**

   - Version 1.74.0 or later (recommended: latest stable version)
   - Version 1.99.0+ required for GitHub Copilot Agent mode features
   - Download from `official VS Code website <https://code.visualstudio.com/>`_

   .. tip::

       While older versions may work for basic Copilot features, VS Code 1.99+ provides
       enhanced Agent mode capabilities and better Copilot integration.

3. **Internet Connection**

   - Stable internet connection for extension download and AI suggestions

Installation Steps
------------------

Method 1: Install via VS Code Extensions Marketplace
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. **Open VS Code**

   Launch Visual Studio Code on your system.

2. **Access Extensions Panel**

   - Click the Extensions icon in the Activity Bar (left sidebar)
   - Or use keyboard shortcut: ``Ctrl+Shift+X`` (Windows/Linux) or ``Cmd+Shift+X``
     (macOS)

3. **Search for GitHub Copilot**

   - Type "GitHub Copilot" in the search box
   - Look for the official extension published by "GitHub"

4. **Install the Extension**

   - Click the "Install" button next to "GitHub Copilot"
   - Wait for the installation to complete

5. **Install GitHub Copilot Chat (Optional but Recommended)**

   - Search for "GitHub Copilot Chat"
   - Install this companion extension for enhanced chat features

Method 2: Install via Command Line
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you prefer command-line installation:

.. code-block:: bash

    # Install GitHub Copilot extension
    code --install-extension GitHub.copilot

    # Install GitHub Copilot Chat extension (optional)
    code --install-extension GitHub.copilot-chat

Configuration and Setup
-----------------------

1. **Sign in to GitHub**

   - After installation, VS Code will prompt you to sign in
   - Click "Sign in to GitHub" when prompted
   - Complete the authentication process in your browser
   - Return to VS Code to complete the setup

2. **Verify Installation**

   - Open a code file (e.g., ``.py``, ``.js``, ``.cpp``)
   - Start typing code and look for Copilot suggestions (gray text)
   - Suggestions should appear automatically as you type

3. **Configure Settings (Optional)**

   Access settings via ``Ctrl+,`` (Windows/Linux) or ``Cmd+,`` (macOS):

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

Important Considerations
------------------------

Version Compatibility
~~~~~~~~~~~~~~~~~~~~~

- **VS Code Minimum Version**: 1.74.0 for basic features, 1.99.0+ for Agent mode
- **Node.js**: Not directly required, but some features may need Node.js 18.x or later
- **Extension Updates**: Enable automatic updates for the latest features and security
  patches

.. note::

    GitHub Copilot Agent mode (available in VS Code 1.99+) provides enhanced
    conversational capabilities and improved code understanding.

Performance Considerations
~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Memory Usage**: Copilot may increase VS Code's memory consumption by 100-200MB
- **Network Usage**: Requires constant internet connection for AI suggestions
- **CPU Impact**: Minimal CPU overhead during normal operation

Security and Privacy
~~~~~~~~~~~~~~~~~~~~

- **Code Privacy**: Your code is sent to GitHub's servers for processing
- **Data Retention**: GitHub may retain code snippets for service improvement
- **Enterprise Setup**: Consider GitHub Copilot for Business for enhanced privacy
  controls

Troubleshooting
---------------

Common Issues and Solutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Issue: Copilot not showing suggestions**

1. Check your GitHub Copilot subscription status
2. Ensure you're signed in to the correct GitHub account
3. Restart VS Code
4. Check extension status in Extensions panel

**Issue: Authentication problems**

1. Sign out and sign in again:

   - Command Palette (``Ctrl+Shift+P`` / ``Cmd+Shift+P``)
   - Type "GitHub Copilot: Sign Out"
   - Then "GitHub Copilot: Sign In"

2. Clear VS Code authentication cache:

   - Command Palette → "Developer: Reload Window"

**Issue: Poor suggestion quality**

1. Provide more context in your code comments
2. Use descriptive variable and function names
3. Write clear, well-structured code for better AI understanding

**Issue: Extension conflicts**

1. Disable other AI coding assistants temporarily
2. Check for conflicting extensions in the Extensions panel
3. Try running VS Code in safe mode: ``code --disable-extensions``

**Issue: Slow suggestions**

1. Check your internet connection speed
2. Restart VS Code to refresh the connection
3. Consider using GitHub Copilot for Business for better performance
4. Clear VS Code workspace cache if performance issues persist

**Issue: Agent mode features not working**

1. Ensure you have VS Code 1.99.0 or later installed
2. Update GitHub Copilot extension to the latest version
3. Restart VS Code after updating
4. Check that Agent mode is enabled in Copilot settings

Verification Commands
~~~~~~~~~~~~~~~~~~~~~

To verify your installation:

.. code-block:: bash

    # Check installed extensions
    code --list-extensions | grep -i copilot

    # Expected output:
    # GitHub.copilot
    # GitHub.copilot-chat

Usage Tips
----------

1. **Accept Suggestions**: Press ``Tab`` to accept the current suggestion
2. **Navigate Suggestions**: Use ``Alt+]`` and ``Alt+[`` to cycle through alternatives
3. **Dismiss Suggestions**: Press ``Esc`` to dismiss current suggestions
4. **Inline Chat**: Use ``Ctrl+I`` (Windows/Linux) or ``Cmd+I`` (macOS) for inline chat
5. **Copilot Chat**: Open the chat panel for conversational coding assistance
6. **Enable/Disable for Specific Languages**: Configure which file types should use
   Copilot
7. **Use Copilot Labs**: Install GitHub Copilot Labs for experimental features
8. **Multi-line Suggestions**: Press ``Ctrl+Enter`` (Windows/Linux) or ``Cmd+Enter``
   (macOS) for multi-line completions
9. **Agent Mode**: Use ``@workspace`` in Copilot Chat to ask questions about your entire
   codebase (VS Code 1.99+)
10. **Context-Aware Chat**: Use ``#file`` or ``#selection`` in chat to reference
    specific code (VS Code 1.99+)

Best Practices
--------------

1. **Write Clear Comments**: Describe what you want to achieve in comments
2. **Use Descriptive Names**: Clear variable and function names improve suggestions
3. **Review Suggestions**: Always review and test generated code
4. **Combine with Testing**: Use Copilot with proper testing practices
5. **Stay Updated**: Keep the extension updated for latest features and improvements
6. **Respect Licensing**: Be aware that suggestions may be similar to existing code
7. **Use with Documentation**: Combine Copilot with proper code documentation
8. **Regular Extension Updates**: Keep both Copilot extensions updated for best
   performance
9. **Customize Settings**: Adjust Copilot settings based on your coding preferences and
   project needs
10. **Leverage Agent Mode**: If using VS Code 1.99+, take advantage of Agent mode for
    enhanced workspace understanding and context-aware assistance

Additional Resources
--------------------

- `GitHub Copilot Documentation <https://docs.github.com/en/copilot>`_
- `VS Code Extension Marketplace
  <https://marketplace.visualstudio.com/items?itemName=GitHub.copilot>`_
- `GitHub Copilot Pricing <https://github.com/features/copilot>`_
- `GitHub Copilot for Students <https://education.github.com/pack>`_

.. note::

    For users with HKUST email addresses, you may be eligible for GitHub Student
    Developer Pack which includes free access to GitHub Copilot. Check the GitHub
    Education website for more details.

.. warning::

    Be mindful of intellectual property and licensing when using AI-generated code
    suggestions. Always review and understand the code before incorporating it into your
    projects.
