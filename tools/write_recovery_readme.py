#!/usr/bin/env python3
"""Write README.txt for EnvyBoot recovery.zip packages."""

from __future__ import annotations

import argparse
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--board", required=True)
    parser.add_argument("--envyboot", required=True)
    parser.add_argument("--sd-name", required=True)
    parser.add_argument("--sd-version", required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--zip", type=Path, help="Append README.txt to this recovery zip")
    args = parser.parse_args()

    sd = f"{args.sd_name.upper()} {args.sd_version}"
    text = f"""EnvyBoot recovery package
=========================

Board profile:  {args.board}
EnvyBoot:       {args.envyboot}
SoftDevice:     {sd} (included in this package)

What this is
------------
Break-glass factory-style reflash of SoftDevice + EnvyBoot together.
This is an adafruit-nrfutil DFU package, not a UF2 drag-and-drop file.

Normal EnvyBoot upgrades do NOT use this file. Use:
  {args.board}_bootloader-{args.envyboot}.uf2
Double-tap reset, copy that UF2 onto the UF2 drive.

When to use recovery
--------------------
- Blank or heavily erased chip
- Wrong or missing SoftDevice on the device
- Corrupted bootloader (UF2 drive missing, wrong board image flashed)
- You cannot enter UF2 mode and need serial DFU recovery

When NOT to use
---------------
- Routine EnvyBoot version bumps (use the *_bootloader-*.uf2 instead)
- Application / MeshCore / EnvyOS firmware updates (use hex, OTA, or motatool)

Requirements
------------
- adafruit-nrfutil (pip install adafruit-nrfutil)
- USB serial port to the device (CDC ACM), typically /dev/ttyACM0 or COM port
- Device in serial DFU mode (double-reset into UF2/serial when possible, or OTA DFU idle with USB connected)

Apply (serial DFU)
------------------
Replace SERIAL with your port.

  adafruit-nrfutil --verbose dfu serial \\
    --package {args.board}_bootloader-{args.envyboot}.recovery.zip \\
    -p SERIAL -b 115200 --singlebank --touch 1200

This rewrites low flash (SoftDevice) and the bootloader region.
Application firmware is erased or invalidated. Reflash application after recovery.

Verify after flash
------------------
Double-tap reset and open INFO_UF2.TXT on the UF2 drive.
Expect EnvyBoot {args.envyboot} and SoftDevice: {sd}.
"""

    args.out.write_text(text, encoding="utf-8")

    if args.zip:
        import zipfile

        with zipfile.ZipFile(args.zip, "a") as zf:
            zf.write(args.out, arcname="README.txt")


if __name__ == "__main__":
    main()
