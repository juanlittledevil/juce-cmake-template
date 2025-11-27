#!/bin/bash

# docs.sh - Launch project documentation in the default browser
# This script opens the generated Doxygen HTML documentation in your default browser.

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_INDEX="$PROJECT_ROOT/docs/doxydocs/html/index.html"

echo "Opening documentation..."

# Check if documentation exists
if [ ! -f "$DOCS_INDEX" ]; then
    echo "Error: Documentation not found at $DOCS_INDEX"
    echo "Run './scripts/generate_docs.sh' first to generate the documentation."
    exit 1
fi

# Open in default browser (macOS)
if command -v open >/dev/null 2>&1; then
    echo "Opening documentation in default browser..."
    open "$DOCS_INDEX"
elif command -v xdg-open >/dev/null 2>&1; then
    echo "Opening documentation in default browser..."
    xdg-open "$DOCS_INDEX"
elif command -v brave-browser >/dev/null 2>&1; then
    echo "Opening documentation in Brave browser..."
    brave-browser "$DOCS_INDEX"
elif command -v google-chrome >/dev/null 2>&1; then
    echo "Opening documentation in Chrome..."
    google-chrome "$DOCS_INDEX"
elif command -v firefox >/dev/null 2>&1; then
    echo "Opening documentation in Firefox..."
    firefox "$DOCS_INDEX"
else
    echo "Error: No suitable browser found. Please open $DOCS_INDEX manually."
    exit 1
fi

echo "Documentation opened successfully!"