#!/usr/bin/env python3
"""Inspect local firmware image metadata without a device or firmware upload."""
import argparse
import json
import struct
import zlib
from pathlib import Path


def inspect(data):
    result = {"size_bytes": len(data)}
    if len(data) < 16 or data[-8:-5] != b"UFD":
        # SAM5000 datasheets describe this little-endian ROM boot marker.
        if data.startswith(b"RD"):
            result["format"] = "Dream ROM boot marker candidate"
        elif data.startswith(b"rd"):
            result["format"] = "Dream DFU application marker candidate"
        else:
            result["format"] = "unrecognized"
        return result

    release, pid, vid, dfu_version, _, suffix_size, crc = struct.unpack(
        "<HHHH3sBI", data[-16:])
    if not 16 <= suffix_size <= len(data):
        raise ValueError("invalid USB DFU suffix length")
    result.update(
        format="USB DFU suffix",
        runtime_vid_pid=f"{vid:04x}:{pid:04x}",
        release_bcd=f"{release:04x}",
        dfu_bcd=f"{dfu_version:04x}",
        crc_valid=crc == (zlib.crc32(data[:-4]) ^ 0xffffffff),
    )
    payload = memoryview(data)[:-suffix_size]
    if payload[-4:] != b"AERD":
        return result
    if len(payload) < 12:
        raise ValueError("truncated Dream trailer")

    payload_size, boot_pid, trailer_size, version = struct.unpack_from("<HHHH", payload, len(payload) - 12)
    if not 12 <= trailer_size <= len(payload):
        raise ValueError("invalid Dream trailer length")
    record_size = payload_size + 12
    record_bytes = len(payload) - trailer_size
    if not payload_size or record_bytes % record_size:
        raise ValueError("Dream transfer records are misaligned")
    result.update(
        format="Dream SAM2DFU container",
        boot_vid_pid=f"{vid:04x}:{boot_pid:04x}",
        transfer_bytes=record_size,
        trailer_bytes=trailer_size,
        trailer_version_word=f"{version:04x}",
        record_count=record_bytes // record_size,
    )
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("image", type=Path)
    args = parser.parse_args()
    try:
        result = inspect(args.image.read_bytes())
    except (OSError, ValueError) as error:
        parser.exit(1, f"{error}\n")
    print(json.dumps(result, indent=2))
    return 0 if result.get("crc_valid", True) else 1


if __name__ == "__main__":
    raise SystemExit(main())
