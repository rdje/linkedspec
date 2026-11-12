"""Retain independent current identity/full-wire review of original after2; no SDK replay."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'after'
target = BASE / 'after-failure-review.json'
assert not target.exists() and (OUT / 'normal-exit.txt').read_text() == '2\n'
assert (BASE / 'launches/after/exit.txt').read_text() == '1\n'
metadata = json.loads((OUT / 'input-identities.json').read_bytes())
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == metadata.keys()
    for member in archive:
        row = metadata[member.name]; body = archive.extractfile(member).read()
        assert member.isfile() and len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
        path = Path(member.name)
        assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
        assert path.read_bytes() == body and path.stat().st_mode & 0o777 == row['mode']
stdout = gzip.decompress((OUT / 'normal-stdout.log.gz').read_bytes())
stderr = gzip.decompress((OUT / 'normal-stderr.log.gz').read_bytes())
rows, products, owners = {}, {}, []
for line in (stdout + b'\n' + stderr).decode().splitlines():
    line = line.lstrip()
    if line.startswith('# '):
        line = line[2:]
    if line.startswith('ARRAY_CONCAT_NORMAL_OWNER '):
        owners.append(json.loads(line[len('ARRAY_CONCAT_NORMAL_OWNER '):]))
    elif line.startswith(('ARRAY_CONCAT_NORMAL_ROW ', 'ARRAY_CONCAT_NORMAL_INPUT ')):
        prefix, key, raw = line.split(' ', 2)
        chosen = rows if prefix == 'ARRAY_CONCAT_NORMAL_ROW' else products
        assert key not in chosen
        chosen[key] = json.loads(raw)
cases = json.loads((BASE / 'cases.json').read_bytes())
assert set(rows) == set(products) == {case['id'] for case in cases} and len(rows) == 504
assert len(owners) == 1
owner = owners[0]; owner_path = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
assert Path(owner['path']).resolve() == ROOT / owner_path
assert owner['sha256'] == metadata[owner_path]['sha256'] and owner['bytes'] == metadata[owner_path]['bytes']


def normalized(value):
    if isinstance(value, dict):
        return {key: normalized(child) for key, child in value.items()}
    if isinstance(value, list):
        return [normalized(child) for child in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


def projection(row):
    return normalized({key: value for key, value in row.items() if key not in ('substitution', 'module_input', 'handler_input')})


expected = json.loads((BASE / 'epoch-expectations.json').read_bytes())['current']
cold = json.loads((BASE / 'baseline.json').read_bytes())['observed']
changed = []
for case in cases:
    key = case['id']
    assert products[key]['source'] == case['source']
    for field, product in (('module_input', 'emitted'), ('handler_input', 'handler')):
        row = rows[key][field]; body = products[key][product].encode()
        assert Path(row['path']).parent == OUT
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert gzip.decompress(Path(row['path']).read_bytes()) == body
    if projection(rows[key]) != expected[key]:
        changed.append(key)
wanted = ['own80_signature_fixed_missing_free_composed', 'own80_signature_rest_missing_free_composed']
assert changed == wanted
assert {key.decode() for key in re.findall(rb'^not ok \d+ - ([a-z][a-z0-9_]+)\s*$', stdout, re.M)} == set(wanted)
oracles = {}
for key in wanted:
    terminal = key.removesuffix('_composed') + '_terminal'
    oracle = projection(cold[terminal])
    assert oracle['metadata']['language_agnostic_action_ir_ready'] == 0
    assert oracle['metadata']['raw_perl_dependency_count'] == oracle['metadata']['canonical_action_ir_fallback_count'] == 0
    assert oracle['metadata']['unresolved_helper_count'] == 1
    assert oracle['metadata']['unresolved_helpers'] == (['pair'] if 'fixed' in key else ['keep'])
    assert oracle['native'] == oracle['fresh'] == [['tail', 'end'], 'TU']
    oracle.update(native=[None, 'TU'], fresh=[None, 'TU'])
    assert projection(rows[key]) == oracle
    oracles[key] = dict(terminal=terminal, derived_projection=oracle)
target.write_text(json.dumps(dict(original_normal_exit=2, original_capture_exit=1, actual_records=504,
    matching_frozen_current_records=502, additional_rejected_signature_changes=wanted, terminal_oracles=oracles,
    actual_module_dump_pairs=504, current_post_run_input_identities='PASS',
    scope='Companion review after original capture stopped at its GREEN assertion. Original producer did not reach its post-run verification; this current companion checks exact archive/current inputs and all504 products/records. No original PASS receipt, SDK replay, source rewrite or malformed-signature admission is inferred.'), indent=2, sort_keys=True) + '\n')
print('Original after2 retained:502 frozen current records exact; two rejected requests match acquired terminal diagnostics, all504 products/current inputs verified')
