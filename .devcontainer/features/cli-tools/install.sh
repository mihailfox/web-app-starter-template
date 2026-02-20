#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# shellcheck disable=SC1091
source ./library_scripts.sh

log "Starting CLI tools installation..."

nanolayer_location=""
ensure_nanolayer nanolayer_location "0.5.6"

DEB_ARCH="$(detect_arch)"
BIN_ARCH="${DEB_ARCH}"

install_ripgrep(){
  local tag="15.1.0"
  local machine
  machine="$(uname -m)"
  local asset_regex=""

  case "${machine}" in
    x86_64|amd64)
      asset_regex="^ripgrep-15\\.1\\.0-x86_64-unknown-linux-musl\\.tar\\.gz$"
      ;;
    armv7|armv7l)
      asset_regex="^ripgrep-15\\.1\\.0-armv7-unknown-linux-musleabihf\\.tar\\.gz$"
      ;;
    *)
      err "Unsupported architecture for ripgrep gh-release asset: ${machine}"
      exit 1
      ;;
  esac

  run_gh_release_install "${nanolayer_location}" "BurntSushi/ripgrep" "rg" "${tag}" "ripgrep" "${asset_regex}"
}

install_shfmt(){
  local tag
  tag="$(resolve_release_tag "mvdan/sh" "SHFMT_TAG" "SHFMT_VERSION" "v3.9.0")"
  local asset_regex="^shfmt_${tag}_linux_${BIN_ARCH}$"
  run_gh_release_install "${nanolayer_location}" "mvdan/sh" "shfmt" "${tag}" "shfmt" "${asset_regex}"
}


install_fd(){
  local version="${FD_VERSION:-10.3.0}"
  local tag="${FD_TAG:-v10.3.0}"
  local url="https://github.com/sharkdp/fd/releases/download/${tag}/fd_${version}_${DEB_ARCH}.deb"
  download_and_install_package "fd" "${version}" "${url}"
}

install_bat(){
  local version="${BAT_VERSION:-0.26.1}"
  local tag="${BAT_TAG:-v0.26.1}"
  local url="https://github.com/sharkdp/bat/releases/download/${tag}/bat_${version}_${DEB_ARCH}.deb"
  download_and_install_package "bat" "${version}" "${url}"
}

install_lsd(){
  local version="${LSD_VERSION:-1.2.0}"
  local tag="${LSD_TAG:-v1.2.0}"
  local url="https://github.com/lsd-rs/lsd/releases/download/${tag}/lsd_${version}_${DEB_ARCH}.deb"
  download_and_install_package "lsd" "${version}" "${url}"
}

install_delta(){
  local version="${DELTA_VERSION:-0.18.2}"
  local tag="${DELTA_TAG:-0.18.2}"
  local url="https://github.com/dandavison/delta/releases/download/${tag}/git-delta_${version}_${DEB_ARCH}.deb"
  download_and_install_package "delta" "${version}" "${url}" "git-delta"
}

install_helix(){
  local version="${HELIX_VERSION:-25.7.1-1}"
  local tag="${HELIX_TAG:-25.07.1}"
  local url="https://github.com/helix-editor/helix/releases/download/${tag}/helix_${version}_${DEB_ARCH}.deb"
  download_and_install_package "helix" "${version}" "${url}"
}

install_fzf(){
  local tag
  tag="$(resolve_release_tag "junegunn/fzf" "FZF_TAG" "FZF_VERSION" "v0.67.0")"
  local asset_version="${tag#v}"
  local asset_regex="^fzf-${asset_version}-linux_${BIN_ARCH}\\.tar\\.gz$"
  run_gh_release_install "${nanolayer_location}" "junegunn/fzf" "fzf" "${tag}" "fzf" "${asset_regex}"
}

install_jq(){
  local tag="${JQ_TAG:-jq-1.8.1}"
  local asset_regex=""

  case "${BIN_ARCH}" in
    amd64)
      asset_regex="^jq-linux-amd64$"
      ;;
    arm64)
      asset_regex="^jq-linux-arm64$"
      ;;
    *)
      err "Unsupported architecture for jq: ${BIN_ARCH}"
      exit 1
      ;;
  esac

  run_gh_release_install "${nanolayer_location}" "jqlang/jq" "jq" "${tag}" "jq" "${asset_regex}"
}

install_yq(){
  local tag
  tag="$(resolve_release_tag "mikefarah/yq" "YQ_TAG" "YQ_VERSION" "v4.52.4")"
  local asset_regex="^yq_linux_${BIN_ARCH}$"
  run_gh_release_install "${nanolayer_location}" "mikefarah/yq" "yq" "${tag}" "yq" "${asset_regex}"
}

install_gojq(){
  local tag
  tag="$(resolve_release_tag "itchyny/gojq" "GOJQ_TAG" "GOJQ_VERSION" "v0.12.18")"
  local asset_regex="^gojq_${tag}_linux_${BIN_ARCH}\\.tar\\.gz$"
  run_gh_release_install "${nanolayer_location}" "itchyny/gojq" "gojq" "${tag}" "gojq" "${asset_regex}"
}

install_shellcheck(){
  local tag
  tag="$(resolve_release_tag "koalaman/shellcheck" "SHELLCHECK_TAG" "SHELLCHECK_VERSION" "v0.11.0")"
  local arch
  arch="$(shellcheck_arch "${BIN_ARCH}")"
  local asset_regex="^shellcheck-${tag}\\.linux\\.${arch}\\.tar\\.xz$"
  run_gh_release_install "${nanolayer_location}" "koalaman/shellcheck" "shellcheck" "${tag}" "shellcheck" "${asset_regex}"
}


if feature_option_enabled "fzf" "true"; then
  install_fzf
else
  log "Skipping fzf installation."
fi

if feature_option_enabled "ripgrep" "true"; then
  install_ripgrep
else
  log "Skipping ripgrep installation."
fi

if feature_option_enabled "fd" "true"; then
  install_fd
else
  log "Skipping fd installation."
fi

if feature_option_enabled "bat" "true"; then
  install_bat
else
  log "Skipping bat installation."
fi

if feature_option_enabled "lsd" "true"; then
  install_lsd
else
  log "Skipping lsd installation."
fi

if feature_option_enabled "delta" "true"; then
  install_delta
else
  log "Skipping git-delta installation."
fi

if feature_option_enabled "helix" "true"; then
  install_helix
else
  log "Skipping helix installation."
fi

if feature_option_enabled "jq" "true"; then
  install_jq
else
  log "Skipping jq installation."
fi

if feature_option_enabled "yq" "true"; then
  install_yq
else
  log "Skipping yq installation."
fi

if feature_option_enabled "gojq" "true"; then
  install_gojq
else
  log "Skipping gojq installation."
fi

if feature_option_enabled "shellcheck" "true"; then
  install_shellcheck
else
  log "Skipping shellcheck installation."
fi

if feature_option_enabled "shfmt" "true"; then
  install_shfmt
else
  log "Skipping shfmt installation."
fi

apt_cleanup

log "cli-tools feature completed."
