"""Retain this finite routing repair's completed outer command streams."""
import gzip
import json
from pathlib import Path
import route as r

target = r.ROOT / (r.PREFIX + 'channels.json.gz')
assert not target.exists()
rows = {}
for path in sorted((r.ROOT / '.linkedspec-data/verification').glob(
        'PERL-PRIVATE-FACTORY-CAPTURE.6-knowledge-route-*.log')):
    value = path.read_bytes()
    rows[path.relative_to(r.ROOT).as_posix()] = dict(base64=r.encode(value), sha256=r.sha(value),
                                                 mode=path.stat().st_mode & 0o7777)
record = dict(producer_sha256=r.sha(Path(__file__).read_bytes()), channels=rows,
              scope='Finite completed routing-preparation, generation, review and pressure-check '
                    'streams. The premature review and its missing-dependency failure are retained '
                    'separately from the unchanged successful retry. Later publication and commit '
                    'streams are outside this snapshot; no proof or native writer is rerun.')
with target.open('xb') as output:
    output.write(gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0))
print('Routing command channels retained:', len(rows))
