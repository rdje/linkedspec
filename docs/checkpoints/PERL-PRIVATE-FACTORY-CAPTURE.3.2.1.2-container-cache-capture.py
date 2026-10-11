"""One-shot fresh-process diagnosis of the native dynamic-container regex cache."""
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
PROBE = 't/actionir_uniform_container_cache_probe.pl'
TARGET = ROOT / (PREFIX + 'container-cache-native.json')
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
    command = ['perl', '-Iperl', './' + PROBE, 'observe']
    result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    unchanged = {path.relative_to(supplied).as_posix(): sha(path.read_bytes())
        for path in supplied.rglob('*') if path.is_file()} == inputs
    row = {'base': BASE, 'seed': SEED, 'seed_sha256': sha(seed_raw),
        'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': inputs,
        'command': command, 'returncode': result.returncode,
        'stdout_base64': base64.b64encode(result.stdout).decode(),
        'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': unchanged,
        'scope': 'First controlled fresh-process diagnosis of _uniform_binding_target_symbol using the accepted215 runtime inputs plus one diagnostic probe. Two fresh Perl processes reverse the first array/hash order and retain every actual command/channel, target/container/result and callback count. This identifies native private helper order dependence; no authored-language failure, public contract admission or production guard fix is inferred. Existing /o behavior stays unchanged in the bounded optional-capture slice; P2 repair is owned by .3.2.1.9 after .2 and due hygiene.'}
    TARGET.write_text(json.dumps(row, indent=2) + '\n')
assert unchanged and result.returncode == 0 and not result.stderr, 'native small optional-kind observation'
print('Uniform container-cache diagnosis capture PASS:', len(inputs), 'supplied inputs; complete channels retained before assertions')
