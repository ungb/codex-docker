FROM node:22-slim

LABEL maintainer="ungb"
LABEL description="OpenAI Codex CLI in a Docker container"
LABEL org.opencontainers.image.source="https://github.com/ungb/codex-docker"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    openssh-client \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install OpenAI Codex CLI globally
RUN npm install -g @openai/codex

# Create non-root user for security
RUN useradd -m -s /bin/bash coder \
    && mkdir -p /home/coder/.codex \
    && chown -R coder:coder /home/coder

# Set up workspace directory
RUN mkdir -p /workspace && chown coder:coder /workspace

# Copy entrypoint script
COPY --chown=coder:coder entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER coder
WORKDIR /workspace

# Environment variables
ENV HOME=/home/coder
ENV CODEX_CONFIG_DIR=/home/coder/.codex
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

# Expose OAuth callback port
EXPOSE 1455

ENTRYPOINT ["/entrypoint.sh"]
CMD ["codex"]
