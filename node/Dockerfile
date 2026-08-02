FROM node:20-alpine

ENV INPUT_DIR=/app/src
ENV OUTPUT_DIR=/app/dist

WORKDIR /opt/minimum
COPY scripts/ ./scripts/

# Install terser in an isolated directory and clean up
RUN npm init -y && \
    npm install terser && \
    rm package.json package-lock.json && \
    npm cache clean --force && \
    chmod +x scripts/optimize.sh

ENTRYPOINT ["/opt/minimum/scripts/optimize.sh"]
