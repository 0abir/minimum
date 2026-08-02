FROM node:24-alpine

ENV INPUT_DIR=/app/src
ENV OUTPUT_DIR=/app/dist

WORKDIR /opt/minimum
COPY scripts/ ./scripts/

RUN cd scripts && \
    npm init -y && \
    npm install terser && \
    npm cache clean --force && \
    chmod +x optimize.sh

ENTRYPOINT ["/opt/minimum/scripts/optimize.sh"]
