# Caddy MCP Server - Docker Setup

This directory contains a complete Docker containerization setup for the [lum8rjack/caddy-mcp](https://github.com/lum8rjack/caddy-mcp) server, providing Model Context Protocol (MCP) integration with Caddy web server management.

## Overview

The caddy-mcp server exposes Caddy management capabilities through the MCP protocol, allowing Claude to:

### Available MCP Tools
1. `get_caddy_config` - Retrieve current JSON configuration
2. `update_caddy_config` - Modify server configuration dynamically
3. `convert_caddyfile_to_json` - Transform Caddyfile to JSON
4. `convert_nginx_to_json` - Convert Nginx config to Caddy JSON
5. `convert_yaml_to_json` - Transform YAML to Caddy JSON
6. `upstream_proxy_statuses` - Check reverse proxy upstream status

### What Claude Can Do with Caddy MCP
Through the caddy-mcp server, Claude can:
- **Domain Management**: Configure virtual hosts and domain routing
- **SSL/TLS**: Manage automatic HTTPS certificates and TLS settings
- **Reverse Proxy**: Set up and modify upstream servers and load balancing
- **Configuration Migration**: Convert between different web server formats
- **Real-time Monitoring**: Check server status and upstream health
- **Dynamic Updates**: Modify configurations without service restart

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│    Claude       │◄──►│   caddy-mcp      │◄──►│   Caddy Server  │
│                 │    │   (MCP Server)   │    │   (Admin API)   │
│  MCP Client     │    │   Port: 7000     │    │   Port: 2019    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │                         │
                              └─────────────────────────┘
                                  Docker Network
```

## Files Structure

```
mcp/caddy/
├── README.md           # This documentation
├── Dockerfile          # Multi-stage Docker build (clones from GitHub)
├── docker-compose.yml  # Complete service orchestration
└── caddy/              # Caddy configuration directory
    ├── Caddyfile       # Sample Caddy configuration
    ├── data/           # Caddy persistent data (SSL certs, etc.)
    └── config/         # Caddy runtime config
```

## Quick Start

### 1. Navigate to Directory
```bash
cd /home/alexmak/jam-system/mcp/caddy
```

### 2. Build and Start Services
```bash
# Start the complete stack
docker-compose up -d --build

# Check service status
docker-compose ps
```

### 3. Verify Installation
```bash
# Check logs
docker-compose logs -f caddy-mcp
docker-compose logs -f caddy

# Test Caddy is responding
curl http://localhost:9080  # Should return "Hello from Caddy managed by MCP! 🚀"
curl http://localhost:9081  # Should return "Test site #2 - Caddy + MCP Integration"

# Test Caddy admin API
curl http://localhost:2019/config/

# Test MCP server HTTP endpoint
curl -X POST http://localhost:7000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "method": "tools/list", "params": {}, "id": 1}'
```

## Claude Configuration for This Computer

Since all projects will run from this computer with the same docker host, add this to your Claude settings:

### Option 1: HTTP Stream Transport (Recommended)
For `~/.claude/settings.json` or Claude Desktop settings:

```json
{
  "mcpServers": {
    "caddy-mcp": {
      "command": "curl",
      "args": [
        "-N",
        "-H", "Content-Type: application/json", 
        "-H", "Accept: application/json",
        "--data-binary", "@-",
        "http://localhost:7000/mcp"
      ]
    }
  }
}
```

### Option 2: Docker Exec (Alternative)
```json
{
  "mcpServers": {
    "caddy-mcp": {
      "command": "docker",
      "args": [
        "exec", 
        "-i", 
        "caddy-mcp-server", 
        "./caddy-mcp", 
        "-transport", 
        "stdio", 
        "-url", 
        "http://caddy:2019"
      ]
    }
  }
}
```

### Option 3: For Development/Testing with Claude Code
Add to project-specific `.claude/settings.local.json`:

```json
{
  "mcpServers": {
    "caddy-local": {
      "command": "docker",
      "args": [
        "exec", 
        "-i", 
        "caddy-mcp-server", 
        "./caddy-mcp", 
        "-transport", 
        "stdio", 
        "-url", 
        "http://caddy:2019"
      ],
      "env": {
        "DOCKER_HOST": "unix:///var/run/docker.sock"
      }
    }
  }
}
```

## Usage Examples

Once configured, Claude can manage your Caddy server:

**Get current configuration:**
```
Human: Get the current Caddy configuration
Claude: [Uses get_caddy_config tool to retrieve current JSON config]
```

**Add a new site:**
```
Human: Add a new site at port 9000 that responds with "New Site"
Claude: [Uses update_caddy_config to add the configuration]
```

**Convert configuration formats:**
```
Human: Convert this Nginx config to Caddy format: [paste config]
Claude: [Uses convert_nginx_to_json tool to convert]
```

**Check upstream status:**
```
Human: Check the status of all reverse proxy upstreams
Claude: [Uses upstream_proxy_statuses tool to check health]
```

## Management Commands

### Start/Stop Services
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart specific service
docker-compose restart caddy
docker-compose restart caddy-mcp

# View logs
docker-compose logs -f caddy-mcp
```

### Rebuild After Changes
```bash
# Rebuild MCP server (pulls latest from GitHub)
docker-compose build caddy-mcp --no-cache
docker-compose up -d caddy-mcp
```

### Troubleshooting
```bash
# Check service health
docker-compose ps
docker ps

# Check network connectivity
docker exec caddy-mcp-server wget -qO- http://caddy:2019/config/

# Test MCP tools manually
docker exec -it caddy-mcp-server ./caddy-mcp -transport stdio -url http://caddy:2019
```

## Production Considerations

### Security
- The MCP server runs as non-root user in container
- Caddy admin API is exposed only within Docker network by default
- Consider adding authentication for production deployments

### Monitoring
- Both services include health checks
- Monitor logs with: `docker-compose logs -f`
- Set up external monitoring for production use

### Data Persistence
- SSL certificates: `./caddy/data/`
- Runtime config: `./caddy/config/`
- Both directories are persisted via Docker volumes

## Customization

### Modify Caddy Configuration
Edit `./caddy/Caddyfile` and restart:
```bash
# Edit configuration
nano ./caddy/Caddyfile

# Restart to apply changes
docker-compose restart caddy
```

### MCP Transport Options
The MCP server supports multiple transport methods. Edit `docker-compose.yml`:

- `stdio`: Standard input/output (for direct execution)
- `sse`: Server-Sent Events over HTTP
- `httpstream`: HTTP streaming (current default)

## Support

- **Caddy MCP Repository**: https://github.com/lum8rjack/caddy-mcp
- **Caddy Documentation**: https://caddyserver.com/docs/
- **MCP Protocol**: https://github.com/modelcontextprotocol/

## Setup Complete ✅

This installation provides:
- ✅ Dockerized Caddy server with admin API
- ✅ Dockerized caddy-mcp server from official repository
- ✅ Sample Caddyfile for testing
- ✅ Complete Docker orchestration
- ✅ Claude integration examples for this computer
- ✅ Management and troubleshooting commands