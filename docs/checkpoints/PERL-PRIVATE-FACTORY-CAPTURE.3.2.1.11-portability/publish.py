"""Final readonly publication with exact decoded diagnostic and historical-input proof."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11'
PREFIX = 'docs/checkpoints/' + LEAF + '-portability/'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
for tail in ('review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual final readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 2
original = (ROOT / (PREFIX + 'original-claim.json')).read_bytes()
paths = set(review['inputs']) | set(evidence['inputs'])
paths.update(PREFIX + tail for tail in ('review.py', 'review.json', 'evidence.py', 'evidence.json', 'publish.py'))
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
    'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for p in sorted(paths)]
claim = json.loads(original)['claims'][0]
claim['statement'] += (' The complete third177-input/full44317 uncommitted publication now replays unchanged through ten exact original '
    'byte overlays and retained unchanged inputs, with two actual corruption/restoration controls. Two failure reports change only '
    'diagnostic encoding; their full original JSON bytes and decoded logs remain exact. Current complete1485/1349 Knowledge/six header '
    'lineages, book89/four controls and unchanged public70/40 checks pass. Diagnostic-byte and rehashed orphan-header forgeries reject and restore.')
claim['scope'] += (' Diagnostic representation closure retains all original177 inputs/full44317 publication and every earlier observation. '
    'Two raw traceback fields become base64 without changing decoded bytes. Canonical4 portability rejection followed by deliberate130 '
    'is retained; no full failed-candidate reconstruction or canonical PASS is inferred. Final exact staged canonical receipt is mandatory.')
claim['rederive'] = {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py',
    'granularity': 'All original177 binding bytes/full44317 publication and ten complete original overlays; two exact decoded diagnostics; current1485 Markdown/1349 facts/six exact header lineages; full book89/four controls; unchanged primary public70/40 and eleven migration controls; actual focused portability/composed public validation; two semantic denials.',
    'result': claim['statement']}
claim['falsify']['hypothesis'] += ' A portable representation could silently alter the original diagnostic bytes or hide a rehashed malformed current header.'
claim['falsify']['oracle'] += ' Complete original whole JSON byte overlays, unchanged third publisher in supplied isolation, byte-exact decoded-log comparison and independent current header parser.'
claim['falsify']['red_control'] += (' Actual canonical4 portability rejects the two plain traceback fields before interruption130. '
    'Unchanged third publisher rejects altered whole claim and missing fixture, then restores. Altered decoded diagnostic byte and '
    'orphan current header with amended immediate hash each fail for the exact named semantic reason and restore.')
claim['durability'] = {'status': 'checked', 'mode': 'live', 'inputs': inputs}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072
if sys.argv[1:]:
    assert TARGET.read_bytes() == original and len(original) == 44317, 'replace only the preserved complete third publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact final readonly publication'
print('Portable Knowledge/documentation publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
