#!/bin/sh
set -e

INPUT_DIR="${INPUT_DIR:-/app/src}"
OUTPUT_DIR="${OUTPUT_DIR:-/app/dist}"

echo "Starting Node optimization..."
echo "INPUT_DIR: $INPUT_DIR"
echo "OUTPUT_DIR: $OUTPUT_DIR"

if [ "$INPUT_DIR" != "$OUTPUT_DIR" ]; then
    echo "Copying files from $INPUT_DIR to $OUTPUT_DIR..."
    mkdir -p "$OUTPUT_DIR"
    cp -a "$INPUT_DIR"/. "$OUTPUT_DIR"/ || true
fi

export TARGET_DIR="$OUTPUT_DIR"
node /opt/minimum/scripts/minify-node.js

if [ -d "$TARGET_DIR/node_modules" ]; then
    echo "Aggressively pruning node_modules..."
    find "$TARGET_DIR/node_modules" -type f \( \
          -iname "*.md" -o -iname "*.markdown" -o -iname "license*" \
          -o -iname "*.map" -o -iname "*.ts" \
        \) -delete \
     && find "$TARGET_DIR/node_modules" -type d \( \
          -iname "test" -o -iname "tests" -o -iname "__tests__" \
          -o -iname ".github" -o -iname "docs" -o -iname "example*" \
        \) -prune -exec rm -rf {} + || true
fi

echo "Optimization complete!"
