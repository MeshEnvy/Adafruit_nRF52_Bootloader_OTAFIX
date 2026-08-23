#!/usr/bin/env bash
# EnvyBoot version helpers (standalone or via EnvyOS bench).
set -euo pipefail

BOOTLOADER_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTLOADER_ROOT="${BOOTLOADER_ROOT:-$BOOTLOADER_SRC/build}"
VERSION_FILE="$BOOTLOADER_SRC/envyboot/VERSION"

normalize_version() {
  local v="${1#v}"
  if [[ ! "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "error: invalid version '$1' (want vMAJOR.MINOR.PATCH)" >&2
    return 1
  fi
  printf 'v%s' "$v"
}

read_bootloader_version_file() {
  if [[ -n "${ENVYOS_ROOT:-}" && -f "${ENVYOS_ROOT}/ENVYOS_VERSIONS" ]]; then
    local line k val
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%%#*}"
      line="${line#"${line%%[![:space:]]*}"}"
      [[ -n "$line" ]] || continue
      k="${line%%=*}"
      k="${k%"${k##*[![:space:]]}"}"
      [[ "$k" == bootloader ]] || continue
      val="${line#*=}"
      val="${val#"${val%%[![:space:]]*}"}"
      val="${val%"${val##*[![:space:]]}"}"
      normalize_version "$val"
      return 0
    done <"${ENVYOS_ROOT}/ENVYOS_VERSIONS"
  fi
  [[ -f "$VERSION_FILE" ]] || {
    echo "error: missing $VERSION_FILE and no ENVYOS_ROOT bootloader key" >&2
    return 1
  }
  normalize_version "$(tr -d '[:space:]' <"$VERSION_FILE")"
}
