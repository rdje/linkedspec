"""Run dependent focused Rust proof steps once, stopping on any actual failure."""
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
assert (BASE / 'after/fresh-exit.txt').read_text() == '0\n'
steps = [
    ('check-after', 'check_after.py', []),
    ('retire-intake', 'retire_intake_copies.py', []),
    ('private-old', 'capture.py', ['private-old', 'private']),
    ('private-fixed', 'capture.py', ['private-fixed', 'private']),
    ('direct', 'capture.py', ['direct', 'direct']),
    ('format', 'capture.py', ['format', 'format']),
    ('seal', 'seal.py', []),
    ('review', 'review.py', []),
    ('current', 'check_current.py', []),
]
for tag, script, arguments in steps:
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / 'run_stage.py'), tag,
        'bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / script), *arguments]
    result = subprocess.run(command, cwd=ROOT)
    assert result.returncode == 0, 'Actual failed step retained; inspect before any qualification:' + tag
print(json.dumps(dict(focused_steps='complete', sdk_replays=False)))
