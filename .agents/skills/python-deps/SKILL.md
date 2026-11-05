---
name: python-deps
description: Install, add or update Python dependencies and environments with uv. Use when syncing the environment, adding a package or touching uv.lock.
---

# Python dependencies

- `uv sync` creates or updates the environment from `pyproject.toml`.
- `uv add <package>` adds a runtime dependency; `uv add --optional dev <package>`
  adds a dev one.
- Commit `uv.lock` with every dependency change.
