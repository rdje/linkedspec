"""Retain the actual callback-source mismatch and its exact guarded result."""
from pathlib import Path
import argparse
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('foreign-source-capture.py')
args = argparse.ArgumentParser(); args.add_argument('--mode', choices=('before', 'after'), required=True)
mode = args.parse_args().mode
paths = ['perl/LinkedSpec/ActionIR/ScannerCore.pm', 'perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm',
         'tools/project_data_run.sh', 'tools/project_data_env.sh', str(Path(__file__).relative_to(ROOT)),
         str(Path(PREFIX + 'foreign-source-probe.pl').relative_to(ROOT))]
inputs = {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in paths}
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', paths[-1]]
result = subprocess.run(command, cwd=ROOT, capture_output=True)
def envelope(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest(),
            'gzip_base64': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}
report = {'mode': mode, 'command': command, 'exit': result.returncode, 'inputs': inputs,
          'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr)}
Path(PREFIX + 'foreign-source-' + mode + '.json').write_text(json.dumps(report, indent=2) + '\n')
assert result.returncode == 0 and not result.stderr
assert inputs == {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in paths}
data = json.loads(result.stdout)
assert data['private']['events'] == data['public']
assert len(data['private']['source_origins']) == (1 if mode == 'before' else 0)
if mode == 'before':
    assert data['private']['source_origins'][0]['source'] != data['source']
print(mode + ': actual foreign-source origin ' + ('reproduced' if mode == 'before' else 'declined'))
