"""One-shot native object-name argument observations before assertions/source changes."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '61cca1cccff6027461e120e4236431d1bc7d20b1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-consumers.json'
PROBE = 't/actionir_small_kind_probe.pl'
SYMBOLIC = 't/actionir_small_kind_symbolic_probe.pl'
EXTRA = 't/actionir_small_kind_reference_probe.pl'
TARGET = ROOT / (PREFIX + 'reference-native.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert not TARGET.exists(), 'one-shot native observation'
seed_raw = old(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 215
files = {path: old(path) for path in seed['inputs']}
assert {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items())
assert PROBE not in files
files[PROBE] = (ROOT / PROBE).read_bytes()
first_raw = (ROOT / (PREFIX + 'native.json')).read_bytes()
first = json.loads(first_raw)
assert first['inputs'] == {path: sha(raw) for path, raw in files.items()}
assert first['returncode'] == 0 and first['unchanged']
files[SYMBOLIC] = (ROOT / SYMBOLIC).read_bytes()
symbolic_raw = (ROOT / (PREFIX + 'symbolic-native.json')).read_bytes()
symbolic = json.loads(symbolic_raw)
assert symbolic['inputs'] == {path: sha(raw) for path, raw in files.items()}
assert symbolic['returncode'] == 0 and symbolic['unchanged']
assert EXTRA not in files
files[EXTRA] = (ROOT / EXTRA).read_bytes()
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0',
                   LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='small-kind-native-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    command = ['perl', '-Iperl', './' + EXTRA]
    result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    unchanged = {path.relative_to(supplied).as_posix(): sha(path.read_bytes())
        for path in supplied.rglob('*') if path.is_file()} == inputs
    row = {'base': BASE, 'seed': SEED, 'seed_sha256': sha(seed_raw),
        'producer_sha256': sha(Path(__file__).read_bytes()), 'first_native_sha256': sha(first_raw), 'symbolic_native_sha256': sha(symbolic_raw), 'inputs': inputs,
        'command': command, 'returncode': result.returncode,
        'stdout_base64': base64.b64encode(result.stdout).decode(),
        'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': unchanged,
        'scope': 'Additional pre-assertion first-native observations of an actual string-overloaded candidate name object: original object argument identity, caller-visible object effects, scalar context, incoming/success errors, undefined/fatal identity, actual CODE known/opaque cases and conservative symbolic second selection. Original216 and217 input observations/probes remain exact; one separate diagnostic probe extends the accepted215-input runtime capsule. No source edits, complete helper/language/private or parent admission.'}
    TARGET.write_text(json.dumps(row, indent=2) + '\n')
assert unchanged and result.returncode == 0 and not result.stderr, 'native small optional-kind observation'
print('Small optional-kind object first native capture PASS:', len(inputs), 'supplied inputs; complete channels retained before assertions')
