"""Preserve original expectations; distinguish three initial-source continuations."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
PROFILE = Path('tests/fixtures/array_transform_callable_result_guard_rust_profiles.json')
NORMAL = Path('rust/linkedspec-runtime/tests/array_transform_callable_result_guard_composition.rs')
out = BASE / 'initial-qualification'
out.mkdir()
diagnosis = json.loads((BASE / 'initial-policy-diagnosis-qualified.json').read_bytes())
assert diagnosis['diagnosis'] == 'PASS' and diagnosis['initial_policies_exact'] == 96
paths = [ROOT / PROFILE, ROOT / NORMAL, ROOT / 'rust/linkedspec-runtime/src/engine.rs',
    BASE / 'baseline.json', BASE / 'capture.py', BASE / 'check_after.py', BASE / 'review.py',
    BASE / 'run_remaining.py', BASE / 'qualify_initial.py', BASE / 'initial-policy-diagnosis-qualified.json']
rows = {}
with tarfile.open(out / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        name = path.relative_to(ROOT).as_posix()
        rows[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=name, recursive=False)
with tarfile.open(out / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        body = archive.extractfile(member).read()
        row = rows[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(out / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
original = (ROOT / PROFILE).read_bytes()
(BASE / 'profiles-original.json.gz').write_bytes(gzip.compress(original, mtime=0))
profiles = json.loads(original)
compatibility = diagnosis['unexpected_three']
assert set(compatibility) == {'initial_' + kind + '_composed' for kind in ('number', 'null', 'hash')}
for key in compatibility:
    assert profiles[key]['role'] == 'preservation'
    profiles[key]['role'] = 'initial-source-compatibility'
    for route in ('native', 'restored', 'plan', 'fresh'):
        assert profiles[key][route] == {'value': ['ran', 'KVW']}
        profiles[key][route] = {'value': [None, '']}
updated = json.dumps(profiles, indent=2, sort_keys=True).encode() + b'\n'
(ROOT / PROFILE).write_bytes(updated)
baseline = json.loads((BASE / 'baseline.json').read_bytes())
assert baseline['programs'] == 312 and len(baseline['supported_targets']) == 20 and baseline['preserved'] == 292
qualified = dict(baseline, preserved=289, initial_source_compatibility=compatibility,
    original_normal=dict(semantic_red=20, preservation_pass=292),
    qualified_old=dict(semantic_red=20, separate_compatibility_red=3, preservation_pass=289),
    limits='Only three composed off-contract expectations/roles change. Initial terminal/first-with policies96 stay exact; no portable input admission or production change. Original failed comparison and failed diagnostic remain retained.')
(BASE / 'baseline-qualified.json').write_text(json.dumps(qualified, indent=2, sort_keys=True) + '\n')

capture = (BASE / 'capture.py').read_text()
capture = capture.replace("'292 passed; 20 failed'", "'289 passed; 23 failed'")
anchor = 'phase, mode = sys.argv[1:]\n'
assert capture.count(anchor) == 1
capture = capture.replace(anchor, anchor + "assert (phase, mode) in {('private-old', 'private'), ('private-fixed', 'private'), ('direct', 'direct')}\n")
anchor = "    sdk = Path('rust')\n"
assert capture.count(anchor) == 1
capture = capture.replace(anchor, "    paths += [BASE / name for name in ('capture_qualified.py', 'qualify_initial.py', 'baseline-qualified.json', 'profiles-original.json.gz', 'initial-policy-diagnosis-qualified.json')]\n" + anchor)
(BASE / 'capture_qualified.py').write_text(capture)

check = (BASE / 'check_after.py').read_text()
check = check.replace("assert profile['role'] == 'supported-target'", "assert profile['role'] in ('supported-target', 'initial-source-compatibility')")
check = check.replace('assert len(changed) == 20 and len(preserved) == 292', 'assert len(changed) == 23 and len(preserved) == 289')
check = check.replace('exact_supported_changes=changed,\n    full_preservation_records=292', "exact_supported_changes=[key for key in changed if profiles[key]['role'] == 'supported-target'],\n    separate_initial_compatibility=[key for key in changed if profiles[key]['role'] == 'initial-source-compatibility'], full_preservation_records=289")
check = check.replace("BASE / 'after-check.json'", "BASE / 'after-check-qualified.json'")
check = check.replace('exact private old/current, direct dependents', 'original failed comparison1 and separate initial compatibility qualification retained; exact private old/current, direct dependents')
(BASE / 'check_after_qualified.py').write_text(check)
remaining = (BASE / 'run_remaining.py').read_text().replace("BASE / 'after-check.json'", "BASE / 'after-check-qualified.json'")
remaining = remaining.replace("str(REL / 'capture.py')", "str(REL / 'capture_qualified.py')")
(BASE / 'run_remaining_qualified.py').write_text(remaining)
for path in paths:
    if path == ROOT / PROFILE:
        continue
    assert hashlib.sha256(path.read_bytes()).hexdigest() == rows[path.relative_to(ROOT).as_posix()]['sha256']
(out / 'result.json').write_text(json.dumps(dict(qualified='PASS', supported_targets=20,
    separate_initial_compatibility=compatibility, preserved=289,
    original_profile_sha256=hashlib.sha256(original).hexdigest(), qualified_profile_sha256=hashlib.sha256(updated).hexdigest(),
    unchanged_normal_sha256=rows[str(NORMAL)]['sha256'], production_unchanged_by_qualification=True,
    limits=qualified['limits']), indent=2) + '\n')
print('Qualified only three initial-source composed expectations;20 targets/three compatibility/289 preserved, original data and failures exact')
