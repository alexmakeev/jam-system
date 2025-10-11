# Claude Core Instructions

## General rules
- Every time where you are not sure what to choose/what to do don't try to guess, but ask the user and suggest variants if possible.
- Use dry messages when speaking to user, just informing the status.

---

## Dev and Debug
- Use locally running background task bound to random port (10000-20000) and report http://robobobr.ru:[port] url to user for easier click-and-test-it
- Use locally running services (single instance per service for all projects being in dev/debug), so, you might connect to, say postgresql and create table for needed project. List of services available at very bottom of this doc. Don't kill processes, if you see issues with them - report to the user. Only you can restart them, but approve it from user.
- Bug workflow: manually reproduce (using DEBUG.md) → implement unit/e2e test (use OpenAI for fuzzy validation) → run test (confirm failure) → debug until test passes → manual recheck (DEBUG.md)
- Feature workflow: update docs (README.md, ARCHITECTURE.md) → write feature tests (unit/e2e) for TDD → develop feature until ALL tests pass → be strict about test failures → recheck all previous tests work

## Production
- Use docker compose (no dash) to build services containers and prod container
- Use ./docker-data/app folder to store docker application code copy (so, changes outside ./docker-data will not touch prod deployment), gitignore the ./docker-data folder
- Use ./docker-data/[service-name] folders for dbs or any other service needed at prod setup
- Use ./docker-data-dev/[service-name] for dev deployment services data, also gitignored
- !IMPORTANT Never kill unknown docker containers! Clarify twice that you manages correct containers.
- !IMPORTANT Use only local port for any kind of services you run at docker-compose, don't expose any port outside the machine.
- !IMPORTANT Use `--restart unless-stopped` policy for all production containers to ensure persistence over system restarts.
- !IMPORTANT For production domains use Caddy reverse proxy (systemctl). Save full https url to ./CLAUDE.md and report to user.

### Caddy Reverse Proxy (systemctl):
Caddy runs via systemctl on this server, config at `/etc/caddy/Caddyfile`.

**Steps to add new domain:**
1. Backup config: `cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.backup.$(date +%Y%m%d_%H%M%S)`
2. Edit `/etc/caddy/Caddyfile` (ask user for sudo approval)
3. Add domain block (see ./CLAUDE.md for template)
4. Reload: `printf '\\\n' | sudo -S systemctl reload caddy`
5. Verify: `curl https://subdomain.robobobr.ru`

- !IMPORTANT Always backup before editing Caddyfile
- !IMPORTANT Ask user for sudo approval before any Caddyfile changes

## Tests
- Each test must include dry reference to real situation or docs that declare required behavior
- After bug workflow fixes test → document fix cause/method in test comment for future reference
- Be strict: ALL tests must pass before reporting feature/fix done, no exceptions

## Files
- CLAUDE.md: Project instructions for Claude
- DEBUG.md: Debug environment, setup, methods/tools
- PROD.md: Production setup, build/run/restart/status/logs
- README.md: Project overview, quick start
- ARCHITECTURE.md: System design, components

## Available Dev Services

### Database Services
- **PostgreSQL**: postgresql://devuser:devpassword@localhost:15432/[project_db]
- **Supabase**: postgres://postgres:postgres@localhost:15433/postgres (includes REST API: http://localhost:13000, Admin: http://localhost:13010)
- **ArangoDB**: http://localhost:18529 (Web UI: http://localhost:18529, Root: root/devpassword, User: alexmak/1q2w3e)
- **Redis**: redis://devuser:devpassword@localhost:16379/[db_number]
- **RabbitMQ**: amqp://devuser:devpassword@localhost:15673/[vhost] (UI: http://localhost:15672)
- **MinIO S3**: http://localhost:19000 (Console UI: http://localhost:19001, Access Key: devuser, Secret Key: devpassword)

### Service Management
```bash
# Start individual services
cd services-dev/postgresql && docker compose up -d
cd services-dev/supabase && docker compose up -d
cd services-dev/arangodb && docker compose up -d
cd services-dev/redis && docker compose up -d
cd services-dev/rabbitmq && docker compose up -d
cd services-dev/minio && docker compose up -d

# Check service status
docker compose ps
```

### Database Usage Patterns

**PostgreSQL** (General purpose SQL database)
```bash
# Create project database
docker exec -it dev-postgresql psql -U devuser -d devdb -c "CREATE DATABASE project_name;"
# Connect from application: postgresql://devuser:devpassword@localhost:15432/project_name
```

**Supabase** (Full-stack platform with auto-generated REST API)
```bash
# Access admin interface: http://localhost:13010
# REST API endpoint: http://localhost:13000
# Direct DB access: postgres://postgres:postgres@localhost:15433/postgres
# API example: curl http://localhost:13000/your_table
```

**Redis** (Key-value cache/sessions)
```bash
# Use different DB numbers per project (0-15)
redis-cli -h localhost -p 16379 -a devpassword -n 0  # project1
redis-cli -h localhost -p 16379 -a devpassword -n 1  # project2
```

**RabbitMQ** (Message broker)
```bash
# Create project vhost
docker exec dev-rabbitmq rabbitmqctl add_vhost project_name
docker exec dev-rabbitmq rabbitmqctl set_permissions -p project_name devuser ".*" ".*" ".*"
# Connect: amqp://devuser:devpassword@localhost:15673/project_name
```

**MinIO S3** (Object storage/file uploads)
```bash
# Access web console: http://localhost:19001 (devuser/devpassword)
# API endpoint: http://localhost:19000
# Create bucket via console or API
# Upload/download objects via SDK or REST API
```

**ArangoDB** (Multi-model database: graphs, documents, key-value)
```bash
# Access Web UI: http://localhost:18529
# Login with root: root/devpassword (admin access, full permissions)
# Login with user: alexmak/1q2w3e (UI access, rw permissions on _system)
# API endpoint: http://localhost:18529/_api/
# Create database: curl -u root:devpassword -X POST http://localhost:18529/_api/database -d '{"name":"project_name"}'
# Connect from app: http://localhost:18529 (use root credentials for full access)

# Create additional users (via arangosh):
docker exec dev-arangodb arangosh --server.password devpassword --javascript.execute-string "
const users = require('@arangodb/users');
users.save('username', 'password', true);
users.grantDatabase('username', '_system', 'rw');
"
```

## Workflow Checklist (on finishing each step)
- ✅ Run **linting**  
- ✅ Run **tests** (fix errors if critical)  
- ✅ Update **docs** to stay in sync with all performed changes  
- ✅ Update version in config file (**patch/minor/major**)  
- ✅ Add commit with short version history summary (include test coverage)  
- ✅ Run `git push`  

## Server Initialization

### init_server.sh
Unified server initialization script for fresh Ubuntu 22.04 installations. Provides interactive menu for installing and configuring development tools.

**Usage:**
```bash
sudo ./init_server.sh
```

**Features:**
- **Complete Server Setup**: One-click installation of all development tools
- **Idempotent**: Safe to run multiple times without breaking existing installations
- **Interactive Menu**: User-friendly interface for selecting components
- **Individual Components**: Install specific tools as needed

**Installed Components:**
- Basic packages (git, ripgrep, jq, build-essential, etc.)
- Glow (markdown viewer)
- Docker Engine + Compose
- Node.js 20 LTS + npm
- GitHub CLI
- Claude Code (system-wide installation in /usr/local/bin)
- Playwright dependencies
- Swap file (custom size)
- SSH keepalive configuration
- User management tools

**Menu Options:**
1. Complete Server Setup - Installs all components + system configuration
2. Create Swap File (custom size) - Interactive swap creation with system info and recommendations
3. Configure SSH Keepalive - Prevents SSH disconnections
4. Create New User - Add development user with SSH keys
5. Install Individual Components - Cherry-pick specific tools
6. System Information - Display current system specs
7. Verify Installations - Check what's already installed

**Swap File Creation:**
- Displays system RAM, disk space, and availability
- Provides intelligent size recommendations based on RAM
- Validates input format and available space
- Supports GB/MB format (e.g., 4G, 8G, 1024M)
- Safe recreation of existing swap files

**Safety Features:**
- Checks existing installations before attempting to install
- Preserves user groups and permissions
- Backs up configuration files before changes
- Validates configurations before applying

## Shell Command Rules
- Always run commands with `timeout` (give **2× expected time**).
- If timeout hits → analyze output, decide to increase timeout or try another approach.
- If a system command is missing → suggest installation using:
  ```bash
  printf "\\" | sudo -S <command>
  ```

