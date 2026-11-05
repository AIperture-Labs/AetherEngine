# C++ style

Applies to every C++ source and header under `sources/` and `tests/`, never
to `extern/`. `.clang-format` and `.clang-tidy` at the root are the source of
truth: never edit them to make code pass.

- C++23. Headers `.hpp`, sources `.cpp`, tests `*.test.cpp`.
- Four spaces for indentation, no tabs, lines up to 120 characters.
- Allman braces for classes, structs, functions and control statements;
  `else` on its own line. Never a one-line `if`, loop, block or function.
- Pointer and reference sign bind to the name: `const char *name`.
- Namespaces `aether::<module>`, closed with `}  // namespace aether::<module>`.
- Functions and methods are `camelCase`; constants are `kPascalCase`.
- Public headers live under `include/aether/<module>/` and are included with
  angle brackets: `#include <aether/core/version.hpp>`. The module's own
  header comes first, then the others, sorted by clang-format.
- Public symbols of a shared library carry the module's generated export
  macro (`AETHER_<MODULE>_API`); everything else stays hidden.
- Mark functions `noexcept` when they cannot throw.
- Prefer the `modernize-*` and `cppcoreguidelines-*` idioms: `nullptr`,
  `auto` where the type is obvious, smart pointers over owning raw pointers,
  `constexpr`/`const` by default.
- First-party code compiles with warnings as errors: fix the cause, never
  silence it with a pragma without a documented reason next to it.
- Tests use doctest: one `TEST_CASE` per behaviour, its name a sentence
  describing that behaviour.
