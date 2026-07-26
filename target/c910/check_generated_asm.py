#!/usr/bin/env python3

import argparse
import re
from pathlib import Path


SCALAR_INSTRUCTIONS = (
    "addsl", "srri", "srriw", "tstnbz", "rev", "ff0", "ff1", "tst", "revw",
    "ext", "extu", "mveqz", "mvnez", "mula", "muls", "mulaw", "mulsw",
    "mulah", "mulsh",
)
MEMORY_INSTRUCTIONS = (
    "lrb", "lrbu", "lrh", "lrhu", "lrw", "lrwu", "lrd",
    "srb", "srh", "srw", "srd",
    "lurb", "lurbu", "lurh", "lurhu", "lurw", "lurwu", "lurd",
    "surb", "surh", "surw", "surd",
    "lwd", "ldd", "lwud", "swd", "sdd",
    "lbia", "lbib", "lbuia", "lbuib", "lhia", "lhib", "lhuia", "lhuib",
    "lwia", "lwib", "lwuia", "lwuib", "ldia", "ldib",
    "sbia", "sbib", "shia", "shib", "swia", "swib", "sdia", "sdib",
    "flrw", "flrd", "flurw", "flurd", "fsrw", "fsrd", "fsurw", "fsurd",
)
CACHE_SYNC_INSTRUCTIONS = (
    "dcache.iall", "dcache.call", "dcache.ciall",
    "dcache.isw", "dcache.csw", "dcache.cisw",
    "dcache.iva", "dcache.cva", "dcache.cval1", "dcache.civa",
    "dcache.ipa", "dcache.cpa", "dcache.cpal1", "dcache.cipa",
    "icache.iall", "icache.ialls", "icache.iva", "icache.ipa",
    "l2cache.iall", "l2cache.call", "l2cache.ciall",
    "sync", "sync.i", "sync.s", "sync.is",
)
INSTRUCTIONS = SCALAR_INSTRUCTIONS + MEMORY_INSTRUCTIONS + CACHE_SYNC_INSTRUCTIONS
INSTR_RE = re.compile(
    rf"^[ \t]+({'|'.join(map(re.escape, INSTRUCTIONS))})(?=[ \t]|$)", re.MULTILINE
)
EXT_RE = re.compile(r"^\s+extu?\s+\w+,\s*\w+,\s*(\d+),\s*(\d+)\s*$", re.MULTILINE)


def check_assembly(
    assembly: str, expected: tuple[str, ...] = INSTRUCTIONS
) -> dict[str, int]:
    counts = {name: 0 for name in expected}
    for mnemonic in INSTR_RE.findall(assembly):
        if mnemonic in counts:
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
    parser.add_argument(
        "--group",
        choices=("all", "scalar", "memory", "cache-sync"),
        default="all",
    )
    args = parser.parse_args()

    expected = {
        "all": INSTRUCTIONS,
        "scalar": SCALAR_INSTRUCTIONS,
        "memory": MEMORY_INSTRUCTIONS,
        "cache-sync": CACHE_SYNC_INSTRUCTIONS,
    }[args.group]
    counts = check_assembly(args.assembly.read_text(encoding="ascii"), expected)
    print(" ".join(f"{name}={count}" for name, count in counts.items()))


if __name__ == "__main__":
    main()
