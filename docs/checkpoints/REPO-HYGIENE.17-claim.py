"""Publish once, or readonly reconstruct, the dated retained metadata review."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'd432a955ca7a976ccbc3fa047f97bc5e3103ea76'
PREFIX = 'docs/checkpoints/REPO-HYGIENE.17-'
TARGET = ROOT / 'docs/claims/REPO-HYGIENE.17.json'
CALLBACK = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
census = json.loads((ROOT / (PREFIX + 'artifact-review.json')).read_bytes())
actual = json.loads((ROOT / (PREFIX + 'actual-verification.json')).read_bytes())
assert actual['result'] == 'PASS' and len(actual['controls']) == 4
assert actual['producer_sha256'] == sha((ROOT / (PREFIX + 'review-actual.py')).read_bytes())
assert census['owner'] == 'REPO-HYGIENE.17' and census['activation_commit'] == BASE
assert census['artifact_files'] == len(census['rows'])
assert census['artifact_bytes'] == sum(row['bytes'] for row in census['rows'])
assert census['removed_files'] == census['removed_bytes'] == 0
cleanup = (ROOT / 'docs/ARTIFACT_CLEANUP.md').read_text()
assert census['at_utc'] in cleanup and 'REPO-HYGIENE.17' in cleanup
baseline = json.loads((ROOT / (PREFIX + 'review-baseline.json')).read_bytes())
assert baseline['returncode'] == 0 and baseline['unchanged'] and not base64.b64decode(baseline['stderr_base64'], validate=True)
assert base64.b64decode(baseline['stdout_base64'], validate=True) == b'ControlFlow expansion publication PASS: 456 live inputs; 108786 bytes\n'
assert baseline['producer_sha256'] == sha((ROOT / (PREFIX + 'review-baseline.py')).read_bytes())
assert all(sha((ROOT / p).read_bytes()) == digest for p, digest in baseline['inputs'].items())
callback_raw = (ROOT / CALLBACK).read_bytes()
callback = json.loads(callback_raw)
assert len(callback_raw) == 108786 and len(callback['claims'][0]['durability']['inputs']) == 456
assert callback_raw == subprocess.check_output(['git', 'show', BASE + ':' + CALLBACK], cwd=ROOT)
assert all(sha((ROOT / x['path']).read_bytes()) == x['sha256'] for x in callback['claims'][0]['durability']['inputs'])
book = 'docs/linkedspec-book/src/development/documentation-workflow.md'
book_raw = (ROOT / book).read_bytes()
assert book_raw == subprocess.check_output(['git', 'show', BASE + ':' + book], cwd=ROOT)
assert b'A successful review may remove zero files.' in book_raw
assert b'All other Git repositories and submodules are excluded before traversal.' in book_raw
statement = (f"At {census['at_utc']}, the scoped parent metadata census retains "
             f"{census['artifact_files']} candidate rows/{census['artifact_bytes']} bytes. "
             "Three explicit Rust release/incremental/deps log-bin locations are observed separately. "
             "Fresh census, independent per-file OS lstat, aggregate/balanced-size and traversal fixtures pass. "
             "Guarded actual commands/exits/full channels and four reason-sensitive evidence RED controls verify. "
             "Zero files are removed; proof data and reusable caches remain retained. "
             "The actual current branch-expansion readonly456-input/108786-byte baseline passes before the "
             "unrelated new maintenance claim. The entire callback publication and all456 input bindings "
             "remain exact; the fixed accepted claim namespace has zero original live intersections. "
             "Existing Knowledge and public retention teaching stay unchanged.")
paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob('REPO-HYGIENE.17-*') if p.is_file()}
paths.update(('.gitignore', '.gitmodules', 'tools/run_python_project_data.sh', 'tools/project_data_env.sh',
              'tools/project_data_run.sh', book, 'docs/ARTIFACT_CLEANUP.md'))
paths.update(baseline['inputs'])
record = {'version': 1, 'owner': 'REPO-HYGIENE.17', 'claims': [{
    'name': 'dated-retained-artifact-review', 'statement': statement,
    'scope': (
        'Dated per-file metadata only. Size/age does not establish content ownership, disposal safety, '
        'reclaimed space, liveness, recovery/purge or global audit completion. Submodules/nested repositories, '
        'symlinks, other volumes, managed runs, reusable caches and all prior hygiene fixtures are excluded '
        'before traversal. Three explicit Rust paths are separate observations. Fixtures assume a quiescent '
        'filesystem; no adversarial concurrent-mutation guarantee. --live measures changing state; default '
        'review checks retained totals. Standard OS/Python/Git dependencies are reused read-only, and every '
        'project-owned output/fixture stays on the repository volume. No deletion or product/storage/public '
        'mechanism changes. Current book/Knowledge teaching remains accurate and unchanged; no new durable '
        'structural fact is introduced. Capture/freezer and --capture publication are one-shot writers; '
        'review-actual.py/claim.py defaults are readonly. Mutable continuity prose is not a measurement '
        'input. The supplemental preceding readonly baseline is retained at accepted d432a955c with its '
        'complete456-input/108786-byte claim, which retains every producer/artifact input identity rather '
        'than duplicating its list here. All original callback bindings are independently hash-checked. '
        'No new callback/runtime/helper/private/parent/canonical admission is inferred.'),
    'rederive': {
        'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review-actual.py; separately '
                   'claim.py under that wrapper. Defaults readonly; capture.py/freeze.py and --capture '
                   'publication are one-shot writers.',
        'granularity': 'Every dated parent/Rust candidate path, suffix and byte size; guarded actual '
                       'commands/exits/full channels; boundary fixtures; retained instrument/input '
                       'identities and latest date/disposition; fixed accepted claim namespace; actual '
                       'preceding readonly baseline and complete unchanged callback claim/all456 bindings.',
        'result': statement,
    },
    'falsify': {
        'status': 'checked',
        'hypothesis': 'Aggregate totals hide altered per-file sizes, unsafe traversal, failed observations '
                      'or forged producer/channel identities; new maintenance writes silently invalidate '
                      'an existing callback publication.',
        'oracle': 'Independent OS lstat and fresh scoped census, fixed traversal fixtures, exact retained '
                  'commands/source/channel identities and accepted Git claim namespace/current456 bindings.',
        'red_control': 'Aggregate inflation and balanced-size redistribution reject. Start/ancestor '
                       'symlinks, nested repositories, mock submodules and outside-root starts reject. '
                       'Four reason-sensitive actual-channel controls reject incomplete capture, forged '
                       'producer, failed review and forged stdout. The original full callback publication '
                       'and all456 inputs remain exact throughout this dated metadata slice.',
    },
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': p, 'sha256': sha((ROOT / p).read_bytes()),
         'role': 'producer' if p.endswith(('.py', '.sh')) else 'input'} for p in sorted(paths)]},
}]}
serialized = (json.dumps(record, indent=2) + '\n').encode()
assert len(serialized) <= 131072
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'dated retention publication drift'
print(statement)
print('Retention claim readonly identity PASS:', len(paths), 'inputs;', len(serialized), 'bytes')
