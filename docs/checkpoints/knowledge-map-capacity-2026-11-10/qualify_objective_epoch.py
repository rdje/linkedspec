"""Replace inline physical bindings with their complete replayed artifact epoch."""
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
RECORD = ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'

data = json.loads(gzip.decompress((HERE / 'objective-frozen-epoch.json.gz').read_bytes()))
original = base64.b64decode(data['original_record']['base64'], validate=True)
assert hashlib.sha256(original).hexdigest() == data['original_record']['sha256']
assert RECORD.read_bytes() == original, 'one-shot publication from exact original declaration'
record = json.loads(original)
prior = copy.deepcopy(record)
claim = record['claims'][4]
assert claim['durability']['inputs'] == data['declared_inputs']
observed = json.loads((ROOT / '.linkedspec-data/objective-frozen-review.stdout.log').read_bytes())
assert observed['result'] == 'PASS' and observed['exact_inline_inputs'] == 231 and observed['logical_sources'] == 232
assert (ROOT / '.linkedspec-data/objective-frozen-review.stderr.log').read_bytes() == b''
result_path = HERE / 'objective-frozen-review-result.json'
assert not result_path.exists()
result_path.write_text(json.dumps(observed, indent=2, sort_keys=True) + '\n')
names = ('objective-frozen-epoch.json.gz', 'objective-frozen-epoch-result.json',
         'objective_frozen_epoch_review.py', 'freeze_objective_epoch.py',
         'qualify_objective_epoch.py', 'objective-frozen-review-result.json',
         'objective-frozen-first-review.py.gz', 'objective-frozen-first-stderr.log.gz')
claim['durability'] = dict(status='checked', mode='live', inputs=[
    dict(path=str((HERE / name).relative_to(ROOT)),
         sha256=hashlib.sha256((HERE / name).read_bytes()).hexdigest(),
         role='producer' if name.endswith('.py') else 'input') for name in names])
claim['scope'] += (' Subsequent fixture evolution preserves this entire uncommitted logical epoch: '
    'all231 original declared bodies/roles/modes and the complete nine-claim declaration are retained, '
    'including a nested exact unit producer (232 logical sources). Both unchanged readonly reviewers '
    'execute successfully from a same-volume provided tree using the real read-only Git object database. '
    'This is a frozen artifact epoch, not a historical Git capture at728. The first provided-root attempt '
    'omits the nested unit producer and fails before admission; its actual source/error are retained. '
    'The qualified replay seeds that already-retained body, without refreshing any old input hash.')
claim['rederive']['command'] = ('bash tools/run_python_project_data.sh '
    'docs/checkpoints/knowledge-map-capacity-2026-11-10/objective_frozen_epoch_review.py')
claim['rederive']['result'] += ' Frozen logical epoch replay: PASS, both unchanged reviewers; 231 inline/232 logical sources; no source write.'
assert all(record['claims'][i] == prior['claims'][i] for i in range(9) if i != 4)
raw = (json.dumps(record, indent=2) + '\n').encode()
assert len(raw) <= 131072
RECORD.write_bytes(raw)
print(json.dumps(dict(result='PASS', bytes=len(raw), claims=len(record['claims']), preserved_inline_inputs=231), sort_keys=True))
