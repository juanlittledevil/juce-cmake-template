#!/bin/bash

# generate_docs.sh - Generate HTML and Markdown documentation from TurnTabby C++ project
# This script uses Doxygen to parse C++ headers and generate HTML documentation
# with diagrams and class hierarchies, then converts XML output to Markdown.

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/docs/doxydocs"
XML_DIR="$OUTPUT_DIR/xml"
MARKDOWN_DIR="$OUTPUT_DIR/markdown"

echo "Generating documentation for TurnTabby..."
echo "Project root: $PROJECT_ROOT"
echo "Output directory: $OUTPUT_DIR"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Change to project root
cd "$PROJECT_ROOT"

# Run Doxygen to generate HTML and XML
echo "Running Doxygen..."
doxygen Doxyfile

# Check if HTML was generated
if [ ! -d "$OUTPUT_DIR/html" ]; then
    echo "Error: Doxygen HTML output not found in $OUTPUT_DIR/html"
    exit 1
fi

# Check if XML was generated
if [ ! -d "$XML_DIR" ]; then
    echo "Error: Doxygen XML output not found in $XML_DIR"
    exit 1
fi

# Convert XML to Markdown
echo "Converting XML to Markdown..."
python3 "$SCRIPT_DIR/xml_to_markdown.py" "$XML_DIR" "$MARKDOWN_DIR"

# Check if Markdown was generated
if [ ! -d "$MARKDOWN_DIR" ]; then
    echo "Error: Markdown output not found in $MARKDOWN_DIR"
    exit 1
fi

# Clean up XML directory
echo "Cleaning up XML intermediate files..."
rm -rf "$XML_DIR"

# Clean up any leftover LaTeX directory (in case of old Doxyfile)
if [ -d "$OUTPUT_DIR/latex" ]; then
    echo "Cleaning up LaTeX directory..."
    rm -rf "$OUTPUT_DIR/latex"
fi

echo "Documentation generation complete."
echo "HTML documentation is available in: $OUTPUT_DIR/html"
echo "Open $OUTPUT_DIR/html/index.html in your browser to view the HTML documentation."
echo "Markdown documentation is available in: $MARKDOWN_DIR"
echo "You can view the Markdown files directly in your editor or IDE."