# Codex Docker

Run [OpenAI Codex CLI](https://github.com/openai/codex) in a Docker container. Codex is OpenAI's lightweight coding agent that runs in your terminal.

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Authentication](#authentication)
  - [API Key (Recommended for Docker)](#api-key-recommended-for-docker)
  - [ChatGPT OAuth Login](#chatgpt-oauth-login)
- [Usage Examples](#usage-examples)
  - [Interactive Session](#interactive-session)
  - [One-Shot Commands (Non-Interactive)](#one-shot-commands-non-interactive)
  - [Piping Input](#piping-input)
  - [Full Configuration (Recommended)](#full-configuration-recommended)
  - [Using Docker Compose](#using-docker-compose)
  - [Full Auto Mode](#full-auto-mode)
  - [Quiet Mode](#quiet-mode)
- [Configuration](#configuration)
  - [Sharing Your Codex Configuration](#sharing-your-codex-configuration)
  - [Custom Instructions](#custom-instructions)
- [Volume Mounts](#volume-mounts)
- [Working with External Files and Screenshots](#working-with-external-files-and-screenshots)
- [Environment Variables](#environment-variables)
- [Ports](#ports)
- [Sandbox Mode](#sandbox-mode)
- [MCP (Model Context Protocol) Support](#mcp-model-context-protocol-support)
- [Troubleshooting](#troubleshooting)
- [Shell Alias (Convenience)](#shell-alias-convenience)
- [Building Locally](#building-locally)
- [License](#license)
- [Links](#links)

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
- One of the following:
  - [OpenAI API key](https://platform.openai.com/api-keys) with API credits
  - ChatGPT account for OAuth login

## Authentication

Choose your authentication method:

| Plan Type | Authentication Method | Section |
|-----------|----------------------|---------|
| **API Credits (Pay-as-you-go)** | API Key (recommended) | [API Key Setup](#api-key-recommended-for-docker) |
| **ChatGPT Subscription** | OAuth Login | [OAuth Setup](#chatgpt-oauth-login) |

### API Key (Recommended for Docker)

Get an API key from [OpenAI Platform](https://platform.openai.com/api-keys):

```bash
# Set your API key as an environment variable
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=sk-... \
  ungb/codex
```

Or use an environment variable from your shell:

```bash
# Export once in your shell
export OPENAI_API_KEY=sk-...

# Then use in docker commands
docker run -it --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

> **Note**: This method doesn't require mounting `~/.codex` for authentication (though you may still want to mount it for custom instructions and history).

### ChatGPT OAuth Login

OAuth login is a two-step process:

#### One-Time Setup

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

This opens your browser, authenticates with your ChatGPT account, and saves tokens to `~/.codex/` on your host machine.

#### Daily Usage

After the one-time login, simply run:

```bash
# No API key needed!
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  ungb/codex
```

> **Important**: Always mount `-v ~/.codex:/home/coder/.codex` to persist your login. Without this mount, you'll need to login every time.

**How it works**: OAuth tokens are stored in `~/.codex/` on your host. By mounting this directory, your credentials persist between container runs. You only need to run `codex login` once (or when tokens expire).

## Usage Examples

### Interactive Session

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

# Analyze git diff
git diff | docker run -i --rm \
  -v $(pwd):/workspace \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex \
  codex exec "review these changes"
```

### Full Configuration (Recommended)

```bash
# Full setup with persistent config, git, SSH, and screenshots
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -v ~/codex-screenshots:/screenshots \
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

### Full Auto Mode

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

## Configuration

### Sharing Your Codex Configuration

The `~/.codex` directory contains your Codex configuration, custom instructions, and session history.

#### What's in ~/.codex

```
~/.codex/
├── config.json           # Settings and preferences
├── instructions.md       # Custom instructions for Codex
└── history/              # Session history
```

#### Mount Your Configuration

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

## Volume Mounts

| Mount | Purpose |
|-------|---------|
| `/workspace` | Your project directory (required) |
| `/home/coder/.codex` | Codex config, instructions, history, OAuth tokens |
| `/home/coder/.ssh` | SSH keys for git operations (read-only) |
| `/home/coder/.gitconfig` | Git configuration (read-only) |
| `/screenshots` | Optional: Dedicated folder for screenshots and images (recommended) |

## Working with External Files and Screenshots

**Important**: Drag-and-drop doesn't work when Codex runs in a Docker container because it's isolated from your host filesystem. You need to explicitly mount directories to make files accessible.

### Recommended Setup: Dedicated Screenshots Folder

Create a dedicated folder on your host machine for screenshots and images you want to share with Codex:

#### Step 1: Create the Screenshots Directory

```bash
# Create a dedicated screenshots folder
mkdir -p ~/codex-screenshots
```

#### Step 2: Mount the Screenshots Folder

**Using docker run:**

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -v ~/codex-screenshots:/screenshots \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

**Using docker-compose:**

Update your `docker-compose.yml` to include the screenshots mount:

```yaml
volumes:
  - ./:/workspace
  - ~/.codex:/home/coder/.codex
  - ~/codex-screenshots:/screenshots  # Add this line
```

#### Step 3: Add Your Files

```bash
# Copy screenshots or images to the folder
cp ~/Downloads/screenshot.png ~/codex-screenshots/
cp ~/Desktop/diagram.jpg ~/codex-screenshots/

# Or save screenshots directly to this folder using your screenshot tool
```

#### Step 4: Reference Files in Codex

Inside Codex, reference files using the mounted path:

```
Can you analyze /screenshots/screenshot.png?
```

```
Please review the UI in /screenshots/mockup.png and suggest improvements
```

```
Read the diagram at /screenshots/architecture.jpg and explain the flow
```

### Alternative: Using Your Downloads Folder

You can also mount your Downloads folder directly:

```bash
# Mount Downloads folder (read-only recommended for safety)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -v ~/Downloads:/downloads:ro \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

Then reference files:

```
Analyze /downloads/screenshot.png
```

### Alternative: Copy Files to Your Workspace

If you're working on a specific project, copy files directly into your project directory:

```bash
# Copy to your project directory (which is already mounted as /workspace)
cp ~/Downloads/screenshot.png /path/to/your/project/

# Then in Codex:
# Analyze /workspace/screenshot.png
```

### Multiple Mount Points Example

You can mount multiple directories for different purposes:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -v ~/codex-screenshots:/screenshots \
  -v ~/Downloads:/downloads:ro \
  -v ~/Documents:/docs:ro \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex
```

This gives you access to:
- `/workspace` - Your current project
- `/screenshots` - Dedicated screenshots folder (read-write)
- `/downloads` - Downloads folder (read-only)
- `/docs` - Documents folder (read-only)

### Tips for Working with External Files

1. **Use descriptive paths**: Instead of `screenshot.png`, use `login-page-error.png`
2. **Organize by purpose**: Create subfolders in `~/codex-screenshots/` like `bugs/`, `designs/`, `diagrams/`
3. **Read-only mounts**: Use `:ro` flag for folders you only need to read from (safety measure)
4. **Absolute paths**: Always use absolute paths when referencing files (e.g., `/screenshots/image.png`)

### Example Workflow

```bash
# 1. Take a screenshot (macOS example)
# Press Cmd+Shift+4 and save to ~/codex-screenshots/

# 2. Start Codex with screenshots mounted
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -v ~/codex-screenshots:/screenshots \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex

# 3. In Codex, reference the screenshot
> Can you analyze the error message in /screenshots/error-screenshot.png and help me fix it?
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Conditional* | Your OpenAI API key |
| `OPENAI_ORG_ID` | No | OpenAI organization ID |
| `OPENAI_API_BASE` | No | Custom API endpoint (for proxies) |

*Required unless using OAuth login.

## Ports

| Port | Purpose |
|------|---------|
| 1455 | OAuth callback for `codex login` |

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
  -v ~/.codex:/home/coder/.codex \
  ungb/codex \
  codex login
```

### OAuth Login Not Persisting

You must mount `~/.codex` to persist OAuth tokens between container runs:

```bash
# Always include this mount for OAuth persistence
-v ~/.codex:/home/coder/.codex
```

If you're still being prompted to login:
1. Verify the mount exists: `ls -la ~/.codex/`
2. Check for credential files: `ls ~/.codex/*.json 2>/dev/null`
3. Ensure you ran `codex login` with the same mount path

### Utility Commands

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

## Shell Alias (Convenience)

Add to your `~/.bashrc` or `~/.zshrc`:

### For API Key Users

```bash
alias codex-docker='docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -v ~/codex-screenshots:/screenshots \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ungb/codex codex'

# Usage (interactive): codex-docker
# Usage (one-shot):    codex-docker exec "explain this code"
# Usage (with screenshot): codex-docker exec "analyze /screenshots/bug.png"
```

### For OAuth Users

```bash
alias codex-docker='docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.codex:/home/coder/.codex \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -v ~/codex-screenshots:/screenshots \
  ungb/codex codex'

# Usage (interactive): codex-docker
# Usage (one-shot):    codex-docker exec "explain this code"
# Usage (with screenshot): codex-docker exec "analyze /screenshots/bug.png"
```

## Building Locally

```bash
git clone https://github.com/ungb/codex-docker.git
cd codex-docker
docker build -t codex .
```

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [Codex CLI Documentation](https://github.com/openai/codex)
- [OpenAI Platform](https://platform.openai.com/)
- [OpenAI API Keys](https://platform.openai.com/api-keys)
