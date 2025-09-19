# Services-Dev

Development services collection for local development environment.

## Overview

This directory contains Docker Compose configurations for development services that can be shared across multiple projects. Each service is isolated in its own subdirectory with persistent data storage.

## Structure

```
services-dev/
├── postgresql/
│   ├── docker-compose.yml
│   └── docker_data/          # Persistent PostgreSQL data (gitignored)
├── redis/
│   ├── docker-compose.yml
│   └── docker_data/          # Persistent Redis data (gitignored)
├── rabbitmq/
│   ├── docker-compose.yml
│   └── docker_data/          # Persistent RabbitMQ data (gitignored)
├── supabase/
│   ├── docker-compose.yml
│   ├── init-db.sql
│   ├── README.md
│   └── docker_data/          # Persistent Supabase data (gitignored)
└── README.md
```

## Security

All services are configured to bind only to localhost (127.0.0.1) following CORE.md security requirements.

## Services

### PostgreSQL

**Location**: `./postgresql/`  
**Port**: `127.0.0.1:15432`  
**Database**: `devdb`  
**User**: `devuser`  
**Password**: `devpassword`

**Usage**:
```bash
cd services-dev/postgresql
docker compose up -d
```

**Connection**:
```
Host: localhost
Port: 15432
Database: devdb
Username: devuser
Password: devpassword
```

### Redis

**Location**: `./redis/`
**Port**: `127.0.0.1:16379`
**Password**: `devpassword`

**Usage**:
```bash
cd services-dev/redis
docker compose up -d
```

**Connection**:
```bash
redis-cli -h localhost -p 16379 -a devpassword
```

### RabbitMQ

**Location**: `./rabbitmq/`
**Port**: `127.0.0.1:15672` (Management UI), `127.0.0.1:15673` (AMQP)
**User**: `devuser`
**Password**: `devpassword`

**Usage**:
```bash
cd services-dev/rabbitmq
docker compose up -d
```

**Connection**:
```
AMQP: amqp://devuser:devpassword@localhost:15673/
Management UI: http://localhost:15672 (devuser/devpassword)
```

### Supabase

**Location**: `./supabase/`
**Ports**: Multiple services (Studio: 13010, REST API: 13000, Auth: 19999, etc.)
**Database**: `postgres`
**User**: `postgres`
**Password**: `postgres`

**Usage**:
```bash
cd services-dev/supabase
docker compose up -d
```

**Access Points**:
```
Studio (Admin): http://localhost:13010
REST API: http://localhost:13000
Database: localhost:15433
```

## Adding New Services

1. Create subdirectory: `services-dev/[service-name]/`
2. Add `docker-compose.yml` with localhost-only binding
3. Create `docker_data/` directory for persistence
4. Update this README with service details
5. Ensure `docker_data/` is gitignored

## Notes

- All persistent data is stored in `docker_data/` directories
- Services use predictable container names: `dev-[service-name]`
- Ports are in range 15000-19999 for dev services
- Follow CORE.md guidelines for security and deployment