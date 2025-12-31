#!/bin/bash
set -e

# Initialize Codex configuration directory if needed
if [ ! -d "$HOME/.codex" ]; then
    mkdir -p "$HOME/.codex"
fi

# Fix SSH permissions if mounted
if [ -d "$HOME/.ssh" ]; then
    # Create a writable copy if needed for known_hosts
    if [ ! -w "$HOME/.ssh" ]; then
        mkdir -p "$HOME/.ssh-local"
        cp -r "$HOME/.ssh/"* "$HOME/.ssh-local/" 2>/dev/null || true
        export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=$HOME/.ssh-local/known_hosts -i $HOME/.ssh/id_rsa -i $HOME/.ssh/id_ed25519 2>/dev/null"
    fi
fi

# Configure git to use safe directory for mounted volumes
git config --global --add safe.directory /workspace 2>/dev/null || true

# Display helpful info on first run
if [ ! -f "$HOME/.codex/.initialized" ]; then
    echo "=================================="
    echo "  OpenAI Codex Docker Container"
    echo "=================================="
    echo ""
    echo "Workspace: /workspace"
    echo "Config:    $HOME/.codex"
    echo ""
    if [ -z "$OPENAI_API_KEY" ]; then
        echo "Note: OPENAI_API_KEY not set"
        echo "Run with: -e OPENAI_API_KEY=your-key"
        echo "Or use 'codex login' for OAuth"
        echo ""
        echo "For OAuth, expose port 1455:"
        echo "  docker run -p 1455:1455 ..."
    else
        echo "API Key: configured"
    fi
    echo ""
    touch "$HOME/.codex/.initialized"
fi

# Execute the command
exec "$@"
