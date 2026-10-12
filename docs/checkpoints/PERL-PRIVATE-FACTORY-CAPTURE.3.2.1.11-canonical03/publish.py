"""Current readonly publication; capture replaces only the complete frozen second record."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11'
PREFIX = 'docs/checkpoints/' + LEAF + '-canonical03/'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
for tail in ('review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual current readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 3
paths = set(review['inputs']) | set(evidence['inputs'])
paths.update(PREFIX + tail for tail in ('review.py', 'review.json', 'evidence.py', 'evidence.json', 'publish.py'))
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
    'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for p in sorted(paths)]
statement = ('Knowledge header list association retains the identical20-case/80-assertion fixture,16 original REDs/64 controls/all GREEN, '
    'source faults14/2/16 and original semantic controls. The complete second337-input/full79329 uncommitted publication replays '
    'unchanged from supplied bytes with two corruption controls; it retains the complete first136/full35512 publication and '
    'original534/full123810 callback proof. Current full1485 Markdown/1349 facts/six full header lineages and full book89/four controls pass. '
    'The unchanged primary public documentation classifier rejects the original private-table wording and passes its original70-file/40-reference '
    'contract after prose correction. Actual current private-label20 rows and two old cached-second-target REDs agree. Exact classification '
    'of eight immutable private/negative sources fixes14 executable-scan REDs;24 copied-path/changed-byte/added-selector controls still reject. '
    'Three current semantic forgeries reject for distinguishing reasons and restore. Exact original Knowledge/CI/storage/auditor sources remain unchanged.')
scope = ('Bounded Knowledge header association and canonical registration/documentation compatibility. Original observations, '
    'failed instruments, both whole uncommitted publications and actual canonical failures remain immutable; no accepted Git revision is fabricated. '
    'Current readers rederive complete source/capsule identities and semantic observations without refreshing historical runtime proof. '
    'The composed focused public result is retained as validation; its full project dependencies require the separate exact staged canonical receipt. '
    'No complete YAML/field-type, cross-toolchain rendering, full-private/parent, new syntax or other-backend admission. P3 block metadata projection '
    'remains .3.2.1.12 after pipeline before TYPE-REFERENCE-BOOK.')
claim = {'name': 'knowledge-list-association-and-registration', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py',
        'granularity': 'Full frozen337 bindings/79329 bytes retaining prior136/full35512 and accepted534/full123810; current1485 Markdown/1349 facts/six headers; primary public70/40 and eleven contrast mutations; twenty current private rows/two historical REDs; scanner8 exact inputs/14 original REDs/24 controls; book89/four controls; three semantic denials.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Detached header lists, stale local public teaching, cached private labels, edited/copied diagnostic sources, or forged semantic reports could appear verified.',
        'oracle': 'Unchanged public fixture/primary documentation classifier, complete byte capsules and isolated replay, native old/current real helper calls, exact whole-source scanner registration inverse, per-file copied/edited/new-selector denial, independent current header/semantic readers and full rendered-book controls.',
        'red_control': 'Original fixture16 REDs/source faults14/2/16 and original semantic controls survive unchanged. Both prior whole publications replay with actual corruption/restoration controls. Original table wording rejects at1547 through the unchanged classifier. Old private helper rejects each correct second label; current twenty rows pass. Original scanner reports14 positives;24 copied-path/changed-byte/added-selector variants reject and restore. Forged classifier count, native second-label result and scanner denial each fail for an exact named semantic reason, then restore. Complete book missing-summary/two marker/missing-include controls remain actual.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072
if sys.argv[1:]:
    original = (ROOT / (PREFIX + 'original-claim.json')).read_bytes()
    assert TARGET.read_bytes() == original and len(original) == 79329, 'replace only the completely preserved second publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('Current Knowledge/documentation publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
