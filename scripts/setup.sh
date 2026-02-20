#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}"

if ! command -v corepack >/dev/null 2>&1; then
  echo "corepack is required (Node 16.10+)."
  exit 1
fi

package_manager_field="$(
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    process.stdout.write(typeof pkg.packageManager === 'string' ? pkg.packageManager : '');
  " 2>/dev/null || true
)"

if [[ -z "${package_manager_field}" || "${package_manager_field}" != yarn@* ]]; then
  echo "package.json must define a Yarn packageManager field (for example: yarn@4.12.0)."
  exit 1
fi

corepack enable >/dev/null 2>&1 || true
corepack prepare "${package_manager_field}" --activate

corepack yarn config set --home enableTelemetry 0
corepack yarn install --immutable

echo "Setup complete. Next steps:"
echo "  yarn dev"
echo "  yarn check"
