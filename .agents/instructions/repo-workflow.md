# Repository workflow

Branches, worktrees, commits, pull requests, releases and tracking.
Read this before any git, branch, commit, PR or issue operation.

## Branches

- `main` — the stable branch, protected: no deletion, no force push. It only
  receives `dev`, through a pull request merged with a merge commit.
  Releases are tagged on it.
- `dev` — the default and integration branch, protected the same way. It
  receives feature and fix branches through pull requests, squash-merged.
- Never commit directly on `main` or `dev`.
- Feature and fix branches — one per change, created from `dev`, named
  `<type>/<short-description>` where `<type>` is a Conventional Commits type:
  `feat/`, `fix/`, `docs/`, `refactor/`, `perf/`, `test/`, `build/`, `ci/`,
  `chore/`, `style/`, `revert/` (e.g. `feat/vulkan-swapchain`).
- Never enable automatic deletion of merged branches on the remote. Never
  delete a branch, locally or on the remote, without asking the user first.
  `main` and `dev` are permanent.

## Worktrees

All work happens in worktrees under `.worktrees/`, ignored by git, one per
branch. Name each worktree after its branch, so the path carries the
Conventional Commits type. Create it from `dev`; once the branch is merged
and the user agrees, remove the worktree and its branch:

```sh
git worktree add -b feat/my-new-feature .worktrees/feat/my-new-feature dev
git worktree remove .worktrees/feat/my-new-feature
git branch -d feat/my-new-feature
```

A worktree containing submodules cannot be moved with `git worktree move`:
move the directory, then run `git worktree repair`.

## GitHub protections

Settings that enforce the rules above; check them with
`gh api repos/{owner}/{repo}/rulesets`. Change them only when the user asks.

- Repository: default branch `dev`; squash merge and merge commit allowed,
  rebase disabled; no automatic deletion of merged branches.
- Ruleset `dev`, no bypass actor: deletion and force push blocked, linear
  history required, changes through a pull request, squash only.
- Ruleset `main`, no bypass actor: deletion and force push blocked, changes
  through a pull request, merge commit only.
- Both: 0 approving reviews while there is a single maintainer.
- Not yet enforced: required status checks (no CI yet) and required reviews.

## Commits

- Follow Conventional Commits:
  <https://www.conventionalcommits.org/en/v1.0.0/>. Read that spec when in
  doubt. Format: `type(scope): description`, with `!` after the type or
  scope, or a `BREAKING CHANGE:` footer, for a breaking change. The scope is
  the area touched (`cmake`, `core`, `deps`, `agents`, `readme`…).
- Keep commits small and atomic: one coherent change, no unrelated work
  mixed in.
- Commit a step only after the user has reviewed it.
- An agent may co-sign its commits and PRs with its own name and the model
  used, e.g. `Co-Authored-By: <agent> <model> <<email>>` as a commit trailer
  or at the end of a PR description. If the user opposes it, don't.

## Pull requests

- Feature or fix branch → `dev`, merged with a squash merge. The PR title
  follows Conventional Commits: the squash keeps it as the commit message.
- `dev` → `main`, merged with a merge commit, so `main` keeps every squashed
  change of `dev`. Only when the user asks.
- Parked in-progress code (an experiment that doesn't work yet but is worth
  keeping) lives in a draft PR, with notes and findings in its description —
  not in a separate Markdown write-up.

## Releases

The project version is `VERSION` in `project()` (`CMakeLists.txt`). Before
each tag, a `chore(release): vX.Y.Z` PR into `dev` sets it to the version
about to be tagged; `dev` is then merged into `main`, and the release is
tagged by hand as semver `vX.Y.Z` on that merge commit, once CI is green.
Never tag unless the user asks.

Pre-releases follow semver: `vX.Y.Z-alpha.N`, then `-beta.N`, then `-rc.N`,
all before `vX.Y.Z`. `project(VERSION)` only takes numbers, so it holds the
`X.Y.Z` the pre-release leads to; the label lives in the tag only.

## Tracking

Work is tracked with GitHub issues, and the roadmap with the organization's
GitHub Project; the global plan lives in the `AIperture-Labs/.github`
repository. An issue is the unit of work handed to an agent: it states its
goal and how to verify it, and the branch and PR reference it. Prefer issues
and PRs to plan or to-do files in the repository.
