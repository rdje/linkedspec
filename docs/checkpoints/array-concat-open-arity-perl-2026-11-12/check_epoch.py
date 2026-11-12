"""Check one actual normal epoch's complete wire/owner/artifact/RED or GREEN proof."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
phase, = sys.argv[1:]
assert phase in ('before', 'after', 'inverse', 'restored', 'direct')
OUT = BASE / phase
target = BASE / (phase + '-check.json')
assert (OUT / 'complete.txt').is_file() and not target.exists()
metadata = json.loads((OUT / 'input-identities.json').read_bytes())
inputs = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == metadata.keys()
    for member in archive:
        path = Path(member.name)
        assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in inputs
        body = archive.extractfile(member).read(); row = metadata[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
        inputs[member.name] = body
records, products, owners = {}, {}, []
stdout = gzip.decompress((OUT / 'normal-stdout.log.gz').read_bytes())
stderr = gzip.decompress((OUT / 'normal-stderr.log.gz').read_bytes())
for line in (stdout + b'\n' + stderr).decode().splitlines():
    line = line.lstrip()
    if line.startswith('# '):
        line = line[2:]
    if line.startswith('ARRAY_CONCAT_NORMAL_OWNER '):
        owners.append(json.loads(line[len('ARRAY_CONCAT_NORMAL_OWNER '):]))
    elif line.startswith(('ARRAY_CONCAT_NORMAL_ROW ', 'ARRAY_CONCAT_NORMAL_INPUT ')):
        prefix, key, raw = line.split(' ', 2)
        chosen = records if prefix == 'ARRAY_CONCAT_NORMAL_ROW' else products
        assert key not in chosen
        chosen[key] = json.loads(raw)
cases = json.loads(inputs[str(BASE / 'cases.json')])
assert set(records) == set(products) == {case['id'] for case in cases} and len(records) == 504
assert len(owners) == 1
owner_path = str(BASE / 'control-owner/MethodLowering.pm') if phase in ('inverse', 'restored') else 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
owner = owners[0]
assert owner['path'] == owner_path and owner['bytes'] == metadata[owner_path]['bytes'] and owner['sha256'] == metadata[owner_path]['sha256']


def normalize(value):
    if isinstance(value, dict):
        return {key: normalize(child) for key, child in value.items()}
    if isinstance(value, list):
        return [normalize(child) for child in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


def project(row):
    return normalize({key: value for key, value in row.items() if key not in ('substitution', 'module_input', 'handler_input')})


old = phase in ('before', 'inverse')
expectations = json.loads(inputs[str(BASE / 'epoch-expectations.json')])['before' if old else 'current']
assert set(expectations) == set(records)
for key in records:
    assert project(records[key]) == expectations[key], (phase, key, 'full record differs')
artifact_count = 0
for case in cases:
    key = case['id']
    assert products[key]['source'] == case['source']
    for field, product in (('module_input', 'emitted'), ('handler_input', 'handler')):
        row, source = records[key][field], products[key][product]
        assert row is not None and isinstance(source, str)
        body = source.encode()
        path = Path(row['path'])
        assert path.parent == OUT and not path.is_absolute() and path.is_file() and not path.is_symlink()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert gzip.decompress(path.read_bytes()) == body
        if phase in ('before', 'inverse', 'restored'):
            original_phase = 'intake' if phase == 'before' else 'before' if phase == 'inverse' else 'after'
            original = BASE / original_phase / path.name
            assert gzip.decompress(original.read_bytes()) == body, (phase, key, field)
        artifact_count += 1
baseline = json.loads(inputs[str(BASE / 'baseline.json')])
for key in baseline['preserved']:
    assert project(records[key]) == project(baseline['observed'][key]), (key, 'preserved full record changed')
failed = re.findall(rb'^not ok \d+ - ([a-z][a-z0-9_]+)\s*$', stdout, re.M)
if old:
    assert {key.decode() for key in failed} == set(baseline['supported_targets'] + baseline['separate_compatibility'])
    assert len(failed) == 28 and (OUT / 'normal-exit.txt').read_text() == '28\n'
else:
    assert not failed and (OUT / 'normal-exit.txt').read_text() == '0\n'
if phase == 'direct':
    assert b'Files=3, Tests=1028' in stdout and b'Result: PASS' in stdout
assert artifact_count == 1008
result = dict(programs=504, full_wire_records='PASS', supported_targets=26, separate_compatibility=2,
    full_preserved_records=476, actual_module_dump_pairs=504, artifact_files=artifact_count,
    loaded_owner=owner, old_failed_groups=28 if old else 0,
    actual_stderr=dict(bytes=len(stderr), sha256=hashlib.sha256(stderr).hexdigest(),
        role='Complete intentional Test::More owner/input/row diagnostics and expected old failures; raw channels retained, not empty SDK stderr.'),
    limits='Finite own normal/overlay proof. Eval serials normalize only in comparisons; raw channels remain. Modules precede fresh eval, native dumps follow internal compilation. Older direct transient strings gain no new custody credit; full4.2/SESSION5 remains open.')
target.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, indent=2, sort_keys=True))
