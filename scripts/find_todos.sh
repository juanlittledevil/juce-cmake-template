#!/usr/bin/env zsh
# Quick TODO finder for this repo.
# Usage: ./scripts/find_todos.sh [PATTERN]
# Default PATTERN: TODO

pattern="${1:-TODO}"

# prefer ripgrep, then git grep, then grep
if command -v rg >/dev/null 2>&1; then
  rg --hidden --glob '!.git/*' --glob '!build/**' --glob '!JUCE/**' --line-number "$pattern"
elif command -v git >/dev/null 2>&1; then
  git grep -n --line-number -e "$pattern" || true
else
  grep -RIn --line-number --exclude-dir=.git --exclude-dir=build --exclude-dir=JUCE "$pattern" . || true
fi

exit 0
