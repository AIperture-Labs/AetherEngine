---
name: lua-test
description: Run Lua tests with busted. Use to verify a Lua change or after fixing a failing Lua test.
---

# Lua test

Run `busted` from the project root. The configuration comes from `.busted`;
don't override it with flags. Specs are `*_spec.lua` files under `tests/`.

If busted prints `0 successes`, report exactly that: nothing ran, so it is not
a passing run.
