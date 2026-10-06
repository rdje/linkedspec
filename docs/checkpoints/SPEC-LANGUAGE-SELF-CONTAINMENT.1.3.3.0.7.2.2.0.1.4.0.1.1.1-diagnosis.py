"""Retain the exact JSON-type RED/GREEN causal probe without filtering channels."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('diagnosis.py')


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw),
            'sha256': hashlib.sha256(raw).hexdigest(),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


commands = []
for mode, expected in [('original', 1), ('fixed', 0)]:
    command = ['perl', Path(PREFIX + 'diagnose.pl').relative_to(ROOT).as_posix(), mode]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert result.returncode == expected and result.stderr == b''
    value = json.loads(result.stdout)
    assert value['comparison'] is (mode == 'fixed')
    assert value['before'] == value['actual'] == '{"segment_id":"4966"}'
    assert value['coerced'] == '{"segment_id":4966}'
    commands.append({'command': command, 'exit': result.returncode,
                     'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr)})
Path(PREFIX + 'diagnosis.json').write_text(json.dumps({
    'complete': True, 'commands': commands,
    'instrument_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    'probe_sha256': hashlib.sha256(Path(PREFIX + 'diagnose.pl').read_bytes()).hexdigest(),
}, indent=2) + '\n')
print('Actual numeric-ID comparison RED/string restoration GREEN retained')
