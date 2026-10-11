"""One-shot native observations before authored assertions or binding edits."""
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
BASE = '61a73324f06238418301eac88fd3f908665ecbe3'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_method_kind_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert sys.argv[1:] in (['before'], ['after'])
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '-authority-native.json')
assert not target.exists(), 'one-shot native capture'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 225 and seed['returncode'] == 0 and seed['unchanged']
files = {path: old(path) for path in seed['inputs']}
assert {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items() if path != MODULE)
if mode == 'before':
    assert (ROOT / MODULE).read_bytes() == files[MODULE]
else:
    files[MODULE] = (ROOT / MODULE).read_bytes()
assert PROBE not in files
files[PROBE] = (ROOT / PROBE).read_bytes()
files['t/actionir_method_kind_authority_probe.pl'] = (ROOT / 't/actionir_method_kind_authority_probe.pl').read_bytes()
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
modes = {path: stat.S_IMODE((ROOT / path).stat().st_mode) for path in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
rows = []
with tempfile.TemporaryDirectory(prefix='method-kind-native-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
        destination.chmod(modes[path])
    for surface in ('authority',):
        command = ['perl', '-Iperl', './t/actionir_method_kind_authority_probe.pl']
        process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
        rows.append({'surface': surface, 'command': command, 'returncode': process.returncode,
            'stdout_base64': base64.b64encode(process.stdout).decode(),
            'stderr_base64': base64.b64encode(process.stderr).decode()})
        (ROOT / (PREFIX + mode + '-authority-reached.json')).write_text(json.dumps({'inputs': inputs, 'modes': modes, 'rows': rows}, indent=2) + '\n')
    actual = {path.relative_to(supplied).as_posix(): sha(path.read_bytes()) for path in supplied.rglob('*') if path.is_file()}
    actual_modes = {path: stat.S_IMODE((supplied / path).stat().st_mode) for path in actual}
record = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()), 'mode': mode,
    'seed': SEED, 'seed_sha256': sha(seed_raw), 'inputs': inputs, 'modes': modes,
    'unchanged': actual == inputs and actual_modes == modes, 'rows': rows,
    'scope': 'Complete accepted225 consumer inputs plus the two diagnostic producers. Original native probe is replayed byte-for-byte before each supplemental authority population. Actual outer local helper and inner AST assignment execute, with explicitly controlled secondary helpers. Separate fresh loaded/cold processes precede authored assertions and binding edits. Complete channels and input modes retained; no full-helper/private/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged']
assert all(row['returncode'] == 0 for row in rows), 'native commands must complete; actual channels retained'
print('Method-kind', mode, 'native commands retained:', len(inputs), 'inputs;', len(rows), 'fresh processes')
