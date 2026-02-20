#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPTS_DIR}/../.." && pwd)"

# shellcheck source=.devcontainer/scripts/common.sh
source "${SCRIPTS_DIR}/common.sh"
# shellcheck source=.devcontainer/scripts/package-manager.sh
source "${SCRIPTS_DIR}/package-manager.sh"

cd "${REPO_ROOT}"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

package_manager="$(pm_detect_manager_label package.json)"
log "Using package manager: ${package_manager}"

pm_prepare_manager package.json

log "Installing project dependencies..."
pm_install_dependencies package.json

log "update-content completed."
