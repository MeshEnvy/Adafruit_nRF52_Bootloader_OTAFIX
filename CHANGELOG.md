# Changelog

EnvyBoot-owned changes only. On upstream freshen, link the pin (Adafruit base, OTAFIX tag, vk496 ref). Do not copy upstream release notes here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions match `ENVYOS_VERSIONS` `bootloader=` in the ota repo and `./scripts/build-bl.sh` output dirs.

Release pins: `FRESHEN.lock` (`adafruit_base`, `oltaco_tag`, `vk496_ref`, `mota_vk_sha`, `overlay_commits`). Freshen workflow: ota repo `.cursor/skills/envyos-freshen/SKILL.md` § Part B.

## [Unreleased]

## [0.2.0] - 2026-08-14

Shipped with EnvyOS distro [v0.2.0](https://github.com/MeshEnvy/envyos/releases/tag/v0.2.0) (practice release).

### Added

- Hardware WDT feed during mota apply, DFU, and UF2 (`MOTA_BL_FEAT_WDT_FEED` in `g_mota_bl_info`; `src/wdt_feed.h`).
- GPREGRET occupancy notes in `ota_layout.h`.

### Changed

- EnvyBoot semver **0.2.0** (`ENVYBOOT_VERSION_DEFAULT`).

Interim EnvyBoot release (bootloader submodule pin only). **Not bundled in an EnvyOS distro publish** — fleet ships **0.1.2** until a later distro bundles EnvyBoot ≥ 0.2.0.

### Added

- Four-line `INFO_UF2.TXT` lineage (`UF2 Bootloader` / `OTAFIX` / `MOTA` / `EnvyBoot`); firmware `get bootloader.ver` reads EnvyBoot semver.
- Recovery package `<board>_bootloader-<ver>.recovery.zip` with embedded `README.txt` (break-glass BL+SoftDevice serial DFU).
- EnvyBoot-owned [`CHANGELOG.md`](CHANGELOG.md) (upstream pin links only; replaced Adafruit `changelog.md`).

### Changed

- Upstream freshen: Adafruit base **0.9.2** · [OTAFIX 0.9.2-OTAFIX2.3-BP1.3](https://github.com/oltaco/Adafruit_nRF52_Bootloader_OTAFIX/releases/tag/0.9.2-OTAFIX2.3-BP1.3) · vk496 [`feature/ota-delta-apply`](https://github.com/vk496/Adafruit_nRF52_Bootloader_OTAFIX/tree/feature/ota-delta-apply) @ **21c8a9c** (see `FRESHEN.lock`).
- EnvyBoot semver split in Makefile; `FRESHEN.lock` lineage fields.
- Artifact names: `<board>_bootloader-<ver>.uf2` and `<board>_bootloader-<ver>.recovery.zip` (dropped legacy `update-` and `_nosd` suffixes).
- RAK4631 hardware profile `wiscore_rak4631_board` → **`rak4631`** (matches firmware slugs `rak4631-*`).
- WisMesh Tag: triple beep on DFU entry.

## [0.1.2] - 2026-08-03

Shipped with EnvyOS distro [v0.1.2](https://github.com/MeshEnvy/envyos/releases/tag/v0.1.2).

### Added

- Fleet build profile **`sensecap_solar_p1`** (SenseCAP Solar P1-Pro) in `./scripts/build-bl.sh` targets.

### Changed

- EnvyBoot semver **0.1.2** (distro bundle pin).

## [0.1.1] - 2026-08-03

Shipped with EnvyOS distro [v0.1.1](https://github.com/MeshEnvy/envyos/releases/tag/v0.1.1).

### Changed

- Submodule pin refresh with distro v0.1.1 (no EnvyBoot feature delta called out).

## [0.1.0] - 2026-08-03

First fleet EnvyBoot release. Shipped with EnvyOS distro [v0.1.0](https://github.com/MeshEnvy/envyos/releases/tag/v0.1.0).

### Added

- EnvyBoot semver tracking (`ENVYOS_VERSIONS` `bootloader=`).
- Fleet profiles **`wiscore_rak4631_board`** (RAK4631) and **`wismesh_tag`** (WisMesh Tag).
- In-place `.mota` delta apply (vk496 layer on OTAFIX stack).

### Changed

- Upstream stack: Adafruit nRF52 Bootloader **0.9.2** lineage via [oltaco OTAFIX](https://github.com/oltaco/Adafruit_nRF52_Bootloader_OTAFIX) + vk496 in-place apply (see upstream tags; not copied here).
