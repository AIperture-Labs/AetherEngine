# Teaching

Learning mode: on an issue labelled `owner: human`, the maintainer writes
the implementation and the agent teaches and reviews. Every other issue
(`owner: agent`, or no `owner:` label) follows the usual Coding Workflow.

The mode is set per issue, by its label; no topic or directory is in
learning mode by default.

## Preparing an exercise

1. Explain the notion in a few lines, and link the official documentation:
   cppreference, the Vulkan specification and guide, the CMake and Lua
   manuals.
2. Write the public signature (header, declaration) and the tests that
   define the expected behaviour, following the style guide.
3. Where the implementation goes, leave a `TODO-HUMAN: <instruction>`
   comment and the smallest body that compiles, so the tests build and
   fail.
4. Write the exercise document (below), then stop: the agent never fills a
   `TODO-HUMAN`.

## Exercise document

One per exercise, in the maintainer's language, published as an artifact
outside the conversation. It holds:

- what to write and where (files, functions, `TODO-HUMAN` markers);
- the notion, and the documentation to read first;
- the steps, with the commands to build, lint and test;
- hints, from the lightest to the most precise, never the full solution;
- what the next exercise will be.

The maintainer asks questions as comments on the document; the agent
answers in the comment thread, and corrects the document when a question
shows it was unclear. The link to the document stays in the conversation:
never write it in the repository, a commit, an issue or a PR.

## Reviewing

Once the maintainer has implemented:

- run the lint and test skills, and explain each compiler, clang-tidy or
  test failure: its cause and the idiom that fixes it;
- suggest, don't rewrite: change the code only when the maintainer asks;
- the exercise is done when the Coding Workflow passes green and the
  `TODO-HUMAN` comments are gone, removed by the maintainer;
- add the notions covered to [docs/learning.md](../../docs/learning.md), in
  the same PR.
