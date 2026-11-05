"""Readonly review of the frozen finite Count/logical regression phases."""
import gzip
import hashlib
import re
from pathlib import Path

BASE = Path(__file__).parent


def body(path):
    return path.read_bytes() if path.exists() else gzip.decompress(Path(str(path) + '.gz').read_bytes())


for name in ('normal.t', 'cases.json'):
    assert body(BASE / 'before' / name) == body(BASE / 'after' / name), name
for phase in ('before', 'after'):
    for line in (BASE / phase / 'inputs.sha256').read_text().splitlines():
        expected, name = line.split(maxsplit=1)
        assert hashlib.sha256(body(Path(name))).hexdigest() == expected, name
    for number in range(1, 15):
        assert body(BASE / phase / 'emitted' / f'{number}.pl'), 'missing actual module'
baseline = body(BASE / 'before/stdout.tap').decode()
rows = re.findall(r'^(ok|not ok) \d+ - (.+)$', baseline, re.M)
assert len(rows) == 14 and re.search(r'^1\.\.14$', baseline, re.M)
assert [name for state, name in rows if state == 'not ok'] == [
    'rejected_copy_logical', 'rejected_logical', 'rejected_logical_without_with',
    'rejected_not_with', 'copied_wrong_count_logical', 'logical_result_rejected_copy',
    'function_logical_scope']
assert (BASE / 'before/exit.txt').read_text().strip() == '7'
for name, plan in [('after/stdout.tap', 14), ('plain-copy.tap', 3),
                   ('logical-methods.tap', 20), ('logical-fences.tap', 16)]:
    text = body(BASE / name).decode()
    assert not re.search(r'^\s*not ok\b', text, re.M), name
    assert re.search(rf'^1\.\.{plan}\s*$', text, re.M), name
    assert len(re.findall(r'^ok \d+\b', text, re.M)) == plan, name
assert (BASE / 'after/exit.txt').read_text().strip() == '0'
print('PASS: exact14 inputs/normal; baseline7PASS7RED; final14PASS; direct3/20/16; retained phase hashes/modules')
