"""One-shot before/after native and actual public Toolbox observations."""
import base64
import hashlib
import json
import os
import stat
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'de02b83a1a794370b4071bb53677ab675745acc2'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_uniform_target_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in (['before'], ['after'])
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '-observations.json')
assert not target.exists(), 'one-shot observation'
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 223 and seed['returncode'] == 0 and seed['unchanged']
files = {p: old(p) for p in seed['inputs']}
assert {p: sha(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
if mode == 'before':
    assert (ROOT / MODULE).read_bytes() == files[MODULE]
else:
    files[MODULE] = (ROOT / MODULE).read_bytes()
assert PROBE not in files
files[PROBE] = (ROOT / PROBE).read_bytes()
inputs = {p: sha(raw) for p, raw in sorted(files.items())}
modes = {p: stat.S_IMODE((ROOT / p).stat().st_mode) for p in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
rows = []
with tempfile.TemporaryDirectory(prefix='uniform-target-observe-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for p, raw in files.items():
        destination = supplied / p
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
        destination.chmod(modes[p])
    for surface in ('native', 'public'):
        for first in ('array', 'hash'):
            command = ['perl', '-Iperl', './' + PROBE, surface, first]
            process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
            rows.append({'surface': surface, 'first': first, 'command': command, 'returncode': process.returncode,
                'stdout_base64': base64.b64encode(process.stdout).decode(),
                'stderr_base64': base64.b64encode(process.stderr).decode()})
            reached = {'inputs': inputs, 'modes': modes, 'rows': rows}
            (ROOT / (PREFIX + mode + '-reached.json')).write_text(json.dumps(reached, indent=2) + '\n')
    actual = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()}
    actual_modes = {p: stat.S_IMODE((supplied / p).stat().st_mode) for p in actual}
record = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()), 'mode': mode,
    'seed': SEED, 'seed_sha256': sha(seed_raw), 'inputs': inputs, 'modes': modes,
    'unchanged': actual == inputs and actual_modes == modes, 'rows': rows,
    'scope': 'Complete accepted223 consumer inputs plus one diagnostic probe. Four fresh native/public processes; explicit private first-container warm-up precedes actual public Toolbox lowering, live Get, standalone emitted-source load/execution. No authored assertions or runtime edits precede the before observation. All actual separate channels, file identities and modes retained; no complete public/private/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged'], 'supplied input mutation'
assert all(r['returncode'] == 0 for r in rows), 'every observation must complete'
print('Container-target', mode, 'observation retained:', len(inputs), 'inputs;', len(rows), 'fresh processes')
