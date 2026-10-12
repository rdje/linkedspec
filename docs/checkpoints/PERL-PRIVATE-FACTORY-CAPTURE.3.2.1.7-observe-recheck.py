"""Distinct unchanged-source recurrence before authored assertions or binding edits."""
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
BASE = 'b1133da422bbf19b54818c97c2b67a5e6a402012'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_formal_trim_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert sys.argv[1:] == ['before-recheck']
mode = sys.argv[1]
first_raw = (ROOT / (PREFIX + 'before-native.json')).read_bytes()
first = json.loads(first_raw)
assert first['producer_sha256'] == sha((ROOT / (PREFIX + 'observe.py')).read_bytes())
assert sha((ROOT / PROBE).read_bytes()) == first['inputs'][PROBE]
target = ROOT / (PREFIX + mode + '-native.json')
assert not target.exists(), 'one-shot native capture'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 240 and seed['returncode'] == 0 and seed['unchanged']
files = {path: old(path) for path in seed['inputs']}
assert {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items() if path != MODULE)
if mode.startswith('before'):
    assert (ROOT / MODULE).read_bytes() == files[MODULE]
else:
    files[MODULE] = (ROOT / MODULE).read_bytes()
assert PROBE not in files
files[PROBE] = (ROOT / PROBE).read_bytes()
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
modes = {path: stat.S_IMODE((ROOT / path).stat().st_mode) for path in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
rows = []
with tempfile.TemporaryDirectory(prefix='formal-trim-native-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
        destination.chmod(modes[path])
    for surface in ('observe', 'cold-observe'):
        command = ['perl', '-Iperl', './' + PROBE, surface]
        process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
        rows.append({'surface': surface, 'command': command, 'returncode': process.returncode,
            'stdout_base64': base64.b64encode(process.stdout).decode(),
            'stderr_base64': base64.b64encode(process.stderr).decode()})
        (ROOT / (PREFIX + mode + '-reached.json')).write_text(json.dumps({'inputs': inputs, 'modes': modes, 'rows': rows}, indent=2) + '\n')
    actual = {path.relative_to(supplied).as_posix(): sha(path.read_bytes()) for path in supplied.rglob('*') if path.is_file()}
    actual_modes = {path: stat.S_IMODE((supplied / path).stat().st_mode) for path in actual}
record = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()), 'mode': mode,
    'first_native_sha256': sha(first_raw), 'first_producer_sha256': first['producer_sha256'],
    'seed': SEED, 'seed_sha256': sha(seed_raw), 'inputs': inputs, 'modes': modes,
    'unchanged': actual == inputs and actual_modes == modes, 'rows': rows,
    'scope': 'Complete accepted240 consumer inputs plus first formal-trim diagnostic. Both real brace/dot helpers execute without stubs; readonly B observes actual expression/formal/trimmed pads and callback argument aliases. Direct CODE, symbolic/blessed/GLOB/call-overload and already-bound formals, native scan/guard/return/coercion/effect/error/fatal/context and cold behavior are observed before assertions or source/card/book changes. Modes, complete channels and input preservation retained. No complete helper/public/private/parent/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged']
assert all(row['returncode'] == 0 for row in rows), 'native commands must complete; actual channels retained'
print('Formal-trim', mode, 'native commands retained:', len(inputs), 'inputs;', len(rows), 'fresh processes')
