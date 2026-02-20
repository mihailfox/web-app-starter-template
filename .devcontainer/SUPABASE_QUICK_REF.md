# Supabase CLI Quick Reference

## Common Commands

### Service Management
```bash
supabase start         # Start all services
supabase stop          # Stop all services
supabase status        # Show service status and URLs
```

### Database
```bash
supabase db reset                    # Reset DB + apply migrations + seed
supabase db diff                     # Compare local vs remote
supabase db push                     # Push migrations to remote
supabase migration new <name>        # Create new migration
supabase migration list              # List migrations
```

### Functions
```bash
supabase functions new <name>        # Create new function
supabase functions serve             # Serve functions locally
supabase functions deploy <name>     # Deploy function
```

### Types
```bash
supabase gen types typescript --local > src/types/supabase.ts
```

### Linking (for remote projects)
```bash
supabase link --project-ref <ref>    # Link to remote project
supabase db pull                     # Pull remote schema
```

## Service URLs (from `supabase status`)

- API: http://localhost:54321
- DB: postgresql://postgres:postgres@localhost:54322/postgres
- Studio: http://localhost:54323
- Inbucket: http://localhost:54324

## Configuration

Edit `supabase/config.toml` to change:
- Ports
- Service settings
- Auth configuration
- Database settings

## Troubleshooting

**Port conflicts:**
```bash
lsof -i :54321  # Check what's using port
```

**Reset everything:**
```bash
supabase db reset
```

**View logs:**
```bash
docker logs supabase-db
docker logs supabase-kong
```

## Hybrid Architecture

This project uses a **hybrid approach**:
- **Supabase CLI** manages: PostgreSQL, Auth, Storage, Realtime, Studio
- **Docker Compose** manages: Workspace, Verdaccio
- **Shared Network**: `supabase_network_web-app-starter-template`

**Start order is flexible:**
```bash
# Either order works
supabase start && docker compose up -d
# or
docker compose up -d && supabase start
```

## Resources

- [Supabase CLI Docs](https://supabase.com/docs/guides/cli)
- [Config Reference](https://supabase.com/docs/guides/cli/config)
- [Local Development](https://supabase.com/docs/guides/local-development)
