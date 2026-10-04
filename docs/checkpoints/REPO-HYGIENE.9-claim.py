"""Check actual retained metadata channels and publish their bounded claim."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.9-'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def decode(value):
    raw = gzip.decompress(base64.b64decode(value['gzip_base64'], validate=True))
    assert len(raw) == value['bytes'] and digest(raw) == value['sha256'], 'actual channel bytes'
    return raw

def check_actual(report):
    assert report['complete'] is True and len(report['runs']) == 2, 'complete actual capture'
    assert report['revision'] == 'abe6756ae638ce68d6219c4794142b02c5450f3e', 'exact clean activation'
    for path, sha in report['inputs'].items():
        assert digest((ROOT / path).read_bytes()) == sha, 'actual producer/input identity'
    for run, name, args, output in zip(report['runs'], ('census.py', 'review.py'), ([], ['--live']),
                                       ('artifact-review.json', 'verification.json')):
        assert run['command'] == ['bash', 'tools/run_python_project_data.sh', PREFIX + name] + args, 'exact actual command'
        assert run['exit'] == 0, 'actual successful exit'
        assert run['inputs_before'] == run['inputs_after'] == report['inputs'], 'actual input guards'
        assert decode(run['stdout']) == (ROOT / (PREFIX + output)).read_bytes(), 'actual stdout publication'
        assert decode(run['stderr']) == b'', 'actual empty stderr'

actual = json.loads((ROOT / (PREFIX + 'actual.json')).read_bytes())
check_actual(actual)
controls = []
for name, change, reason in (
        ('promote incomplete capture', lambda d: d.update(complete=False), 'complete actual capture'),
        ('forge capture producer', lambda d: d['inputs'].update({PREFIX + 'capture.py': '0' * 64}), 'actual producer/input identity'),
        ('promote failed review', lambda d: d['runs'][1].update(exit=1), 'actual successful exit'),
        ('forge census stdout', lambda d: d['runs'][0]['stdout'].update(sha256='0' * 64), 'actual channel bytes')):
    candidate = copy.deepcopy(actual); change(candidate)
    try:
        check_actual(candidate)
    except AssertionError as error:
        assert str(error) == reason, (name, str(error), reason)
        controls.append({'name': name, 'rejected': True, 'reason': reason})
    else:
        raise AssertionError('accepted corruption: ' + name)
(ROOT / (PREFIX + 'actual-verification.json')).write_text(json.dumps({'controls': controls, 'complete': True,
    'instrument_sha256': digest(Path(__file__).read_bytes())}, indent=2) + '\n')

census = json.loads((ROOT / (PREFIX + 'artifact-review.json')).read_bytes())
review = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
book = json.loads((ROOT / (PREFIX + 'book-verification.json')).read_bytes())
freeze = json.loads((ROOT / (PREFIX + 'freeze.json')).read_bytes())
assert census['owner'] == review['owner'] == 'REPO-HYGIENE.9'
assert census['artifact_files'] == review['artifact_files'] == len(census['rows'])
assert census['artifact_bytes'] == review['artifact_bytes'] == sum(row['bytes'] for row in census['rows'])
assert census['removed_files'] == census['removed_bytes'] == review['removed_files'] == review['removed_bytes'] == 0
assert all(review[key] for key in ('live_metadata_checked', 'fresh_metadata_census_matches',
           'per_file_os_metadata_oracle_matches', 'aggregate_inflation_rejected', 'balanced_size_redistribution_rejected'))
assert book['complete'] and book['book_inputs'] == 58 and book['rendered_examples'] == 1
assert book['instrument_sha256'] == digest((ROOT / (PREFIX + 'book.py')).read_bytes())
assert len(book['controls']) == 5 and all(control['rejected'] for control in book['controls'])
assert freeze['bound_inputs'] == 37 and freeze['revision'] == actual['revision']
assert freeze['instrument_sha256'] == digest((ROOT / (PREFIX + 'freeze.py')).read_bytes())
statement = ('At ' + census['at_utc'] + ', the parent metadata census retains ' + str(census['artifact_files']) +
             ' candidates/' + str(census['artifact_bytes']) + ' bytes, excludes ' +
             str(len(census['nested_repositories_excluded'])) + ' nested repositories and inspects three explicit Rust '
             'locations separately. Fresh census and independent per-file lstat agree. Aggregate inflation and balanced '
             'wrong sizes reject, and inclusion/exclusion fixtures pass. Actual census/review exit0 and both full channels '
             'are retained with producer/input guards and four reason-sensitive channel controls. Zero files are removed. '
             'One retained-review example renders from all 58 book inputs with five controls. The prior frame claim '
             'freezes at the exact activation after its original 37 input hashes verify.')
scope = ('Dated metadata snapshot and direct OS metadata check; not content-hash ownership, disposability, resource '
         'reclamation, runtime behavior, process liveness/recovery/purge or global audit closure. Parent traversal excludes '
         'submodules/other repositories before traversal, symlinks, other volumes, managed runs, retained caches and '
         'generated Dart/book/Rust outputs; only Rust release/incremental/deps log-bin metadata is separately inspected. '
         'All artifacts and package/build caches remain retained. The default reviewer checks retained totals and hashes; '
         '--live measures current state and can reject after changing metadata, so it is not a timeless replay claim. '
         'The exact dated rows, submodule exclusions, producers and actual full channels are recoverable. Necessary external '
         'OS/Python standard library/Git/mdBook prerequisites are read-only; render executable SHA identity is separately '
         'observed, with no cross-host identical-output claim. All project-owned scratch/output stays on the repository volume.')
paths = [path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob('REPO-HYGIENE.9-*') if path.is_file()]
paths += ['.gitmodules', 'docs/linkedspec-book/src/development/documentation-workflow.md',
          'tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh']
inputs = [{'path': path, 'sha256': digest((ROOT / path).read_bytes()),
           'role': 'producer' if path.endswith(('.py', '.sh')) else 'input'} for path in sorted(set(paths))]
record = {'version': 1, 'owner': 'REPO-HYGIENE.9', 'claims': [{
    'name': 'dated-retained-artifact-review', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py; bash tools/run_python_project_data.sh ' +
                 PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'freeze.py; bash tools/run_python_project_data.sh ' +
                 PREFIX + 'book.py --review; bash tools/run_python_project_data.sh ' + PREFIX + 'claim.py',
                 'granularity': 'Each dated candidate path/suffix/size and explicit Rust row; full scoped fresh metadata '
                 'comparison and independent lstat, aggregate/balanced-size controls and inclusion/exclusion fixtures; actual '
                 'commands, producers/guards/exits/full channels; all book input bytes/modes and one rendered original example; '
                 '37 original claim/input identities at immutable Git activation. New capture is a new dated observation.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Aggregate counts may conceal incorrect per-file sizes or excluded repository traversal; '
                'unretained or failed actual producers and incomplete publication may falsely support cleanup acceptance.',
                'oracle': 'Independent per-path lstat and fresh scoped census; fixed included/excluded artifact fixture with '
                'nested Git marker and mock submodule; original actual full channels/producer identities/input guards; '
                'complete book capsule and original literal example in actual HTML.',
                'red_control': 'Inflated aggregate count rejects; balanced +1/-1 log sizes keep aggregate totals green but '
                'reject against per-file OS metadata. Scope fixture retains exactly log/bin/Finder metadata and excludes '
                'ordinary files/.git/.agents/mock submodule/nested Git. Four reason-checked corruptions reject incomplete '
                'capture, forged producer, failed actual review and forged census stdout. Five render corruptions reject '
                'failed render, absent guard, forged producer/channel and absent original example.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
target = ROOT / 'docs/claims/REPO-HYGIENE.9.json'
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print('Retained dated census claim; two metadata/four actual-channel/five render controls; zero removals')
