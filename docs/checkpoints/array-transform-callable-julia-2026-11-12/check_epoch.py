"""Compare complete Julia normal records and actual pairs to the frozen cold epoch."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
phase = sys.argv[1]
assert phase in ('before', 'after', 'private-old', 'private-fixed', 'direct')
target = BASE / (phase + '-check.json')
assert not target.exists()
baseline = json.loads((BASE / 'baseline.json').read_bytes())
cold, expected = baseline['observed'], baseline['expected']

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

actual = {}
stdout = gzip.decompress((BASE / phase / 'normal-stdout.log.gz').read_bytes())
for line in stdout.decode().splitlines():
    if line.startswith('CALLABLE_TRANSFORM_JULIA_NORMAL '):
        _, key, body = line.split(' ', 2)
        assert key not in actual
        actual[key] = json.loads(body)
assert len(actual) == 312
old = phase in ('before', 'private-old')
assert encoded(actual) == encoded(cold if old else expected), 'complete available wires'
assert (BASE / phase / 'normal-exit.txt').read_text() == ('1\n' if old else '0\n')

def artifacts(name):
    packet = next(p for p in json.loads((BASE / name / 'custody.json').read_bytes()) if p['tag'] == 'artifacts')
    result = {}
    with tarfile.open(ROOT / packet['archive']) as archive:
        assert set(archive.getnames()) == packet['files'].keys()
        assert len(packet['files']) == 624
        for member in archive:
            assert member.isfile() and member.name not in result
            assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            body = archive.extractfile(member).read(); row = packet['files'][member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            result[member.name] = body
    return result

original, current = artifacts('intake'), artifacts(phase)
for key in actual:
    for folder, suffix in (('parsed', '.json'), ('emitted', '.jl')):
        assert original[str(REL / 'intake' / folder / (key + suffix))] == current[str(REL / phase / folder / (key + suffix))], 'actual parsed/module bytes'
assert len(baseline['initial_policies']) == 104
assert all(encoded(actual[key]) == encoded(cold[key]) for key in baseline['initial_policies'])
assert len(baseline['preserved']) == 281
assert all(encoded(actual[key]) == encoded(cold[key]) for key in baseline['preserved'])
stderr = gzip.decompress((BASE / phase / 'normal-stderr.log.gz').read_bytes())
if old:
    assert b'Some tests did not pass: 1124 passed, 124 failed, 0 errored, 0 broken.' in stderr
if phase == 'before':
    assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'julia/src', 'julia/test/runtests.jl'], cwd=ROOT) == b''
result = dict(phase=phase, full_wire_records='PASS', programs=312, routes=4,
    supported_targets=28, separate_initial_compatibility=3, preserved=281, initial_policies_exact=104,
    actual_parsed_module_pairs_exact=312,
    actual_stderr=dict(bytes=len(stderr), sha256=hashlib.sha256(stderr).hexdigest()),
    scope='Finite authored full-wire/pair comparison. Raw stderr is retained, never stripped; expected old Test failure is separate from any successful-precompile or launcher notices. Full native/cache/transitive4.2/SESSION5 and admission remain open.')
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
