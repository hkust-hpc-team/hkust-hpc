..
    Please complete the article below using proper wordings in reStructuredText format.
    - Guidelines and TODOs are marked as comment, those should be removed in the refined article.
    - Subdomain name should be replaced with generic term, e.g. "hpcname", if it is not necessary for the context.
    - Any username should be replaced with generic term "username".
    - Truncate directory paths and filenames if it is not necessary for the context of the article.
    - Remove the .. rst-class:: sample-whatever, those are for showcasing the template structure only.

.. TODO: Update the title to reflect the article's content

Example: How to create a knowledgebase article using LLM
========================================================

..
    TODO: Update description and keywords
      - Description should be a brief summary of the article
      - Keywords should be relevant to the article content
    :description: A guide to create a knowledgebase article using LLM
    :keywords: knowledgebase, article, template, workflow

.. meta::
    :description: A guide to create a knowledgebase article using LLM
    :keywords: knowledgebase, article, template, workflow
    :author: user <user@ust.hk>

.. TODO: Update "Last updated" to today's date

.. Article should be *Solution under review* until verified

.. When verified, change to "Solution verified: YYYY-MM-DD"

.. rst-class:: header

    | Last updated: YYYY-MM-DD
    | *Solution under review*

Environment
-----------

    .. TODO: Update solution's applicable environment details

    .. Include e.g. software name; applicable version(s) if needed

    .. If it is a hardware specific issues, include hardware / OS details

    .. For clarity, should be in point-form, 1 indent level

    .. rst-class:: sample-environment-block

        - restructured text (rst) format
        - sphinx (readthedocs.io)

Issue
-----

    .. TODO: Describe the procedure to reproduce the issue

    .. For clarity, all text should start with 1 indent level

    .. rst-class:: sample-issue-block

        - When creating a knowledgebase article, it is time consuming to

          - follow template structure
          - ensure all sections are complete
          - describe all steps in detail
          - include masked sample outputs for users to follow
        - Some simple FAQs may need more efforts to write-up than working out the solution.

Resolution
----------

.. TODO: Effectively illustrate the solution with sample code and corresponding screen output

..
    Do:
    - Use subsections at level ~~~~ and ^^^^
    - Use bullet point with no indent to indicate steps, each step should be actionable
    - Use note:: to emphasize whatever care should be taken at some steps
    - Use warning:: to point out potential mistake
    - Use error:: to point out cases where it cannot be solved
    - Provide code in .. code-block::
    - Provide both code and expected screen output in code-block:: shell-session when needed

..
    Don't
    - Indent the paragraph of resolution section
    - Explain technical details in this section, technical details should go to "Root Cause" section

.. rst-class:: sample-resolution

    Large language model can help the process of writing articles.

    Here is a simple workflow outline

    1. Make a copy of this template
    2. Fill in minimal working details in the template, including necessary code details
    3. Paste the whole draft to LLM, supplied with another sample article
    4. Iteratively refine parts to give more details
    5. Instruct to LLM to refine wordings for general audience

Root Cause
----------

.. TODO: If there is a root technical cause, describe it.

.. TODO: If not required, remove this section.

.. rst-class:: example-rootcause-block

    It is sometimes harder to communication a solution than implement it.

Diagnosis
---------

..
    TODO: A diagnosis section is only needed if
    - User may be required to further check the details instead of a straightforward solution
    - There are methods for users to check if the solution is applicable to their case if they find
      multiple similar solutions

.. TODO: If section not required, remove this section.

References
----------

.. TODO: If not required, remove this section.

.. rst-class:: footer

    .. TODO: Do not change the HPC Support Team information, and ask the author to fill in the email

    **HPC Support Team**
      | ITSO, HKUST
      | Email: cchelp@ust.hk
      | Web: https://itso.hkust.edu.hk/

    **Article Info**
      | Issued: YYYY-MM-DD
      | Issued by: user@ust.hk
