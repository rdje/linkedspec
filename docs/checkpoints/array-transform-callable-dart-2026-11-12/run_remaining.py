"""Run Dart private old/current and direct647 serially with host headroom."""
import gzip
import json
import os
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
assert json.loads((BASE / 'after-check.json').read_bytes())['repaired'] == 'PASS'
out = BASE / 'remaining'
out.mkdir()
for phase in ('private-old', 'private-fixed', 'direct'):
    assert not (BASE / phase).exists(), 'one-shot epoch already exists'
    memory_command = ['bash', 'tools/project_data_run.sh', 'memory_pressure']
    (out / (phase + '-memory-command.json')).write_text(json.dumps(dict(argv=memory_command, cwd='.'), indent=2) + '\n')
    memory = subprocess.run(memory_command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (out / (phase + '-memory-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(memory, channel), mtime=0))
    (out / (phase + '-memory-exit.txt')).write_text(str(memory.returncode) + '\n')
    assert memory.returncode == 0
    match = re.search(rb'System-wide memory free percentage: (\d+)%', memory.stdout)
    assert match and int(match[1]) >= 30, 'Defer build: conservative4 GB peak plus headroom unavailable on shared24 GB host'
    child = [str(REL / 'capture.py'), phase, 'test'] if phase == 'direct' else [str(REL / 'private_control.py'), phase]
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P',
        str(REL / 'run_stage.py'), phase, 'bash', 'tools/project_data_run.sh', 'env',
        'PYTHONPATH=', 'python3', '-P', *child]
    (out / (phase + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=os.environ.copy(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (out / (phase + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (out / (phase + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, 'Actual failing epoch retained; do not replay'
    print(json.dumps(dict(completed=phase, actual_exit=result.returncode, free_before_percent=int(match[1]))), flush=True)
(out / 'complete.txt').write_text('Actual Dart private old/current and direct647 epochs completed serially.\n')
