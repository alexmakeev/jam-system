# JAM System

System administration and configuration management repository with MCP (Model Context Protocol) servers for Claude integration.

## MCP Servers

### 1. Caddy MCP Server ✅ **INSTALLED**
- **Location**: `./mcp/caddy/`
- **Repository**: [lum8rjack/caddy-mcp](https://github.com/lum8rjack/caddy-mcp)
- **Status**: Running in Docker
- **Purpose**: Comprehensive Caddy web server management through MCP

#### Features:
- Dynamic Caddy configuration retrieval and updates
- Multi-format configuration conversion (JSON, Caddyfile, YAML, Nginx)
- Real-time reverse proxy upstream status monitoring
- Support for multiple transport methods (stdio, SSE, HTTP stream)

#### Quick Access:
```bash
cd ./mcp/caddy
docker compose ps              # Check status
docker compose logs -f caddy-mcp  # View logs
```

#### Test Endpoints:
- Caddy Test Site 1: http://localhost:9080
- Caddy Test Site 2: http://localhost:9081  
- Caddy Admin API: http://localhost:2019

#### Claude Configuration:
Add to your Claude settings (`~/.claude/settings.json`):

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

**Available MCP Tools:**
1. `get_caddy_config` - Retrieve current JSON configuration
2. `update_caddy_config` - Modify server configuration dynamically
3. `convert_caddyfile_to_json` - Transform Caddyfile to JSON
4. `convert_nginx_to_json` - Convert Nginx config to Caddy JSON
5. `convert_yaml_to_json` - Transform YAML to Caddy JSON
6. `upstream_proxy_statuses` - Check reverse proxy upstream status

---

## Installation Commands

### Start All MCP Services
```bash
# Caddy MCP
cd ./mcp/caddy && docker compose up -d
```

### Stop All MCP Services  
```bash
# Caddy MCP
cd ./mcp/caddy && docker compose down
```

## Project Structure

```
jam-system/
├── README.md           # This file
├── CLAUDE.md          # Claude Code project instructions
├── .gitignore         # Git ignore patterns
├── .claude/           # Claude Code settings
└── mcp/               # MCP servers directory
    └── caddy/         # Caddy MCP server setup
        ├── README.md  # Detailed Caddy MCP documentation
        ├── Dockerfile # Multi-stage build from GitHub
        ├── docker-compose.yml # Service orchestration
        └── caddy/     # Caddy configuration
            ├── Caddyfile # Sample configuration
            ├── data/     # Persistent data (SSL certs)
            └── config/   # Runtime config
```

## Next MCP Servers to Add

Planned additions based on system administration needs:
- Database management MCP servers
- Container orchestration MCP servers  
- Monitoring and alerting MCP servers
- File system management MCP servers