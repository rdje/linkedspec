"""Run each Lua host's old/current inverse and unchanged direct normals serially."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
assert all(row['full_wire_records'] == 'PASS' for row in json.loads((BASE / 'after-check.json').read_bytes()).values())
OUT = BASE / 'remaining'
OUT.mkdir()
prefix = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P']
for phase in ('inverse', 'restored', 'direct'):
    for tag, program in ((phase, 'capture_epochs.py'), (phase + '-check', 'check_epoch.py')):
        command = prefix + [str(REL / 'run_stage.py'), tag, *prefix, str(REL / program), phase]
        (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
        result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        for channel in ('stdout', 'stderr'):
            (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
        (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
        assert result.returncode == 0, 'Actual failed step retained; do not replay an epoch'
        print(json.dumps(dict(step=tag, actual_exit=result.returncode)), flush=True)
(OUT / 'complete.txt').write_text('Both installed Lua hosts complete inverse/restored/direct3939 and full-record/pair/native-image checks serially.\n')
