FROM node:24-alpine

ENV INPUT_DIR=/app/src
ENV OUTPUT_DIR=/app/dist

WORKDIR /opt/minimum
COPY scripts/ ./scripts/

RUN npm init -y && \
    npm install terser && \
    rm package.json package-lock.json && \
    npm cache clean --force && \
    chmod +x scripts/optimize.sh

ENTRYPOINT ["/opt/minimum/scripts/optimize.sh"]
