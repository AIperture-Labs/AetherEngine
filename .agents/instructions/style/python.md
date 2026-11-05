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
- One line when the statement and its action are short:
  `if not items: return`, `for x in xs: seen.add(x)`.
- Simple conditional assignment is a ternary, not an `if`/`else` block:
  `label = "items" if items else "none"`.
- ruff config in `pyproject.toml`: `line-length = 100`,
  `target-version = "py311"`, rules `E`, `F`, `I`, `UP`, `B`, ignoring `E701`
  and `E702` (one-line statements). Don't run `ruff format`: it expands
  one-line statements.
