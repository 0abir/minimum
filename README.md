# Minimum Docker Optimizer

A super lightweight, multi-stage Docker image suite designed to minify, optimize, and reduce the size of your projects automatically.

## Overview

This project provides Docker images that can be used directly in your multi-stage builds to automatically minify your code.

- **Mother Image (`0abir/minimum:latest`)**: Auto-detects project languages. Includes tools for Node.js, Python, HTML, CSS, JSON, SVG, XML.
- **Node Tag (`0abir/minimum:node`)**: A hyper-lightweight Alpine image dedicated solely to JavaScript minification using Terser.
- **Python Tag (`0abir/minimum:python`)**: A lightweight image dedicated to Python minification.

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

You can customize the minification process by setting these environment variables before running the optimizer:

- `INPUT_DIR`: The directory containing your source code (default: `/app/src`).
- `OUTPUT_DIR`: The directory where optimized code will be placed (default: `/app/dist`). If `INPUT_DIR` matches `OUTPUT_DIR`, files are optimized in-place.
- `LANGUAGE`: Force a specific language pipeline (`node`, `python`, `auto`, `mother`). (default: `auto`).
- `IGNORE_PATTERN`: A regex string to ignore specific folders or files (default: `node_modules|\.git`).

## Building the Images

Run the included build script to build the images locally:

```bash
./build.sh your_dockerhub_username
```

This will build `your_dockerhub_username/minimum:latest`, `:node`, and `:python`.
