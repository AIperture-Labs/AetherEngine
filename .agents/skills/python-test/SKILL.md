---
name: python-test
description: Run Python tests with pytest. Use to verify a Python change or after fixing a failing test.
---

# Python test

Run `uv run pytest -q` from the project root. Configuration comes from the
project's pytest config (`[tool.pytest.ini_options]` in `pyproject.toml`) and
its `conftest.py` files (fixtures, hooks); don't override it with flags.
