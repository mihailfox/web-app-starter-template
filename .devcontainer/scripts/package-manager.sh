#!/usr/bin/env bash
set -euo pipefail

pm_warn(){
  if declare -f warn >/dev/null 2>&1; then
    warn "$@"
  else
    printf '[WARN] %s\n' "$*" >&2
  fi
}

pm_read_package_manager_field(){
  local package_json_path="${1:-package.json}"

  if [[ ! -f "${package_json_path}" ]]; then
    printf '%s' ""
    return 0
  fi

  node -e "
    const fs = require('fs');
    const path = process.argv[1];
    try {
      const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));
      const value = typeof pkg.packageManager === 'string' ? pkg.packageManager : '';
      process.stdout.write(value);
    } catch {
      process.stdout.write('');
    }
  " "${package_json_path}"
}

pm_repo_root_from_package_json(){
  local package_json_path="${1:-package.json}"
  local package_json_dir=""

  package_json_dir="$(dirname "${package_json_path}")"
  (
    cd "${package_json_dir}" >/dev/null 2>&1
    pwd
  )
}

pm_manager_from_spec(){
  local package_manager_field="${1:-}"
  local manager="${package_manager_field%%@*}"

  case "${manager}" in
    yarn|pnpm|npm)
      printf '%s\n' "${manager}"
      ;;
    *)
      printf '%s\n' ""
      ;;
  esac
}

pm_resolve_spec(){
  local package_json_path="${1:-package.json}"
  local package_manager_field=""
  local manager=""

  package_manager_field="$(pm_read_package_manager_field "${package_json_path}")"
  manager="$(pm_manager_from_spec "${package_manager_field}")"

  if [[ -n "${manager}" ]]; then
    printf '%s\n' "${package_manager_field}"
    return 0
  fi

  manager="$(pm_detect_manager "${package_json_path}")"
  case "${manager}" in
    yarn)
      printf '%s\n' "yarn@stable"
      ;;
    pnpm)
      printf '%s\n' "pnpm@latest"
      ;;
    npm)
      printf '%s\n' ""
      ;;
    *)
      pm_warn "Unknown package manager '${manager}', defaulting to npm."
      printf '%s\n' ""
      ;;
  esac
}

pm_detect_manager(){
  local package_json_path="${1:-package.json}"
  local package_manager_field=""
  local manager=""
  local repo_root=""

  package_manager_field="$(pm_read_package_manager_field "${package_json_path}")"
  manager="$(pm_manager_from_spec "${package_manager_field}")"
  if [[ -n "${manager}" ]]; then
    printf '%s\n' "${manager}"
    return 0
  fi

  repo_root="$(pm_repo_root_from_package_json "${package_json_path}")"
  if [[ -f "${repo_root}/yarn.lock" ]]; then
    printf '%s\n' "yarn"
    return 0
  fi

  if [[ -f "${repo_root}/pnpm-lock.yaml" ]]; then
    printf '%s\n' "pnpm"
    return 0
  fi

  printf '%s\n' "npm"
}

pm_detect_manager_label(){
  local package_json_path="${1:-package.json}"
  local package_manager_field=""
  local manager=""

  package_manager_field="$(pm_read_package_manager_field "${package_json_path}")"
  manager="$(pm_detect_manager "${package_json_path}")"

  if [[ -n "${package_manager_field}" ]]; then
    printf '%s\n' "${manager} (${package_manager_field})"
    return 0
  fi

  printf '%s\n' "${manager}"
}

pm_prepare_manager(){
  local package_json_path="${1:-package.json}"
  local manager=""
  local package_manager_spec=""

  manager="$(pm_detect_manager "${package_json_path}")"
  package_manager_spec="$(pm_resolve_spec "${package_json_path}")"
  export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

  case "${manager}" in
    yarn|pnpm)
      if ! command -v corepack >/dev/null 2>&1; then
        echo "corepack is required to prepare ${manager}." >&2
        return 1
      fi

      corepack enable --install-directory "${HOME}/.local/bin" >/dev/null 2>&1 || corepack enable >/dev/null 2>&1
      corepack prepare "${package_manager_spec}" --activate
      ;;
    npm)
      if ! command -v npm >/dev/null 2>&1; then
        echo "npm is required but was not found in PATH." >&2
        return 1
      fi
      ;;
    *)
      echo "Unsupported package manager '${manager}'." >&2
      return 1
      ;;
  esac
}

pm_install_dependencies(){
  local package_json_path="${1:-package.json}"
  local manager=""
  local repo_root=""

  manager="$(pm_detect_manager "${package_json_path}")"
  repo_root="$(pm_repo_root_from_package_json "${package_json_path}")"

  case "${manager}" in
    yarn)
      if [[ -f "${repo_root}/yarn.lock" ]]; then
        yarn install --immutable
      else
        yarn install
      fi
      ;;
    pnpm)
      if [[ -f "${repo_root}/pnpm-lock.yaml" ]]; then
        pnpm install --frozen-lockfile
      else
        pnpm install
      fi
      ;;
    npm)
      if [[ -f "${repo_root}/package-lock.json" || -f "${repo_root}/npm-shrinkwrap.json" ]]; then
        npm ci
      else
        npm install
      fi
      ;;
    *)
      echo "Unsupported package manager '${manager}'." >&2
      return 1
      ;;
  esac
}

pm_has_playwright_dependency(){
  local package_json_path="${1:-package.json}"

  [[ -f "${package_json_path}" ]] || return 1

  node -e "
    const fs = require('fs');
    const path = process.argv[1];
    try {
      const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));
      const allDeps = Object.assign({}, pkg.dependencies || {}, pkg.devDependencies || {});
      process.exit(allDeps.playwright || allDeps['@playwright/test'] ? 0 : 1);
    } catch {
      process.exit(1);
    }
  " "${package_json_path}" >/dev/null 2>&1
}

pm_set_registry(){
  local registry="$1"
  local package_json_path="${2:-package.json}"
  local manager=""

  manager="$(pm_detect_manager "${package_json_path}")"
  case "${manager}" in
    yarn)
      yarn config set npmRegistryServer "${registry}" --home >/dev/null
      ;;
    pnpm)
      pnpm config set registry "${registry}" --global >/dev/null
      ;;
    npm)
      npm config set registry "${registry}" --location=user >/dev/null
      ;;
    *)
      echo "Unsupported package manager '${manager}'." >&2
      return 1
      ;;
  esac
}

pm_install_playwright_browser(){
  local browser="${1:-chromium}"
  local package_json_path="${2:-package.json}"
  local manager=""

  manager="$(pm_detect_manager "${package_json_path}")"
  case "${manager}" in
    yarn)
      yarn playwright install --with-deps "${browser}"
      ;;
    pnpm)
      pnpm exec playwright install --with-deps "${browser}"
      ;;
    npm)
      npx --no-install playwright install --with-deps "${browser}"
      ;;
    *)
      echo "Unsupported package manager '${manager}'." >&2
      return 1
      ;;
  esac
}
