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

## How to use in your Multi-Stage Dockerfile

### Example 1: Node.js Project (Using the Node tag)

```dockerfile
# Step 1: Optimize your code
FROM 0abir/minimum:node AS optimizer
# By default INPUT_DIR is /app/src and OUTPUT_DIR is /app/dist
COPY ./src /app/src
RUN /opt/minimum/scripts/optimize.sh

# Step 2: Build your actual image
FROM node:20-alpine
WORKDIR /app
# Copy the minified code from the optimizer stage
COPY --from=optimizer /app/dist ./src
CMD ["node", "src/index.js"]
```

### Example 2: In-Place Optimization (Mother Image)

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
- `IGNORE_PATTERN`: A regex string to ignore specific folders or files (default: `node_modules|\.git`).

## Automated Publishing (GitHub Actions)

This repository is equipped with a GitHub Action workflow (`.github/workflows/docker-publish.yml`). 
To automatically publish these images to your Docker Hub account:
1. Go to your GitHub repository **Settings** > **Secrets and variables** > **Actions**.
2. Add a `DOCKERHUB_USERNAME` secret.
3. Add a `DOCKERHUB_TOKEN` secret (Ensure the access token has **Read & Write** scopes).
4. Push your code to the `main` branch.

## Building the Images Locally

Run the included bash script to build all the images on your local machine:

```bash
./build.sh your_dockerhub_username
```
