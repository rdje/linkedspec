"""Qualify two rejected requests using pre-repair terminals/original canonical-two controls."""
import copy
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'outcome_qualification'
OUT.mkdir()
FIXTURE = Path('tests/fixtures/array_concat_open_arity_result_guard_perl_cases.json')
NORMAL = Path('t/array_concat_open_arity_result_guard_composition.t')
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
names = [FIXTURE, NORMAL, OWNER, BASE / 'qualify_outcomes.py', BASE / 'baseline.json',
    BASE / 'epoch-expectations.json', BASE / 'after-failure-review.json', BASE / 'check_epoch_qualified.py',
    BASE / 'owner-after.pm.gz', BASE / 'signature_oracle/result.json']
names += [BASE / 'signature_oracle' / name for name in ('inputs-before-first-run.tar.gz', 'input-identities.json', 'stdout.log.gz', 'stderr.log.gz', 'exit.txt', 'command.json')]
names += [Path('tools/project_data_env.sh'), Path('tools/project_data_run.sh')]
identities = {}
with tarfile.open(OUT / 'inputs-before-qualification.tar.gz', 'x:gz') as archive:
    for path in names:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        identities[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-qualification.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        row = identities[member.name]; raw = archive.extractfile(member).read()
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
review = json.loads((BASE / 'after-failure-review.json').read_bytes())
oracle = json.loads((BASE / 'signature_oracle/result.json').read_bytes())
assert review['original_normal_exit'] == 2 and review['matching_frozen_current_records'] == 502
assert oracle['canonical_two_rejected_signature_oracle'] == 'PASS' and oracle['programs'] == 4
assert oracle['original_loaded_owner']['sha256'] == hashlib.sha256(gzip.decompress((BASE / 'owner-before.pm.gz').read_bytes())).hexdigest()
assert OWNER.read_bytes() == gzip.decompress((BASE / 'owner-after.pm.gz').read_bytes())
keys = ['own80_signature_fixed_missing_free_composed', 'own80_signature_rest_missing_free_composed']
assert review['additional_rejected_signature_changes'] == keys
before = FIXTURE.read_text()
profiles = json.loads(before)
decoder = json.JSONDecoder()
position = before.index('[') + 1
splices = []
while True:
    while before[position].isspace() or before[position] == ',':
        position += 1
    if before[position] == ']':
        break
    row, end = decoder.raw_decode(before, position)
    key = row['case']['id']
    if key in keys:
        assert row['role'] == 'preservation' and row['case']['question'] == 'invalid-signature'
        qualified = copy.deepcopy(row)
        qualified['role'] = 'compatibility-rejected-signature'
        qualified['oracle'] = review['terminal_oracles'][key]['terminal']
        qualified['expected_observation'] = review['terminal_oracles'][key]['derived_projection']
        assert qualified['expected_observation']['metadata']['language_agnostic_action_ir_ready'] == 0
        assert qualified['expected_observation']['native'] == qualified['expected_observation']['fresh'] == [None, 'TU']
        splices.append((position, end, json.dumps(qualified, indent=2).replace('\n', '\n  ')))
    position = end
assert len(splices) == 2
after = before
for start, end, replacement in reversed(splices):
    after = after[:start] + replacement + after[end:]
for original, qualified in zip(profiles, json.loads(after)):
    if original['case']['id'] in keys:
        assert original['case'] == qualified['case']
    else:
        assert original == qualified
normal_before = NORMAL.read_text()
anchor = "    : $profile->{role} eq 'compatibility-result-guard' ? 'disclosed concat result-guard compatibility'\n"
assert normal_before.count(anchor) == 1
normal_after = normal_before.replace(anchor, anchor + "    : $profile->{role} eq 'compatibility-rejected-signature' ? 'rejected signature remains unready; producer oracle retained'\n")
for label, original, qualified in (('fixture', before, after), ('normal', normal_before, normal_after)):
    for version, body in (('original-v1', original), ('qualified-v2', qualified)):
        path = BASE / (label + '-' + version + ('.json.gz' if label == 'fixture' else '.t.gz'))
        assert not path.exists()
        path.write_bytes(gzip.compress(body.encode(), mtime=0))
        assert gzip.decompress(path.read_bytes()) == body.encode()
baseline = json.loads((BASE / 'baseline.json').read_bytes())
assert len(baseline['separate_compatibility']) == 2 and len(baseline['preserved']) == 476
baseline['compatibility_classes'] = dict(non_array_excess_operands=list(baseline['separate_compatibility']), rejected_signatures=keys)
baseline['separate_compatibility'] += keys
baseline['preserved'] = [key for key in baseline['preserved'] if key not in keys]
baseline['rejected_signature_oracles'] = review['terminal_oracles']
assert len(baseline['preserved']) == 474
(BASE / 'baseline-qualified.json').write_text(json.dumps(baseline, indent=2, sort_keys=True) + '\n')
expectations = json.loads((BASE / 'epoch-expectations.json').read_bytes())
for key in keys:
    expectations['current'][key] = review['terminal_oracles'][key]['derived_projection']
(BASE / 'epoch-expectations-qualified.json').write_text(json.dumps(expectations, indent=2, sort_keys=True) + '\n')
checker = (BASE / 'check_epoch_qualified.py').read_text()
replacements = {
    "assert phase in ('before', 'after', 'inverse', 'restored', 'direct')": "assert phase in ('inverse', 'restored', 'direct')",
    "BASE / 'epoch-expectations.json'": "BASE / 'epoch-expectations-qualified.json'",
    "str(BASE / 'epoch-expectations.json')": "str(BASE / 'epoch-expectations-qualified.json')",
    "str(BASE / 'baseline.json')": "str(BASE / 'baseline-qualified.json')",
    "assert len(failed) == 28 and (OUT / 'normal-exit.txt').read_text() == '28\\n'": "assert len(failed) == 30 and (OUT / 'normal-exit.txt').read_text() == '30\\n'",
    'full_preserved_records=476': 'full_preserved_records=474',
    'old_failed_groups=28 if old else 0': 'old_failed_groups=30 if old else 0',
    'supported_targets=26, separate_compatibility=2': 'supported_targets=26, separate_compatibility=4',
}
for old, new in replacements.items():
    count = checker.count(old)
    # Only the bracketed archive-key spelling is present for expectations.
    assert count == 1 or (old == "BASE / 'epoch-expectations.json'" and count == 0)
    if count:
        checker = checker.replace(old, new)
target = BASE / 'check_epoch_outcomes_qualified.py'
assert not target.exists()
target.write_text(checker)
for path, desired in ((FIXTURE, after.encode()), (NORMAL, normal_after.encode())):
    temporary = path.with_name(path.name + '.concat-qualified')
    assert not temporary.exists()
    mode = stat.S_IMODE(path.stat().st_mode)
    with temporary.open('xb') as stream:
        stream.write(desired)
    temporary.chmod(mode)
    assert temporary.read_bytes() == desired
    os.replace(temporary, path)
    assert stat.S_IMODE(path.stat().st_mode) == mode
assert OWNER.read_bytes() == gzip.decompress((BASE / 'owner-after.pm.gz').read_bytes())
(OUT / 'result.json').write_text(json.dumps(dict(original_after_normal_exit=2, original_after_capture_exit=1,
    supported_targets=26, separate_compatibility=4, full_preserved_records=474,
    qualified_rejected_signatures=keys, original_normal_and_fixture='Retained as original-v1 images and original before/after input archives',
    scope='Only two rejected free-composed requests adopt their acquired terminal diagnostics/producer TU, also established by exact-original canonical-two controls. Both stay unready, raw0/fallback0/unresolved1; no function/input admission or product-RED credit. SDK bytes remain unchanged. Original first after2/capture1 remains; no SDK epoch replay. Private current/direct normal executions will validate the qualified regression data.'), indent=2) + '\n')
(OUT / 'complete.txt').write_text('Exact two-request expectation qualification complete; SDK source unchanged.\n')
print('Qualified two rejected-request observations from independent original oracles;26 targets/four compatibility/474 preserved, SDK unchanged')
