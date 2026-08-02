const fs = require('fs');
const path = require('path');
const { minify } = require('terser');

const targetDir = process.env.TARGET_DIR || '/app/dist';
const ignorePattern = process.env.IGNORE_PATTERN ? new RegExp(process.env.IGNORE_PATTERN) : /node_modules|\.git/;

async function processDirectory(dir) {
    const items = fs.readdirSync(dir);

    for (const item of items) {
        const fullPath = path.join(dir, item);

        if (ignorePattern.test(fullPath)) {
            continue;
        }

        const stat = fs.statSync(fullPath);

        if (stat.isDirectory()) {
            await processDirectory(fullPath);
        } else if (stat.isFile()) {
            if (item.endsWith('.js') || item.endsWith('.mjs') || item.endsWith('.cjs')) {
                if (item.includes('.min.')) {
                    continue;
                }

                const code = fs.readFileSync(fullPath, 'utf8');
                try {
                    const result = await minify(code, {
                        compress: { passes: 2, evaluate: true, dead_code: true },
                        format: { comments: false }
                    });
                    
                    if (result.code) {
                        fs.writeFileSync(fullPath, result.code);
                        console.log(`[OK] Minified JS: ${fullPath}`);
                    }
                } catch (err) {
                    console.warn(`[WARN] Failed to minify JS ${fullPath}, kept as-is. Error: ${err.message}`);
                }
            }
        }
    }
}

async function main() {
    console.log(`Starting Node in-place minification in ${targetDir}...`);
    try {
        await processDirectory(targetDir);
    } catch (err) {
        console.error('Fatal error during minification:', err);
    }
}

main();
