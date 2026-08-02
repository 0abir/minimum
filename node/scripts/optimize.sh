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
    # Use /. to copy hidden files properly
    cp -a "$INPUT_DIR"/. "$OUTPUT_DIR"/ || true
fi

export TARGET_DIR="$OUTPUT_DIR"
node /opt/minimum/scripts/minify-node.js
echo "Optimization complete!"
