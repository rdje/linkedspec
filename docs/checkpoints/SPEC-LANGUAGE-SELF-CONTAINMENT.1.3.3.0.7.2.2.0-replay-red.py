"""Replay the exact diagnostic fixture without installing a failing recurring test."""
from pathlib import Path
import hashlib
import importlib.util
import json
import os
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-'
spec = importlib.util.spec_from_file_location('capture', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
original = json.loads((ROOT / (PREFIX + 'tests-before.json')).read_bytes())
path = PREFIX + 'red-fixture.t'
digest = hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
assert digest == original['test_sha256'], 'fixture bytes drifted during preservation'
command = ['prove', '-v', '-Iperl', path]
result = subprocess.run(command, cwd=ROOT, capture_output=True,
                        env=dict(os.environ, PERL5LIB='', PERL_HASH_SEED='0', PERL_PERTURB_KEYS='2',
                                 LINKEDSPEC_QUOTE_BASELINE='1'))
record = {'command': command, 'baseline': '1', 'test_path': path, 'test_sha256': digest,
          'exit': result.returncode, 'stdout': capture.envelope(result.stdout),
          'stderr': capture.envelope(result.stderr)}
(ROOT / (PREFIX + 'replay-red.json')).write_text(json.dumps(record, indent=2) + '\n')
text = result.stdout.decode()
assert result.returncode == 1
assert re.search(r'^1\.\.13$', text, re.M)
assert len(re.findall(r'^not ok \d+ -', text, re.M)) == 11
assert re.search(r'^ok 12 -', text, re.M) and re.search(r'^ok 13 -', text, re.M)
print('PASS diagnostic replay retains complete13 groups /11 expected RED /2 guards GREEN')
