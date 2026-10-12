"""Readonly bounded current header review; --capture writes once after the repair."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '22132b2b0eccb5ac38ef3c756f1b1e5b08992947'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-'
ROUTE = ('Current proof: bash tools/run_python_project_data.sh ' + PREFIX +
    'publish-claim.py; review.py, native-review.py, book-review.py, headers-review.py and '
    'evidence.py under the same wrapper/prefix have readonly defaults. '
    'Historical routes below require their accepted Git inputs; capture writers are retired.')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
census = load(PREFIX + 'headers-census.json')
assert census['base'] == BASE
assert census['producer_sha256'] == sha((ROOT / (PREFIX + 'headers.py')).read_bytes())
assert len(census['rows']) == 6
for path, digest in census['original_inputs'].items():
    assert sha(old(path)) == digest, 'exact accepted header/parser input'
    if not path.startswith('docs/knowledge/'):
        assert sha((ROOT / path).read_bytes()) == digest, 'unchanged architecture/parser'
current_orphans = []
for row in census['rows']:
    raw = old(row['path'])
    head, body = raw.split(b'\n---\n', 1)
    assert row['original_sha256'] == sha(raw)
    assert base64.b64decode(row['header_base64'], validate=True) == head
    # Independently enumerate the original reverify tail; it is the final field.
    tail = head.decode().split('\nreverify:', 1)[1].splitlines()
    scalar = tail[0].strip()
    assert not any(re.match(r'^[A-Za-z_][A-Za-z0-9_]*:', line) for line in tail[1:])
    notes = ([scalar.removeprefix('"').removesuffix('"')] if scalar else [])
    items = []
    for number, line in enumerate(head.decode().splitlines(), 1):
        if line in tail[1:] and re.match(r'^\s+-\s+', line):
            value = re.sub(r'^\s+-\s+', '', line)
            notes.append(value.removeprefix('"').removesuffix('"'))
            items.append({'line': number, 'text': value})
    assert row['routes'] == notes
    assert row['reverify_kind'] == ('scalar' if scalar else 'block-list')
    assert row['orphan_items'] == (items if scalar else [])
    current = (ROOT / row['path']).read_bytes()
    current_head, current_body = current.split(b'\n---\n', 1)
    assert current_body.startswith(body), 'original Knowledge body retained'
    active = None
    for number, line in enumerate(current_head.decode().splitlines(), 1):
        field = re.match(r'^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$', line)
        if field:
            active = field[1] if not field[2] else None
        elif re.match(r'^\s+-\s+', line) and active is None:
            current_orphans.append({'path': row['path'], 'line': number})
assert not current_orphans, ('current Knowledge header has orphan list entries', current_orphans)
for row in census['rows']:
    head, body = (ROOT / row['path']).read_bytes().split(b'\n---\n', 1)
    lines = re.findall(rb'^reverify: (.*)$', head, re.M)
    assert lines == [json.dumps(ROUTE).encode()], 'single current scalar reverify route'
    archived = '\n\nHistorical header routes retained at accepted22132b2b:\n'
    archived += ''.join('- ' + note + '\n' for note in row['routes'])
    assert archived.encode() in body, 'all original header routes retained'
ast = (ROOT / 'docs/knowledge/perl-method-ast-call-capture.md').read_bytes()
assert b'Historical iterator repair: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-iterator-review.py requires accepted99f2939ac logical inputs.' in ast
assert sum(len(row['orphan_items']) for row in census['rows']) == 4
paths = set(census['original_inputs']) | {
    PREFIX + 'headers.py', PREFIX + 'headers-census.json', PREFIX + 'headers-review.py'}
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {path: sha((ROOT / path).read_bytes()) for path in sorted(paths)},
    'cards': 6, 'original_orphans': 4, 'current_orphans': 0,
    'scope': 'Six current headers have one scalar current readonly route and no orphan list entries. Exact accepted original headers/parser inputs and original fact bodies remain; every original route is explicitly historical in the body. The iterator route names its actual .5 accepted inputs. This bounded repair does not claim canonical gate/full Knowledge syntax admission; .11 owns enforcement.'}
if sys.argv[1:] == ['--preflight']:
    print('Current Knowledge header preflight PASS:6 scalar routes;4 original orphan entries repaired')
    sys.exit(0)
target = ROOT / (PREFIX + 'headers-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot bounded header review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'headers-review.json') == report
print('Current Knowledge header review PASS:6 scalar routes;4 original orphan entries repaired')
