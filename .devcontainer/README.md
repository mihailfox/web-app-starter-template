# Devcontainer Template

This template targets web application development with Node.js 24 and Docker Compose.

## Included Tooling

- Node.js 24 (custom `.devcontainer/Dockerfile`)
- Corepack-enabled Yarn workflow (`packageManager` in `package.json`)
- Docker CLI access from inside the devcontainer
- GitHub CLI
- Supabase CLI (devcontainer feature)
- Verdaccio CLI (global npm install)
- Playwright browser bootstrap (when Playwright dependency is present)

## Package Manager Strategy

This template is Yarn-only:

1. `package.json#packageManager` must be `yarn@<version>`
2. lifecycle scripts run `corepack prepare <packageManager> --activate`
3. dependency install uses `yarn install --immutable`

## Workspace Mounting

This devcontainer supports **both bind mount and container volume workspaces**, making it compatible with:
- Local development (bind mount from host filesystem)
- GitHub Codespaces (container volume)
- VS Code "Clone Repository in Container Volume" (container volume)

### How It Works

The workspace mount is **dynamically configured** at container creation time:

1. **`initializeCommand`** runs `.devcontainer/scripts/gen-workspace-env.sh` on the host
2. Script detects workspace type (bind mount vs. container volume)
3. Generates `.devcontainer/.env` with appropriate environment variables
4. `docker-compose.yml` uses these variables to mount the workspace correctly

### Generated Environment Variables

The script generates different variables based on workspace type:

**For bind mount workspaces** (local clone):
```bash
WORKSPACE_SOURCE=/home/user/projects/myproject  # Host path
WORKSPACE_TARGET=/workspaces/myproject          # Container path
WORKSPACE_ROOT=/workspaces/myproject
WORKSPACE_IS_CONTAINER_VOLUME=false
WORKSPACE_IS_BIND_MOUNT=true
```

**For container volume workspaces** (Codespaces, Clone in Volume):
```bash
WORKSPACE_CONTAINER_VOLUME_SOURCE=vscode-projects  # Volume name
WORKSPACE_CONTAINER_VOLUME_TARGET=/workspaces
WORKSPACE_SOURCE=devcontainer-volume               # Alias
WORKSPACE_TARGET=/workspaces
WORKSPACE_ROOT=/workspaces/myproject
WORKSPACE_IS_CONTAINER_VOLUME=true
WORKSPACE_IS_BIND_MOUNT=false
```

### Template-Safe Design

The workspace path uses `${localWorkspaceFolderBasename}` in `devcontainer.json`, which means:
- ✅ No hardcoded project names
- ✅ Works when repository is cloned with a different name
- ✅ Generic and reusable across projects

**Note:** The `.devcontainer/.env` file is automatically generated and should not be committed to version control.

## Environment Variables

Environment variables are split between infrastructure and developer settings:

### Infrastructure Variables (docker-compose.yml)
These are service-level configuration shared across all containers:
- `NODE_ENV`: Node.js environment (default: `development`)
- `PLAYWRIGHT_BROWSERS_PATH`: Browser install location
- `VERDACCIO_URL`: Private npm registry URL (when enabled)

### Developer Variables (devcontainer.json)
These are personal credentials and preferences:
- `COREPACK_ENABLE_DOWNLOAD_PROMPT`: Suppress corepack prompts (default: `0`)
- `GH_PAT`: GitHub Personal Access Token (from host environment)
- `GH_TOKEN`: GitHub token alias (from host environment)
- `GITHUB_TOKEN`: GitHub token alias (from host environment)

**Note:** `devcontainer.json` containerEnv overrides docker-compose.yml environment when using VS Code Dev Containers.

## Port Mappings

| Port | Service | Description |
|------|---------|-------------|
| 5173 | Vite | Development server |
| 4173 | Vite | Preview server |
| 4873 | Verdaccio | Private npm registry (optional) |
| 54321 | Kong | Supabase API Gateway |
| 54322 | PostgreSQL | Supabase Database |
| 54323 | Studio | Supabase Web UI |
| 54324 | Inbucket | Email testing web UI |
| 54325 | Inbucket | Email testing SMTP |

## Optional Services

### Verdaccio (Private npm Registry)

Verdaccio is an optional service for local npm package caching and private package hosting.

**Enable auto-start:**
```bash
# Add to .env or your shell environment
echo "START_VERDACCIO=true" >> .env

# Then rebuild/restart the devcontainer
```

**Manual control:**
```bash
# Start Verdaccio
docker compose --profile verdaccio up -d

# Stop Verdaccio
docker compose --profile verdaccio down

# Check status
docker compose ps
```

- **Purpose**: Local npm package caching and private package hosting
- **URL**: `http://localhost:4873`
- **Auto-configured**: Scripts automatically use Verdaccio when available

## Supabase Local Development

This project uses the **Supabase CLI** to manage local Supabase services, integrated with our devcontainer via a shared Docker network.

### Architecture

- **Supabase CLI** manages: PostgreSQL, Auth, Storage, Realtime, Studio, etc.
- **Docker Compose** manages: Workspace, Verdaccio
- **Shared Network**: Both connect to `supabase_network_web-app-starter-template`

### Auto-Start Behavior

**Services start automatically when you open the devcontainer!** ✨

The devcontainer is configured to auto-start:
- ✅ **Supabase stack** (PostgreSQL, Auth, Storage, Realtime, Studio, etc.)
- ⚙️ **Verdaccio** (optional - set `START_VERDACCIO=true` in `.env` to enable)

**What happens on container start:**
1. VS Code loads the container (immediately usable)
2. In background: `post-start.sh` runs
3. Supabase services start (30-60 seconds)
4. Services are ready while you work

**Monitor startup progress:**
```bash
# Watch logs in real-time
tail -f .devcontainer/logs/supabase-startup.log

# Check service status
supabase status
```

### Manual Control (Optional)

You can still manually control services if needed:

```bash
# Stop Supabase
supabase stop

# Start Supabase manually
supabase start

# Stop/start Verdaccio
docker compose --profile verdaccio down
docker compose --profile verdaccio up -d
```

### Disabling Auto-Start

To disable auto-start, remove the `postStartCommand` from `.devcontainer/devcontainer.json`:

```json
// Comment out or remove this line:
// "postStartCommand": ".devcontainer/scripts/post-start.sh",
```

### Accessing Supabase Services

Once `supabase start` completes, services are available at:

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **Studio (Web UI)** | http://localhost:54323 | - |
| **API Gateway** | http://localhost:54321 | `ANON_KEY` from `supabase status` |
| **PostgreSQL** | `postgresql://postgres:postgres@localhost:54322/postgres` | Password: `postgres` |
| **Inbucket (Email)** | http://localhost:54324 | - |

**Get credentials:**
```bash
supabase status
# Shows all URLs and API keys
```

### Common Workflows

**Daily Development:**
```bash
# Start everything (run once)
supabase start
docker compose up -d

# Create a migration
supabase migration new add_feature

# Edit migration file in supabase/migrations/

# Apply migrations + seed
supabase db reset

# Generate TypeScript types
supabase gen types typescript --local > src/types/supabase.ts

# Stop everything (optional, can leave running)
supabase stop
docker compose down
```

**Database Operations:**
```bash
# Reset database (destroys all data, applies migrations + seed)
supabase db reset

# Connect with psql
psql postgresql://postgres:postgres@localhost:54322/postgres

# Create new migration
supabase migration new migration_name

# List migrations
supabase migration list
```

**Edge Functions:**
```bash
# Create new function
supabase functions new hello

# Serve functions locally (hot reload)
supabase functions serve

# Deploy function
supabase functions deploy hello
```

**Check Status:**
```bash
# Show all services and URLs
supabase status

# Check service health
docker compose ps
```

### Configuration

Supabase is configured via `supabase/config.toml`:
- Port mappings
- Service enablement
- Database settings
- Auth configuration

See [Supabase CLI Config Reference](https://supabase.com/docs/guides/cli/config) for all options.

### Migrations and Seed Data

**Location:**
- Migrations: `supabase/migrations/*.sql`
- Seed data: `supabase/seed.sql`

**Workflow:**
1. Create migration: `supabase migration new <name>`
2. Edit SQL file in `supabase/migrations/`
3. Apply: `supabase db reset` (or migrations auto-apply on `supabase start`)
4. Seed data runs automatically after migrations

### Network Integration

The workspace container and Supabase services share the same Docker network (`supabase_network_web-app-starter-template`), enabling seamless communication.

**From your application code:**
```typescript
// Use localhost URLs
const supabase = createClient(
  'http://localhost:54321',
  'YOUR_ANON_KEY' // Get from: supabase status
)
```

### Troubleshooting

**Issue: Auto-start didn't run or failed**
```bash
# Check startup logs
tail -f .devcontainer/logs/supabase-startup.log

# Manually start services
supabase start

# Check if containers are running
docker ps --filter "name=supabase"
```

**Issue: `supabase start` fails with "port already allocated"**
```bash
# Check what's using the port
lsof -i :54321

# Stop conflicting service or change ports in config.toml
```

**Issue: Can't connect to database**
```bash
# Verify Supabase is running
supabase status

# Test connection
psql postgresql://postgres:postgres@localhost:54322/postgres
```

**Issue: Migrations not applying**
```bash
# Check migration files
supabase migration list

# Force reset
supabase db reset --debug
```

**Issue: Verdaccio auto-start not working**
```bash
# Check if environment variable is set
echo $START_VERDACCIO

# Enable Verdaccio auto-start
echo "START_VERDACCIO=true" >> .env

# Manually start Verdaccio
docker compose --profile verdaccio up -d
```

### Stopping Services

```bash
# Stop Supabase (preserves data)
supabase stop

# Stop workspace
docker compose down
```

## Security Notes

### Optional Environment Variables

You can optionally set these in your host environment:

- `GITHUB_USER`: Display GitHub username in shell prompt (cosmetic)
- `GH_PAT`: GitHub Personal Access Token for CLI operations
