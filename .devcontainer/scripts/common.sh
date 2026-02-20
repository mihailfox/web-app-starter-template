#!/usr/bin/env bash
# shellcheck disable=SC2148

_log_source_tag() {
	local source_file=""
	local this_file="${BASH_SOURCE[0]}"

	for source_file in "${BASH_SOURCE[@]:1}"; do
		if [[ -n "${source_file}" && "${source_file}" != "${this_file}" ]]; then
			break
		fi
	done

	if [[ -z "${source_file}" || "${source_file}" == "${this_file}" ]]; then
		source_file="${this_file}"
	fi

	source_file="${source_file##*/}"
	source_file="${source_file%.*}"
	printf '%s' "${source_file:-script}"
}

_log_colors_enabled() {
	[[ -z "${NO_COLOR:-}" ]] || return 1

	case "${1:-stdout}" in
	stdout)
		[[ -t 1 ]]
		;;
	stderr)
		[[ -t 2 ]]
		;;
	*)
		return 1
		;;
	esac
}

_log_emit() {
	local severity="$1"
	local stream="$2"
	shift 2
	local message="$*"
	local tag
	tag="[$(_log_source_tag)]"
	local indicator=""
	local color=""
	local reset=""

	case "${severity}" in
	info)
		indicator=""
		;;
	warn)
		indicator="[WARN]"
		color="\033[33m"
		;;
	error)
		indicator="[ERROR]"
		color="\033[31m"
		;;
	*)
		indicator="[${severity^^}]"
		;;
	esac

	if [[ -n "${color}" ]] && _log_colors_enabled "${stream}"; then
		reset="\033[0m"
	else
		color=""
		reset=""
	fi

	local prefix="${tag}${indicator}"
	if [[ -n "${color}" ]]; then
		prefix="${color}${prefix}${reset}"
	fi

	if [[ "${stream}" == "stderr" ]]; then
		printf '%s %s\n' "${prefix}" "${message}" >&2
	else
		printf '%s %s\n' "${prefix}" "${message}"
	fi
}

log() { _log_emit info stdout "$*"; }
warn() { _log_emit warn stderr "$*"; }
err() { _log_emit error stderr "$*"; }

_sudo_exec() {
	if command -v sudo >/dev/null 2>&1; then
		sudo "$@"
		return
	fi

	"$@"
}

ensure_npm_package() {
	local package="${1:-}"
	local version="${2:-}"
	local command_name="${3:-$package}"

	if [[ -z "${package}" ]]; then
		err "ensure_npm_package requires a package name."
		return 1
	fi

	if ! command -v npm >/dev/null 2>&1; then
		err "npm is required to install ${package}."
		return 1
	fi

	if [[ -n "${command_name}" ]] && command -v "${command_name}" >/dev/null 2>&1; then
		log "Command ${command_name} already available; skipping npm install for ${package}."
		return 0
	fi

	local package_spec="${package}"
	if [[ -n "${version}" ]]; then
		package_spec="${package}@${version}"
	fi

	log "Installing npm package ${package_spec} globally..."
	npm install --silent --location=global "${package_spec}" >/dev/null
}

sanitize_devcontainer_json() {
	local file="$1"
	local tmp

	if [[ ! -f "${file}" ]]; then
		err "Cannot sanitize missing file: ${file}"
		return 1
	fi

	tmp="$(mktemp)" || return 1
	if ! sed -E 's/^[[:space:]]*\/\/.*$//' "${file}" >"${tmp}"; then
		rm -f "${tmp}"
		return 1
	fi

	printf '%s\n' "${tmp}"
}
