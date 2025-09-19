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
- !IMPORTANT For production domains use Caddy auto-discovery with Docker labels. Save full https url to ./CLAUDE.md and report to user.

### Caddy Auto-Discovery Pattern:
```bash
# Before launching, stop any existing containers with same domain label
docker stop old-container-name 2>/dev/null || true
docker run -d --name service-name \
  --label "caddy=subdomain.robobobr.ru" \
  --label "caddy.reverse_proxy={{upstreams PORT}}" \
  --restart unless-stopped image:tag
```
- !IMPORTANT Check for existing containers with same domain before deploy - otherwise traffic may be served by old container

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
- PostgreSQL: postgresql://devuser:devpassword@localhost:15432/[devdb] (replace with project db name; create new db: CREATE DATABASE project_name;)
- Redis: redis://devuser:devpassword@localhost:16379/[db_number] (16 databases 0-15, use different db per project; example: /0 for project1, /1 for project2)
- RabbitMQ: amqp://devuser:devpassword@localhost:15673/[vhost_name] (create vhost per project; Management UI: http://localhost:15672)

### Multi-Project Usage
**PostgreSQL**: Create separate databases per project
```bash
# Connect to PostgreSQL and create new database
docker exec -it dev-postgresql psql -U devuser -d devdb -c "CREATE DATABASE project_name;"
```

**Redis**: Use different database numbers (0-15) per project
```bash
# Connect to specific Redis database
redis-cli -h localhost -p 16379 -a devpassword -n [db_number]
```

**RabbitMQ**: Create virtual hosts per project
```bash
# Create new virtual host and set permissions
docker exec dev-rabbitmq rabbitmqctl add_vhost project_name
docker exec dev-rabbitmq rabbitmqctl set_permissions -p project_name devuser ".*" ".*" ".*"
```

## Workflow Checklist (on finishing each step)
- ✅ Run **linting**  
- ✅ Run **tests** (fix errors if critical)  
- ✅ Update **docs** to stay in sync with all performed changes  
- ✅ Update version in config file (**patch/minor/major**)  
- ✅ Add commit with short version history summary (include test coverage)  
- ✅ Run `git push`  

## Shell Command Rules
- Always run commands with `timeout` (give **2× expected time**).  
- If timeout hits → analyze output, decide to increase timeout or try another approach.  
- If a system command is missing → suggest installation using:  
  ```bash
  printf "\\" | sudo -S <command>
  ```

