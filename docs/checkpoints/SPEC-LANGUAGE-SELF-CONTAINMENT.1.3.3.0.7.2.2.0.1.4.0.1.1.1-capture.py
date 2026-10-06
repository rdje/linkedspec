"""Retain complete, unfiltered public-regression channels and producer guards."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
BASE = '224d5443af794d4e5ade6e80bd8f09145ee7b5b3'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


epoch = sys.argv[1]
assert epoch in ('before', 'after')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
paths = ['tools/test_document_history_rollover.py', 'tools/roll_document_history.pl',
         'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
before = {p: sha((ROOT / p).read_bytes()) for p in paths}
result_path = Path(PREFIX + epoch + '.json').relative_to(ROOT).as_posix()
command = ['bash', 'tools/run_python_project_data.sh', 'tools/test_document_history_rollover.py']
if epoch == 'before':
    command.append('--original')
command += ['--report', result_path]
result = subprocess.run(command, cwd=ROOT, capture_output=True)
after = {p: sha((ROOT / p).read_bytes()) for p in paths}
report = {'complete': True, 'epoch': epoch, 'base': BASE, 'command': command,
          'exit': result.returncode, 'stdout': envelope(result.stdout),
          'stderr': envelope(result.stderr), 'inputs_before': before, 'inputs_after': after,
          'instrument_sha256': sha(Path(__file__).read_bytes()),
          'result_sha256': sha((ROOT / result_path).read_bytes())}
Path(PREFIX + epoch + '-command.json').write_text(json.dumps(report, indent=2) + '\n')
assert before == after, 'actual immutable producer guards'
assert result.stderr == b'', 'unfiltered outer diagnostics must be empty'
assert result.returncode == (1 if epoch == 'before' else 0), 'expected actual regression exit'
print(epoch + ' complete public-regression capture accepted')
