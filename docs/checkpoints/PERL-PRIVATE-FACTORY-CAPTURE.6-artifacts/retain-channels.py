"""Retain the reached artifact-transport instrument streams as one finite snapshot."""
import gzip
import json
from pathlib import Path
import artifact as a

target = a.ROOT / (a.HOME + 'channels.json.gz')
assert not target.exists()
rows = {}
for path in sorted((a.ROOT / '.linkedspec-data/verification').glob(
        'PERL-PRIVATE-FACTORY-CAPTURE.6-artifact-*.log')):
    value = path.read_bytes()
    rows[path.relative_to(a.ROOT).as_posix()] = dict(base64=a.encode(value), sha256=a.sha(value),
                                                 mode=path.stat().st_mode & 0o7777)
record = dict(producer_sha256=a.sha(Path(__file__).read_bytes()), channels=rows,
              scope='Finite reached stream snapshot, including known wrapper diagnostics when '
                    'present. Later publication/commit streams are outside this snapshot. This '
                    'retainer does not execute or refresh any proof or native producer.')
with target.open('xb') as output: output.write(gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0))
print('Reached artifact instrument channels retained:', len(rows))
