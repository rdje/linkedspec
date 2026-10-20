"""Same-volume one-shot data for the numeric admission correction."""
import gzip
import json
import sys
from pathlib import Path
sys.path.insert(1, str(Path(__file__).resolve().parents[1] / 'type-numeric-codeblocks'))
import common as c

PREFIX = 'docs/checkpoints/type-numeric-admission/'


def load(name):
    raw = (c.ROOT / (PREFIX + name)).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def write(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()
    if name.endswith('.gz'):
        raw = gzip.compress(raw, mtime=0)
    with (c.ROOT / (PREFIX + name)).open('xb') as output:
        output.write(raw)
