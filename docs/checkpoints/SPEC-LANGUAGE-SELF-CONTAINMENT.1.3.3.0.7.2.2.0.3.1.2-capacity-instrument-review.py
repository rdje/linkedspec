"""Verify the exact reviewer correction and retained first rejection independently."""
from pathlib import Path
import base64
import copy
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-'
def sha(value): return hashlib.sha256(value).hexdigest()
error = json.loads((ROOT / (PREFIX + 'capacity-review-error.json')).read_bytes())
initial = (ROOT / (PREFIX + 'capacity-review-initial.py')).read_bytes()
corrected = (ROOT / (PREFIX + 'capacity-review.py')).read_bytes()
old = b"bad['actual']['commands'][0]['input_hashes_before'].pop(next(iter(before)))"
new = b"bad['actual']['commands'][0]['input_hashes_before'].pop(next(iter(bad['actual']['commands'][0]['input_hashes_before'])))"
observed = {'error': error, 'initial': initial, 'corrected': corrected,
            'initial_channels': {p: (ROOT / p).read_bytes() for p in error['retained_initial_control_channels']}}

def verify(value):
    e = value['error']
    assert e['complete'] and e['observed_exit_code'] == 1, 'actual incomplete initial rejection'
    assert e['producer_sha256'] == sha((ROOT / (PREFIX + 'capacity-retain-error.py')).read_bytes()), 'actual error retainer'
    assert sha(value['initial']) == e['original_source_sha256'], 'exact failed producer bytes'
    assert value['initial'].count(old) == 1 and value['initial'].count(new) == 0, 'original wrong dictionary selection'
    assert value['corrected'] == value['initial'].replace(old, new), 'sole exact guard-key correction'
    assert sha(value['corrected']) == e['corrected_source_sha256'], 'actual corrected producer bytes'
    raw = base64.b64decode(e['combined_log']['base64'], validate=True)
    assert len(raw) == e['combined_log']['bytes'] and sha(raw) == e['combined_log']['sha256'], 'actual complete combined error identity'
    assert b'KeyError:' in raw and b'capacity-controls.pl' in raw and b'line 178' in raw, 'actual distinguishing rejected mutation'
    assert set(value['initial_channels']) == set(e['retained_initial_control_channels']), 'complete initial control channels'
    for p, raw in value['initial_channels'].items():
        assert sha(raw) == e['retained_initial_control_channels'][p], 'retained actual initial channel bytes'
    command = json.loads(value['initial_channels'][PREFIX+'capacity-controls-command-initial.json'])
    assert command['exit_code'] == 0 and command['review_producer_sha256'] == sha(value['initial']), 'actual reached initial control recurrence'
    assert value['initial_channels'][PREFIX+'capacity-controls-initial.json'] == (ROOT / (PREFIX+'capacity-controls.json')).read_bytes(), 'unchanged exact actual authority observations'

verify(observed)
controls = []
for name in ('unrelated_reviewer_edit', 'wrong_first_exit', 'forged_error', 'lost_initial_channel', 'wrong_retainer'):
    bad = copy.deepcopy(observed)
    if name == 'unrelated_reviewer_edit': bad['corrected'] += b'\n'
    elif name == 'wrong_first_exit': bad['error']['observed_exit_code'] = 0
    elif name == 'forged_error': bad['error']['combined_log']['base64'] = base64.b64encode(b'PASS\n').decode()
    elif name == 'lost_initial_channel': bad['initial_channels'].pop(next(iter(bad['initial_channels'])))
    else: bad['error']['producer_sha256'] = '0'*64
    try: verify(bad)
    except AssertionError as problem: controls.append({'name': name, 'observed_red': str(problem)})
    else: raise AssertionError('instrument corruption admitted: '+name)
result = {'complete': True, 'producer_sha256': sha(Path(__file__).read_bytes()), 'controls': controls,
          'original_source_sha256': sha(initial), 'corrected_source_sha256': sha(corrected),
          'scope': 'Exact first used reviewer, actual combined failure and initial reached control channels; sole guard-key correction. Original distinct stdout/stderr are unavailable. No product or policy repair inferred from this instrument error.'}
(ROOT / (PREFIX+'capacity-instrument-verification.json')).write_text(json.dumps(result, indent=2)+'\n')
print('Exact original/corrected producer and actual first rejection retained; five instrument RED controls PASS.')
