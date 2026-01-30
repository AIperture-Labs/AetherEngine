# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://just.systems/man/en/


# Update submodules from remotes (pulls from origin/forks)
submodules-update:
    git submodule update --remote --merge

# Initialize and update submodules recursively
submodules-init:
    git submodule update --init --recursive

# Show all remotes for each submodule
submodules-remote:
    git submodule foreach 'echo "=== $name ===" && git remote -v'

# Sync submodules with upstream repositories (fetch + merge from upstream)
submodules-sync:
    @echo "Syncing submodules with upstream..."
    git submodule foreach 'git fetch upstream && (git merge upstream/main 2>$null || git merge upstream/master)'

# Push submodule changes to forks (origin)
submodules-push:
    @echo "Pushing submodule changes to forks..."
    git submodule foreach 'git push origin HEAD'

# Full sync: upstream -> local -> fork (fetch from upstream, merge, push to fork)
submodules-full-sync:
    @echo "Fetching from upstream repositories..."
    git submodule foreach 'git fetch upstream'
    @echo "Merging upstream changes..."
    git submodule foreach '(git merge upstream/main 2>$null || git merge upstream/master)'
    @echo "Pushing to forks..."
    git submodule foreach 'git push origin HEAD'
    @echo "Updating parent repository..."
    git add extern/
    git commit -m "chore: sync submodules with upstream" || echo "No changes to commit"

# Fetch all remotes for all submodules
submodules-fetch-all:
    git submodule foreach 'git fetch --all'

# Show status of all submodules
submodules-status:
    git submodule status
    @echo ""
    @echo "Detailed status:"
    git submodule foreach 'echo "=== $name ===" && git status -s'

# Show current branch for each submodule
submodules-branch:
    git submodule foreach 'echo "$name: $(git branch --show-current)"'
