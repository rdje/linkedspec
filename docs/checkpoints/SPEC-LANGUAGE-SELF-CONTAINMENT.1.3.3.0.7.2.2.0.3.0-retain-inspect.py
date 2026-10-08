"""Preserve and recur the display helper's packet-schema error before correcting it."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('retain-inspect.py')


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest(),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def main():
    source = Path(PREFIX + 'inspect.py'); original = source.read_bytes()
    target = Path(PREFIX + 'initial-inspect.py'); assert not target.exists(); target.write_bytes(original)
    command = ['bash', 'tools/run_python_project_data.sh', source.relative_to(ROOT).as_posix()]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert result.returncode == 1 and b"KeyError: 'contract_id'" in result.stderr
    report = {'command': command, 'exit': result.returncode, 'stdout': envelope(result.stdout),
              'stderr': envelope(result.stderr), 'source_sha256': hashlib.sha256(original).hexdigest(),
              'scope': 'Actual recurrence of the initial display failure; initial console return remains separate. '
                       'Public capture bytes are untouched. Ordinary scanner packets do not include contract_id.'}
    Path(PREFIX + 'inspect-error.json').write_text(json.dumps(report, indent=2) + '\n')
    old = b"event['event']['contract_id'] == case['contract']"
    new = b"event['event']['raw'] in {span['raw'] for span in case['spans']}"
    assert original.count(old) == 1
    source.write_bytes(original.replace(old, new))
    print('Exact display source/rejection retained; sole schema assumption corrected')


if __name__ == '__main__':
    main()
