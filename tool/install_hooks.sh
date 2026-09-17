#!/bin/sh
set -eu

root=$(git rev-parse --show-toplevel)
hook_dir="$root/.githooks"
existing=$(git config --get core.hooksPath || true)
if [ -n "$existing" ] && [ "$existing" != ".githooks" ] && [ "$existing" != "$hook_dir" ]; then
  echo "A different hooksPath is configured. Review it before replacing hooks." >&2
  exit 1
fi
if [ -z "$existing" ] && [ -x "$(git rev-parse --git-path hooks)/pre-push" ]; then
  echo "An active pre-push hook already exists. Review it before replacing hooks." >&2
  exit 1
fi
if [ ! -x "$hook_dir/pre-push" ]; then
  echo "The pre-push hook is missing or not executable." >&2
  exit 1
fi
if git config --local --get core.worktree >/dev/null 2>&1; then
  echo "Explicit core.worktree requires manual review before enabling worktree configuration." >&2
  exit 1
fi
command -v python3 >/dev/null
command -v fvm >/dev/null
python3 -c 'import fcntl'
git config --local extensions.worktreeConfig true
git config --worktree core.hooksPath .githooks
echo "Pre-push hook enabled for this worktree only."
