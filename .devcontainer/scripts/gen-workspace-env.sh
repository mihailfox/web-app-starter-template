#!/usr/bin/env bash
# Generate environment variables for devcontainer Docker Compose workspace mounting
#
# This script enables Docker Compose devcontainer services to work consistently
# whether using a local filesystem bind mount or a named container volume
# (e.g., GitHub Codespaces, "Clone in Volume").
#
# Inspired by: https://github.com/h4l/dev-container-docker-compose-volume-or-bind
# Simplified for this template's specific use case.

set -euo pipefail

SCRIPT_VERSION="1.0.0"

# Default values
ENV_FILE_DIR=".devcontainer"
NO_WRITE="false"
CONTAINER_WORKSPACE_FOLDER=""
LOCAL_WORKSPACE_FOLDER=""

show_help() {
	cat <<EOF
Generate environment variables for devcontainer Docker Compose workspace mounting

Usage: gen-workspace-env.sh [options]

Options:
  --container-workspace-folder PATH
      The value of \${containerWorkspaceFolder} from devcontainer.json
      
  --local-workspace-folder PATH
      The value of \${localWorkspaceFolder} from devcontainer.json
      
  --env-dir PATH
      Directory to create .env file in (default: .devcontainer)
      
  --no-write
      Print environment variables without writing .env file
      
  --version
      Show version information
      
  --help
      Show this help message

Generated Environment Variables:
  WORKSPACE_SOURCE       - Source for Docker Compose volumes entry
  WORKSPACE_TARGET       - Target for Docker Compose volumes entry  
  WORKSPACE_ROOT         - Path to workspace code in container
  WORKSPACE_IS_CONTAINER_VOLUME - true/false
  WORKSPACE_IS_BIND_MOUNT        - true/false

For container volume workspaces (Codespaces, Clone in Volume):
  WORKSPACE_CONTAINER_VOLUME_SOURCE - Volume name (e.g., vscode-projects)
  WORKSPACE_CONTAINER_VOLUME_TARGET - Volume mount point (e.g., /workspaces)

For bind mount workspaces (local clone):
  WORKSPACE_BIND_MOUNT_SOURCE - Host path (e.g., /home/user/projects/myproject)
  WORKSPACE_BIND_MOUNT_TARGET - Container path (e.g., /workspaces/myproject)

Example devcontainer.json configuration:
  {
    "dockerComposeFile": "docker-compose.yml",
    "service": "workspace",
    "workspaceFolder": "/workspaces/\${localWorkspaceFolderBasename}",
    "initializeCommand": ".devcontainer/scripts/gen-workspace-env.sh --container-workspace-folder '\${containerWorkspaceFolder}' --local-workspace-folder '\${localWorkspaceFolder}'"
  }

Example docker-compose.yml configuration:
  services:
    workspace:
      volumes:
        - \${WORKSPACE_SOURCE:?}:\${WORKSPACE_TARGET:?}
  
  volumes:
    devcontainer-volume:
      name: \${WORKSPACE_CONTAINER_VOLUME_SOURCE:-not-used-in-bind-mount}
      external: \${WORKSPACE_IS_CONTAINER_VOLUME:?}

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	--container-workspace-folder)
		CONTAINER_WORKSPACE_FOLDER="$2"
		shift 2
		;;
	--local-workspace-folder)
		LOCAL_WORKSPACE_FOLDER="$2"
		shift 2
		;;
	--env-dir)
		ENV_FILE_DIR="$2"
		shift 2
		;;
	--no-write)
		NO_WRITE="true"
		shift
		;;
	--version)
		echo "gen-workspace-env.sh version ${SCRIPT_VERSION}"
		exit 0
		;;
	--help)
		show_help
		exit 0
		;;
	*)
		echo "Error: Unknown option: $1" >&2
		echo "Run with --help for usage information" >&2
		exit 1
		;;
	esac
done

# Validate required arguments
if [[ -z "${CONTAINER_WORKSPACE_FOLDER}" ]]; then
	echo "Error: --container-workspace-folder is required" >&2
	exit 1
fi

if [[ -z "${LOCAL_WORKSPACE_FOLDER}" ]]; then
	echo "Error: --local-workspace-folder is required" >&2
	exit 1
fi

# Get the name of the Docker volume containing the workspace (if applicable)
# Only works when workspace is in a container volume, not a bind mount.
get_workspace_volume_name() {
	local container_id
	container_id="$(hostname 2>/dev/null)" || return 1

	# VS Code runs initializeCommand in a bootstrap container that has the
	# workspace volume mounted at /workspaces. We inspect this container to
	# find the volume name.
	local volume_query
	volume_query='{{- range .HostConfig.Mounts }}{{- if (and (eq .Type "volume") (eq .Target "/workspaces")) }}{{- .Source }}{{- end }}{{- end }}'

	docker container inspect "${container_id}" --format="${volume_query}" 2>/dev/null || echo ""
}

# Determine if we're using a container volume workspace
workspace_is_container_volume() {
	[[ -n "$(get_workspace_volume_name)" ]]
}

# Generate environment variables based on workspace type
if workspace_is_container_volume; then
	# Container Volume Workspace (Codespaces, Clone in Volume)
	# =========================================================
	# In this mode:
	# - LOCAL_WORKSPACE_FOLDER is the workspace path inside the volume (e.g., /workspaces/myproject)
	# - CONTAINER_WORKSPACE_FOLDER is the same path
	# - devcontainer.json workspaceFolder value is ignored

	WORKSPACE_CONTAINER_VOLUME_SOURCE="$(get_workspace_volume_name)" || {
		echo "Error: Failed to determine workspace container volume name" >&2
		exit 1
	}

	WORKSPACE_CONTAINER_VOLUME_TARGET="$(dirname "${LOCAL_WORKSPACE_FOLDER}")"
	WORKSPACE_SOURCE="devcontainer-volume" # Alias defined in docker-compose.yml
	WORKSPACE_TARGET="${WORKSPACE_CONTAINER_VOLUME_TARGET}"
	WORKSPACE_ROOT="${LOCAL_WORKSPACE_FOLDER}"
	WORKSPACE_IS_CONTAINER_VOLUME="true"
	WORKSPACE_IS_BIND_MOUNT="false"
else
	# Bind Mount Workspace (Local Clone)
	# ===================================
	# In this mode:
	# - LOCAL_WORKSPACE_FOLDER is the host filesystem path (e.g., /home/user/projects/myproject)
	# - CONTAINER_WORKSPACE_FOLDER is devcontainer.json workspaceFolder value

	WORKSPACE_BIND_MOUNT_SOURCE="${LOCAL_WORKSPACE_FOLDER}"
	WORKSPACE_BIND_MOUNT_TARGET="${CONTAINER_WORKSPACE_FOLDER}"
	WORKSPACE_SOURCE="${WORKSPACE_BIND_MOUNT_SOURCE}"
	WORKSPACE_TARGET="${WORKSPACE_BIND_MOUNT_TARGET}"
	WORKSPACE_ROOT="${WORKSPACE_BIND_MOUNT_TARGET}"
	WORKSPACE_IS_CONTAINER_VOLUME="false"
	WORKSPACE_IS_BIND_MOUNT="true"
fi

# Generate environment variables output
generate_env_output() {
	cat <<EOF
# Generated by .devcontainer/scripts/gen-workspace-env.sh
# DO NOT EDIT - This file is automatically generated
# Workspace Type: $(${WORKSPACE_IS_CONTAINER_VOLUME} && echo "Container Volume" || echo "Bind Mount")

WORKSPACE_SOURCE=${WORKSPACE_SOURCE}
WORKSPACE_TARGET=${WORKSPACE_TARGET}
WORKSPACE_ROOT=${WORKSPACE_ROOT}
WORKSPACE_IS_CONTAINER_VOLUME=${WORKSPACE_IS_CONTAINER_VOLUME}
WORKSPACE_IS_BIND_MOUNT=${WORKSPACE_IS_BIND_MOUNT}
EOF

	# Add volume-specific variables if applicable
	if [[ "${WORKSPACE_IS_CONTAINER_VOLUME}" == "true" ]]; then
		cat <<EOF
WORKSPACE_CONTAINER_VOLUME_SOURCE=${WORKSPACE_CONTAINER_VOLUME_SOURCE}
WORKSPACE_CONTAINER_VOLUME_TARGET=${WORKSPACE_CONTAINER_VOLUME_TARGET}
EOF
	fi

	# Add bind mount-specific variables if applicable
	if [[ "${WORKSPACE_IS_BIND_MOUNT}" == "true" ]]; then
		cat <<EOF
WORKSPACE_BIND_MOUNT_SOURCE=${WORKSPACE_BIND_MOUNT_SOURCE}
WORKSPACE_BIND_MOUNT_TARGET=${WORKSPACE_BIND_MOUNT_TARGET}
EOF
	fi
}

# Output to stdout
ENV_CONTENT="$(generate_env_output)"
echo "${ENV_CONTENT}"

# Write to .env file if requested
if [[ "${NO_WRITE}" == "false" ]]; then
	mkdir -p "${ENV_FILE_DIR}"
	echo "${ENV_CONTENT}" >"${ENV_FILE_DIR}/.env"
	echo "" >&2
	echo "✓ Generated ${ENV_FILE_DIR}/.env" >&2
fi
