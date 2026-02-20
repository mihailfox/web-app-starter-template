#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPTS_DIR}/../.." && pwd)"

# shellcheck source=.devcontainer/scripts/common.sh
source "${SCRIPTS_DIR}/common.sh"
# shellcheck source=.devcontainer/scripts/package-manager.sh
source "${SCRIPTS_DIR}/package-manager.sh"

cd "${REPO_ROOT}"

set_registry_with_fallback(){
  local verdaccio_registry="${VERDACCIO_URL:-http://verdaccio:4873}"
  local default_registry="https://registry.npmjs.org"

  if command -v curl >/dev/null 2>&1 && curl --silent --fail --max-time 2 "${verdaccio_registry}/-/ping" >/dev/null; then
    log "Using Verdaccio registry: ${verdaccio_registry}"
    pm_set_registry "${verdaccio_registry}" package.json >/dev/null 2>&1 || true
    return 0
  fi

  log "Verdaccio unavailable, using npmjs registry: ${default_registry}"
  pm_set_registry "${default_registry}" package.json >/dev/null 2>&1 || true
}

package_manager="$(pm_detect_manager_label package.json)"
log "Using package manager: ${package_manager}"
pm_prepare_manager package.json

set_registry_with_fallback

if pm_has_playwright_dependency package.json; then
  log "Installing Playwright browser dependencies (chromium)..."
  pm_install_playwright_browser chromium package.json
else
  log "No root Playwright dependency found; skipping browser install."
fi

log "post-create completed."
