# Minimum Docker Optimizer

A super lightweight, multi-stage Docker image suite designed to minify, optimize, and reduce the size of your projects automatically.

## Overview

This project provides Docker images that can be used directly in your multi-stage builds to automatically minify your code. The architecture is completely isolated to ensure Docker build contexts remain tiny and optimized.

- **Mother Image (`0abir/minimum:latest`)**: Auto-detects project languages. Includes tools for Node.js, Python, HTML, CSS, JSON, SVG, XML, PHP, Lua, and Shell scripts.
- **Node Tag (`0abir/minimum:node`)**: A hyper-lightweight Alpine image dedicated solely to JavaScript minification using Terser.
- **Python Tag (`0abir/minimum:python`)**: A lightweight image dedicated strictly to Python minification.

## Supported Languages

The `mother` image will automatically detect and safely optimize:
- **Node.js / JavaScript**: (`.js`, `.mjs`, `.cjs`) safely via Terser (skips already `.min.` files).
- **Python**: (`.py`) via `python-minifier`.
- **Web Assets**: (`.html`, `.css`, `.json`, `.svg`, `.xml`) via `tdewolff/minify`.
- **PHP**: (`.php`) via PHP's native whitespace/comment stripper.
- **Lua**: (`.lua`) via `luamin`.
- **Shell Scripts**: (`.sh`) via `shfmt`.

## ✨ Powerful Features

- **Aggressive Node Pruning**: If your `$TARGET_DIR` contains a `node_modules` folder, the optimizer will automatically strip out all unnecessary bloat from your dependencies (e.g., Markdown files, Licenses, Source Maps, TypeScript definitions, and entire `test`, `docs`, and `.github` folders) to drastically reduce your final image size.
- **Isolated Internals**: The minification tools (like Terser) are installed in a hidden internal folder, and their `package.json` is completely deleted. This guarantees zero conflict if you run `npm` commands inside the container.
- **Detailed Logging**: Every action is clearly logged (`[OK] Minified`, `[SKIP] Already minified`, `[SKIP] Ignored by pattern`, `[WARN] Failed`) so you always have perfect transparency in your CI/CD pipeline.

## The `node_modules` Lifecycle

The optimizer **does not** run `npm install` for you. Here is exactly how you handle dependencies:
1. **You install them:** You run `RUN npm install` in your Dockerfile (usually inside `/app/src`).
2. **The Optimizer prunes them:** When our script runs, it minifies your code AND aggressively prunes your `node_modules` folder to make it tiny.
3. **You copy them out:** You use `COPY --from=optimizer` to pull the pruned `node_modules` safely into your final production image.

---

## How to use in your Multi-Stage Dockerfile

### Example 1: Node.js Project (Installing & Optimizing Dependencies)

```dockerfile
# Step 1: Install Dependencies & Optimize
FROM 0abir/minimum:node AS optimizer
WORKDIR /app/src

# Install dependencies (they will be huge at first!)
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of your app code
COPY . .

# Run the optimizer in-place to minify code AND aggressively prune the node_modules!
ENV INPUT_DIR=/app/src
ENV OUTPUT_DIR=/app/src
RUN /opt/minimum/scripts/optimize.sh

# Step 2: Final Production Image
FROM node:20-alpine
WORKDIR /app

# Copy the completely minified app (with the pruned node_modules) over!
COPY --from=optimizer /app/src /app

CMD ["node", "index.js"]
```

### Example 2: Pulling out `node_modules` and `src` Separately

If you want granular control over exactly what goes into your final image, you can pull specific folders out of the optimizer independently:

```dockerfile
# ... (optimizer step happens above) ...

# Step 2: Final Production Image
FROM node:20-alpine
WORKDIR /app

# 1. Pull out ONLY the aggressively pruned node_modules
COPY --from=optimizer /app/src/node_modules ./node_modules

# 2. Pull out ONLY your minified source folder
COPY --from=optimizer /app/src/src ./src

# 3. Pull out specific files
COPY --from=optimizer /app/src/package.json ./
COPY --from=optimizer /app/src/index.js ./

CMD ["node", "index.js"]
```

### Example 3: In-Place Optimization (Mother Image)

```dockerfile
FROM 0abir/minimum:latest AS optimizer
COPY . /app/src
ENV INPUT_DIR=/app/src
ENV OUTPUT_DIR=/app/src
# Since INPUT_DIR == OUTPUT_DIR, it will minify files in-place!
RUN /opt/minimum/scripts/optimize.sh

FROM nginx:alpine
COPY --from=optimizer /app/src /usr/share/nginx/html
```

## Environment Variables

Customize the minification process by setting these environment variables before running the optimizer step:

- `INPUT_DIR`: The directory containing your source code (default: `/app/src`).
- `OUTPUT_DIR`: The directory where optimized code will be placed (default: `/app/dist`). If `INPUT_DIR` matches `OUTPUT_DIR`, files are optimized in-place (which also correctly preserves hidden files like `.env`).
- `IGNORE_PATTERN`: A regex string to ignore specific folders or files (default: `node_modules|\.git`). *(Note: The aggressive pruning script explicitly targets `node_modules` independently, but the JS minifier ignores it so it doesn't waste time trying to minify third-party code).*

## Automated Publishing (GitHub Actions)

This repository is equipped with a manual GitHub Action workflow (`.github/workflows/docker-publish.yml`). 
To automatically publish these images to your Docker Hub account:
1. Go to your GitHub repository **Settings** > **Secrets and variables** > **Actions**.
2. Add a `DOCKERHUB_USERNAME` secret.
3. Add a `DOCKERHUB_TOKEN` secret (Ensure the access token has **Read & Write** scopes).
4. Go to the **Actions** tab in your repository.
5. Select the **Publish Docker Images** workflow and click **Run workflow**.

## Building the Images Locally

Run the included bash script to build all the images on your local machine:

```bash
./build.sh your_dockerhub_username
```
