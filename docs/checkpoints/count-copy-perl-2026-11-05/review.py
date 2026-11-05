"""Readonly finite phase/TAP/input review; no historical acquisition replay."""
import gzip
import hashlib
import json
import re
from pathlib import Path

BASE = Path(__file__).parent


def body(path):
    if path.exists():
        return path.read_bytes()
    return gzip.decompress(Path(str(path) + '.gz').read_bytes())


before = json.loads(body(BASE / 'before/cases.json'))
after = json.loads(body(BASE / 'after/cases.json'))
assert before[:15] == after[:15], 'original assessment inputs changed'
assert body(BASE / 'before/normal.t') == body(BASE / 'after/normal.t'), 'normal changed'
# Review the frozen phase, not future production bytes from later repair leaves.
for phase in ('before', 'after'):
    for line in (BASE / phase / 'inputs.sha256').read_text().splitlines():
        expected, name = line.split(maxsplit=1)
        assert hashlib.sha256(body(Path(name))).hexdigest() == expected, name
    for module in range(1, 16 if phase == 'before' else 20):
        assert body(BASE / phase / 'emitted' / f'{module}.pl'), 'missing actual module'

baseline = body(BASE / 'before/stdout.tap').decode()
baseline_rows = re.findall(r'^(ok|not ok) \d+ - (.+)$', baseline, re.M)
assert len(baseline_rows) == 15 and (BASE / 'before/exit.txt').read_text().strip() == '143'
assert [name for state, name in baseline_rows if state == 'not ok'] == [
    'rejection_through_copy', 'repeated_count_after_copy']
for name, plan in [('after/stdout.tap', 19), ('source-fences.tap', 18),
                   ('count-length.tap', 5), ('index-copy.tap', 2)]:
    text = body(BASE / name).decode()
    assert not re.search(r'^\s*not ok\b', text, re.M), name
    assert re.search(rf'^1\.\.{plan}\s*$', text, re.M), name
    assert len(re.findall(r'^ok \d+\b', text, re.M)) == plan, name
assert (BASE / 'after/exit.txt').read_text().strip() == '0'
print('PASS: original15 inputs and normal exact; baseline13PASS2RED/interrupted16-19; final19PASS; direct18/5/2; retained phase hashes/modules')
