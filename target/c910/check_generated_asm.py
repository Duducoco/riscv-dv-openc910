#!/usr/bin/env python3

import argparse
import re
from pathlib import Path


INSTRUCTIONS = (
    "addsl", "srri", "srriw", "tstnbz", "rev", "ff0", "ff1", "tst", "revw",
    "ext", "extu", "mveqz", "mvnez", "mula", "muls", "mulaw", "mulsw",
    "mulah", "mulsh",
)
INSTR_RE = re.compile(
    rf"^\s+({'|'.join(map(re.escape, INSTRUCTIONS))})\s+", re.MULTILINE
)
EXT_RE = re.compile(r"^\s+extu?\s+\w+,\s*\w+,\s*(\d+),\s*(\d+)\s*$", re.MULTILINE)


def check_assembly(assembly: str) -> dict[str, int]:
    counts = {name: 0 for name in INSTRUCTIONS}
    for mnemonic in INSTR_RE.findall(assembly):
        counts[mnemonic] += 1

    missing = [name for name, count in counts.items() if count == 0]
    if missing:
        raise ValueError(f"missing custom instructions: {', '.join(missing)}")

    for msb_text, lsb_text in EXT_RE.findall(assembly):
        msb = int(msb_text)
        lsb = int(lsb_text)
        if not 0 <= lsb <= msb <= 63:
            raise ValueError(f"invalid ext bit range: msb={msb}, lsb={lsb}")

    return counts


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate a generated C910 assembly test")
    parser.add_argument("assembly", type=Path)
    args = parser.parse_args()

    counts = check_assembly(args.assembly.read_text(encoding="ascii"))
    print(" ".join(f"{name}={count}" for name, count in counts.items()))


if __name__ == "__main__":
    main()
