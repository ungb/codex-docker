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

## Usage

### Using Docker Run

```bash
# Basic usage with API key
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex

# With persistent config (remembers settings between runs)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v codex-config:/home/coder/.codex \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex

# With git/ssh support
docker run -it --rm \
  -v $(pwd):/workspace \
  -v codex-config:/home/coder/.codex \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

### Using Docker Compose

1. Clone this repo or copy `docker-compose.yml` to your project:

```bash
curl -O https://raw.githubusercontent.com/ungb/codex-docker/main/docker-compose.yml
```

2. Create a `.env` file with your API key:

```bash
echo "OPENAI_API_KEY=your-key-here" > .env
```

3. Run:

```bash
docker compose run --rm codex
```

### Run a Specific Command

```bash
# Run codex with arguments
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex "explain this codebase"

# Check version
docker run -it --rm ungb/codex codex --version

# Run with full auto-approve (be careful!)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex --full-auto "fix the tests"
```

## Authentication

### Option 1: API Key (Recommended for Docker)

Get an API key from [OpenAI Platform](https://platform.openai.com/api-keys) and pass it as an environment variable:

```bash
-e OPENAI_API_KEY=sk-...
```

### Option 2: ChatGPT OAuth Login

For browser-based OAuth, expose port 1455 for the callback:

```bash
docker run -it --rm \
  -p 1455:1455 \
  -v $(pwd):/workspace \
  -v codex-config:/home/coder/.codex \
  ungb/codex \
  codex login
```

Or use host network mode:

```bash
docker run -it --rm \
  --network host \
  -v $(pwd):/workspace \
  -v codex-config:/home/coder/.codex \
  ungb/codex \
  codex login
```

## Volume Mounts

| Mount | Purpose |
|-------|---------|
| `/workspace` | Your project directory (required) |
| `/home/coder/.codex` | Codex config and cache (optional, for persistence) |
| `/home/coder/.ssh` | SSH keys for git operations (optional, read-only) |
| `/home/coder/.gitconfig` | Git configuration (optional, read-only) |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes* | Your OpenAI API key |
| `OPENAI_ORG_ID` | No | OpenAI organization ID |
| `OPENAI_API_BASE` | No | Custom API endpoint (for proxies) |

*Required unless using OAuth login

## Ports

| Port | Purpose |
|------|---------|
| 1455 | OAuth callback for `codex login` |

## Building Locally

```bash
git clone https://github.com/ungb/codex-docker.git
cd codex-docker
docker build -t codex .
```

## Troubleshooting

### Permission Denied on Mounted Files

The container runs as user `coder` (UID 1000). If you have permission issues:

```bash
# Run with your user ID
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

### Git Operations Failing

Ensure SSH keys are mounted and git is configured:

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
  -v $(pwd):/workspace \
  -v codex-config:/home/coder/.codex \
  ungb/codex \
  codex login
```

## Sandbox Mode

Codex supports running in sandbox mode using Docker. When you run Codex inside this container, it's already isolated. For nested Docker support (Docker-in-Docker), mount the Docker socket:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [Codex CLI Documentation](https://github.com/openai/codex)
- [OpenAI Platform](https://platform.openai.com/)
- [OpenAI API Keys](https://platform.openai.com/api-keys)
