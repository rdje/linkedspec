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
BASE = '22132b2b0eccb5ac38ef3c756f1b1e5b08992947'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_named_dispatch_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert sys.argv[1:] in (['before'], ['before-recheck'], ['after'])
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '-native.json')
assert not target.exists(), 'one-shot native capture'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 243 and seed['returncode'] == 0 and seed['unchanged']
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
with tempfile.TemporaryDirectory(prefix='named-dispatch-native-', dir=os.environ['TMPDIR']) as directory:
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
    'seed': SEED, 'seed_sha256': sha(seed_raw), 'inputs': inputs, 'modes': modes,
    'unchanged': actual == inputs and actual_modes == modes, 'rows': rows,
    'scope': 'Complete accepted243 consumer inputs plus first named-dispatch diagnostic. The real owner body executes with six explicit localized selected CODE references and controlled secondary AST/assignment/component helpers. Readonly B observes native expression/trimmed/deps/selected pads and argument aliases; first-result selection, list snapshot versus next-call name replacement, guards, context, return/coercion/effect/error/fatal/reference identity and cold behavior precede assertions or source/card/book changes. No complete named helper/public/private/parent/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged']
assert all(row['returncode'] == 0 for row in rows), 'native commands must complete; actual channels retained'
print('Named-dispatch', mode, 'native commands retained:', len(inputs), 'inputs;', len(rows), 'fresh processes')
