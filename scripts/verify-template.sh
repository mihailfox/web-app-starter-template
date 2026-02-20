#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}"

# Forbidden patterns catch common placeholder/customization mistakes
# that downstream users should replace in their projects
forbidden_pattern='CHANGEME|YOUR[-_]PROJECT[-_]NAME|YOUR[-_]ORG[-_]NAME|YOUR[-_]COMPANY|PLACEHOLDER[^"]*:|acme[-_]corp|TODO:?\s*(customize|replace|update)|FIXME:?\s*(template|customize)'
scan_paths=(AGENTS.md .env.example package.json .github/workflows scripts src .devcontainer)

# Run primary pattern check
matches="$(
	rg -n -i "${forbidden_pattern}" "${scan_paths[@]}" \
		--glob '!scripts/verify-template.sh' \
		--glob '!docs/TEMPLATE_MAINTENANCE.md' \
		--glob '!docs/TEMPLATE_CUSTOMIZATION.md' \
		--glob '!README.md' \
		--glob '!src/config/example.ts' \
		--glob '!src/config/example.*.ts' \
		--glob '!.git/**' \
		--glob '!node_modules/**' \
		--glob '!dist/**' \
		--glob '!tmp/**' \
		--glob '!yarn.lock' ||
		true
)"

# Check for example.com but exclude robots.txt, lighthouse workflow, and documentation
example_matches="$(
	rg -n -i 'example\.com' "${scan_paths[@]}" \
		--glob '!scripts/verify-template.sh' \
		--glob '!docs/TEMPLATE_MAINTENANCE.md' \
		--glob '!docs/TEMPLATE_CUSTOMIZATION.md' \
		--glob '!README.md' \
		--glob '!public/robots.txt' \
		--glob '!.github/workflows/lighthouse.yml' \
		--glob '!.git/**' \
		--glob '!node_modules/**' \
		--glob '!dist/**' \
		--glob '!tmp/**' \
		--glob '!yarn.lock' ||
		true
)"

# Combine results
if [[ -n "${example_matches}" ]]; then
	if [[ -n "${matches}" ]]; then
		matches="${matches}"$'\n'"${example_matches}"
	else
		matches="${example_matches}"
	fi
fi

if [[ -n "${matches}" ]]; then
	echo "Template hygiene check failed. Forbidden project-specific strings detected:"
	echo
	echo "Files containing forbidden strings:"
	printf '%s\n' "${matches}" | cut -d: -f1 | sort -u | sed 's/^/  - /'
	echo
	echo "${matches}"
	echo
	echo "These patterns suggest placeholder values that should be customized."
	echo "See docs/TEMPLATE_CUSTOMIZATION.md for guidance."
	exit 1
fi

echo "Template hygiene check passed."
