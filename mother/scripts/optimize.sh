#!/bin/sh
set -e

INPUT_DIR="${INPUT_DIR:-/app/src}"
OUTPUT_DIR="${OUTPUT_DIR:-/app/dist}"

echo "Starting Universal optimization..."
echo "INPUT_DIR: $INPUT_DIR"
echo "OUTPUT_DIR: $OUTPUT_DIR"

if [ "$INPUT_DIR" != "$OUTPUT_DIR" ]; then
    echo "Copying files from $INPUT_DIR to $OUTPUT_DIR..."
    mkdir -p "$OUTPUT_DIR"
    cp -a "$INPUT_DIR"/. "$OUTPUT_DIR"/ || true
fi

export TARGET_DIR="$OUTPUT_DIR"

if command -v node >/dev/null 2>&1; then
    echo "Running Node/Lua minification..."
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
fi

if command -v python3 >/dev/null 2>&1; then
    echo "Running Python minification..."
    python3 /opt/minimum/scripts/minify-python.py
fi

if command -v minify >/dev/null 2>&1; then
    echo "Running HTML/CSS/JSON/SVG minification..."
    minify -v -r --match="\.(html|css|json|svg|xml)$" -o "$TARGET_DIR/" "$TARGET_DIR/" || true
fi

if command -v php >/dev/null 2>&1; then
    echo "Running PHP minification..."
    find "$TARGET_DIR" -type f -name "*.php" -print0 | while IFS= read -r -d '' file; do
        if php -w "$file" > "$file.tmp" && mv "$file.tmp" "$file"; then
            echo "[OK] Minified PHP: $file"
        else
            echo "[WARN] Failed to minify PHP: $file"
            rm -f "$file.tmp"
        fi
    done
fi

if command -v shfmt >/dev/null 2>&1; then
    echo "Running Shell minification..."
    find "$TARGET_DIR" -type f -name "*.sh" -print0 | while IFS= read -r -d '' file; do
        if shfmt -mn "$file" > "$file.tmp" && mv "$file.tmp" "$file"; then
            echo "[OK] Minified Shell script: $file"
        else
            echo "[WARN] Failed to minify Shell script: $file"
            rm -f "$file.tmp"
        fi
    done
fi

echo "Optimization complete!"
