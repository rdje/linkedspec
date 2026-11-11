"""Qualify the direct run with explicit actual SDK/instrument inputs."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
inputs = {}
for name in ('capture_direct.py', 'direct_runner.pl'):
    raw = (BASE / name).read_bytes()
    target = BASE / ('qualified-template-' + name + '.gz')
    assert not target.exists()
    target.write_bytes(gzip.compress(raw, mtime=0))
    inputs[name] = dict(sha256=hashlib.sha256(raw).hexdigest(), retained=target.name)
runner = (BASE / 'direct_runner.pl').read_text()
old = r'array-pipeline-callable-result-perl-2026-11-11/direct\z'
assert runner.count(old) == 1
runner = runner.replace(old, r'array-pipeline-callable-result-perl-2026-11-11/direct_qualified\z')
assert not (BASE / 'direct_runner_qualified.pl').exists()
(BASE / 'direct_runner_qualified.pl').write_text(runner)
capture = (BASE / 'capture_direct.py').read_text()
changes = [
    ("OUT = BASE / 'direct'", "OUT = BASE / 'direct_qualified'"),
    ("paths += [p for p in BASE.iterdir() if p.is_file()]", "paths += [BASE / name for name in ('capture_direct2.py', 'direct_runner_qualified.pl', 'prepare_direct_qualified.py', 'direct-qualified-inputs.json', 'direct-template.pl.gz')]"),
    ("str(BASE / 'direct_runner.pl')", "str(BASE / 'direct_runner_qualified.pl')"),
]
for old, new in changes:
    assert capture.count(old) == 1, old
    capture = capture.replace(old, new)
assert not (BASE / 'capture_direct2.py').exists()
(BASE / 'capture_direct2.py').write_text(capture)
for name in ('capture_direct2.py', 'direct_runner_qualified.pl', 'prepare_direct_qualified.py'):
    inputs[name] = dict(sha256=hashlib.sha256((BASE / name).read_bytes()).hexdigest())
(BASE / 'direct-qualified-inputs.json').write_text(json.dumps(inputs, indent=2) + '\n')
print('Qualified instruments authored; all runtime/default grammar/selected tests/fixtures remain captured')
