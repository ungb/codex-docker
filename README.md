# Codex Docker

Run [OpenAI Codex CLI](https://github.com/openai/codex) in a Docker container. Codex is OpenAI's lightweight coding agent that runs in your terminal.

## Quick Start

```bash
# Pull and run (replace with your API key)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=your-key \
  ungb/codex
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- [OpenAI API key](https://platform.openai.com/api-keys) or ChatGPT account for OAuth

## Usage Examples

### Basic Interactive Session

```bash
# Start an interactive Codex session
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

### One-Shot Commands (Non-Interactive)

Use `codex exec` (or `codex e`) for non-interactive mode:

```bash
# Ask a question about your codebase
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex exec "explain the architecture of this project"

# Generate code
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex exec "add input validation to the user form"

# Fix bugs (with auto-approval)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex exec --ask-for-approval never "fix the type errors in src/utils"

# JSON output (for scripts/automation)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex exec --json "list all TODO comments"
```

### Piping Input

```bash
# Pipe prompt from stdin
echo "explain this code" | docker run -i --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex exec -
```

### With Full Configuration (Recommended)

```bash
# Full setup with persistent config, git, and SSH
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

### Using Docker Compose

1. Copy `docker-compose.yml` to your project:

```bash
curl -O https://raw.githubusercontent.com/ungb/codex-docker/main/docker-compose.yml
```

2. Create a `.env` file:

```bash
echo "OPENAI_API_KEY=your-key-here" > .env
```

3. Run:

```bash
# Interactive session
docker compose run --rm codex

# One-shot command (non-interactive)
docker compose run --rm codex codex exec "explain this code"
```

### Full Auto Mode (Careful!)

```bash
# Auto-approve all changes (use with caution)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex --full-auto "implement the TODO items in this file"

# YOLO mode - no approvals, no sandbox (dangerous!)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex exec --yolo "fix the failing tests"
```

### Quiet Mode

```bash
# Less verbose output
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex --quiet
```

## Sharing Your Codex Configuration

The `~/.codex` directory contains your Codex configuration and session history.

### What's in ~/.codex

```
~/.codex/
├── config.json           # Settings and preferences
├── instructions.md       # Custom instructions for Codex
└── history/              # Session history
```

### Mount Your Configuration

```bash
# Share your Codex config folder
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

### Custom Instructions

Create `~/.codex/instructions.md` with custom instructions that Codex will follow:

```markdown
# My Codex Instructions

- Always use TypeScript strict mode
- Prefer functional programming patterns
- Add JSDoc comments to public functions
```

Then mount it:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

## MCP (Model Context Protocol) Support

> **Warning**: MCP support in Docker containers is limited and may require additional configuration.

### Current Limitations

MCP servers may not work out of the box in Docker because:

1. **Stdio-based MCP servers** need the server binary installed inside the container
2. **Network-based MCP servers** need proper network configuration
3. **MCP servers that access local resources** need those resources mounted
4. **Authentication** for MCP servers may not transfer into the container

### What Might Work

| MCP Type | Status | Notes |
|----------|--------|-------|
| HTTP/SSE servers (remote) | May work | Requires `--network host` or port mapping |
| Stdio servers (local) | Unlikely | Server must be installed in container |
| Servers needing local files | Partial | Files must be mounted |
| Servers with OAuth | Unlikely | Auth flow may not complete |

### Attempting MCP with Docker

```bash
# Mount MCP config and use host network
docker run -it --rm \
  --network host \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

### Building a Custom Image with MCP Servers

```dockerfile
FROM ungb/codex:latest

USER root
RUN npm install -g @modelcontextprotocol/some-server
USER coder
```

### MCP Investigation Needed

Full MCP support requires further investigation. If you have solutions, please open an issue or PR!

## Authentication

### Option 1: API Key (Recommended for Docker)

Get an API key from [OpenAI Platform](https://platform.openai.com/api-keys):

```bash
-e OPENAI_API_KEY=sk-...
```

### Option 2: ChatGPT OAuth Login

OAuth login is a two-step process:

**Step 1: Login (once)**

```bash
# Login with browser OAuth - expose port 1455 for callback
docker run -it --rm \
  -p 1455:1455 \
  -v ~/.codex:/home/coder/.codex \
  ungb/codex \
  codex login
```

Or use host network:

```bash
docker run -it --rm \
  --network host \
  -v ~/.codex:/home/coder/.codex \
  ungb/codex \
  codex login
```

**Step 2: Use normally**

```bash
# Now run without API key - tokens are in ~/.codex
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  ungb/codex
```

> **Note**: Mount `~/.codex` from your host so tokens persist between container runs.

## Volume Mounts

| Mount | Purpose |
|-------|---------|
| `/workspace` | Your project directory (required) |
| `/home/coder/.codex` | Codex config, instructions, history |
| `/home/coder/.ssh` | SSH keys for git operations (read-only) |
| `/home/coder/.gitconfig` | Git configuration (read-only) |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes* | Your OpenAI API key |
| `OPENAI_ORG_ID` | No | OpenAI organization ID |
| `OPENAI_API_BASE` | No | Custom API endpoint |

*Required unless using OAuth login

## Ports

| Port | Purpose |
|------|---------|
| 1455 | OAuth callback for `codex login` |

## Utility Commands

```bash
# Check version
docker run --rm ungb/codex codex --version

# Show help
docker run --rm ungb/codex codex --help

# View configuration
docker run --rm \
  -v ~/.codex:/home/coder/.codex \
  ungb/codex \
  cat /home/coder/.codex/config.json
```

## Sandbox Mode

Codex recommends Docker for sandboxing. When you run Codex inside this container, it's already isolated from your host system.

For nested Docker (Docker-in-Docker), mount the Docker socket:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

## Building Locally

```bash
git clone https://github.com/ungb/codex-docker.git
cd codex-docker
docker build -t codex .
```

## Troubleshooting

### Permission Denied on Mounted Files

```bash
# Run with your user ID
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

### Git Operations Failing

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

### OAuth Login Not Working

Ensure port 1455 is exposed:

```bash
docker run -it --rm \
  -p 1455:1455 \
  -v ~/.codex:/home/coder/.codex \
  ungb/codex \
  codex login
```

## Shell Alias (Convenience)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias codex-docker='docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex codex'

# Usage (interactive): codex-docker
# Usage (one-shot):    codex-docker exec "explain this code"
```

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [Codex CLI Documentation](https://github.com/openai/codex)
- [OpenAI Platform](https://platform.openai.com/)
- [OpenAI API Keys](https://platform.openai.com/api-keys)
