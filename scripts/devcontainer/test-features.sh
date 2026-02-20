#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${REPO_ROOT}/scripts/common.sh"

DEFAULT_IMAGE="mcr.microsoft.com/devcontainers/typescript-node:24-bookworm"
IMAGE="${FEATURE_TEST_IMAGE:-$DEFAULT_IMAGE}"

usage(){
  cat <<'USAGE'
Usage: scripts/devcontainer/test-features.sh [options] [feature...]

Run devcontainer feature installers in disposable Docker containers without
rebuilding the devcontainer image.

Options:
  -i, --image <image>     Docker image to use for tests.
                          Default: mcr.microsoft.com/devcontainers/typescript-node:24-bookworm
  -f, --feature <name>    Feature to test (repeatable).
  -h, --help              Show this help.

Features:
  cli-tools
  supabase-cli
  uv

Examples:
  scripts/devcontainer/test-features.sh
  scripts/devcontainer/test-features.sh -f cli-tools
  scripts/devcontainer/test-features.sh supabase-cli uv
  scripts/devcontainer/test-features.sh --image mcr.microsoft.com/devcontainers/base:ubuntu
USAGE
}

require_docker(){
  if ! command -v docker >/dev/null 2>&1; then
    err "docker is required"
    exit 1
  fi

  if ! docker info >/dev/null 2>&1; then
    err "Docker daemon is not reachable"
    exit 1
  fi
}

is_supported_feature(){
  case "$1" in
    cli-tools|supabase-cli|uv)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

feature_expected_bins(){
  case "$1" in
    cli-tools)
      printf '%s\n' "rg fd bat lsd delta hx jq yq gojq fzf shellcheck shfmt"
      ;;
    supabase-cli)
      printf '%s\n' "supabase"
      ;;
    uv)
      printf '%s\n' "uv uvx"
      ;;
  esac
}

run_feature_test(){
  local feature="$1"
  local expected_bins
  local feature_path

  expected_bins="$(feature_expected_bins "$feature")"
  feature_path=".devcontainer/features/${feature}"

  log "Testing feature '${feature}' using image '${IMAGE}'"

  if [[ ! -d "${REPO_ROOT}/${feature_path}" ]]; then
    err "Feature path not found: ${REPO_ROOT}/${feature_path}"
    exit 1
  fi

  tar -C "${REPO_ROOT}" -cf - "${feature_path}" \
    | docker run --rm -i \
      -e "FEATURE=${feature}" \
      -e "EXPECTED_BINS=${expected_bins}" \
      "${IMAGE}" \
      bash -lc '
        set -euo pipefail
        mkdir -p /workspace
        tar -xf - -C /workspace
        cd "/workspace/.devcontainer/features/${FEATURE}"
        case "${FEATURE}" in
          supabase-cli|uv)
            export VERSION=latest
            ;;
        esac
        bash ./install.sh
        for bin in ${EXPECTED_BINS}; do
          command -v "$bin" >/dev/null
        done
      '

  log "Feature '${feature}' passed"
}

FEATURES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--image)
      if [[ $# -lt 2 ]]; then
        err "Missing value for $1"
        exit 1
      fi
      IMAGE="$2"
      shift 2
      ;;
    -f|--feature)
      if [[ $# -lt 2 ]]; then
        err "Missing value for $1"
        exit 1
      fi
      if ! is_supported_feature "$2"; then
        err "Unsupported feature: $2"
        exit 1
      fi
      FEATURES+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if ! is_supported_feature "$1"; then
        err "Unsupported argument/feature: $1"
        usage
        exit 1
      fi
      FEATURES+=("$1")
      shift
      ;;
  esac
done

if [[ ${#FEATURES[@]} -eq 0 ]]; then
  FEATURES=(cli-tools supabase-cli uv)
fi

require_docker

for feature in "${FEATURES[@]}"; do
  run_feature_test "$feature"
done

log "All selected features passed"
