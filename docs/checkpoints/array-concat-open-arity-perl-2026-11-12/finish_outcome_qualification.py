"""Complete only an assertion-stopped qualification; preserve its original actual1."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import stat
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'outcome_qualification'
assert not (OUT / 'complete.txt').exists()
failed = BASE / 'launches/qualify-outcomes'
assert (failed / 'exit.txt').read_text() == '1\n'
stderr = gzip.decompress((failed / 'stderr.log.gz').read_bytes())
assert b'assert count == 1' in stderr and b'AssertionError' in stderr
FIXTURE = Path('tests/fixtures/array_concat_open_arity_result_guard_perl_cases.json')
NORMAL = Path('t/array_concat_open_arity_result_guard_composition.t')
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
assert not (BASE / 'check_epoch_outcomes_qualified.py').exists()
for path, image in ((FIXTURE, 'fixture-original-v1.json.gz'), (NORMAL, 'normal-original-v1.t.gz'), (OWNER, 'owner-after.pm.gz')):
    assert path.read_bytes() == gzip.decompress((BASE / image).read_bytes())
keys = ['own80_signature_fixed_missing_free_composed', 'own80_signature_rest_missing_free_composed']
original = json.loads(FIXTURE.read_bytes())
qualified_body = gzip.decompress((BASE / 'fixture-qualified-v2.json.gz').read_bytes())
qualified = json.loads(qualified_body)
review = json.loads((BASE / 'after-failure-review.json').read_bytes())
assert len(original) == len(qualified) == 504
for old, new in zip(original, qualified):
    key = old['case']['id']
    assert old['case'] == new['case']
    if key in keys:
        assert new['role'] == 'compatibility-rejected-signature'
        assert new['expected_observation'] == review['terminal_oracles'][key]['derived_projection']
        assert new['expected_observation']['metadata']['language_agnostic_action_ir_ready'] == 0
    else:
        assert old == new
baseline = json.loads((BASE / 'baseline-qualified.json').read_bytes())
assert len(baseline['supported_targets']) == 26 and len(baseline['separate_compatibility']) == 4 and len(baseline['preserved']) == 474
expected = json.loads((BASE / 'epoch-expectations-qualified.json').read_bytes())
for key in keys:
    assert expected['current'][key] == review['terminal_oracles'][key]['derived_projection']
source = (BASE / 'check_epoch_qualified.py').read_text()
replacements = [
    ("assert phase in ('before', 'after', 'inverse', 'restored', 'direct')", "assert phase in ('inverse', 'restored', 'direct')"),
    ('epoch-expectations.json', 'epoch-expectations-qualified.json'),
    ('baseline.json', 'baseline-qualified.json'),
    ('len(failed) == 28', 'len(failed) == 30'),
    ("'28\\n'", "'30\\n'"),
    ('full_preserved_records=476', 'full_preserved_records=474'),
    ('old_failed_groups=28 if old else 0', 'old_failed_groups=30 if old else 0'),
    ('supported_targets=26, separate_compatibility=2', 'supported_targets=26, separate_compatibility=4'),
]
for old, new in replacements:
    assert source.count(old) == 1, old
    source = source.replace(old, new)
compile(source, 'check_epoch_outcomes_qualified.py', 'exec')
paths = [BASE / 'finish_outcome_qualification.py', BASE / 'check_epoch_qualified.py', FIXTURE, NORMAL,
    BASE / 'fixture-qualified-v2.json.gz', BASE / 'normal-qualified-v2.t.gz', BASE / 'baseline-qualified.json',
    BASE / 'epoch-expectations-qualified.json', BASE / 'after-failure-review.json']
rows = {}
with tarfile.open(OUT / 'completion-inputs.tar.gz', 'x:gz') as archive:
    for path in paths:
        raw = path.read_bytes()
        rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'completion-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
with tarfile.open(OUT / 'completion-inputs.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        raw = archive.extractfile(member).read(); row = rows[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(BASE / 'check_epoch_outcomes_qualified.py').write_text(source)
for path, desired in ((FIXTURE, qualified_body), (NORMAL, gzip.decompress((BASE / 'normal-qualified-v2.t.gz').read_bytes()))):
    temporary = path.with_name(path.name + '.concat-qualified')
    assert not temporary.exists()
    mode = stat.S_IMODE(path.stat().st_mode)
    with temporary.open('xb') as stream:
        stream.write(desired)
    temporary.chmod(mode)
    assert temporary.read_bytes() == desired
    os.replace(temporary, path)
    assert path.read_bytes() == desired and stat.S_IMODE(path.stat().st_mode) == mode
assert OWNER.read_bytes() == gzip.decompress((BASE / 'owner-after.pm.gz').read_bytes())
(OUT / 'result.json').write_text(json.dumps(dict(original_after_normal_exit=2, original_after_capture_exit=1,
    original_qualification_exit=1, supported_targets=26, separate_compatibility=4, full_preserved_records=474,
    qualified_rejected_signatures=keys,
    preparation_cause='The original qualification asserted on two overlapping checker replacement keys before mutating the root fixture/normal or writing its checker. Prepared images/expectations were already correct; this separate completion verifies them and changes each distinct token once.',
    scope='Only two rejected requests adopt independently acquired terminal/canonical-two diagnostics and TU; both stay unready/raw0/fallback0/unresolved1. No function/input admission or product-RED credit. Original normal2/capture1/qualification1 and all original source/data remain retained; SDK bytes unchanged. Private/direct normals validate qualified regression data.'), indent=2) + '\n')
(OUT / 'complete.txt').write_text('Exact two-request qualification complete through separate retained completion; SDK source unchanged.\n')
print('Completed qualified26 targets/four compatibility/474 preserved; original qualification1 retained, SDK unchanged')
