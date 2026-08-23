#!/usr/bin/env bash
# Build the OTAFIX nRF52 bootloader (MOTA in-place apply) via Docker.
#
# Usage:
#   ./scripts/build-bl.sh [version] [--targets-file <path>] [--list-boards]
#   ./scripts/build-bl.sh [version] BOARD [BOARD…]
#
# version defaults to ENVYOS_VERSIONS bootloader or envyboot/VERSION.
# With no BOARD args, otafix profiles are inferred from envycore/scripts/targets.txt.
#
# Output: build/<version>/

set -euo pipefail

BL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOOTLOADER_ROOT="${BOOTLOADER_ROOT:-$BL_ROOT/build}"
MESHENVY_ROOT="$(cd "$BL_ROOT/.." && pwd)"
ENVYCORE_ROOT="${ENVYCORE_ROOT:-$MESHENVY_ROOT/envycore}"
TARGETS_FILE="${TARGETS_FILE:-$ENVYCORE_ROOT/scripts/targets.txt}"
IMAGE="vk-otafix-build"

# shellcheck source=scripts/version.sh
source "$BL_ROOT/scripts/version.sh"
# shellcheck source=scripts/targets-lib.sh
source "$BL_ROOT/scripts/targets-lib.sh"

if [[ -n "${ENVYOS_ROOT:-}" && -f "${ENVYOS_ROOT}/scripts/version.sh" ]]; then
  # shellcheck source=/dev/null
  source "${ENVYOS_ROOT}/scripts/version.sh"
fi

usage() {
  cat >&2 <<EOF
usage: $0 [version] [--targets-file <path>] [--list-boards]
       $0 [version] BOARD [BOARD…]

  version         Optional override; default is ENVYOS_VERSIONS bootloader
  (no BOARD args) Build otafix bootloaders for base boards in targets file
  BOARD…          Build explicit otafix board name(s) instead
  --list-boards   Print inferred otafix boards from targets file and exit
  --targets-file  Target map (default: envycore/scripts/targets.txt)
EOF
  exit 2
}

LIST_BOARDS=0
POSITIONAL=()

while (($# > 0)); do
  case "$1" in
    --targets-file)
      [[ $# -ge 2 ]] || usage
      TARGETS_FILE=$2
      shift 2
      ;;
    --list-boards)
      LIST_BOARDS=1
      shift
      ;;
    -h | --help)
      usage
      ;;
    --*)
      echo "error: unknown option: $1" >&2
      usage
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if ((LIST_BOARDS == 1)); then
  otafix_boards_from_targets_file "$TARGETS_FILE"
  exit 0
fi

VER=""
EXPLICIT_BOARDS=()
if ((${#POSITIONAL[@]} > 0)); then
  if VER="$(normalize_version "${POSITIONAL[0]}" 2>/dev/null)"; then
    EXPLICIT_BOARDS=("${POSITIONAL[@]:1}")
  else
    EXPLICIT_BOARDS=("${POSITIONAL[@]}")
  fi
fi

if [[ -z "$VER" ]]; then
  VER="$(read_bootloader_version_file)" || usage
fi

OUT="$BOOTLOADER_ROOT/$VER"
if declare -F assert_component_tree_not_released >/dev/null 2>&1; then
  assert_component_tree_not_released bootloader "$VER"
fi

BOARDS=()
if ((${#EXPLICIT_BOARDS[@]} > 0)); then
  BOARDS=("${EXPLICIT_BOARDS[@]}")
else
  while IFS= read -r board; do
    [[ -n "$board" ]] && BOARDS+=("$board")
  done < <(otafix_boards_from_targets_file "$TARGETS_FILE")
fi

ensure_otafix_ready() {
  (
    cd "$BL_ROOT"
    if [[ ! -f lib/nrfx/nrfx.h ]] || [[ ! -f lib/tinyusb/src/tusb.h ]] || [[ ! -f lib/uf2/utils/uf2conv.py ]]; then
      echo "    git submodule update --init --recursive"
      git submodule update --init --recursive
    fi
    if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
      echo "    docker build -t $IMAGE ."
      docker build -t "$IMAGE" .
    fi
  )
}

build_board() {
  local board=$1
  local git_version="${VER#v}"
  echo "==> bootloader $VER  BOARD=$board"

  (
    cd "$BL_ROOT"
    echo "    docker run … make BOARD=$board GIT_VERSION=$git_version all"
    docker run --rm -v "$PWD":/src -w /src "$IMAGE" make "BOARD=$board" "GIT_VERSION=$git_version" all
  )

  local build_dir="$BL_ROOT/_build/build-$board"
  local uf2
  uf2="$(ls -1 "$build_dir"/update-*_nosd.uf2 2>/dev/null | head -1 || true)"
  [[ -n "$uf2" && -f "$uf2" ]] || { echo "error: no update-*_nosd.uf2 in $build_dir" >&2; exit 1; }

  mkdir -p "$OUT"
  cp -f "$uf2" "$OUT/"
  local zip
  zip="$(ls -1 "$build_dir"/*_s140_*.zip 2>/dev/null | head -1 || true)"
  [[ -n "$zip" && -f "$zip" ]] && cp -f "$zip" "$OUT/"

  echo "    UF2: $uf2"
  echo "    copy: $OUT/$(basename "$uf2")"
}

if ((${#EXPLICIT_BOARDS[@]} > 0)); then
  echo "==> otafix boards: ${BOARDS[*]} (explicit)"
else
  echo "==> otafix boards: ${BOARDS[*]} (from $TARGETS_FILE)"
fi

rm -rf "$OUT"
mkdir -p "$OUT"
printf '%s\n' "$VER" >"$OUT/version.txt"

ensure_otafix_ready

for board in "${BOARDS[@]}"; do
  build_board "$board"
done

echo "==> done $VER"
ls -la "$OUT"
