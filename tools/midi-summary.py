#!/usr/bin/env python3
"""Summarize WinMM text captures or MIDIEWI Lab JSON captures."""
import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path
from statistics import median


def read_events(path):
    content = path.read_text(encoding="utf-8-sig")
    if content.lstrip().startswith("{"):
        for event in json.loads(content)["events"]:
            yield event["ms"], event["bytes"]
    else:
        for line in content.splitlines():
            if not line.strip() or line.startswith("ms_since_start"):
                continue
            ms, *data = line.split()
            yield int(ms), [int(byte, 16) for byte in data]


def summarize(events):
    counts = Counter()
    controls = defaultdict(list)
    velocities = Counter()
    notes = set()
    for ms, data in events:
        if not data or not 0x80 <= data[0] < 0xf0:
            counts["system_or_unknown"] += 1
            continue
        status, channel = data[0] & 0xf0, (data[0] & 15) + 1
        counts[f"channel_{channel}_status_{status:02x}"] += 1
        if len(data) < 3:
            continue
        if status == 0xb0:
            controls[(channel, data[1])].append((ms, data[2]))
        if status in (0x80, 0x90):
            notes.add(data[1])
        if status == 0x90 and data[2]:
            velocities[data[2]] += 1

    controllers = {}
    for (channel, controller), observations in sorted(controls.items()):
        times, values = zip(*observations)
        gaps = [b - a for a, b in zip(times, times[1:])]
        controllers[f"channel_{channel}_cc_{controller}"] = {
            "count": len(values), "min": min(values), "max": max(values),
            "median_host_gap_ms": median(gaps) if gaps else None,
        }
    return {
        "messages": sum(counts.values()), "message_counts": dict(sorted(counts.items())),
        "controllers": controllers, "notes": sorted(notes),
        "note_on_velocities": dict(sorted(velocities.items())),
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("capture", type=Path)
    args = parser.parse_args()
    print(json.dumps(summarize(read_events(args.capture)), indent=2))
