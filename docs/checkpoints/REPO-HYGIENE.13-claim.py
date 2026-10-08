"""Verify retained actual channels and publish only the dated metadata claim."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.13-'
BASE = '60e8ef2ab571bab5d951e0d6f701daf1752df36e'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def decode(value):
    raw = gzip.decompress(base64.b64decode(value['gzip_base64'], validate=True))
    assert len(raw) == value['bytes'] and digest(raw) == value['sha256'], 'channel identity'
    return raw

def verify_actual(record):
    assert record['complete'] and record['revision'] == BASE and len(record['runs']) == 2, 'complete actual capture'
    for path, sha in record['inputs'].items():
        assert digest((ROOT / path).read_bytes()) == sha, 'producer identity'
    for run, source, args, output in zip(record['runs'], ('census.py', 'review.py'),
                                         ([], ['--live']), ('artifact-review.json', 'verification.json')):
        assert run['command'] == ['bash', 'tools/run_python_project_data.sh', PREFIX + source] + args, 'actual command'
        assert run['exit'] == 0, 'actual exit'
        assert run['inputs_before'] == run['inputs_after'] == record['inputs'], 'source guards'
        assert decode(run['stdout']) == (ROOT / (PREFIX + output)).read_bytes(), 'published stdout'
        assert decode(run['stderr']) == b'', 'actual stderr'

actual = json.loads((ROOT / (PREFIX + 'actual.json')).read_bytes())
verify_actual(actual)
controls = []
for name, change, reason in (
    ('incomplete capture', lambda d: d.update(complete=False), 'complete actual capture'),
    ('forged producer', lambda d: d['inputs'].update({PREFIX + 'capture.py': '0' * 64}), 'producer identity'),
    ('failed review', lambda d: d['runs'][1].update(exit=1), 'actual exit'),
    ('forged stdout', lambda d: d['runs'][0]['stdout'].update(sha256='0' * 64), 'channel identity')):
    candidate = copy.deepcopy(actual)
    change(candidate)
    try:
        verify_actual(candidate)
    except AssertionError as error:
        assert str(error) == reason, (name, str(error))
        controls.append({'name': name, 'rejected': True, 'reason': reason})
    else:
        raise AssertionError('accepted corruption: ' + name)

census = json.loads((ROOT / (PREFIX + 'artifact-review.json')).read_bytes())
review = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
assert census['owner'] == review['owner'] == 'REPO-HYGIENE.13'
assert census['at_utc'] == review['at_utc'] and census['activation_commit'] == BASE
assert census['artifact_files'] == review['artifact_files'] == len(census['rows'])
assert census['artifact_bytes'] == review['artifact_bytes'] == sum(row['bytes'] for row in census['rows'])
assert census['removed_files'] == census['removed_bytes'] == review['removed_files'] == review['removed_bytes'] == 0
assert all(review[key] for key in ('live_metadata_checked', 'fresh_metadata_census_matches',
    'per_file_os_metadata_oracle_matches', 'aggregate_inflation_rejected',
    'balanced_size_redistribution_rejected', 'start_symlink_rejected',
    'ancestor_symlink_rejected', 'start_nested_repository_rejected',
    'start_submodule_rejected', 'outside_root_rejected'))

freeze = json.loads((ROOT / (PREFIX + 'freeze.json')).read_bytes())
assert freeze['revision'] == BASE
assert freeze['producer_sha256'] == digest((ROOT / (PREFIX + 'freeze.py')).read_bytes())
for entry in freeze['records']:
    original = (ROOT / entry['before']).read_bytes()
    assert digest(original) == entry['original_sha256']
    expected = json.loads(original)
    bindings = 0
    for claim in expected['claims']:
        durability = claim['durability']
        if durability.get('mode') != 'live':
            continue
        # This slice's one intersecting live record binds the changed continuity.
        for item in durability['inputs']:
            raw = subprocess.check_output(['git', 'show', BASE + ':' + item['path']], cwd=ROOT)
            assert digest(raw) == item['sha256'], item['path']
            bindings += 1
        durability.update(mode='historical', revision=BASE)
    assert bindings == entry['verified_bindings']
    current = (ROOT / entry['path']).read_bytes()
    assert json.loads(current) == expected and digest(current) == entry['after_sha256']

error = json.loads((ROOT / (PREFIX + 'freeze-initial-error.json')).read_bytes())
assert error['producer_sha256'] == digest((ROOT / (PREFIX + 'freeze-initial.py')).read_bytes())
assert error['exit'] == 1 and b"KeyError: 'mode'" in base64.b64decode(error['stderr_base64'], validate=True)
failure_inputs = json.loads((ROOT / (PREFIX + 'freeze-initial-inputs.json')).read_bytes())
assert failure_inputs['revision'] == BASE
loaded = failure_inputs['loaded_original_claims']
assert [entry['path'] for entry in loaded] == failure_inputs['ordered_git_claim_paths'][:len(loaded)]
assert loaded[-1]['path'] == failure_inputs['first_missing_mode_record']
for entry in loaded:
    raw = base64.b64decode(entry['base64'], validate=True)
    assert digest(raw) == entry['sha256']
    assert raw == subprocess.check_output(['git', 'show', BASE + ':' + entry['path']], cwd=ROOT)
assert any('mode' not in claim['durability'] for claim in json.loads(raw)['claims'])
publication = json.loads((ROOT / (PREFIX + 'publication-verification.json')).read_bytes())
assert publication['complete'] and publication['revision'] == BASE and publication['original_preamble_red_retained']
assert publication['producer_sha256'] == digest((ROOT / (PREFIX + 'publication-review.py')).read_bytes())
for entry in publication['results']:
    assert entry['preamble_and_prior_records_exact']
    assert digest((ROOT / entry['path']).read_bytes()) == entry['current_sha256']
verification = {'complete': True, 'controls': controls,
    'instrument_sha256': digest(Path(__file__).read_bytes()),
    'original_freeze_preparation_failure_retained': True,
    'public_book': 'Unchanged retention guidance and immutable example reviewed; no public behavior change.'}
(ROOT / (PREFIX + 'actual-verification.json')).write_text(json.dumps(verification, indent=2) + '\n')

statement = ('At ' + census['at_utc'] + ', the scoped parent census records ' + str(census['artifact_files']) +
    ' artifact candidates/' + str(census['artifact_bytes']) + ' bytes, with three explicit Rust locations '
    'observed separately. Fresh census and independent per-file lstat agree; aggregate/balanced-size controls '
    'and traversal fixtures pass. Actual source-guarded producers, exits and both full channels are retained, '
    'with four effective evidence RED controls. Zero files are removed; original intersecting claim hashes '
    'are preserved at the exact clean activation. The initial legacy-mode preparation failure remains retained.')
scope = ('Dated metadata, not content ownership, disposal safety, reclaimed space, current process liveness, '
    'recovery/purge or global audit closure. No deletion is attempted. Traversal excludes submodules/nested '
    'repositories, symlinks, foreign volumes, caches and managed runs; start-path guards are fixture-verified '
    'under a quiescent filesystem, not an adversarial concurrent-mutation guarantee. Retained review checks '
    'snapshot totals; --live measures a new changing state. Julia/Dart reusable caches and Lua native outputs '
    'remain retained under existing repository-local conventions. External OS/Python/Git prerequisites are '
    'read-only; all project-owned output and fixtures stay on the repository volume. Public retention guidance '
    'is unchanged, so no render is required. Earlier dated snapshots remain immutable.')
paths = [path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob('REPO-HYGIENE.13-*') if path.is_file()]
paths += ['.gitignore', '.gitmodules', 'tools/run_python_project_data.sh',
          'tools/project_data_env.sh', 'tools/project_data_run.sh',
          'docs/linkedspec-book/src/development/documentation-workflow.md',
          'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md',
          'docs/TASK_TREE.md', 'docs/tasks/REPO-HYGIENE.md', 'docs/ARTIFACT_CLEANUP.md',
          'docs/knowledge/repo-generated-artifact-cleanup-boundary.md']
inputs = [{'path': path, 'sha256': digest((ROOT / path).read_bytes()),
           'role': 'producer' if path.endswith(('.py', '.sh')) else 'input'} for path in sorted(set(paths))]
record = {'version': 1, 'owner': 'REPO-HYGIENE.13', 'claims': [{
    'name': 'dated-retained-artifact-review', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py; '
        'bash tools/run_python_project_data.sh ' + PREFIX + 'freeze.py; bash tools/run_python_project_data.sh ' + PREFIX + 'claim.py',
        'granularity': 'Every dated path/suffix/size and Rust row, actual full channels/source guards, fixture exclusions and original claim hashes.',
        'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'Totals can hide wrong per-file sizes, boundary traversal or failed/unbound observations.',
        'oracle': 'Independent OS lstat, fresh scoped census, fixed boundary fixtures and guarded actual channel identities.',
        'red_control': 'Aggregate inflation and balanced size redistribution reject; start/ancestor symlink, nested repository, mock submodule and outside-root starts reject. Four reason-sensitive evidence mutations reject incomplete capture, forged producer, failed review and forged stdout.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
target = ROOT / 'docs/claims/REPO-HYGIENE.13.json'
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print(statement)
