"""Retain the known outer-wrapper notice without attributing it to Dart."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
raw = gzip.decompress((BASE / 'launches/check-after/stderr.log.gz').read_bytes())
match = re.fullmatch(rb'tools/project_data_run.sh: child setpgid \((\d+) to (\d+)\): Operation not permitted\n', raw)
assert match and match[1] == match[2] and len(raw) == 83
assert (BASE / 'launches/check-after/exit.txt').read_text() == '0\n'
assert json.loads((BASE / 'after-check.json').read_bytes())['repaired'] == 'PASS'
for phase in ('intake', 'after'):
    for channel in ('native-stderr.log.gz', 'fresh-stderr.log.gz'):
        assert gzip.decompress((BASE / phase / channel).read_bytes()) == b''
result = dict(known_notice='retained', layer='outer managed wrapper for the Python after-comparator',
    actual_comparator_exit=0, bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(),
    observed_child_pid=int(match[1]), original_final_pgid='uncaptured',
    raw_channel='launches/check-after/stderr.log.gz', repair_owner='SESSION-STARTUP-READING.7',
    schedule='Existing P1 establishment/denied-liveness repair after feature coverage and before admission',
    scope='All four actual Dart native/fresh stderr channels remain empty. This recurrence establishes neither original group identity nor lifecycle/isolation correctness or timing cause. No suppression, runtime change, recover or purge.')
target = BASE / 'launcher-notice.json'
assert not target.exists()
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
