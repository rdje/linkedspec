"""Retain actual legacy callback probes after the sole regex fix, before fixture migration."""
import base64
import hashlib
import json
import os
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'de02b83a1a794370b4071bb53677ab675745acc2'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
LEGACY = 't/actionir_small_kind_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
target = ROOT / (PREFIX + 'legacy.json')
assert not target.exists(), 'one-shot observation'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
files = {p: old(p) for p in seed['inputs']}
assert len(files) == 223 and {p: sha(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
assert (ROOT / LEGACY).read_bytes() == files[LEGACY], 'observe before authored expectation changes'
files[MODULE] = (ROOT / MODULE).read_bytes()
inputs = {p: sha(raw) for p, raw in sorted(files.items())}
modes = {p: stat.S_IMODE((ROOT / p).stat().st_mode) for p in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
rows = []
with tempfile.TemporaryDirectory(prefix='uniform-target-legacy-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
        destination.chmod(modes[path])
    for name, command in (
        ('main', ['perl', '-Iperl', './t/actionir_small_kind_probe.pl', 'observe']),
        ('symbolic', ['perl', '-Iperl', './t/actionir_small_kind_symbolic_probe.pl']),
        ('reference', ['perl', '-Iperl', './t/actionir_small_kind_reference_probe.pl']),
    ):
        process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
        rows.append({'name': name, 'command': command, 'returncode': process.returncode,
            'stdout_base64': base64.b64encode(process.stdout).decode(),
            'stderr_base64': base64.b64encode(process.stderr).decode()})
        (ROOT / (PREFIX + 'legacy-reached.json')).write_text(json.dumps({'inputs': inputs, 'modes': modes, 'rows': rows}, indent=2) + '\n')
    actual = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()}
    actual_modes = {p: stat.S_IMODE((supplied / p).stat().st_mode) for p in actual}
record = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()), 'seed_sha256': sha(seed_raw),
    'inputs': inputs, 'modes': modes, 'rows': rows, 'unchanged': actual == inputs and actual_modes == modes,
    'scope': 'Complete223 accepted consumer inputs, sole current regex source overlay, unchanged original probes/fixture. Actual three callback probe commands precede any authored expectation migration. Compare with retained accepted .2 current observations; keep all original producer bytes and invalid-call locations.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged'] and all(r['returncode'] == 0 and not base64.b64decode(r['stderr_base64']) for r in rows)
print('Container-target legacy observations retained:223 inputs/three actual probe commands')
