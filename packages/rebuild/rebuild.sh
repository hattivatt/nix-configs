#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com:hattivatt/nix-configs.git"
REPO_DIR="${HOME}/.nixos"
NIXOS_REBUILD="$(command -v nixos-rebuild)"

if [ "$#" -gt 1 ]; then
    echo "usage: rebuild [host]" >&2
    exit 1
fi
host="${1:-$(hostname)}"

# 1. Клонируем репо (с сабмодулем), если его нет или он пуст
if [ ! -d "${REPO_DIR}" ] || [ -z "$(ls -A "${REPO_DIR}" 2>/dev/null)" ]; then
    echo "Cloning ${REPO_URL} (with submodules) into ${REPO_DIR} ..."
    mkdir -p "$(dirname "${REPO_DIR}")"
    git clone --recurse-submodules "${REPO_URL}" "${REPO_DIR}"
fi

# 2. Подстраховка: если сабмодуль не инициализирован — подтянуть (no-op, если уже там)
git -C "${REPO_DIR}" submodule update --init --recursive

# 3. Ребилд от рута; sudo внутри скрипта, локальный сабмодуль, без сети
echo "Rebuilding ${host} from ${REPO_DIR} ..."
exec sudo "${NIXOS_REBUILD}" switch --flake "git+file://${REPO_DIR}?submodules=1#${host}"
