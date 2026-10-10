"""Replay retained native fixture premises and the rejected seed-count reviewer.

Only supplied repository-volume scratch is written. Original instruments and
channels stay exact; Git is used read-only for the accepted native inputs.
"""
import base64
import hashlib
import json
import os
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
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'checked': dict(sorted(checked.items())), 'rows': rows,
          'scope': 'Actual native supplied replays reproduce both rejected fixture premises with exact original channels. The draft reviewer rejects166 original files at its mistaken168 check; the corrected reviewer differs by that one count only. No original instrument, result, measurement or production source is rewritten. Git dependency reads are accepted native blobs only; scratch stays on repository volume.'}
target = ROOT / (PREFIX + 'draft-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot draft review already exists'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'draft replay drift'
print('Retained native draft review PASS: read-only literal, shape local copy and original seed-count rejection')
