"""Retain/review the actual initial pressure and supplied replay of its matcher failure."""
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
BASE = '9085eb1e5075146ca00dab52304f85937cf7ea05'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4-'
TARGET = ROOT / (PREFIX + 'draft-review.json')
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def read(tail):
    return (ROOT / (PREFIX + tail)).read_bytes()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


draft = read('draft-capacity.py')
applied = read('applied-capacity.py')
assert applied == draft.replace(b"b'REQUIRED'", b"b'document-history rollover required for change_history:'")
expected_current = applied.replace(b"plan['producer_sha256'] == sha(Path(__file__).read_bytes())", b"plan['producer_sha256'] == sha(read(PREFIX + 'applied-capacity.py'))").replace(b"BASE + ':DEVELOPMENT_NOTES.md'", b"BASE + ':CHANGES.md'")
assert read('capacity.py') == expected_current
red = json.loads(read('applied-review-red.json'))
assert red['producer_sha256'] == digest(applied) and red['plan_sha256'] == digest(read('plan.json'))
assert red['resulting_inputs'] == json.loads(read('plan.json'))['resulting_inputs']
assert red['command'] == ['python3', PREFIX + 'applied-capacity.py', 'capture'] and red['returncode'] == 1
assert b'AssertionError: exact clean source segment' in base64.b64decode(red['stderr_base64'], validate=True)
assert not base64.b64decode(red['stdout_base64'], validate=True)
assert draft.count(b"b'REQUIRED'") == 2
snapshot = json.loads(read('draft-inputs.json'))
pressure_raw = read('draft-pressure.json')
pressure = json.loads(pressure_raw)
assert snapshot['base'] == BASE and snapshot['producer_sha256'] == digest(draft)
original = {p: blob(p) for p in snapshot['initial_inputs']}
assert snapshot['initial_inputs'] == {p: digest(raw) for p, raw in original.items()}
after = {p: base64.b64decode(row['base64'], validate=True) for p, row in snapshot['observed_after'].items()}
assert {p: digest(raw) for p, raw in after.items()} == {p: row['sha256'] for p, row in snapshot['observed_after'].items()}
assert set(after) == set(original)
assert {p for p in original if original[p] != after[p]} == {'CHANGES.md', 'DEVELOPMENT_NOTES.md'}
for path in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    head = re.search(rb'^## ', original[path], re.MULTILINE).start()
    assert after[path].startswith(original[path][:head]) and after[path].endswith(original[path][head:])
assert pressure['args'] == ['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--check']
assert pressure['exit_code'] == 255
for channel in ('stdout', 'stderr'):
    row = pressure[channel]
    raw = base64.b64decode(row['base64'], validate=True)
    assert row == {'base64': base64.b64encode(raw).decode(), 'bytes': len(raw), 'sha256': digest(raw)}
message = b'document-history rollover required for change_history: '
assert message in base64.b64decode(pressure['stderr']['base64'])
assert b'REQUIRED' not in base64.b64decode(pressure['stderr']['base64'])
files = dict(original, **{PREFIX + 'draft-capacity.py': draft})
inputs = {p: digest(raw) for p, raw in files.items()}
expected_after = dict(inputs, **{p: digest(raw) for p, raw in after.items()},
                      **{PREFIX + 'pressure.json': digest(pressure_raw)})
command = ['python3', PREFIX + 'draft-capacity.py', 'apply']
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot draft replay'
    with tempfile.TemporaryDirectory(prefix='capacity-matcher-replay-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, raw in files.items():
            target = supplied / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        assert census(supplied) == inputs
        # Only own read-only Git object queries are used; no Git mutation occurs.
        environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied),
                           PYTHONDONTWRITEBYTECODE='1')
        result = subprocess.run(command, cwd=supplied, env=environment,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        observed = census(supplied)
        row = {'command': command, 'returncode': result.returncode,
               'stdout_base64': base64.b64encode(result.stdout).decode(),
               'stderr_base64': base64.b64encode(result.stderr).decode(),
               'before': inputs, 'after': observed}
        assert observed == expected_after
        assert (supplied / (PREFIX + 'pressure.json')).read_bytes() == pressure_raw
        assert result.returncode == 1 and not result.stdout
        assert b'AssertionError: actual pressure RED before rollover' in result.stderr
        report = {'result': 'PASS', 'base': BASE, 'producer_sha256': digest(Path(__file__).read_bytes()),
                  'draft_sha256': digest(draft), 'applied_sha256': digest(applied), 'applied_red_sha256': digest(read('applied-review-red.json')), 'current_sha256': digest(read('capacity.py')),
                  'snapshot_sha256': digest(read('draft-inputs.json')), 'pressure_sha256': digest(pressure_raw),
                  'replay': row,
                  'scope': 'Original draft producer, actual initial pressure255 channel and exact two draft roots retained. Fresh same-volume supplied replay uses only own read-only Git objects and captures complete process channels; it stops at the same uppercase matcher before archive/manifest/registry/index/ADR/book writes. Applied producer differs from initial draft only by two pressure matcher literals. Current readonly review additionally corrects the one source-blob path and references the retained actual applied producer; its original plan hashes remain unchanged. Actual stale-source-blob RED is retained. Initial replay reviewer used an unanchored heading guard; its exact unpublished draft survives and the final guard anchors real heading lines. No production tool or threshold changes.'}
        TARGET.write_text(json.dumps(report, indent=2) + '\n')
report = json.loads(TARGET.read_bytes())
assert report['result'] == 'PASS' and report['base'] == BASE
assert report['producer_sha256'] == digest(Path(__file__).read_bytes())
assert report['applied_sha256'] == digest(applied) and report['applied_red_sha256'] == digest(read('applied-review-red.json'))
assert report['draft_sha256'] == digest(draft) and report['current_sha256'] == digest(read('capacity.py'))
assert report['snapshot_sha256'] == digest(read('draft-inputs.json')) and report['pressure_sha256'] == digest(pressure_raw)
row = report['replay']
assert row['command'] == command and row['returncode'] == 1
assert row['before'] == inputs and row['after'] == expected_after
assert not base64.b64decode(row['stdout_base64'], validate=True)
assert b'AssertionError: actual pressure RED before rollover' in base64.b64decode(row['stderr_base64'], validate=True)
print('Draft pressure/replay review PASS: actual255 and same isolated matcher stop; exact draft/applied/readonly instrument chain')
