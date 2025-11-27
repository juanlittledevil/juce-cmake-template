# JUCE project environment setup
# This file is sourced by ~/.zshrc when entering the project directory
#
# To make this work, add the following to your ~/.zshrc:
#
# # Source zsh.profile from repo root if running in VS Code and in a git repo
# if [[ $TERM_PROGRAM == vscode ]] && git rev-parse --git-dir > /dev/null 2>&1; then
#     source "$(git rev-parse --show-toplevel)/zsh.profile"
# fi

# Set PROJECT_HOME to the repository root
export PROJECT_HOME=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Add scripts directory to PATH
export PATH="${PROJECT_HOME}/scripts:$PATH"
