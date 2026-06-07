#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

bash -n docker_all_clean.sh
shellcheck docker_all_clean.sh
