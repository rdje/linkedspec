"""Retain read-only reproduction of three stale current Knowledge routes."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('historical-routing.py')
BASE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.'


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw),
            'sha256': hashlib.sha256(raw).hexdigest(),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def main():
    rows = []
    for suffix in ('1.2.1', '2.3', '3.3'):
        path = BASE + suffix + '-review.py'
        command = ['bash', 'tools/run_python_project_data.sh', path]
        result = subprocess.run(command, cwd=ROOT, capture_output=True)
        assert result.returncode == 1, 'historical current-root guards reject'
        assert result.stderr.decode().splitlines()[-1] == 'AssertionError: unchanged current production and tests', 'exact historical source guard'
        rows.append({'producer': path, 'producer_sha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest(),
                     'command': command, 'exit': result.returncode,
                     'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr)})
    report = {'complete': True, 'runs': rows,
              'instrument_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'scope': 'Historical accepted current-root guards reject after the shared fixture evolved; this is not a product regression. Preserve historical bytes/adjudication and route current Knowledge verification to independently reviewed all-producer recurrence.'}
    Path(PREFIX + 'historical-routing.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Three historical current-root routes independently reject at exact source guard; original producers unchanged')


if __name__ == '__main__': main()
