FROM python:3.11-alpine

ENV INPUT_DIR=/app/src
ENV OUTPUT_DIR=/app/dist

WORKDIR /opt/minimum
COPY scripts/ ./scripts/

# Install python-minifier
RUN pip install --no-cache-dir python-minifier && \
    chmod +x scripts/optimize.sh

ENTRYPOINT ["/opt/minimum/scripts/optimize.sh"]
