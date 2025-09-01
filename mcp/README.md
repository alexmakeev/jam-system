# MCP Servers - Docker Setup Guide

This directory contains all MCP (Model Context Protocol) servers for Claude integration, each containerized with Docker for consistent deployment and isolation.

## Standard Docker MCP Pattern

All MCP servers in this repository follow a consistent Docker-based architecture and configuration pattern.

### Directory Structure
```
mcp/
├── README.md          # This guide
├── server-name/       # Each MCP server gets its own directory
│   ├── README.md      # Server-specific documentation
│   ├── Dockerfile     # Multi-stage build (usually clones from GitHub)
│   ├── docker-compose.yml  # Service orchestration
│   └── config/        # Server-specific configuration files
└── ...
```

### Docker Compose Template
Each MCP server uses a standardized `docker-compose.yml` structure:

```yaml
version: '3.8'

services:
  # Main application/service the MCP server manages
  target-service:
    image: target-service:latest
    container_name: target-service-server
    # ... service-specific configuration

  # MCP Server
  mcp-server:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: mcp-server-name
    restart: unless-stopped
    ports:
      - "7XXX:7000"  # MCP server port (unique per server)
    environment:
      - TARGET_URL=http://target-service:PORT
    command: ["./mcp-binary", "-transport", "httpstream", "-url", "http://target-service:PORT", "-port", "7000"]
    networks:
      - mcp-network
    depends_on:
      target-service:
        condition: service_healthy

networks:
  mcp-network:
    driver: bridge
    name: mcp-network-name
```

### Dockerfile Template
Each MCP server uses a multi-stage build pattern:

```dockerfile
# Multi-stage build for MCP server
FROM golang:1.24-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make

# Clone the official repository
WORKDIR /build
RUN git clone https://github.com/owner/mcp-repo.git .

# Build the application
RUN make

# Final stage: minimal runtime image
FROM alpine:latest

# Install CA certificates for HTTPS support
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S mcp-user && \
    adduser -u 1001 -S mcp-user -G mcp-user

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /build/mcp-binary ./

# Change ownership to non-root user
RUN chown -R mcp-user:mcp-user /app

# Switch to non-root user
USER mcp-user

# Expose default port
EXPOSE 7000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep mcp-binary > /dev/null || exit 1

# Default command
CMD ["./mcp-binary", "-transport", "stdio", "-url", "http://localhost:PORT"]
```

## Claude Configuration Pattern

All Docker-hosted MCP servers follow the same configuration pattern across different Claude clients:

## Configuration Methods by Claude Client

### **Claude Code (Native CLI) - RECOMMENDED** ⭐

Claude Code has native MCP support with multiple configuration options:

#### **Method 1: CLI Command (Quickest)**
```bash
claude mcp add caddy-mcp --scope user -- docker exec -i caddy-mcp-server ./caddy-mcp -transport stdio -url http://caddy:2019
```

#### **Method 2: Configuration File (Recommended)**

**User-level configuration** (available across all projects):
```bash
# Create configuration directory
mkdir -p ~/.claude

# Create MCP configuration
cat > ~/.claude/mcp.json << 'EOF'
{
  "mcpServers": {
    "mcp-server-name": {
      "type": "stdio",
      "command": "docker",
      "args": ["exec", "-i", "container-name", "./mcp-binary", "-transport", "stdio", "...server-specific-args"]
    }
  }
}
EOF
```

**Configuration scope options:**
- **User scope**: `~/.claude/mcp.json` (all projects) ⭐ **Recommended**
- **Project scope**: `./.mcp.json` (shared via git)
- **Local scope**: `./.claude/mcp.json` (current project only)

**Management commands:**
```bash
claude mcp list                    # List configured servers
claude mcp get server-name        # Get specific server details  
claude mcp remove server-name     # Remove a server
```

### **Claude Desktop (Desktop App)**

For users preferring the desktop application:

```json
{
  "mcpServers": {
    "mcp-server-name": {
      "command": "docker",
      "args": [
        "exec", "-i", "container-name", 
        "./mcp-binary", "-transport", "stdio", 
        "...server-specific-args"
      ]
    }
  }
}
```

**Configuration location:**
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

### **Claude.ai Web Interface**

❌ **Local Docker MCP servers are NOT supported** in the web interface. Web interface only supports cloud-based connectors.

### Configuration Components

| Component | Purpose | Example |
|-----------|---------|---------|
| `"mcp-server-name"` | Unique identifier in Claude | `"caddy-mcp"` |
| `"command": "docker"` | **Always the same** - uses Docker CLI | Fixed |
| `"exec", "-i"` | **Always the same** - interactive container exec | Fixed |
| `"container-name"` | Docker container name | `"caddy-mcp-server"` |
| `"./mcp-binary"` | Executable inside container | `"./caddy-mcp"` |
| `"-transport", "stdio"` | **Always the same** - communication method | Fixed |
| `"...server-specific-args"` | MCP-specific configuration | `-url`, `-host`, etc. |

### Communication Flow
```
Claude ←→ Docker CLI ←→ MCP Container ←→ Target Service
```

1. **Claude** sends MCP requests via Docker exec
2. **Docker** forwards communication to the MCP container  
3. **MCP Server** processes requests and calls target service API
4. **Target Service** responds with data
5. Response flows back to Claude through the same chain

## Examples

### Current MCP Servers

#### Caddy MCP Server ✅ **INSTALLED**

**Claude Code configuration** (user-level):
```bash
# Already configured at ~/.claude/mcp.json
cat ~/.claude/mcp.json
```

**Claude Desktop configuration:**
```json
{
  "mcpServers": {
    "caddy-mcp": {
      "command": "docker",
      "args": [
        "exec", "-i", "caddy-mcp-server", 
        "./caddy-mcp", "-transport", "stdio", 
        "-url", "http://caddy:2019"
      ]
    }
  }
}
```

**Claude Code template for new servers:**
```bash
# Replace values for new MCP servers
claude mcp add SERVER-NAME --scope user -- docker exec -i CONTAINER-NAME ./MCP-BINARY -transport stdio -url http://TARGET:PORT
```

### Future MCP Server Examples

#### Database MCP Server (Hypothetical)
```json
{
  "mcpServers": {
    "postgres-mcp": {
      "command": "docker",
      "args": [
        "exec", "-i", "postgres-mcp-server", 
        "./postgres-mcp", "-transport", "stdio", 
        "-host", "postgres", "-port", "5432", 
        "-database", "main"
      ]
    }
  }
}
```

#### File System MCP Server (Hypothetical)  
```json
{
  "mcpServers": {
    "filesystem-mcp": {
      "command": "docker",
      "args": [
        "exec", "-i", "filesystem-mcp-server", 
        "./fs-mcp", "-transport", "stdio", 
        "-root", "/app/data"
      ]
    }
  }
}
```

## Port Allocation

To avoid conflicts, each MCP server uses a unique port range:

| MCP Server | Container Port | Host Port | Purpose |
|------------|---------------|-----------|---------|
| Caddy MCP | 7000 | 7000 | HTTP stream transport |
| *Next MCP* | 7000 | 7001 | HTTP stream transport |
| *Next MCP* | 7000 | 7002 | HTTP stream transport |

## Development Workflow

### Adding a New MCP Server

1. **Create directory structure:**
   ```bash
   mkdir -p ./mcp/new-server/config
   ```

2. **Create Dockerfile** (follow template above)

3. **Create docker-compose.yml** (follow template above) 

4. **Test the setup:**
   ```bash
   cd ./mcp/new-server
   docker compose up -d --build
   docker compose ps  # Verify health
   ```

5. **Configure in Claude Code** (recommended):
   ```bash
   claude mcp add new-server --scope user -- docker exec -i new-server-container ./mcp-binary -transport stdio -url http://target:port
   ```

6. **Document in server README.md** with:
   - Installation instructions
   - Available MCP tools  
   - Usage examples
   - Troubleshooting guide

### Common Commands

```bash
# Start all MCP servers
find ./mcp -name "docker-compose.yml" -exec dirname {} \; | xargs -I {} sh -c 'cd {} && docker compose up -d'

# Stop all MCP servers  
find ./mcp -name "docker-compose.yml" -exec dirname {} \; | xargs -I {} sh -c 'cd {} && docker compose down'

# Check status of all MCP servers
find ./mcp -name "docker-compose.yml" -exec dirname {} \; | xargs -I {} sh -c 'echo "=== {} ===" && cd {} && docker compose ps'
```

## Benefits of This Pattern

- **Consistency**: Same configuration approach for all MCP servers
- **Isolation**: Each MCP server runs in its own container environment  
- **Security**: Non-root users, minimal attack surface
- **Maintainability**: Standardized structure makes updates easier
- **Scalability**: Easy to add new MCP servers following the same pattern
- **Portability**: Docker ensures consistent behavior across environments

## Next Steps

When adding new MCP servers, follow this established pattern for consistent deployment and Claude integration across the entire jam-system.