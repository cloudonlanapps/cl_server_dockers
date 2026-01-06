FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libmagic1 \
    libmagic-dev \
    file \
    ffmpeg \
    libimage-exiftool-perl \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv

ENV PYTHONUNBUFFERED=1
ENV CL_SERVER_DIR=/data

WORKDIR /app

ARG REPO_URL
ARG REPO_REF=main

RUN git clone --depth 1 --branch ${REPO_REF} ${REPO_URL} .

RUN mkdir -p /data



CMD ["bash"]
