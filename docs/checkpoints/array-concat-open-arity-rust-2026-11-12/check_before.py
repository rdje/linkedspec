"""Check the unchanged-engine normal against the independently retained intake."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROUTES = ('native', 'restored', 'plan')


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def frames(body, tag):
    rows = {}
    for key, raw in re.findall(r'^' + tag + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in rows
        rows[key] = json.loads(raw)
    return rows


assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
stdout = gzip.decompress((BASE / 'before/normal-stdout.log.gz').read_bytes())
stderr = gzip.decompress((BASE / 'before/normal-stderr.log.gz').read_bytes())
actual = frames(stderr, 'ARRAY_CONCAT_RUST_NORMAL')
expected = {key: {route: row[route] for route in ROUTES} for key, row in assessment['observed'].items()}
assert wire(actual) == wire(expected), 'complete original normal observations'
failed = {key.decode() for key in re.findall(rb'^test (\w+) \.\.\. FAILED$', stdout, re.M)}
assert failed == set(assessment['targets']) | set(assessment['compatibility']), 'exact RED set'
assert b'486 passed; 18 failed' in stdout and (BASE / 'before/normal-exit.txt').read_text() == '101\n'
for tag, directory, field in (
    ('ARRAY_CONCAT_RUST_NORMAL_PARSED_INPUT', 'normal-parsed', 'parsed'),
    ('ARRAY_CONCAT_RUST_NORMAL_INPUT', 'normal-inputs', 'compiled'),
):
    inputs = frames(stderr, tag)
    assert inputs.keys() == actual.keys()
    for key, row in inputs.items():
        assert (BASE / 'before' / directory / (key + '.json')).read_bytes() == row[field].encode()
assert Path('rust/linkedspec-runtime/src/engine.rs').read_bytes() == gzip.decompress((BASE / 'owner-before.rs.gz').read_bytes())
print('Exact unchanged owner:18RED/486PASS; all504 native/restored/plan records and parsed/compiled inputs equal independent intake')
