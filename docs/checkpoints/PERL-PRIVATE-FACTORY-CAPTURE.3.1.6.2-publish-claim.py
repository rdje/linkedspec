"""Guarded metadata closure over the exact retained original323-input publication."""
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
FOLDER = 'docs/checkpoints/' + LEAF + '/'
SOURCE = PREFIX + 'publish-claim.py'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
ARRAY = 'docs/knowledge/perl-array-receiver-required-capture.md'
SCALAR = 'docs/knowledge/perl-scalar-receiver-required-capture.md'
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()

for producer in (PREFIX + 'review.py', PREFIX + 'evidence.py', PREFIX + 'compatibility/run.py',
                 FOLDER + 'review-consolidation.py', FOLDER + 'check-consolidation.py'):
    result = subprocess.run(['python3', producer], cwd=ROOT, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, check=False)
    assert result.returncode == 0 and not result.stderr, ('actual readonly closure', producer, result.stderr)
original_raw = (ROOT / (FOLDER + 'original-claim.json')).read_bytes()
original = json.loads(original_raw)
preservation = json.loads((ROOT / (FOLDER + 'preservation.json')).read_bytes())
assert original['owner'] == preservation['owner'] == LEAF and len(original_raw) == 77181
assert sha(original_raw) == preservation['original_files']['original-claim.json']['sha256']
review = json.loads((ROOT / (FOLDER + 'consolidation-review.json')).read_bytes())
evidence = json.loads((ROOT / (FOLDER + 'consolidation-evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
assert (review['original_bindings'], review['unchanged_live_originals'], review['combined_questions']) == (323, 321, 13)
assert len(evidence['controls']) == 2
assert json.loads((ROOT / (FOLDER + 'consolidation-evidence-reached.json')).read_bytes()) == {
    'healthy': evidence['healthy'], 'rows': evidence['controls']}
entries = original['claims'][0]['durability']['inputs']
assert len(entries) == 323
remap = {SOURCE: FOLDER + 'original-publisher.py', SCALAR: FOLDER + 'original-scalar-card.md'}
assert review['relocated_originals'] == remap
mapped = []
for entry in entries:
    path = remap.get(entry['path'], entry['path'])
    assert sha((ROOT / path).read_bytes()) == entry['sha256'], 'every original hash retained'
    mapped.append(dict(entry, path=path))
paths = {entry['path'] for entry in mapped} | {SOURCE, ARRAY}
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / FOLDER).rglob('*') if p.is_file())
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t') else 'input'}
          for path in sorted(paths)]
lookup = {entry['path']: entry for entry in inputs}
assert all(lookup[entry['path']] == entry for entry in mapped), 'original roles and byte identities retained'
assert not (ROOT / SCALAR).exists()
metadata = ('The first normal commit hook rejected the new Knowledge card at1351/1350 files. Its exact original77181-byte '
            'claim, actual publisher and scalar card remain tracked outside the bounded card collection. All323 original hashes '
            'remain exact:321 current files and two byte-identical relocations. Actual original publication replays PASS in its '
            '323-input logical state, rejects a changed card, and restores PASS. Both original card bodies and all13 questions '
            'are independently reconstructed in the existing related receiver card. Two additional actual metadata RED/restorations '
            'reject a missing question and a forged original binding beyond its updated immediate claim-SHA record. Registry limits, '
            'native/runtime/TAP/fault/consumer/book/evidence instruments and observations remain unchanged; only publication metadata '
            'and Knowledge routing are repaired. The complete original claim fields remain byte-exact in original-claim.json; this '
            'closure appends disclosure and binds the additional preserved producers, data and current combined card.')
data = copy.deepcopy(original)
primary = data['claims'][0]
assert primary['name'] == 'scalar-required-callback-isolation' and primary['durability']['mode'] == 'live'
primary['scope'] += ' ' + metadata
primary['rederive']['command'] = ('bash tools/run_python_project_data.sh ' + SOURCE + '; independent original replay, '
    'review-consolidation.py and check-consolidation.py under ' + FOLDER + ' with that wrapper. Defaults readonly; '
    'capture/apply/freezer/fault/evidence writers are one-shot. Original logical publication inputs are supplied from retained bytes.')
primary['rederive']['granularity'] += ' Every323 original physical/logical binding, exact original77181-byte claim/publisher/card, both fact bodies/all13 questions, original publication healthy/changed/restored channels and two additional metadata control populations/channels.'
primary['rederive']['result'] += ' ' + metadata
primary['falsify']['hypothesis'] += ' Metadata consolidation might drop a fact, refresh an original producer/hash or conceal the original uncommitted publication boundary.'
primary['falsify']['oracle'] += ' Exact original full claim/publisher/card, actual original publication in supplied logical inputs, independently reconstructed combined card from accepted Git and original scalar bytes, and every original323 hash with only two byte-identical path relocations.'
primary['falsify']['red_control'] += ' The original publisher rejects the changed-card input and exact restoration passes. Two new actual reviewer RED/restorations reject a missing receiver question by full card reconstruction and a forged original native binding beyond the updated immediate original-claim SHA record. Every reached channel and changed byte is retained before assertions.'
primary['durability']['inputs'] = inputs
assert data['claims'][1:] == original['claims'][1:], 'original historical claims unchanged'
assert primary['statement'] == original['claims'][0]['statement'], 'original runtime measurement statement unchanged'
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('bounded publication size', len(serialized))
if sys.argv[1:]:
    assert TARGET.read_bytes() == original_raw, 'one-shot metadata closure requires the exact original publication'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'metadata closure drift'
print('Scalar publication metadata closure PASS:', len(inputs), 'live inputs;', len(serialized),
      'bytes; original323 exact; both bodies/13 questions; original card RED and two metadata RED/restorations')
