"""One-shot native dropped-value trim observations before assertions and source changes."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '354c15530fd1445ebfa8c6c0683e7b8d066caced'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-consumers-final.json'
PROBE = 't/actionir_dropped_trim_probe.pl'
COLD = 't/actionir_dropped_trim_cold_probe.pl'
TARGET = ROOT / (PREFIX + 'native.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert not TARGET.exists(), 'one-shot native observation'
seed_raw = old(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 211
files = {path: old(path) for path in seed['inputs']}
assert {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items())
assert PROBE not in files
files[PROBE] = (ROOT / PROBE).read_bytes()
assert COLD not in files
files[COLD] = (ROOT / COLD).read_bytes()
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0',
                   LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='method-native-inventory-', dir=os.environ['TMPDIR']) as directory:
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
        'scope': 'First actual native dropped-value trim/caller callback, guard, authority and cold observations over accepted211-file final consumer capsule plus two diagnostic probes,213 inputs. Actual inline CODE selection, local slots/reference identities, scalar contexts, effects/errors/fatal objects, map FETCH order/replacement and controlled secondary helpers are retained before assertions/source edits. This is bounded private caller proof, not complete AST/helper/language or parent admission.'}
    TARGET.write_text(json.dumps(row, indent=2) + '\n')
assert unchanged and result.returncode == 0 and not result.stderr, 'native compiled-source observation'
print('Dropped trim first native capture PASS:', len(inputs), 'supplied inputs; complete channels retained before assertions')
