# Python style

Applies to every Python file in the repo.

- `pyproject.toml` is the single config file: hatchling build backend,
  `src/<package>/` layout, tests in `tests/`, dev tools in the `dev` extra,
  `requires-python = ">=3.11"`.
- Python 3.11 or later; use native syntax: `list[str]`, `dict[str, int]`,
  `X | None`. No `from __future__ import annotations`, no `typing.List` /
  `Optional`.
- Type hints are mandatory on every function: all parameters and the return
  type.
- Four spaces for indentation, lines up to 100 characters.
- `_name` is module-private. `__name` is for class internals ("protected",
  name-mangled).
- The body of an `if`, `for` or `while` goes on its own line (PEP 8). A
  simple loop that builds a list, a set or a dict is a comprehension, with an
  `if` to filter when needed: `[x.name for x in items if x.enabled]`.
- Simple conditional assignment is a ternary, not an `if`/`else` block:
  `label = "items" if items else "none"`.
- ruff config in `pyproject.toml`: `line-length = 100`,
  `target-version = "py311"`, rules `E`, `F`, `I`, `UP`, `B`.
- The layout is the one `ruff format` produces, except a long list of plain
  values (e.g. codes), which keeps several per line with a trailing
  `# fmt: skip`.
- Docstrings are added on need, not by default: for a substantial class or
  function whose use the name and the signature don't tell, or for code whose
  API docs are generated from them.
