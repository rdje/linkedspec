"""Retain actual probe channels before independently reviewing observations."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-'
BASE = '476bbd1f916edb4c6593bad3c5a8381447c211b6'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs'], cwd=ROOT).decode().split('\0')
paths = [p for p in paths if p and (ROOT / p).is_file()]
paths += [PREFIX + s for s in ('probe.pl', 'cases.json', 'capture.py')]
inputs = {p: digest((ROOT / p).read_bytes()) for p in sorted(set(paths))}
result = subprocess.run(['perl', '-Iperl', PREFIX + 'probe.pl'], cwd=ROOT,
                        env=dict(os.environ, PERL5OPT='', PERL5LIB=''),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
report = {'base': BASE, 'command': ['perl', '-Iperl', PREFIX + 'probe.pl'],
          'inputs': inputs, 'returncode': result.returncode,
          'stdout_base64': base64.b64encode(result.stdout).decode(),
          'stderr_base64': base64.b64encode(result.stderr).decode(),
          'unchanged': all(digest((ROOT / p).read_bytes()) == h for p, h in inputs.items()),
          'production_matches_base': all(digest(subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)) == h
                                         for p, h in inputs.items() if p.startswith(('perl/', 'specs/'))),
          'scope': 'Guarded live parent source superset; standard Perl/core and published dependency outputs reused. No immutable full Phase0 or dependency reproduction claim.'}
(ROOT / (PREFIX + 'actual.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Actual probe exit', result.returncode, '; guarded inputs', len(inputs))
if result.returncode:
    print(result.stderr.decode(errors='replace'))
raise SystemExit(result.returncode)
