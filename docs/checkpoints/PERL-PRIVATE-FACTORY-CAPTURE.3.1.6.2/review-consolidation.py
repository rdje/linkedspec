"""Independently check the original input remapping and lossless receiver-card consolidation."""
import base64
import hashlib
import json
import runpy
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FOLDER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2/'
PUBLISHER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-publish-claim.py'
SCALAR = 'docs/knowledge/perl-scalar-receiver-required-capture.md'
ARRAY = 'docs/knowledge/perl-array-receiver-required-capture.md'
SOURCE = FOLDER + 'review-consolidation.py'
TARGET = ROOT / (FOLDER + 'consolidation-review.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
used = set()


def read(path):
    used.add(path)
    return (ROOT / path).read_bytes()


preserved = json.loads(read(FOLDER + 'preservation.json'))
original_raw = read(FOLDER + 'original-claim.json')
original = json.loads(original_raw)
assert sha(original_raw) == preserved['original_files']['original-claim.json']['sha256'], 'original claim identity'
assert len(original_raw) == 77181 and original['owner'] == preserved['owner']
entries = original['claims'][0]['durability']['inputs']
assert len(entries) == preserved['original_inputs'] == 323
remap = {PUBLISHER: FOLDER + 'original-publisher.py', SCALAR: FOLDER + 'original-scalar-card.md'}
assert set(remap).issubset({entry['path'] for entry in entries})
for entry in entries:
    assert sha(read(remap.get(entry['path'], entry['path']))) == entry['sha256'], 'preserved original input'
for name, entry in preserved['original_files'].items():
    assert sha(read(FOLDER + name)) == entry['sha256'], 'protected original file'

read(FOLDER + 'fold-card.py')
fold = runpy.run_path(str(ROOT / (FOLDER + 'fold-card.py')))
old_array, old_scalar, combined = fold['expected']()
assert read(ARRAY) == combined, 'combined receiver card identity'
assert read(FOLDER + 'original-array-card.md') == old_array
assert read(FOLDER + 'original-scalar-card.md') == old_scalar
assert not (ROOT / SCALAR).exists(), 'redundant new card remains'
fold_report = json.loads(read(FOLDER + 'fold.json'))
assert fold_report['result'] == 'PASS' and fold_report['producer_sha256'] == sha(read(FOLDER + 'fold-card.py'))
assert fold_report['old_array_sha256'] == sha(old_array)
assert fold_report['original_scalar_sha256'] == sha(old_scalar)
assert fold_report['combined_sha256'] == sha(combined)
assert (fold_report['old_questions'], fold_report['new_questions'], fold_report['combined_questions']) == (7, 6, 13)

replay = json.loads(read(FOLDER + 'original-replay.json'))
assert replay['result'] == 'PASS' and replay['producer_sha256'] == sha(read(FOLDER + 'replay-original.py'))
assert replay['original_claim_sha256'] == sha(original_raw)
assert replay['original_publisher_sha256'] == sha(read(FOLDER + 'original-publisher.py'))
assert replay['original_card_sha256'] == sha(old_scalar) and replay['original_binding_count'] == 323
expected_inputs = {entry['path']: entry['sha256'] for entry in entries}
expected_inputs['docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2.json'] = sha(original_raw)
assert replay['inputs'] == expected_inputs and len(expected_inputs) == 324
changed = old_scalar + b'\n'
assert base64.b64decode(replay['changed_card_base64'], validate=True) == changed
assert [row['label'] for row in replay['rows']] == ['healthy', 'changed-card', 'restored']
for row in replay['rows']:
    damaged = row['label'] == 'changed-card'
    assert row['command'] == ['python3', PUBLISHER] and row['unchanged']
    assert row['inputs'] == (dict(expected_inputs, **{SCALAR: sha(changed)}) if damaged else expected_inputs)
    error = base64.b64decode(row['stderr_base64'], validate=True)
    output = base64.b64decode(row['stdout_base64'], validate=True)
    if damaged:
        assert row['returncode'] != 0 and b'required scalar publication drift' in error
    else:
        assert row['returncode'] == 0 and not error and b'323 live inputs; 77181 bytes;' in output

command = ['python3', FOLDER + 'replay-original.py']
actual = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
assert actual.returncode == 0 and not actual.stderr, 'actual original replay review'
read(SOURCE)
report = {'result': 'PASS', 'producer_sha256': sha(read(SOURCE)),
          'original_bindings': 323, 'unchanged_live_originals': 321, 'relocated_originals': remap,
          'original_claim_sha256': sha(original_raw), 'combined_card_sha256': sha(combined),
          'old_questions': 7, 'new_questions': 6, 'combined_questions': 13,
          'actual_replay_review': {'command': command, 'returncode': actual.returncode,
                                  'stdout_base64': base64.b64encode(actual.stdout).decode(),
                                  'stderr_base64': base64.b64encode(actual.stderr).decode()},
          'inputs': {path: sha((ROOT / path).read_bytes()) for path in sorted(used)},
          'scope': 'Every original323 input hash remains exact:321 current files plus two verified relocations. Original77181-byte claim/publisher/card and actual supplied original publication healthy/RED/restored channels remain recoverable. Both fact bodies and all13 questions are independently reconstructed from accepted Git and the original scalar card. Native/runtime/TAP/fault/consumer/book/evidence observations and registry limits are unchanged.'}
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot consolidation review already retained'
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(TARGET.read_bytes()) == report, 'consolidation review drift'
print('Consolidation review PASS: original323 hashes/321 unchanged/two relocations; both bodies/all13 questions')
