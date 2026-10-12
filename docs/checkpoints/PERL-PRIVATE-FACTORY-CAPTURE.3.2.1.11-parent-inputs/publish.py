"""Final readonly publication with exact decoded diagnostic and historical-input proof."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11'
PREFIX = 'docs/checkpoints/' + LEAF + '-parent-inputs/'
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
claim['statement'] += (' The complete fourth198-input/full51535 uncommitted publication replays unchanged with two actual corruption/restoration controls. The sole parent-untracked published public input is explicitly mapped from rgx/README.md to a byte-exact parent-owned snapshot. Current public bytes and the unchanged gitlink are checked read-only. Rehashed snapshot and forged gitlink-record controls reject and restore; current Knowledge1485/1349, book89/four controls and public70/40 pass.')
claim['scope'] += (' Parent-tracked public-input closure only. Published README snapshotting does not authorize inspecting submodule implementation, changing its pin or writing to another repository. Every original198 input byte/full51535 publication and prior observation is retained. Canonical5 claim-registration rejection remains exact; final exact staged canonical admission is mandatory.')
claim['rederive'] = {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py',
    'granularity': 'Every original198 binding byte/full51535 publication/eight original overlays; sole published public input exact snapshot/gitlink; current1485 Markdown/1349 facts/six full header lineages; book89/four controls; public70/40/eleven migration controls; two semantic denials.',
    'result': claim['statement']}
claim['falsify']['hypothesis'] += ' A copied public input could differ from its published bytes, or its retained gitlink record could falsely claim unchanged dependency identity.'
claim['falsify']['oracle'] += ' Byte-exact parent snapshot compared with the live published README, unchanged real Git index gitlink, complete unchanged fourth publisher in supplied isolation and independent current Knowledge/book/public checks.'
claim['falsify']['red_control'] += (' Actual canonical5 rejects the sole parent-untracked rgx/README.md binding. Unchanged fourth publisher rejects altered whole claim and missing fixture, then restores. A changed parent snapshot with amended immediate hash and a forged gitlink record each reject for the exact named semantic reason and restore; no submodule bytes or pin are mutated.')
assert 'rgx/README.md' not in paths, 'parent-owned snapshot replaces the external public input binding'
claim['durability'] = {'status': 'checked', 'mode': 'live', 'inputs': inputs}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072
if sys.argv[1:]:
    assert TARGET.read_bytes() == original and len(original) == 51535, 'replace only the preserved complete third publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact final readonly publication'
print('Parent-owned Knowledge/documentation publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
