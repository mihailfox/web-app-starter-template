#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# shellcheck disable=SC1091
source ./library_scripts.sh

# nanolayer is a cli utility which keeps container layers as small as possible
# source code: https://github.com/devcontainers-extra/nanolayer
# `ensure_nanolayer` is a bash function that will find any existing nanolayer installations,
# and if missing - will download a temporary copy that automatically get deleted at the end
# of the script
ensure_nanolayer nanolayer_location "v0.5.4"


# shellcheck disable=SC2154
$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers-extra/features/gh-release:1.0.25" \
    --option repo='supabase/cli' --option binaryNames='supabase' --option version="$VERSION"



echo 'Done!'
