#!/usr/bin/env bash

log(){ printf '[cli-tools] %s\n' "$*"; }
warn(){ printf '[cli-tools][WARN] %s\n' "$*" >&2; }
err(){ printf '[cli-tools][ERROR] %s\n' "$*" >&2; }

_sudo_exec(){
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    "$@"
  fi
}

APT_UPDATED=false

ensure_apt_packages(){
  if (( $# == 0 )); then
    warn "ensure_apt_packages received no package names; skipping."
    return 0
  fi

  local -a missing=()
  local pkg=""
  for pkg in "$@"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if (( ${#missing[@]} == 0 )); then
    return 0
  fi

  if [[ "${APT_UPDATED}" != true ]]; then
    _sudo_exec apt-get update -qqy >/dev/null
    APT_UPDATED=true
  fi

  _sudo_exec apt-get -qq -o Dpkg::Use-Pty=0 install -y --no-install-recommends "${missing[@]}"
}

apt_cleanup(){
  if command -v apt-get >/dev/null 2>&1; then
    _sudo_exec apt-get clean >/dev/null 2>&1 || true
  fi
  if [[ -d /var/lib/apt/lists ]]; then
    _sudo_exec rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/partial >/dev/null 2>&1 || true
  fi
}

feature_option_enabled(){
  local name="$1"
  local default="$2"
  local upper_name="${name^^}"
  local lower_name="${name,,}"
  local value="${!upper_name:-${!lower_name:-$default}}"

  case "${value,,}" in
    true|1|yes|on) return 0 ;;
    *) return 1 ;;
  esac
}

feature_option_value(){
  local name="$1"
  local default="$2"
  local upper_name="${name^^}"
  local lower_name="${name,,}"
  local value="${!upper_name:-${!lower_name:-$default}}"
  printf '%s\n' "${value}"
}

normalize_tag(){
  local value="$1"
  if [[ -z "${value}" ]]; then
    return 0
  fi
  if [[ "${value}" == v* ]]; then
    printf '%s\n' "${value}"
  else
    printf 'v%s\n' "${value}"
  fi
}

detect_arch(){
  local machine
  machine="$(uname -m)"
  case "${machine}" in
    x86_64|amd64)
      printf 'amd64'
      ;;
    aarch64|arm64)
      printf 'arm64'
      ;;
    *)
      err "Unsupported architecture: ${machine}"
      exit 1
      ;;
  esac
}

shellcheck_arch(){
  local bin_arch="$1"
  case "${bin_arch}" in
    amd64) printf 'x86_64' ;;
    arm64) printf 'aarch64' ;;
    *)
      err "Unsupported architecture for shellcheck: ${bin_arch}"
      exit 1
      ;;
  esac
}

gh_can_auth(){
  if ! command -v gh >/dev/null 2>&1; then
    return 1
  fi

  if [[ -n "${GH_TOKEN:-}" || -n "${GITHUB_TOKEN:-}" ]]; then
    return 0
  fi

  gh auth status >/dev/null 2>&1
}

fetch_release_tag(){
  local repo="$1"
  local fallback_tag="$2"
  local tag=""

  if gh_can_auth; then
    tag="$(gh release view --repo "${repo}" --json tagName --jq '.tagName' 2>/dev/null || true)"
  fi

  if [[ -z "${tag}" ]]; then
    local release_json=""
    if release_json="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" 2>/dev/null)"; then
      if command -v jq >/dev/null 2>&1; then
        tag="$(jq -r '.tag_name' <<<"${release_json}")"
      else
        tag="$(awk -F'"' '/"tag_name"/ {print $4; exit}' <<<"${release_json}")"
      fi
    fi
  fi

  if [[ -z "${tag}" || "${tag}" == "null" ]]; then
    tag="${fallback_tag}"
  fi

  normalize_tag "${tag}"
}

resolve_release_tag(){
  local repo="$1"
  local tag_env="$2"
  local version_env="$3"
  local fallback_tag="$4"

  local tag="${!tag_env:-}"
  if [[ -n "${tag}" ]]; then
    normalize_tag "${tag}"
    return
  fi

  local version="${!version_env:-}"
  if [[ -n "${version}" ]]; then
    if [[ "${version,,}" == "latest" ]]; then
      fetch_release_tag "${repo}" "${fallback_tag}"
      return
    fi
    normalize_tag "${version}"
    return
  fi

  fetch_release_tag "${repo}" "${fallback_tag}"
}

download_and_install_package(){
  local package="$1"
  local version="$2"
  local url="$3"
  local package_id="${4:-$package}"
  local installed_version=""

  if dpkg -s "$package_id" >/dev/null 2>&1; then
    installed_version="$(dpkg-query -W -f='${Version}' "$package_id" 2>/dev/null || true)"
    if [[ "${installed_version}" == "${version}" ]]; then
      log "${package_id} ${version} already installed; skipping."
      return 0
    fi
  fi

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local deb_path="${tmp_dir}/${package}_${version}.deb"

  log "Downloading ${package} ${version} from ${url}..."
  curl -fsSL -o "${deb_path}" "${url}"
  _sudo_exec dpkg -i "${deb_path}"
  rm -rf "${tmp_dir}"
}

ensure_nanolayer(){
  local variable_name="$1"
  local required_version="$2"
  local normalized_required=""
  normalized_required="$(normalize_tag "${required_version}")"

  local nanolayer_location=""
  if [[ -z "${NANOLAYER_FORCE_CLI_INSTALLATION:-}" ]]; then
    if [[ -z "${NANOLAYER_CLI_LOCATION:-}" ]]; then
      if command -v nanolayer >/dev/null 2>&1; then
        nanolayer_location="nanolayer"
      fi
    elif [[ -x "${NANOLAYER_CLI_LOCATION}" ]]; then
      nanolayer_location="${NANOLAYER_CLI_LOCATION}"
    fi

    if [[ -n "${nanolayer_location}" ]]; then
      local current_version=""
      current_version="$("${nanolayer_location}" --version 2>/dev/null || true)"
      current_version="$(normalize_tag "${current_version}")"
      if [[ "${current_version}" != "${normalized_required}" ]]; then
        nanolayer_location=""
      fi
    fi
  fi

  if [[ -z "${nanolayer_location}" ]]; then
    local uname_sm
    uname_sm="$(uname -sm)"
    case "${uname_sm}" in
      "Linux x86_64"|"Linux aarch64"|"Linux arm64")
        ;;
      *)
        err "No nanolayer binary available for architecture: ${uname_sm}"
        exit 1
        ;;
    esac

    local tmp_dir
    tmp_dir="$(mktemp -d -t nanolayer-XXXXXXXXXX)"

    local trap_cmd=""
    trap_cmd="__nanolayer_rc=\$?; rm -rf ${tmp_dir} >/dev/null 2>&1 || true; exit \$__nanolayer_rc"
    # shellcheck disable=SC2064
    trap "${trap_cmd}" EXIT

    local clib_type="gnu"
    if [[ -x "/sbin/apk" ]]; then
      clib_type="musl"
    fi

    local arch
    arch="$(uname -m)"
    local tar_filename="nanolayer-${arch}-unknown-linux-${clib_type}.tgz"
    local archive_path="${tmp_dir}/${tar_filename}"
    local url="https://github.com/devcontainers-extra/nanolayer/releases/download/${normalized_required}/${tar_filename}"

    if command -v curl >/dev/null 2>&1; then
      curl -fsSL -o "${archive_path}" "${url}"
    elif command -v wget >/dev/null 2>&1; then
      wget -q "${url}" -O "${archive_path}"
    else
      ensure_apt_packages ca-certificates wget
      wget -q "${url}" -O "${archive_path}"
    fi

    tar -xzf "${archive_path}" -C "${tmp_dir}"
    chmod +x "${tmp_dir}/nanolayer"
    nanolayer_location="${tmp_dir}/nanolayer"
  fi

  declare -g "${variable_name}=${nanolayer_location}"
}

run_gh_release_install(){
  local nanolayer_cli="$1"
  local repo="$2"
  local binary_names="$3"
  local version="$4"
  local lib_name="${5:-}"
  local asset_regex="${6:-}"
  local gh_release_feature_ref="${GH_RELEASE_FEATURE_REF:-ghcr.io/devcontainers-extra/features/gh-release:1}"

  local -a args=(
    install
    devcontainer-feature
    "${gh_release_feature_ref}"
    --option "repo=${repo}"
    --option "binaryNames=${binary_names}"
    --option "version=${version}"
  )

  if [[ -n "${lib_name}" ]]; then
    args+=(--option "libName=${lib_name}")
  fi

  if [[ -n "${asset_regex}" ]]; then
    args+=(--option "assetRegex=${asset_regex}")
  fi

  # shellcheck disable=SC2154
  "${nanolayer_cli}" "${args[@]}"
}
