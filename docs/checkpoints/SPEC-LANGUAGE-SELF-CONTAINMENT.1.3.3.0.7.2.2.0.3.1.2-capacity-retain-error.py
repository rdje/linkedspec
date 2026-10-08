"""Retain the actual first reviewer failure and correct only its guard-key selection."""
from pathlib import Path
import base64
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-'
source_path = PREFIX + 'capacity-review.py'
raw = (ROOT / source_path).read_bytes()
error = (ROOT / '.linkedspec-data/logs/replacement-note-capacity-review.log').read_bytes()
assert b"KeyError: 'docs/checkpoints/" in error and b'capacity-controls.pl' in error
old = b"bad['actual']['commands'][0]['input_hashes_before'].pop(next(iter(before)))"
new = b"bad['actual']['commands'][0]['input_hashes_before'].pop(next(iter(bad['actual']['commands'][0]['input_hashes_before'])))"
assert raw.count(old) == 1 and raw.count(new) == 0
corrected = raw.replace(old, new)
def sha(value): return hashlib.sha256(value).hexdigest()
initial = PREFIX + 'capacity-review-initial.py'
assert not (ROOT / initial).exists()
(ROOT / initial).write_bytes(raw)
retained = {}
for name in ('capacity-controls-command.json', 'capacity-controls.json'):
    value = (ROOT / (PREFIX + name)).read_bytes()
    target = PREFIX + name.replace('.json', '-initial.json')
    assert not (ROOT / target).exists()
    (ROOT / target).write_bytes(value)
    retained[target] = sha(value)
record = {'complete': True, 'producer_sha256': sha(Path(__file__).read_bytes()),
          'actual_first_command': 'bash tools/run_python_project_data.sh ' + source_path + ' > .linkedspec-data/logs/replacement-note-capacity-review.log 2>&1',
          'observed_exit_code': 1, 'original_used_path': source_path, 'retained_source_path': initial,
          'original_source_sha256': sha(raw), 'corrected_source_sha256': sha(corrected),
          'combined_log': {'base64': base64.b64encode(error).decode(), 'bytes': len(error), 'sha256': sha(error)},
          'retained_initial_control_channels': retained,
          'scope': 'Actual first shell-redirected combined error log and exact used source; distinct original stdout/stderr are unavailable. The initial reviewer is incomplete at its missing-input mutation. Sole correction selects the key from the actual publication guard dictionary; no product, history or policy change.'}
(ROOT / (PREFIX + 'capacity-review-error.json')).write_text(json.dumps(record, indent=2) + '\n')
(ROOT / source_path).write_bytes(corrected)
print('Exact failed source/error/initial control channels retained; sole guard-key selection corrected.')
