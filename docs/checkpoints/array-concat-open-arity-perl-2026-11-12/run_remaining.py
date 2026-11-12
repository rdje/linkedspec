"""Run own inverse/restored/direct epochs serially after qualified record recovery."""
import gzip
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'remaining'
OUT.mkdir()
assert json.loads((BASE / 'after-qualified-review.json').read_bytes())['retained_record_recovery'] == 'PASS'
assert (BASE / 'outcome_qualification/complete.txt').is_file()
for phase in ('inverse', 'restored', 'direct'):
    for tag, script, argument in ((phase, 'capture_epoch.py', phase), (phase + '-check', 'check_epoch_outcomes_qualified.py', phase)):
        argv = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'run_stage.py'),
            tag, 'bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / script), argument]
        (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
        result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        for channel in ('stdout', 'stderr'):
            (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
        (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
        assert result.returncode == 0 and result.stderr == b'', 'Original child/outer failure retained; do not replay'
        print(tag + ': actual0/complete channels retained', flush=True)
(OUT / 'complete.txt').write_text('Inverse/restored/direct focused epochs and full qualified wire/owner/artifact checks complete.\n')
