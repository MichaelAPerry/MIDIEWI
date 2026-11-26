#!/usr/bin/env python3
"""Print shareable numeric USB descriptors for an explicitly selected VID:PID."""
import argparse
import json
import re
from pathlib import Path


def decode(raw):
    descriptors = []
    offset = 0
    while offset < len(raw):
        size = raw[offset]
        if size < 2 or offset + size > len(raw):
            raise ValueError(f"invalid descriptor at byte {offset}")
        part = raw[offset:offset + size]
        kind = part[1]
        row = {"type": f"0x{kind:02x}", "length": size}
        if kind == 1 and size >= 18:
            # Omit all string indices, including iSerialNumber.
            row.update(usb_bcd=part[2:4][::-1].hex(), device_class=part[4:7].hex(),
                       vid_pid=f"{part[8:10][::-1].hex()}:{part[10:12][::-1].hex()}",
                       release_bcd=part[12:14][::-1].hex(), configurations=part[17])
        elif kind == 2 and size >= 9:
            row.update(total_length=int.from_bytes(part[2:4], 'little'),
                       interfaces=part[4], configuration=part[5], attributes=part[7])
        elif kind == 4 and size >= 9:
            row.update(interface=part[2], alternate=part[3], endpoints=part[4],
                       class_subclass_protocol=part[5:8].hex())
        elif kind == 5 and size >= 7:
            row.update(address=f"0x{part[2]:02x}", attributes=f"0x{part[3]:02x}",
                       max_packet=int.from_bytes(part[4:6], 'little'), interval=part[6])
        elif kind in (0x24, 0x25) and size >= 3:
            row["subtype"] = f"0x{part[2]:02x}"
        descriptors.append(row)
        offset += size
    return descriptors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("vid_pid")
    args = parser.parse_args()
    if not re.fullmatch(r"[a-fA-F0-9]{4}:[a-fA-F0-9]{4}", args.vid_pid):
        parser.error("expected VID:PID in hexadecimal")
    devices = []
    for device in sorted(Path("/sys/bus/usb/devices").glob("*")):
        try:
            vid = (device / "idVendor").read_text().strip()
            pid = (device / "idProduct").read_text().strip()
        except FileNotFoundError:
            continue
        if f"{vid}:{pid}" == args.vid_pid.lower():
            try:
                devices.append(decode((device / "descriptors").read_bytes()))
            except (OSError, ValueError) as error:
                parser.exit(1, f"Could not decode selected device: {error.strerror if isinstance(error, OSError) else error}\n")
    print(json.dumps(devices, indent=2))
    return 0 if devices else 1


if __name__ == "__main__":
    raise SystemExit(main())
