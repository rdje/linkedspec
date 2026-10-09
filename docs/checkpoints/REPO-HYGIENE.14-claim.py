"""Publish the dated retention claim with all retained artifact/producer inputs."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.14-'
census = json.loads((ROOT / (PREFIX + 'artifact-review.json')).read_bytes())
actual = json.loads((ROOT / (PREFIX + 'actual-verification.json')).read_bytes())
assert actual['result'] == 'PASS'
statement = (f"At {census['at_utc']}, the scoped parent metadata census retains "
             f"{census['artifact_files']} candidate rows/{census['artifact_bytes']} bytes; "
             "three explicit Rust release/incremental/deps log-bin locations are observed separately. "
             "Fresh census, independent per-file OS lstat, aggregate/balanced-size and traversal fixtures pass. "
             "Actual source-guarded commands/exits/full channels and four reason-sensitive evidence RED controls verify. "
             "Zero files are removed; proof data and reusable caches remain retained.")
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob('REPO-HYGIENE.14-*') if p.is_file()]
paths += ['.gitignore', '.gitmodules', 'tools/run_python_project_data.sh', 'tools/project_data_env.sh',
          'tools/project_data_run.sh', 'docs/linkedspec-book/src/development/documentation-workflow.md',
          'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md',
          'docs/TASK_TREE.md', 'docs/tasks/REPO-HYGIENE.md', 'docs/ARTIFACT_CLEANUP.md',
          'docs/knowledge/repo-generated-artifact-cleanup-boundary.md']
record = {'version': 1, 'owner': 'REPO-HYGIENE.14', 'claims': [{
    'name': 'dated-retained-artifact-review', 'statement': statement,
    'scope': 'Dated per-file metadata only. Candidate size/age does not establish content ownership, disposal safety, reclaimed space, process liveness, recovery/purge or global audit completion. Submodules/nested repositories, symlinks, other volumes, managed runs and reusable caches are excluded before traversal. Three explicit Rust paths are separate observations. Boundary fixtures assume a quiescent filesystem; no adversarial concurrent-mutation guarantee. --live measures new changing state; default review checks retained totals. Standard OS/Python/Git dependencies are read-only; all project-owned outputs and fixtures remain on the repository volume. No deletion or public behavior change; public retention teaching remains accurate.',
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capture.py; bash tools/run_python_project_data.sh ' + PREFIX + 'review-actual.py',
                 'granularity': 'Each dated candidate/Rust path, suffix and byte size; actual commands/exits/channels/source guards; boundary fixtures and historical claim bindings.',
                 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'Aggregate totals might hide altered per-file sizes, unsafe traversal, failed observations or forged producer/channel identities.',
                'oracle': 'Independent OS lstat and fresh census, fixed traversal fixtures, exact retained command/source/channel identities.',
                'red_control': 'Aggregate inflation and balanced-size redistribution reject. Start/ancestor symlinks, nested repositories, mock submodules and outside-root starts reject. Four actual-channel controls reject incomplete capture, forged producer, failed review and forged stdout with their named reasons.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': p, 'sha256': hashlib.sha256((ROOT / p).read_bytes()).hexdigest(),
         'role': 'producer' if p.endswith(('.py', '.sh')) else 'input'} for p in sorted(set(paths))]}
}]}
(ROOT / 'docs/claims/REPO-HYGIENE.14.json').write_text(json.dumps(record, indent=2) + '\n')
print(statement)
