#!/usr/bin/env python3
"""Read exact immutable predecessor narratives, by stable ID or whole source."""
import argparse
import sys
from task_narrative import TREES, archive, nodes, require

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--tree', choices=TREES, required=True)
selection = parser.add_mutually_exclusive_group(required=True)
selection.add_argument('--all', action='store_true')
selection.add_argument('--id')
args = parser.parse_args()
try:
    raw = archive(args.tree)
    if args.id:
        available = nodes(raw)[1]
        require(args.id in available, 'ID absent from this explicit predecessor snapshot')
        raw = available[args.id]
    sys.stdout.buffer.write(raw)
except (ValueError, OSError) as error:
    parser.exit(1, str(error) + '\n')
