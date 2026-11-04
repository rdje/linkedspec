#!/usr/bin/env python3
"""Read exact immutable predecessor narratives, by stable ID or whole source."""
import argparse
import sys
from task_narrative import TREES, archive, epoch_source, nodes, require

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--tree', required=True)
parser.add_argument('--epoch', help='explicit later extraction owner; omit for the original archive')
selection = parser.add_mutually_exclusive_group(required=True)
selection.add_argument('--all', action='store_true')
selection.add_argument('--id')
args = parser.parse_args()
if not args.epoch and args.tree not in TREES:
    parser.error('legacy --tree must be one of ' + ', '.join(TREES))
try:
    if args.epoch:
        row, raw = epoch_source(args.epoch)
        require(row['tree'] == args.tree, 'requested tree differs from epoch source')
    else:
        raw = archive(args.tree)
    if args.id:
        available = nodes(raw)[1]
        require(args.id in available, 'ID absent from this explicit predecessor snapshot')
        raw = available[args.id]
    sys.stdout.buffer.write(raw)
except (ValueError, OSError) as error:
    parser.exit(1, str(error) + '\n')
