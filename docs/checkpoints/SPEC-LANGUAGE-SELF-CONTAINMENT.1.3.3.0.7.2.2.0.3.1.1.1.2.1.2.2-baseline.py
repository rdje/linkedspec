"""Capture the authored interface fixture against immutable activation inputs."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '3dbe7b10a8b6cbe1f6ea92afcb235cc1a71cd59e'
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
SEED = 'docs/checkpoints/' + LEAF[:-1] + '1-consumers.json'
TEST = 't/actionir_event_input_grants.t'
MODULE = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


assert not (ROOT / (PREFIX + 'before.json')).exists(), 'one-shot capture'
seed_raw = blob(SEED)
seed = json.loads(seed_raw)
files = {path: blob(path) for path in sorted(seed['inputs'])}
assert {path: digest(raw) for path, raw in files.items()} == seed['inputs']
assert len(files) == 133 and (ROOT / MODULE).read_bytes() == files[MODULE]
files[TEST] = (ROOT / TEST).read_bytes()
inputs = {path: digest(raw) for path, raw in sorted(files.items())}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0',
                   LINKEDSPEC_MEMBERSHIP_BASELINE='0')
with tempfile.TemporaryDirectory(prefix='event-input-baseline-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
    assert census(supplied) == inputs
    command = ['perl', '-Iperl', TEST]
    result = subprocess.run(command, cwd=supplied, env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    report = {'base': BASE, 'seed': SEED, 'seed_sha256': digest(seed_raw),
              'producer_sha256': digest(Path(__file__).read_bytes()), 'inputs': inputs,
              'command': command, 'returncode': result.returncode,
              'stdout_base64': base64.b64encode(result.stdout).decode(),
              'stderr_base64': base64.b64encode(result.stderr).decode(),
              'unchanged': census(supplied) == inputs,
              'scope': 'Availability RED only, not semantic falsification. Exact133 original Perl/spec/test/JSON files plus the newly authored fixture, with actual full channels. Read-only standard Perl/core modules and repository-volume scratch reused.'}
(ROOT / (PREFIX + 'before-fixture.t')).write_bytes(files[TEST])
(ROOT / (PREFIX + 'before-SourceEmissions.pm')).write_bytes(files[MODULE])
(ROOT / (PREFIX + 'before.json')).write_text(json.dumps(report, indent=2) + '\n')
assert result.returncode != 0 and report['unchanged']
assert b'original-event input grant interface unavailable' in result.stdout
print('Original interface availability RED retained; exact134-file supplied population unchanged')
