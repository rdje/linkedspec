"""Readonly switch publication; --capture writes the bounded claim exactly once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.3.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for name in ('compose.py', 'faults-review.py'):
    result = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, (name, result.stderr)
review = json.loads((ROOT / (PREFIX + 'review-composed.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
population = review['population']
assert population['paired_assertions'] == 1641 and population['original_red'] == 273
assert population['source_faults'] == 15 and population['unobserved_source_faults'] == 1
paths = set(review['inputs']) | set(evidence['inputs']) | {
    PREFIX + name for name in ('review-composed.json', 'evidence.py', 'evidence.json',
        'evidence-data.json.gz', 'evidence-baseline.json', 'publish.py', 'compat.json',
        'fault-loop-tool-result.json', 'draft-review-tool-result.json')}
inputs = []
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    inputs.append({'path': path, 'sha256': sha(source.read_bytes()),
                   'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'})
statement = (
    'Six original ControlFlow switch-family required-validator returns now isolate actual argument '
    'normalizers in switch, case, default, endcase, endswitch and inline switch branches. Only these '
    'six return lines change. Public maps/references, eager validation, selected callbacks, native '
    'scalar contexts, argument aliases, values, once-only effects, successful errors, original fatal '
    'objects, switch counters/stacks and cold loading remain unchanged in every333 warm and297 cold '
    'ordinary observation with exact fresh-process recurrences. Identical1641 assertions retain273 '
    'original authority REDs/1368 passing controls and all current GREEN. Fifteen complete-source '
    'faults have observed distinguishing failures, including all six individual validator inverses '
    'and the exact whole-source inverse. A sixteenth copied-normalizer-array-return variant has no '
    'witness in this fixture and is explicitly unassessed. All85 supplied suites/317 inputs/26600 '
    'assertions pass with predecessor84 headers/plans/stderr unchanged. Nine coherent artifact '
    'denials/restorations, full Knowledge1486 Markdown/1349 facts/twelve overlays/8388218 card bytes, '
    'and two full book89-input/four-control epochs pass. The entire463-input/109061-byte '
    'prior publication and its actual readonly baseline remain historical at09000223f. Supplemental '
    'standard syntax/public Phase01035 and public selector/capability guard pass. Later ControlFlow, '
    'default registration, direct/rule calls, pipeline and independent admissions remain open.')
claim = {
    'name': 'controlflow-switch-required-callback-capture',
    'statement': statement,
    'scope': (
        'Controlled injected dependencies delegate actual MethodExpr parsing, not facade DSL execution. '
        'All504 observed required-normalizer calls are scalar. The original helper/algorithms/defaults '
        'and line count remain exact; the source oracle independently reconstructs just six validator '
        'return edits. Normalizer arrays remain the callback actual return objects in the ledger; the '
        'copied-container source mutant is observationally indistinguishable here, so exhaustive '
        'returned-container identity sensitivity is not claimed. Original sixteen-variant producer '
        'and all channels stay frozen, including its final failed effectiveness assertion. The '
        'distinct readonly faults-review.py reports15 effective/one unobserved. Original draft '
        'review.py stops on an obsolete inventory variable; review-final.py corrects that name without '
        'refreshing observations. Native/tied-map/error/source-fault witnesses cover observed paths, '
        'not every possible injected implementation. Full original/current Knowledge bytes are '
        'recoverable, eleven card bodies remain exact, and only framework facts change. Historical '
        'tar permissions are separate from actual filesystem modes. System Perl/stdlib/mdBook are '
        'read-only dependencies without immutable portable toolchain claims. Standard Phase0/public '
        'guard are supplemental without complete transitive input capsules. No public switch defect '
        'or complete private/helper/parent/canonical admission is claimed. The initial workflow '
        'paragraph still described if/while after its route moved to switch. Its whole465-input '
        'proof snapshot is retained; compose.py replays original review/artifact readers from those '
        'bytes and independently checks the corrected current book. Both actual render epochs remain '
        'distinct. first-proof-snapshot.py retains the exact capture fragment originally executed inline.'),
    'rederive': {
        'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly default). '
            'compose.py, faults-review.py, evidence.py, validation.py and both book readers are '
            'readonly by default; original review/artifacts require their first supplied snapshot. '
            'Capture/freezer/native/paired/consumer/book/Knowledge/standard '
            'writers are retired one-shot instruments.',
        'granularity': 'Each native input/333 warm/297 cold row and recurrence; every actual required '
            'callback frame and parent packet; full1641 TAP/273 original RED/1368 controls;15 effective '
            'full-source faults and one unobserved variant;85 ordered full supplied suites/317 inputs/'
            '26600 assertions; all463 prior bindings/full109061 bytes and actual baseline; full '
            'Knowledge/book custody and nine coherent artifact controls.',
        'result': statement,
    },
    'falsify': {
        'status': 'checked',
        'hypothesis': 'Required switch normalizers could borrow outer callback authority or donate '
            'equal-text child publication, copy aliases, reselect maps, mutate public references, '
            'repeat effects, localize errors, disable validation or eagerly load the private channel. '
            'Coherent immediate hashes could conceal changed native rows, parent donation, missing '
            'inverse failures, a rewritten prior publication, forged suite headers or missing teaching.',
        'oracle': 'Unchanged first native ordinary ledger and independently checked accepted Git '
            'source; identical paired fixture checks actual callback identity, own eligibility and '
            'parent publication separately. Independently reconstructed complete-source variants '
            'and exact273-failure inverse, predecessor full suite population, fixed accepted Git '
            'claim census and independently enumerated/rendered book sources distinguish competing '
            'mechanisms. The sixteenth array-copy hypothesis has no fixture witness and remains '
            'outside the sensitivity claim.',
        'red_control': 'Original273 of1641 fail before the six edits; all1641 pass afterward. '
            'Fifteen syntax-valid complete-source variants fail273,48,57,42,33,36,66,237,446,570,843,'
            '2,12,594,24 assertions; the final array-copy variant passes1641 and is disclosed. '
            'Nine coherently rehashed artifacts fail deeper native-alias, parent-packet, inverse, '
            'prior-claim, suite-header, rendered-reference/inline/stack or runtime-path oracles and '
            'restore exact original bytes/modes and PASS. Book controls retain missing SUMMARY, '
            'two missing rendered markers and a missing recursive include.',
    },
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}
record = {'version': 1, 'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.5.3', 'claims': [claim]}
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value
print('ControlFlow switch publication PASS:', len(inputs), 'live inputs;', len(value), 'bytes')
