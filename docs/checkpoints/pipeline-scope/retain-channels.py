"""Retain the finite reached transport-instrument channels before publication."""
import gzip
import json
from pathlib import Path
from common_final import ROOT, PREFIX, sha, encode

target = ROOT / (PREFIX + 'channels.json.gz')
assert not target.exists()
paths = sorted((ROOT / '.linkedspec-data/verification').glob(
    'PERL-PRIVATE-FACTORY-CAPTURE.6-transport-*.log'))
assert paths
rows = {}
for source in paths:
    value = source.read_bytes()
    rows[source.relative_to(ROOT).as_posix()] = dict(base64=encode(value), sha256=sha(value),
                                                  mode=source.stat().st_mode & 0o7777)
record = dict(producer_sha256=sha(Path(__file__).read_bytes()), channels=rows,
              scope='Finite reached instrument channels, including failed replay and observed wrapper '
                    'warnings. This is a snapshot, not a dynamic future log population or a lifecycle '
                    'claim. It executes no proof producer and does not refresh original observations.')
with target.open('xb') as output: output.write(gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0))
print('Retained reached transport instrument channels:', len(rows))
