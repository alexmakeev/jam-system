# Docker Data Strategy

## Overview

This document outlines the standardized approach for managing Docker persistent data volumes across all MCP servers in the jam-system repository.

## Directory Structure

All Docker persistent data should be stored in a standardized `docker-data/` folder within each MCP server directory:

```
mcp/
├── [mcp-server]/
│   ├── docker-compose.yml
│   ├── docker-data/           # All persistent volumes here
│   │   ├── [service-name-1]/  # Data for first service
│   │   ├── [service-name-2]/  # Data for second service
│   │   └── ...
│   └── ...
```

## Implementation Rules

1. **Location**: All bound volumes must be stored in `./docker-data/[service-name]/` relative to the docker-compose.yml file
2. **Naming**: Use service name as the subdirectory name (e.g., `caddy-data`, `caddy-config`)
3. **Gitignore**: All `docker-data/` folders are automatically ignored via `**/docker-data/` pattern
4. **Restart Policy**: All services must use `restart: unless-stopped` for system reboot stability

## Example Configuration

```yaml
services:
  caddy:
    image: caddy:latest
    restart: unless-stopped
    volumes:
      - ./docker-data/caddy-data:/data
      - ./docker-data/caddy-config:/config
```

## Benefits

- **Predictable**: All persistent data follows the same pattern
- **Clean Git**: Docker runtime data is automatically gitignored
- **System Stability**: Services restart automatically after system reboot
- **Easy Backup**: All persistent data is contained in known directories
- **Clear Separation**: Configuration files vs runtime data vs docker data