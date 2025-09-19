# Supabase Development Service

## Architecture

```
┌─────────────┐
│   Studio    │
│ (UI Admin)  │
│ Port: 13010 │
└─────────────┘
        │
        │
        │
        ┌──────────────┐
        │  REST API    │
        │ (PostgREST)  │
        │ Port: 13000  │
        └──────────────┘
                │
                │
        ┌──────────────┐
        │ PostgreSQL   │
        │ Port: 15433  │
        └──────────────┘
```

The simplified architecture consists of three main components:
- **Database**: PostgreSQL with Supabase extensions and basic auth schema
- **REST API**: Auto-generated REST API from database schema with RLS
- **Studio**: Web-based admin interface for database management

## Functionalities

### 1. REST API Auto-generation

**Inputs:** Database schema changes, SQL queries via HTTP
**Outputs:** JSON responses, CRUD operations, filtered data
**Implementation:** PostgREST introspects database schema → generates endpoints → applies RLS policies

### 2. Database Administration

**Inputs:** SQL queries, schema changes, user management
**Outputs:** Visual interface, query results, performance metrics
**Implementation:** Studio connects to REST API → provides web interface for all operations

### 3. Row Level Security

**Inputs:** JWT tokens, database queries, user roles
**Outputs:** Filtered data based on user permissions
**Implementation:** PostgreSQL RLS policies applied at database level → enforced for all API access

## Module Contents

### Implementation Files

- `docker-compose.yml` - **Orchestrates all services** (Database, REST API, Studio)
- `init-db.sql` - **Database initialization** (Creates schemas, roles, basic auth tables, RLS policies)
- `README.md` - **Documentation** (This file)

### Service Components

- **db service** - PostgreSQL 15 with Supabase extensions (uuid-ossp, pgcrypto, pgjwt)
- **rest service** - PostgREST API server with automatic schema introspection
- **studio service** - Web admin interface for database management

### Data Persistence

- `docker_data/db/` - **PostgreSQL data volume** (Contains all database files, automatically gitignored)

## To Do's

### Security Enhancements
- [ ] **Custom JWT secrets** - Replace default demo secrets with secure random values
- [ ] **SSL/TLS configuration** - Enable encrypted connections for production use
- [ ] **Rate limiting** - Implement API rate limits to prevent abuse

### Development Features
- [ ] **Database migrations** - Add migration management system for schema changes
- [ ] **Custom auth providers** - Configure additional OAuth providers (GitHub, Google, etc.)
- [ ] **Email configuration** - Set up SMTP for actual email notifications

### Monitoring & Debugging
- [ ] **Logging configuration** - Centralize logs from all services for debugging
- [ ] **Health checks** - Improve health check coverage for all services
- [ ] **Performance monitoring** - Add metrics collection for database and API performance

### Integration Improvements
- [ ] **Custom functions** - Add example Edge Functions for common use cases
- [ ] **Storage service** - Add Supabase Storage for file management
- [ ] **Backup automation** - Implement automated database backups

## Usage

### Start Supabase

```bash
cd services-dev/supabase
docker compose up -d
```

### Access Points

- **Supabase Studio**: http://localhost:13010 (Admin interface)
- **REST API**: http://localhost:13000 (Auto-generated API)
- **PostgreSQL**: localhost:15433 (Direct database access)

### Database Connection

```
Host: localhost
Port: 15433
Database: postgres
Username: postgres
Password: postgres
```

### API Keys (Development Only)

```bash
# Anonymous key (public)
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0

# Service role key (admin)
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
```

### Stop Supabase

```bash
cd services-dev/supabase
docker compose down
```

**⚠️ Warning**: These are development keys only. Never use in production.