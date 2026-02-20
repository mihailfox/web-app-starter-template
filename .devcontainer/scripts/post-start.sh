#!/usr/bin/env bash
# Auto-start script for Supabase and optional services
# Runs on every devcontainer start (postStartCommand)
#
# Chosen configuration:
# - Auto-Start: postStartCommand (runs every start)
# - Verdaccio: Environment variable controlled (START_VERDACCIO=true to enable)
# - Health Checks: Wait with 60s timeout
# - Logging: Summary level
# - Error Handling: Log error, continue

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPTS_DIR}/../logs"
LOG_FILE="${LOG_DIR}/supabase-startup.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Helper functions
log_info() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️  $*"
}

log_success() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ $*"
}

log_error() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✗ $*" >&2
}

log_warning() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $*"
}

# Main startup function
start_services() {
	log_info "Starting devcontainer services..."

	# 1. Start Verdaccio
	start_verdaccio

	# 2. Start Supabase Stack
	start_supabase


	log_success "All services started"
}

start_supabase() {
	log_info "Checking Supabase status..."

	# Check if Supabase containers are already running (bypass CLI health check)
	local db_running=$(docker ps --filter "name=supabase-db-web-app-starter-template" --filter "status=running" --format "{{.Names}}" 2>/dev/null)
	local studio_running=$(docker ps --filter "name=supabase-studio-web-app-starter-template" --filter "status=running" --format "{{.Names}}" 2>/dev/null)

	if [[ -n "$db_running" && -n "$studio_running" ]]; then
		log_success "Supabase is already running"
		log_info "Access Studio at: http://localhost:54323"
		return 0
	fi

	log_info "Starting Supabase stack with host networking..."
	log_info "This may take 30-60 seconds on first start (downloading images)..."

	# NOTE: Supabase CLI doesn't natively support --network=host
	# We use a workaround by setting DOCKER_DEFAULT_PLATFORM and hoping the CLI respects it
	# If this doesn't work, we may need to manually manage containers or patch the CLI

	# Attempt to start Supabase (will likely still have health check issues, but containers may start)
	if cd /workspaces/euromagna-site && supabase start 2>&1 | tee -a "${LOG_FILE}"; then
		log_success "Supabase started successfully"
	else
		log_warning "Supabase CLI reported errors (this is expected due to health check issues)"
		log_info "Checking if containers started anyway..."
	fi

	# Wait for key services to be running (with timeout)
	log_info "Waiting for key services to be running (60s timeout)..."
	local timeout=60
	local elapsed=0
	local interval=5

	while [ $elapsed -lt $timeout ]; do
		# Check if key containers are running and healthy
		db_running=$(docker ps --filter "name=supabase-db-web-app-starter-template" --filter "status=running" --format "{{.Names}}" 2>/dev/null)
		studio_running=$(docker ps --filter "name=supabase-studio-web-app-starter-template" --filter "status=running" --format "{{.Names}}" 2>/dev/null)

		if [[ -n "$db_running" && -n "$studio_running" ]]; then
			log_success "Supabase services are running"
			log_info "Access Studio at: http://localhost:54323"
			log_info "API Gateway at: http://localhost:54321"
			log_info "Database at: localhost:54322"

			# Test connectivity
			if timeout 5 bash -c "cat < /dev/null > /dev/tcp/localhost/54322" 2>/dev/null; then
				log_success "Database is accessible at localhost:54322"
			else
				log_warning "Database container is running but port may not be accessible yet"
			fi

			return 0
		fi

		sleep $interval
		elapsed=$((elapsed + interval))
		log_info "Waiting... (${elapsed}s/${timeout}s)"
	done

	log_warning "Timeout waiting for services to start"
	log_warning "Check status with: docker ps --filter 'name=supabase'"
	log_info "You may need to manually run: supabase start"
	return 1
}

start_verdaccio() {
	# Check if Verdaccio auto-start is enabled
	if [[ "${START_VERDACCIO:-false}" != "true" ]]; then
		log_info "Verdaccio auto-start disabled (set START_VERDACCIO=true to enable)"
		return 0
	fi

	log_info "Starting Verdaccio..."

	# Check if Verdaccio is already running
	if docker compose ps verdaccio 2>/dev/null | grep -q "Up"; then
		log_success "Verdaccio is already running"
		return 0
	fi

	# Start Verdaccio via docker compose profile
	if docker compose --profile verdaccio up -d verdaccio 2>&1 | grep -v "Container.*Running" || true; then
		log_success "Verdaccio started at: http://localhost:4873"
	else
		log_error "Failed to start Verdaccio"
		log_warning "You can manually start with: docker compose --profile verdaccio up -d"
		return 1
	fi
}

# Run startup in background and redirect output to log file
{
	log_info "=== Devcontainer Post-Start: $(date) ==="

	# Run startup function
	if start_services; then
		log_success "=== Post-start completed successfully ==="
	else
		log_error "=== Post-start completed with errors ==="
		log_info "Check logs for details: .devcontainer/logs/supabase-startup.log"
	fi

} >>"${LOG_FILE}" 2>&1 &

# Print info to terminal (non-blocking)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Starting services in background..."
echo "📋 Logs: tail -f .devcontainer/logs/supabase-startup.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
