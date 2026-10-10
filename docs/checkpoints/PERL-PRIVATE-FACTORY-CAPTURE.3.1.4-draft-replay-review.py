"""Replay retained native fixture premises and the rejected seed-count reviewer.

Only supplied repository-volume scratch is written. Original instruments and
channels stay exact; Git is used read-only for the accepted native inputs.
"""
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
BASE = '049e1ba537f2bde635b2c0fed31fe83f6b3c129b'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4-'
TEST = 't/actionir_method_value_capture.t'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3-consumers.json'
assert sys.argv[1:] in ([], ['--capture'])
checked = {}
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


native = json.loads(read(PREFIX + 'native.json'))
files = {}
for path, expected in native['inputs'].items():
    raw = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT) if path == MODULE else read(path)
    assert digest(raw) == expected, 'native supplied input drift'
    files[path] = raw

cases = [
    ('readonly-kind', 'draft-fixture.t', 'draft-observe.json', ['perl', '-Iperl', TEST, 'observe']),
    ('shape-member-copy', 'alias-draft.t', 'alias-draft.json', ['perl', '-Iperl', TEST]),
    ('seed-count', 'review-draft.py', 'review-draft.json', ['python3', PREFIX + 'review.py', '--capture']),
]
rows = []
for name, instrument, artifact, command in cases:
    instrument_raw = read(PREFIX + instrument)
    prior = json.loads(read(PREFIX + artifact))
    field = 'producer_sha256' if name == 'seed-count' else 'fixture_sha256'
    assert prior[field] == digest(instrument_raw) and prior['command'] == command
    selected = dict(files)
    if name == 'seed-count':
        selected[PREFIX + 'review.py'] = instrument_raw
        selected[SEED] = read(SEED)
        current = read(PREFIX + 'review.py')
        assert current == instrument_raw.replace(b'assert len(original) == 168 and',
                                                  b'assert len(original) == 166 and', 1)
    else:
        selected[TEST] = instrument_raw
    inputs = {p: digest(raw) for p, raw in sorted(selected.items())}
    with tempfile.TemporaryDirectory(prefix='main-native-draft-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, raw in selected.items():
            target = supplied / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        environment = dict(os.environ, PERL5LIB='', PERL5OPT='', PYTHONDONTWRITEBYTECODE='1',
                           GIT_DIR=str(ROOT / '.git'))
        result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True, check=False)
        assert result.returncode == prior['returncode']
        if name == 'seed-count':
            assert result.returncode != 0 and b'len(original) == 168' in result.stderr
        else:
            assert result.stdout == base64.b64decode(prior['stdout_base64'], validate=True)
            assert result.stderr == base64.b64decode(prior['stderr_base64'], validate=True)
            if name == 'readonly-kind':
                observed = json.loads(result.stdout)
                rejected = [r for r in observed if r['role'] == 'lower_declare_initializer_expr']
                assert len(rejected) == 3 and all('read-only value' in r['error'] for r in rejected)
            else:
                failures = [line for line in result.stdout.splitlines() if line.startswith(b'not ok ')]
                assert result.returncode == 43 and len(failures) == 43
                assert b'trim-csv-slot keeps actual returned-array scalar alias' in failures[-1]
        after = {p.relative_to(supplied).as_posix(): digest(p.read_bytes())
                 for p in supplied.rglob('*') if p.is_file()}
        assert after == inputs, 'draft replay wrote supplied inputs'
        rows.append({'case': name, 'command': command, 'inputs': inputs,
                     'returncode': result.returncode, 'stdout_sha256': digest(result.stdout),
                     'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': True})
# The original report retained the full seed-review traceback, including its
# random supplied directory. Preserve that record; compare this one path field
# structurally while retaining complete new actual channels separately.
initial_producer = read(PREFIX + 'draft-review.py')
initial = json.loads(read(PREFIX + 'draft-review.json'))
assert initial['producer_sha256'] == digest(initial_producer)
assert initial['result'] == 'PASS' and len(initial['rows']) == len(rows) == 3
for path, expected in initial['checked'].items():
    assert digest(read(path)) == expected, 'initial replay input drift'

def stable_stderr(raw):
    return re.sub(rb'File "[^"\n]*/(docs/checkpoints/[^"\n]+)"',
                  rb'File "<supplied>/\1"', raw)

stable_rows, channels = [], []
for original, current in zip(initial['rows'], rows):
    original_stderr = base64.b64decode(original['stderr_base64'], validate=True)
    current_stderr = base64.b64decode(current['stderr_base64'], validate=True)
    assert stable_stderr(original_stderr) == stable_stderr(current_stderr)
    assert {k: v for k, v in original.items() if k != 'stderr_base64'} == {
        k: v for k, v in current.items() if k != 'stderr_base64'}
    stable = {k: v for k, v in current.items() if k != 'stderr_base64'}
    stable['stderr_supplied_path_normalized_base64'] = base64.b64encode(stable_stderr(current_stderr)).decode()
    stable_rows.append(stable)
    channels.append({'case': current['case'], 'stderr_base64': current['stderr_base64']})
proof = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
         'checked': dict(sorted(checked.items())), 'rows': stable_rows,
         'scope': 'Fresh supplied native replays reproduce all original instrument outcomes and input identities. Only the generated supplied-directory prefix in the Python seed-review traceback is normalized for repeatable comparison; complete actual stderr channels remain retained separately. Both native fixture channels stay byte-exact. Original draft-review producer/result remain unchanged; no old measurement is refreshed.'}
target = ROOT / (PREFIX + 'draft-replay-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot deterministic draft replay already exists'
    target.write_text(json.dumps({'proof': proof, 'actual_channels': channels}, indent=2) + '\n')
else:
    retained = json.loads(target.read_bytes())
    assert retained['proof'] == proof, 'deterministic draft replay drift'
    assert len(retained['actual_channels']) == len(stable_rows)
    for channel, stable in zip(retained['actual_channels'], stable_rows):
        assert channel['case'] == stable['case']
        assert base64.b64encode(stable_stderr(base64.b64decode(channel['stderr_base64'], validate=True))).decode() == stable['stderr_supplied_path_normalized_base64']
print('Retained native draft review PASS: read-only literal, shape local copy and original seed-count rejection')
