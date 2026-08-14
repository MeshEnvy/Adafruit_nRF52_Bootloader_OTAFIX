# EnvyBoot

MeshEnvy's nRF52 UF2 bootloader for EnvyOS field nodes: in-place `.mota` apply, BLE/serial DFU, and UF2 drag-and-drop.

**Version:** four lineage lines in `INFO_UF2.TXT` on the UF2 drive (defaults mirror `FRESHEN.lock`; override via `make` vars):

1. `UF2 Bootloader <adafruit_base>` — Adafruit base (currently **0.9.2**)
2. `OTAFIX <otafix_version>` — oltaco OTAFIX pin (currently **2.3-BP1.3**)
3. `MOTA <mota_vk_sha>` — vk496 in-place apply layer (short SHA, currently **21c8a9c**)
4. `EnvyBoot <semver>` — MeshEnvy overlay (**`ENVYOS_VERSIONS` `bootloader=`**, currently **0.1.3**; shipped **0.1.2** in distro **v0.1.2**)

Official builds: `./scripts/build-bl.sh` from repo root. `get bootloader.ver` reads the **EnvyBoot** line.

**Lineage:** forked from [Adafruit nRF52 Bootloader](https://github.com/adafruit/Adafruit-nRF52-Bootloader) 0.9.2 and [oltaco OTAFIX](https://github.com/oltaco/Adafruit_nRF52_Bootloader_OTAFIX). Release pins and MeshEnvy overlay history: **[CHANGELOG.md](CHANGELOG.md)** and `FRESHEN.lock`. Git tags here use EnvyBoot `v0.1.x`, not `0.9.2-OTAFIX*`.

Git remote remains `MeshEnvy/Adafruit_nRF52_Bootloader_OTAFIX` until a repo rename.

---

## Upstream

Do not duplicate upstream release notes in this repo. See:

- [Adafruit nRF52 Bootloader](https://github.com/adafruit/Adafruit-nRF52-Bootloader) (base **0.9.2**)
- [oltaco OTAFIX releases](https://github.com/oltaco/Adafruit_nRF52_Bootloader_OTAFIX/releases)
- vk496 in-place delta apply: [`feature/ota-delta-apply`](https://github.com/vk496/Adafruit_nRF52_Bootloader_OTAFIX/tree/feature/ota-delta-apply)

EnvyBoot freshen pins (which tag + vk496 SHA shipped): **`CHANGELOG.md`** + `FRESHEN.lock`.

---

## Boards supported
- Elecrow ThinkNode M1
- Elecrow ThinkNode M3
- Elecrow ThinkNode M6
- Heltec Automation Mesh Node T114 / HT-nRF5262
- LilyGO T-Echo
- Minewsemi MX25LE01
- Nologo ProMicro NRF52840 (aka SuperMini NRF52840)
- RAK 4631 ([See note](#notes-on-RAK4631-bootloader))
- RAK WisMesh Tag
- Seeed Studio SenseCAP Card Tracker T1000-E
- Seeed SenseCAP Solar Node P1
- Seeed Studio Wio Tracker L1
- Seeed Studio XIAO nRF52840 BLE ([See note](#notes-on-xiao-nrf52840-ble)
- Seeed Studio XIAO nRF52840 BLE SENSE

If there is another nRF52840-based board you would like to see supported please raise a github issue and we can make it happen.

---

## Building from source (Docker)

Recommended on macOS/Linux — avoids installing a local ARM GCC toolchain:

```sh
git submodule update --init --recursive
docker build -t vk-otafix-build .
docker run --rm -v "$PWD":/src -w /src vk-otafix-build make BOARD=wismesh_tag all
```

UF2 output: `_build/build-<board>/<board>_bootloader-<ver>.uf2`  
Swap `BOARD=` for any board under `src/boards/` (e.g. `rak4631`, `wismesh_tag`).

## Installation

**IMPORTANT:** If you are running a MeshCore companion firmware or Ripple firmware on your device **you will need to run an erase after flashing a new bootloader**. Use the MeshCore web flasher to do the erase, it will guide you to the correct erase firmware for your device. Other erase firmwares will not work, they will not erase the ExtraFS area.

The recommended way to install the bootloader is using the UF2 file.  
Download the UF2 file for your board (look for `<board>_bootloader-<ver>.uf2` in releases), enter UF2 mode (usually by double pressing the reset button within 0.5s) and copy the UF2 file across. Or build from source (Docker section above) and copy that UF2.

If you have somehow managed to accidentally flash an incorrect bootloader to your device you will likely require the **recovery package** (`<board>_bootloader-<ver>.recovery.zip`). Unzip is not required: open `README.txt` inside the zip for SoftDevice version, EnvyBoot version, and serial DFU steps. Flash with `adafruit-nrfutil dfu serial` (see README).

---

## Troubleshooting

### Device does not appear as a USB drive or serial port

If the device does not show up on your computer after flashing the bootloader or performing an OTA update, it may be **waiting in OTA DFU mode**.

In **OTAFIX 2.0** and above, OTA DFU is the default state when no valid application is present.  
In this mode:
- No UF2 drive is exposed
- No serial port is available
- The device is waiting for an OTA firmware update over BLE

**What to do:**
- Perform an OTA update using a supported DFU app, **or**
- Explicitly request UF2/serial mode using **double-reset**.

This behaviour is intentional and prevents devices from getting stuck in UF2 mode after failed OTA updates.

---

### OTA update fails with `Error: Operation Failed`

If an OTA update consistently fails early with `Error: Operation Failed`, this is often caused by BLE stack incompatibilities when **Request High MTU** is enabled.

**What to try:**
- Experiment with different PRN settings. Try 12, 8, 1, or even off altogether!
- Disable **Request High MTU** in your DFU app

While high MTU significantly improves performance on supported devices, it is not required for a successful OTA update.

---

## Recommended OTA DFU settings

To perform the OTA update you can use **nRF Device Firmware Update**  
([Android](https://play.google.com/store/apps/details?id=no.nordicsemi.android.dfu&hl=en&gl=US) / [iOS](https://apps.apple.com/sa/app/device-firmware-update/id1624454660))  
or **nRF Connect**  
([Android](https://play.google.com/store/apps/details?id=no.nordicsemi.android.mcp&hl=en&gl=US) / [iOS](https://apps.apple.com/gb/app/nrf-connect-for-mobile/id1054362403)).

My preference is the **nRF Device Firmware Update** app.

For **OTAFIX 2.0**, the following settings are recommended (these may change — feel free to experiment and report your findings):

<table>
<tr>
<td valign="top">

**Packet Receipt Notification (PRN):** ON  
**Number of packets:** 30  
**Reboot time:** 0ms  
**Scan timeout:** 2000ms  
**Request high MTU:** ON for Android (See notes below) / Not available on iOS  
**Disable resume:** ON  
**Prepare object delay:** 0ms  
**Force scanning:** ON  
**Keep bond:** OFF  
**External MCU DFU:** OFF  

**Notes:**
- Some Android devices and BLE stacks do not behave well with **Request high MTU** enabled.  
  If the transfer fails early with `ERROR: Operation Failed`, retry with **Request high MTU turned OFF**.
- For maximum speed, Packet Receipt Notification can be disabled, and the number of packets increased.  
  Android is generally more tolerant of higher values; on iOS and other small-packet hosts, values above ~60 are not recommended.

</td>
</tr>
</table>

[Recommended settings for versions prior to 2.0 can be found here](docs/oldsettings.md).

**IMPORTANT:**  
On <u>older versions</u> of the bootloader, performing an OTA update while the device was connected to a computer USB host would complete successfully but **would not automatically boot into the new application firmware**, requiring a manual reset.  
This issue is fixed in **OTAFIX 2.0**.

---

## OTA update on a MeshCore repeater

First you will need to login to the repeater and issue the `start ota` CLI command.

Next, open the nRF Device Firmware Update app, select the appropriate MeshCore firmware zip file for your device, select your device (it will be advertised as `ProMicro_OTA` / `RAK4631_OTA`, etc), and press start.

---

## Donations

Although it's not necessary, if you find this useful please consider donating to support my work!

[![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/oltaco)

---

## Notes on Xiao NRF52840 BLE

Many of these boards are shipped with the Sense version of the bootloader installed. If your board has the Sense version installed you must use the Sense version when updating via UF2.

You can look at the INFO_UF2.TXT file on the UF2 drive to check what version is currently installed.

To check:
1. Enter UF2 DFU mode (double-press reset) 
2. Open the `INFO_UF2.TXT` file on the mounted drive  

If the file shows: "Board-ID: nRF52840-SeeedXiaoSense-v1" then you must install the ***SENSE*** variant if updating via UF2 file.

## Notes on RAK4631 bootloader

This version of the RAK4631 bootloader is based on a much newer version (0.9.2) of the Adafruit nRF52 bootloader than what RAK Wireless uses on their official bootloader (0.6.2-11).  

I haven't looked to see what changes (if any) that RAK made to the Adafruit bootloader, so I'm not sure if there's any difference but I have tested this bootloader and I haven't found any problems thus far. If you would rather use the original RAK bootloader but with these patches included you can find that [here](https://github.com/oltaco/WisCore_RAK4631_Bootloader/releases).