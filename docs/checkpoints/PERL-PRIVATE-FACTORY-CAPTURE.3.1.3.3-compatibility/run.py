"""Retain complete channels for supplemental standard live-worktree checks.

This is not the supplied, input-bound runtime capsule. Its full transitive input
population is not reconstructed here; private/canonical admission remains with
the existing parent owners. Default execution verifies retained artifact shape;
--capture is the one-shot actual public compatibility run.
"""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TARGET = Path(__file__).with_name('result.json')
assert sys.argv[1:] in ([], ['--capture'])
commands = [['perl', '-c', 'perl/LinkedSpec.pm'],
            ['perl', '-c', '-Iperl', 't/phase0_regression.t'],
            ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def pack(raw):
    return base64.b64encode(gzip.compress(raw, mtime=0)).decode()


if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot compatibility result already exists'
    rows = []
    environment = dict(os.environ, PERL5LIB='')
    for command in commands:
        result = subprocess.run(command, cwd=ROOT, env=environment,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        rows.append({'command': command, 'returncode': result.returncode,
                     'stdout_gzip_base64': pack(result.stdout), 'stderr_gzip_base64': pack(result.stderr)})
        if result.returncode:
            break
    report = {'producer_sha256': digest(Path(__file__).read_bytes()), 'rows': rows,
              'scope': 'Actual standard syntax and public Phase0 in the live repository. Complete channels retained. Supplemental compatibility only: no full transitive input capsule, runtime benchmark, output-volume comparison or private/canonical admission.'}
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(TARGET.read_bytes())
assert report['producer_sha256'] == digest(Path(__file__).read_bytes())
assert [r['command'] for r in report['rows']] == commands
assert all(r['returncode'] == 0 for r in report['rows'])
for row in report['rows'][:2]:
    assert b'syntax OK' in gzip.decompress(base64.b64decode(row['stderr_gzip_base64'], validate=True))
stdout = gzip.decompress(base64.b64decode(report['rows'][-1]['stdout_gzip_base64'], validate=True))
stderr = gzip.decompress(base64.b64decode(report['rows'][-1]['stderr_gzip_base64'], validate=True))
assert b'All tests successful.' in stdout and b'Result: PASS' in stdout
assert re.search(rb'^1\.\.1035$', stdout, re.MULTILINE)
assert not re.search(rb'^not ok ', stdout, re.MULTILINE)
print('Supplemental standard compatibility PASS: both syntax checks and Phase0 1035; complete channels retained')
