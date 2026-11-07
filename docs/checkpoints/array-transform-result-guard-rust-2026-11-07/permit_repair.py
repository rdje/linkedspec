"""Require actual unchanged195 qualified RED and its explicit include before repair."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
OWNER = 'rust/linkedspec-runtime/src/engine.rs'
OPTIONAL = 'tests/fixtures/array_transform_optional_result_guard_cases.json'
ACTIVATION = 'b0376420ba6258420b146981b848d4646fb3ff55'


def frames(path, prefix):
    rows = {}
    for line in gzip.decompress(path.read_bytes()).decode().splitlines():
        if line.startswith(prefix + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows


native = frames(BASE / 'intake/native-stdout.log.gz', 'ARRAY_TRANSFORM_RUST')
for phase in ('before', 'qualified-before'):
    out = BASE / phase
    assert (out / 'normal-exit.txt').read_text() == '101\n'
    stdout = gzip.decompress((out / 'normal-stdout.log.gz').read_bytes())
    assert b'174 passed; 21 failed; 0 ignored; 0 measured; 0 filtered out' in stdout
    actual = frames(out / 'normal-stderr.log.gz', 'ARRAY_TRANSFORM_RUST_NORMAL')
    assert len(actual) == len(native) == 195 and actual == native
first = json.loads((BASE / 'before/custody.json').read_bytes())[0]['files']
qualified = json.loads((BASE / 'qualified-before/custody.json').read_bytes())[0]['files']
assert OPTIONAL not in first
row = qualified[OPTIONAL]
assert hashlib.sha256(Path(OPTIONAL).read_bytes()).hexdigest() == row['sha256']
assert Path(OPTIONAL).stat().st_mode & 0o777 == row['mode']
assert Path(OWNER).read_bytes() == subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER])
assert hashlib.sha256(Path(OWNER).read_bytes()).hexdigest() == qualified[OWNER]['sha256']
print('actual unchanged195 qualified174PASS/21FAIL, exact intake projections and declared include; production still unchanged')
