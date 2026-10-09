"""Capture the same paired native/joined lifetime oracle before and after repair."""
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
MODULE = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
TEST = 't/actionir_event_input_grants.t'
assert sys.argv[1:] in (['before'], ['after'])
mode = sys.argv[1]
target = ROOT / (PREFIX + 'lifetime-' + mode + '.json')
assert not target.exists(), 'one-shot capture'
seed = json.loads((ROOT / (PREFIX + 'after.json')).read_bytes())
files = {path: (ROOT / path).read_bytes() for path in seed['inputs']}
digest = lambda raw: hashlib.sha256(raw).hexdigest()
if mode == 'before':
    assert files[MODULE] == (ROOT / (PREFIX + 'pre-lifetime-SourceEmissions.pm')).read_bytes()
inputs = {path: digest(raw) for path, raw in sorted(files.items())}


def census(root):
    return {p.relative_to(root).as_posix(): digest(p.read_bytes()) for p in root.rglob('*') if p.is_file()}


with tempfile.TemporaryDirectory(prefix='opaque-input-lifetime-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
    command = ['perl', '-Iperl', TEST]
    environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
    result = subprocess.run(command, cwd=supplied, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    row = {'mode': mode, 'producer_sha256': digest(Path(__file__).read_bytes()),
           'inputs': inputs, 'command': command, 'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': census(supplied) == inputs,
           'scope': 'Same authored185-assertion fixture and complete134-file supplied population. Paired native and joined opaque return release is the actual product oracle. No historical input hash is refreshed; retained before-module bytes own the original defect.'}
target.write_text(json.dumps(row, indent=2) + '\n')
assert row['unchanged'] and re.search(rb'^1\.\.185$', result.stdout, re.MULTILINE)
assert b'ok 149 - native opaque AST return releases without construction authority' in result.stdout
assert result.returncode == (1 if mode == 'before' else 0)
assert (b'not ok 150 - joined opaque AST return preserves native immediate release' in result.stdout) == (mode == 'before')
print('Actual opaque AST lifetime', 'RED1' if mode == 'before' else 'GREEN185', 'retained; supplied134 inputs unchanged')
