"""Retain this finite completed metadata diagnostic and focused-check snapshot."""
from pathlib import Path
import common as c

rows = {}
for path in sorted((c.ROOT / '.linkedspec-data/verification').glob('knowledge-fields-*.log')):
    rows[path.relative_to(c.ROOT).as_posix()] = c.read(path.relative_to(c.ROOT).as_posix())
record = dict(producer_sha256=c.sha(Path(__file__).read_bytes()), channels=rows,
              scope='Finite completed diagnostic, correction, source/control/render/documentation '
                    'and focused-check streams before final publication/canonical admission. '
                    'Later streams are outside this snapshot. Existing wrapper warnings remain '
                    'under SESSION-STARTUP-READING.7; no native/capture writer is replayed.')
c.write_new(c.HOME + 'channels.json.gz', record, packed=True)
print('Completed metadata channels retained:', len(rows))
