"""Require the exact own normal RED, then change only the demonstrated arity guard."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
OWNER = ROOT / 'dart/lib/src/runtime/interpreter.dart'


def frames(body, tag):
    rows = {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in rows
        rows[key] = json.loads(value)
    return rows


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


assert (BASE / 'launches/before/exit.txt').read_text() == '0\n'
assert (BASE / 'before/normal-exit.txt').read_text() == '1\n'
body = gzip.decompress((BASE / 'before/normal-stdout.log.gz').read_bytes())
assert b'+484 -24: Some tests failed.' in body
normal = frames(body, 'ARRAY_CONCAT_DART_NORMAL')
intake = frames(gzip.decompress((BASE / 'intake/native-stdout.log.gz').read_bytes()), 'ARRAY_CONCAT_DART')
assert len(normal) == 508 and wire(normal) == wire(intake)
profiles = json.loads((ROOT / 'tests/fixtures/array_concat_open_arity_result_guard_dart_profiles.json').read_bytes())
differences = {key for key, row in normal.items() if wire(row) != wire({r: profiles[key][r] for r in row})}
assert len(differences) == 24
assert differences == {key for key, row in profiles.items() if row['role'] != 'preservation'}
before = gzip.decompress((BASE / 'owner-before.dart.gz').read_bytes())
assert OWNER.read_bytes() == before
anchor = b"      'concat_arrays' => count == 2,"
assert before.count(anchor) == 1
after = before.replace(anchor, b"      'concat_arrays' => count >= 1,", 1)
assert before != after and len(before.splitlines()) == len(after.splitlines())
(BASE / 'owner-after.dart.gz').write_bytes(gzip.compress(after, mtime=0))
(BASE / 'repair-assessment.json').write_text(json.dumps(dict(programs=508, actual_red=sorted(differences), preserved=484,
    before_sha256=hashlib.sha256(before).hexdigest(), after_sha256=hashlib.sha256(after).hexdigest(),
    change='One result-chain count guard only: concat_arrays count == 2 becomes count >= 1; producer/function/signature/emitter unchanged.'), indent=2, sort_keys=True) + '\n')
OWNER.write_bytes(after)
print('Exact508 own normal observations;24RED/484PASS; applied one existing-arity result guard')
