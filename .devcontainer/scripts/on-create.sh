#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.devcontainer/scripts/common.sh
source "${SCRIPTS_DIR}/common.sh"
# shellcheck source=.devcontainer/scripts/config.sh
source "${SCRIPTS_DIR}/config.sh"
# shellcheck source=.devcontainer/scripts/package-manager.sh
source "${SCRIPTS_DIR}/package-manager.sh"

log "Bootstrapping devcontainer tools..."

ensure_npm_package npm
ensure_npm_package yarn

package_json_path="${SCRIPTS_DIR}/../../package.json"
package_manager="$(pm_detect_manager_label "${package_json_path}")"
log "Preparing package manager: ${package_manager}"
pm_prepare_manager "${package_json_path}"

mkdir -p "${HOME}/.cache/ms-playwright" "${HOME}/.local/bin"

log "on-create completed."
