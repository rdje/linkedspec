"""Publish once, or readonly reconstruct, the dated retention measurement.

Continuity prose does not produce the metadata measurement and is not bound here.
The actual producers, raw captures, independent reviews, boundary inputs, current
date/disposition and public retention guidance are retained and hash-gated.
"""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.15-'
TARGET = ROOT / 'docs/claims/REPO-HYGIENE.15.json'
assert sys.argv[1:] in ([], ['--capture'])
census = json.loads((ROOT / (PREFIX + 'artifact-review.json')).read_bytes())
actual = json.loads((ROOT / (PREFIX + 'actual-verification.json')).read_bytes())
assert actual['result'] == 'PASS' and len(actual['controls']) == 4
assert actual['producer_sha256'] == hashlib.sha256((ROOT / (PREFIX + 'review-actual.py')).read_bytes()).hexdigest()
assert census['owner'] == 'REPO-HYGIENE.15'
assert census['artifact_files'] == len(census['rows'])
assert census['artifact_bytes'] == sum(row['bytes'] for row in census['rows'])
assert census['removed_files'] == census['removed_bytes'] == 0
cleanup = (ROOT / 'docs/ARTIFACT_CLEANUP.md').read_text()
assert census['at_utc'] in cleanup and 'REPO-HYGIENE.15' in cleanup
statement = (f"At {census['at_utc']}, the scoped parent metadata census retains "
             f"{census['artifact_files']} candidate rows/{census['artifact_bytes']} bytes; "
             "three explicit Rust release/incremental/deps log-bin locations are observed separately. "
             "Fresh census, independent per-file OS lstat, aggregate/balanced-size and traversal fixtures pass. "
             "Source-guarded actual commands/exits/full channels and four reason-sensitive evidence RED controls verify. "
             "Zero files are removed; proof data and reusable caches remain retained.")
paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob('REPO-HYGIENE.15-*') if p.is_file()}
paths.update(['.gitignore', '.gitmodules', 'tools/run_python_project_data.sh', 'tools/project_data_env.sh',
              'tools/project_data_run.sh', 'docs/linkedspec-book/src/development/documentation-workflow.md',
              'docs/ARTIFACT_CLEANUP.md', 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'])
record = {'version': 1, 'owner': 'REPO-HYGIENE.15', 'claims': [{
    'name': 'dated-retained-artifact-review', 'statement': statement,
    'scope': 'Dated per-file metadata only. Candidate size/age does not establish content ownership, disposal safety, reclaimed space, liveness, recovery/purge or global audit completion. Submodules/nested repositories, symlinks, other volumes, managed runs, reusable caches and prior hygiene fixtures are excluded before traversal. Three explicit Rust paths are separate observations. Boundary fixtures assume a quiescent filesystem; no adversarial concurrent-mutation guarantee. --live measures changing state; default review checks retained totals. Standard OS/Python/Git dependencies are read-only; all project-owned outputs/fixtures remain on the repository volume. No deletion or public behavior change; existing public retention teaching remains accurate. Capture/freezer and --capture publication are one-shot writers; review-actual.py/claim.py defaults are readonly. Mutable continuity prose is not a measurement input.',
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review-actual.py; separately claim.py under that wrapper. Defaults readonly; capture.py/freeze.py and --capture publication are one-shot writers.',
                 'granularity': 'Every dated parent/Rust candidate path, suffix and byte size; actual commands/exits/channels/source guards; boundary fixtures, exact retained instrument/input identities and date/disposition.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Aggregate totals hide altered per-file sizes, unsafe traversal, failed observations or forged producer/channel identities.',
                'oracle': 'Independent OS lstat and fresh scoped census, fixed traversal fixtures, exact retained command/source/channel identities.',
                'red_control': 'Aggregate inflation and balanced-size redistribution reject. Start/ancestor symlinks, nested repositories, mock submodules and outside-root starts reject. Four reason-sensitive actual-channel controls reject incomplete capture, forged producer, failed review and forged stdout.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': path, 'sha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest(),
         'role': 'producer' if path.endswith(('.py', '.sh')) else 'input'} for path in sorted(paths)]}
}]}
serialized = (json.dumps(record, indent=2) + '\n').encode()
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot dated claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'dated retention publication drift'
print(statement)
print('Retention claim readonly identity PASS:', len(paths), 'inputs;', len(serialized), 'bytes')
