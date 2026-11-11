"""Read the complete retained baseline; never accept an early test failure as RED."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
phase = BASE / 'before'
assert (phase / 'run-exit.txt').read_text().strip() == '43'
tap = gzip.decompress((phase / 'run-stdout.log.gz').read_bytes()).decode()
assert re.search(r'^1\.\.312$', tap, re.M), 'incomplete TAP reach'
failed = set(re.findall(r'^not ok \d+ - (\w+)', tap, re.M))
roles = json.loads((BASE / 'classification.json').read_bytes())['roles']
assert failed == {key for key, role in roles.items() if role != 'preservation'}
raw = gzip.decompress((phase / 'run-stderr.log.gz').read_bytes()).decode()
rows, inputs = {}, {}
for line in raw.splitlines():
    row = re.fullmatch(r'\s*# CALLABLE_ARRAY_TRANSFORM_RESULT_ROW (\w+) (.*)', line)
    source = re.fullmatch(r'CALLABLE_ARRAY_TRANSFORM_RESULT_INPUT (\w+) (.*)', line)
    if row:
        assert row[1] not in rows
        rows[row[1]] = json.loads(row[2])
    if source:
        assert source[1] not in inputs
        inputs[source[1]] = json.loads(source[2])
assert set(rows) == set(inputs) == set(roles)
for key, row in rows.items():
    for field, source in (('module_input', 'emitted'), ('handler_input', 'handler')):
        artifact = row[field]
        body = inputs[key][source].encode()
        assert gzip.decompress(Path(artifact['path']).read_bytes()) == body
        assert hashlib.sha256(body).hexdigest() == artifact['sha256'] and len(body) == artifact['bytes']
print(json.dumps(dict(result='PASS', complete_groups=len(rows), actual_failed_targets=len(failed), actual_source_pairs=len(inputs)), sort_keys=True))
sample = inputs['take_receiver_hash_guard']['handler']
for line in sample.splitlines():
    if '.take(' in line:
        print('Actual retained Get source:', line.strip()[:240])
        break
