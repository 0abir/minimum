FROM alpine:3.19

ENV INPUT_DIR=/app/src
ENV OUTPUT_DIR=/app/dist

WORKDIR /opt/minimum
COPY scripts/ ./scripts/

# Install Node.js, Python, PHP, shfmt, minify
RUN apk add --no-cache nodejs npm python3 py3-pip curl tar php shfmt && \
    # Install Node tools in an isolated directory
    npm init -y && npm install terser luamin && rm package.json package-lock.json && npm cache clean --force && \
    # Install Python tools
    pip install --no-cache-dir --break-system-packages python-minifier && \
    # Install tdewolff/minify
    curl -L https://github.com/tdewolff/minify/releases/download/v2.20.19/minify_linux_amd64.tar.gz | tar xz -C /usr/local/bin minify && \
    chmod +x /opt/minimum/scripts/optimize.sh

ENTRYPOINT ["/opt/minimum/scripts/optimize.sh"]
