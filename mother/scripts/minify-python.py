import os
import sys
import re
import python_minifier

target_dir = os.environ.get('TARGET_DIR', '/app/dist')
ignore_pattern = os.environ.get('IGNORE_PATTERN', r'node_modules|\.git')

try:
    ignore_regex = re.compile(ignore_pattern)
except re.error:
    ignore_regex = None

def process_directory(directory):
    for root, dirs, files in os.walk(directory):
        if ignore_regex:
            for d in list(dirs):
                full_dir = os.path.join(root, d)
                if ignore_regex.search(full_dir):
                    print(f"[SKIP] Ignored by pattern: {full_dir}")
                    dirs.remove(d)

        for file in files:
            full_path = os.path.join(root, file)
            if ignore_regex and ignore_regex.search(full_path):
                print(f"[SKIP] Ignored by pattern: {full_path}")
                continue

            if file.endswith('.py'):
                full_path = os.path.join(root, file)
                
                with open(full_path, 'r', encoding='utf-8') as f:
                    code = f.read()

                try:
                    minified = python_minifier.minify(
                        code,
                        remove_annotations=True,
                        remove_pass=True,
                        remove_literal_statements=True,
                        combine_imports=True,
                        hoist_literals=True,
                        rename_locals=True,
                        preserve_locals=None,
                        rename_globals=False
                    )
                    with open(full_path, 'w', encoding='utf-8') as f:
                        f.write(minified)
                    print(f"[OK] Minified Python: {full_path}")
                except Exception as e:
                    print(f"[WARN] Failed to minify Python {full_path}, kept as-is. Error: {e}")

if __name__ == '__main__':
    print(f"Starting Python in-place minification in {target_dir}...")
    process_directory(target_dir)
