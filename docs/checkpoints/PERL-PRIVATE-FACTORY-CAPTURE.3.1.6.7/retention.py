"""Preserve original369-input publication; default readonly, --capture is one-shot."""
import base64
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DIR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7/'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7.json'
EXPECTED_ORIGINAL = '3948b9a84e4dba1e018643dffc667149ca1eb7176d256726fed708b273026a7d'
CHANGED = [PREFIX + 'book-correction.json', PREFIX + 'review.py',
           'docs/knowledge/guarded-ast-change-history-capacity.md']
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()
assert sys.argv[1:] in ([], ['--capture'])
if sys.argv[1:]:
    assert not (ROOT / (DIR + 'retention.json')).exists()
    original = read(CLAIM)
    assert sha(original) == EXPECTED_ORIGINAL
    entries = json.loads(original)['claims'][0]['durability']['inputs']
    assert len(entries) == 369
    for entry in entries:
        assert sha(read(entry['path'])) == entry['sha256'], 'preserve before any bound write'
    supplied = {p: {'base64': base64.b64encode(read(p)).decode(), 'bytes': len(read(p)),
                    'sha256': sha(read(p))} for p in CHANGED}
    (ROOT / (DIR + 'original-claim.json')).write_bytes(original)
    raw = (json.dumps(supplied, indent=2) + '\n').encode()
    (ROOT / (DIR + 'original-inputs.json')).write_bytes(raw)
    report = {'producer_sha256': sha(Path(__file__).read_bytes()),
        'original_claim_sha256': sha(original), 'original_inputs_sha256': sha(raw),
        'original_bindings': 369, 'relocations': CHANGED,
        'scope': 'All369 first-publication inputs/full claim are verified before writes. '
            'Three changing inputs relocate in exact decoded form;366 other bytes stay current. '
            'The original94175-byte publication, publisher and observations remain exact. '
            'This is byte-bound preservation, not a fresh original-publication execution. '
            'The complete current proof is separately rerun after the encoding repair.'}
    (ROOT / (DIR + 'retention.json')).write_text(json.dumps(report, indent=2) + '\n')
original = read(DIR + 'original-claim.json')
assert sha(original) == EXPECTED_ORIGINAL, 'frozen original publication identity'
record = json.loads(original)
entries = record['claims'][0]['durability']['inputs']
assert len(entries) == len({e['path'] for e in entries}) == 369
metadata = json.loads(read(DIR + 'retention.json'))
assert metadata['producer_sha256'] == sha(Path(__file__).read_bytes())
assert metadata['original_claim_sha256'] == sha(original)
raw = read(DIR + 'original-inputs.json')
assert metadata['original_inputs_sha256'] == sha(raw)
supplied = json.loads(raw)
assert set(supplied) == set(CHANGED) and metadata['relocations'] == CHANGED
assert metadata['original_bindings'] == 369
for entry in entries:
    path = entry['path']
    if path in supplied:
        item = supplied[path]
        content = base64.b64decode(item['base64'], validate=True)
        assert item['bytes'] == len(content) and item['sha256'] == sha(content)
    else:
        content = read(path)
    assert sha(content) == entry['sha256'], 'original369 input hash: ' + path
print('Original369 publication preservation PASS: full94175-byte claim/three exact decoded relocations/366 unchanged inputs; no fresh original replay')
