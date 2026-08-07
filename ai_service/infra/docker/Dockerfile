FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY pyproject.toml README.md ./
COPY app ./app
COPY main.py ./
COPY infra/docker/entrypoint.sh /entrypoint.sh

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install ".[dev]"

# Pre-download the embedding model at build time so startup and first
# requests never block on HuggingFace. Set HF_TOKEN at build for unthrottled
# downloads: docker build --build-arg HF_TOKEN=<token>.
ARG HF_TOKEN=""
ENV HF_TOKEN=$HF_TOKEN
RUN python -c "from fastembed import TextEmbedding; TextEmbedding(model_name='BAAI/bge-small-en-v1.5')"

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]