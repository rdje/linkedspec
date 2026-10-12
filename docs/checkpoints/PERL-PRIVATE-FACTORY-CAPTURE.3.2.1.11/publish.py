"""Final current publication; --capture replaces only the fully frozen first record."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11'
PREFIX = 'docs/checkpoints/' + LEAF + '/'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
for tail in ('review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual final readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
assert (review['frozen_bindings'], review['frozen_claim_bytes'], review['registration_original_reds'], review['registration_denials']) == (136, 35512, 2, 12)
assert (review['current_markdown'], review['current_facts'], review['book_inputs'], review['book_controls']) == (1485, 1349, 89, 4)
assert len(evidence['rows']) == 2
paths = set(review['inputs']) | set(evidence['inputs'])
paths.update(PREFIX + tail for tail in ('review.py', 'review.json', 'evidence.py', 'evidence.json', 'publish.py'))
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
    'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for p in sorted(paths)]
statement = ('Knowledge header list association is repaired with the identical20-case/80-assertion public fixture: '
    '16 original REDs/64 controls become all GREEN, source faults fail14/2/16, and two original semantic controls reject and restore. '
    'The complete first136-input/full35512 uncommitted focused publication and original observations replay unchanged from '
    'supplied frozen bytes, with two actual isolated corruption/restoration controls. Original534 bindings/full123810 '
    'callback publication remain historical at328b11c5. Current full1485 Markdown/1349 facts/six route overlays and '
    'book89 inputs/four controls pass. Exact CI and managed-storage historical inverses pass two original-source REDs, '
    'twelve current registration denials, full isolated historical recovery and the actual29-owner managed-storage proof. '
    'Two final semantic report/header corruptions reject and restore.')
scope = ('Constrained Knowledge list association and exact CI/storage registration compatibility only. Empty-value '
    'keys own block items; scalar/inline values close association. The original first candidate, full publication, '
    'every136 input byte, native/fault/book/evidence observations and canonical1 failure remain immutable. It is an '
    'uncommitted candidate, not a fabricated accepted Git revision. Distinct final producers check current card/map/book '
    'identities and exact original-source normalization; historical runtime observations are never refreshed. The first '
    'mistaken source-fault control and first registration producer KeyError remain retained with their disclosed '
    'limitations. Block evidence/reverify projection remains P3 PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12 after pipeline, '
    'before TYPE-REFERENCE-BOOK. No complete YAML/field-type, new runtime, private/parent or other-backend admission '
    'is claimed. A later exact staged canonical receipt is mandatory for this infrastructure landing and is separate '
    'from the focused measurements. No immutable toolchain/cross-version rendering identity is claimed.')
claim = {'name': 'knowledge-list-association-and-registration', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py',
        'granularity': 'All20 named cases/80 assertions, original16 failures/64 controls; source faults14/2/16; complete136 frozen inputs/full35512 record and prior534/full123810; current1485 Markdown/1349 facts/six headers; book89/four controls; two original registration REDs/twelve current denials; actual full public recovery and29-owner managed storage; two final semantic controls.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Detached header lists, concealed malformed answers, missing or weakened CI/storage registrations, unrelated source drift, substituted historical observations or rehashed false semantic results may appear verified.',
        'oracle': 'Unchanged public fixture and complete original Git/input byte capsules; exact whole-source historical inverses; original and repaired registration functions with source-specific denials; full public isolated recovery/read-denied guard; independently parsed current headers, complete rendered book controls and deeper semantic reader denials.',
        'red_control': 'Original80 tests fail16 while64 controls pass; source faults fail14/2/16 and restore. First mistaken34-failure fault is retained. Original136 publication replays with changed full claim and missing fixture denials then exact restoration. Original CI/storage auditors reject current sources; six malformed CI and six malformed storage variants reject for exact recorded reasons. Final forged registration reason and orphan current header with amended immediate hash each reject semantically then restore. Original and final book four controls and original semantic two controls remain retained.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded final record', len(raw))
if sys.argv[1:]:
    original = (ROOT / (PREFIX + 'original-claim.json')).read_bytes()
    assert TARGET.read_bytes() == original and len(original) == 35512, 'replace only the preserved first publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact final readonly publication'
print('Final Knowledge publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
