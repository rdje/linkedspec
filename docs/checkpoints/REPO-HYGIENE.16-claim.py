"""Publish once, or readonly reconstruct, the dated retention measurement.

Continuity prose does not produce the metadata measurement and is not bound here.
The actual producers, raw captures, independent reviews, boundary inputs, current
date/disposition and public retention guidance are retained and hash-gated.
"""
import hashlib
import json
import sys
import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.16-'
TARGET = ROOT / 'docs/claims/REPO-HYGIENE.16.json'
assert sys.argv[1:] in ([], ['--capture'])
census = json.loads((ROOT / (PREFIX + 'artifact-review.json')).read_bytes())
actual = json.loads((ROOT / (PREFIX + 'actual-verification.json')).read_bytes())
assert actual['result'] == 'PASS' and len(actual['controls']) == 4
assert actual['producer_sha256'] == hashlib.sha256((ROOT / (PREFIX + 'review-actual.py')).read_bytes()).hexdigest()
assert census['owner'] == 'REPO-HYGIENE.16'
assert census['artifact_files'] == len(census['rows'])
assert census['artifact_bytes'] == sum(row['bytes'] for row in census['rows'])
assert census['removed_files'] == census['removed_bytes'] == 0
cleanup = (ROOT / 'docs/ARTIFACT_CLEANUP.md').read_text()
assert census['at_utc'] in cleanup and 'REPO-HYGIENE.16' in cleanup
baseline = json.loads((ROOT / (PREFIX + 'review-baseline.json')).read_bytes())
assert baseline['returncode'] == 0 and baseline['unchanged'] and not base64.b64decode(baseline['stderr_base64'], validate=True)
assert b'Small optional-kind publication PASS: 366 live inputs; 85779 bytes' in base64.b64decode(baseline['stdout_base64'], validate=True)
assert baseline['producer_sha256'] == hashlib.sha256((ROOT / (PREFIX + 'review-baseline.py')).read_bytes()).hexdigest()
assert all(hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest for path, digest in baseline['inputs'].items())
statement = (f"At {census['at_utc']}, the scoped parent metadata census retains "
             f"{census['artifact_files']} candidate rows/{census['artifact_bytes']} bytes; "
             "three explicit Rust release/incremental/deps log-bin locations are observed separately. "
             "Fresh census, independent per-file OS lstat, aggregate/balanced-size and traversal fixtures pass. "
             "Source-guarded actual commands/exits/full channels and four reason-sensitive evidence RED controls verify. "
             "Zero files are removed; proof data and reusable caches remain retained. "
             "The actual preceding optional-kind readonly366-input/85779-byte publication baseline passes before the unrelated new maintenance claim.")
paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob('REPO-HYGIENE.16-*') if p.is_file()}
paths.update(['.gitignore', '.gitmodules', 'tools/run_python_project_data.sh', 'tools/project_data_env.sh',
              'tools/project_data_run.sh', 'docs/linkedspec-book/src/development/documentation-workflow.md',
              'docs/ARTIFACT_CLEANUP.md', 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'])
paths.update(baseline['inputs'])
paths.add('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-review.py')
record = {'version': 1, 'owner': 'REPO-HYGIENE.16', 'claims': [{
    'name': 'dated-retained-artifact-review', 'statement': statement,
    'scope': 'Dated per-file metadata only. Candidate size/age does not establish content ownership, disposal safety, reclaimed space, liveness, recovery/purge or global audit completion. Submodules/nested repositories, symlinks, other volumes, managed runs, reusable caches and prior hygiene fixtures are excluded before traversal. Three explicit Rust paths are separate observations. Boundary fixtures assume a quiescent filesystem; no adversarial concurrent-mutation guarantee. --live measures changing state; default review checks retained totals. Standard OS/Python/Git dependencies are read-only; all project-owned outputs/fixtures remain on the repository volume. No deletion or public behavior change; existing public retention teaching remains accurate. Capture/freezer and --capture publication are one-shot writers; review-actual.py/claim.py defaults are readonly. Mutable continuity prose is not a measurement input. Supplemental preceding readonly baseline is retained at accepted fc96936fb with its full366-input/85779-byte claim and actual producers; that complete claim retains the original artifact input identities rather than duplicating its list here. The source-established current-namespace/fixed-baseline review defect is owned by .3.2.1.10, whose first complete new-claim rejection and repair follow this clean maintenance commit. No product regression or completed proof-routing repair is claimed here.',
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review-actual.py; separately claim.py under that wrapper. Defaults readonly; capture.py/freeze.py and --capture publication are one-shot writers.',
                 'granularity': 'Every dated parent/Rust candidate path, suffix and byte size; actual commands/exits/channels/source guards; boundary fixtures, exact retained instrument/input identities and date/disposition, plus the actual preceding readonly publication baseline and its full accepted claim input record.',
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
