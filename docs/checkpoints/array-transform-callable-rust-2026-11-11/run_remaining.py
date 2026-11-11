"""Run frozen private-old/current and direct proofs serially with RAM headroom."""
import gzip
import json
import os
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
assert json.loads((BASE / 'after-check.json').read_bytes())['repaired_public'] == 'PASS'
out = BASE / 'remaining'
out.mkdir()
for phase, mode in (('private-old', 'private'), ('private-fixed', 'private'), ('direct', 'direct')):
    assert not (BASE / phase).exists(), 'one-shot epoch already exists'
    memory_command = ['bash', 'tools/project_data_run.sh', 'memory_pressure']
    (out / (phase + '-memory-command.json')).write_text(json.dumps(dict(argv=memory_command, cwd='.'), indent=2) + '\n')
    memory = subprocess.run(memory_command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (out / (phase + '-memory-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(memory, channel), mtime=0))
    (out / (phase + '-memory-exit.txt')).write_text(str(memory.returncode) + '\n')
    assert memory.returncode == 0
    match = re.search(rb'System-wide memory free percentage: (\d+)%', memory.stdout)
    assert match and int(match[1]) >= 30, 'Defer this build: conservative 4 GB expected peak plus headroom is unavailable on the shared24 GB host'
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P',
        str(REL / 'run_stage.py'), phase, 'bash', 'tools/project_data_run.sh', 'env',
        'PYTHONPATH=', 'python3', '-P', str(REL / 'capture.py'), phase, mode]
    (out / (phase + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=os.environ.copy(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (out / (phase + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (out / (phase + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, 'Actual failing epoch retained; do not replay over it'
    print(json.dumps(dict(completed=phase, actual_exit=result.returncode, free_before_percent=int(match[1]))), flush=True)
(out / 'complete.txt').write_text('Actual private old/current and direct epochs completed serially.\n')
