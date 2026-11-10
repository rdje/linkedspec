"""Add the separately retained staged-format proof without changing the map claim."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
owner = 'TYPE-REFERENCE-BOOK.1.2.23.4.18.1'
destination = ROOT / 'docs/claims' / (owner + '.json')
original = destination.read_bytes()
record = json.loads(original)
assert len(record['claims']) == 1, 'one-shot qualification already exists'
archive = HERE / 'implementation-original-claim.json.gz'
assert not archive.exists()
archive.write_bytes(gzip.compress(original, mtime=0))
assert gzip.decompress(archive.read_bytes()) == original
names = ('task_format.py', 'task-format-before.json.gz', 'task-format-after.json.gz',
         'task-format-result.json', 'canonical-first.log.gz',
         'implementation-original-claim.json.gz', 'qualify_task_format.py')
inputs = []
for name in names:
    path = HERE / name
    inputs.append({'path': path.relative_to(ROOT).as_posix(),
                   'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                   'role': 'producer' if name.endswith('.py') else 'input'})
record['claims'].append({
    'name': 'documented-staged-checklist-format-correction',
    'statement': 'The actual staged evidence checker rejects the old checked-line future-work qualification and accepts moving it to the following line; gate bytes, statuses and every other staged task byte remain exact in the captured pair.',
    'scope': 'Two retained actual staged-checker epochs only. This applies the existing documented whole-file checklist-format constraint. First canonical attempt was deliberately terminated143 after its TASK-ACCEPTANCE failure; it earns no complete-CI or receipt credit. No gate-policy, task-status or runtime change.',
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/task_format.py',
                 'granularity': 'Complete captured staged task files, actual gate/instrument sources, staged path lists and actual exit/stdout/stderr; exact single qualification relocation.',
                 'result': (HERE / 'task-format-result.json').read_text().strip()},
    'falsify': {'status': 'checked',
                'hypothesis': 'The older completed checked-line qualification can pass unchanged, or correcting it requires a gate or task-status change.',
                'oracle': 'Unchanged actual staged evidence checker plus independent full captured task-byte comparison against the sole documented relocation.',
                'red_control': 'Real unchanged staged checker exit1 with the governing checklist diagnostic; corrected staged checker exit0 with the complete-evidence diagnostic. All other task/gate/instrument bytes are equal across the pair.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
})
assert record['claims'][0] == json.loads(gzip.decompress(archive.read_bytes()))['claims'][0]
destination.write_text(json.dumps(record, indent=2) + '\n')
