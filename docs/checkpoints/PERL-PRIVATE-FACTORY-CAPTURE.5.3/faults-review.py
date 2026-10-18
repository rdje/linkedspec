"""Read the original fault loop, including its unobserved copied-return case."""
import base64
import gzip
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3/'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
raw = (ROOT / (PREFIX + 'faults-reached.json.gz')).read_bytes()
rows = json.loads(gzip.decompress(raw))
assert len(rows) == 16
for index, row in enumerate(rows):
    assert row['unchanged'] and row['channels'][0]['returncode'] == 0
    assert sha(base64.b64decode(row['module_base64'], validate=True)) == row['module_sha256']
    text = base64.b64decode(row['channels'][1]['stdout_base64'], validate=True).decode()
    assertions = re.findall(r'^(not )?ok (\d+) - (.*)$', text, re.M)
    assert re.findall(r'^1\.\.(\d+)$', text, re.M) == ['1641']
    assert [int(n) for _, n, _ in assertions] == list(range(1, 1642))
    failures = [{'number': int(n), 'name': name} for bad, n, name in assertions if bad]
    assert failures == row['failures']
    assert bool(failures) == bool(row['channels'][1]['returncode']) == (index < 15)
assert rows[-1]['name'] == 'copied-normalizer-array-return'
report = {
    'result': 'PASS-with-disclosed-limit',
    'producer_sha256': sha(Path(__file__).read_bytes()),
    'original_producer_sha256': sha((ROOT / (PREFIX + 'faults.py')).read_bytes()),
    'positive_capsule_sha256': sha((ROOT / (PREFIX + 'after-inputs.json.gz')).read_bytes()),
    'data_sha256': sha(raw),
    'variants': [{'name': row['name'], 'assertions': 1641,
                  'failures': len(row['failures']), 'module_sha256': row['module_sha256']}
                 for row in rows],
    'effective': 15,
    'unobserved': ['copied-normalizer-array-return'],
    'limit': 'The original one-shot loop stops at its final effectiveness assertion. '
             'Every original variant and complete channel remains in faults-reached.json.gz. '
             'This unchanged fixture has no witness for copying the returned array container. '
             'No sixteen-effective-fault or exhaustive reference-identity claim is made. '
             'The production helper is unchanged; only six validator returns differ.',
}
target = ROOT / (PREFIX + 'faults-review.json')
value = (json.dumps(report, indent=2) + '\n').encode()
if sys.argv[1:]:
    with target.open('xb') as output:
        output.write(value)
else:
    assert target.read_bytes() == value
print('Switch faults reviewed: 15 effective; 1 copied-return case without an observed witness')
