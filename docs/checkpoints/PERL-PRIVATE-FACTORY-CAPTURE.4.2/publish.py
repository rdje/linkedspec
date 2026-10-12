"""Readonly optional FlowExpr publication; --capture writes the bounded claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.2/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.2.json'
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
for tail in ['review.py', 'evidence-recovery.py']:
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly optional FlowExpr proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
recovery = json.loads((ROOT / (PREFIX + 'evidence-recovery.json')).read_bytes())
assert review['result'] == recovery['result'] == 'PASS'
assert (review['paired_assertions'], review['original_red'], review['original_controls'],
        review['consumer_suites'], review['consumer_inputs'], review['consumer_assertions']) == (762, 154, 608, 78, 263, 20232)
paths = set(review['inputs']) | set(recovery['sources'])
paths.update(PREFIX + tail for tail in ['review.json', 'evidence-recovery.json', 'publish.py'])
inputs = []
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink(), ('regular retained artifact input', path)
    inputs.append({'path': path, 'sha256': sha(source.read_bytes()),
                   'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'})
statement = (
    'Both optional kind invocations in FlowExpr emptiness lowering now have separate private boundaries. '
    'An actual unblessed CODE retains its own registration; native symbolic, blessed-CODE and amp-callable '
    'second selections stay opaque. Original two map reads, selection timing, name guards, match argument '
    'write rejection, scalar callback context under scalar/list/void owners, values, coercions, once-only '
    'effects, successful errors, fatal identity, public maps and cold loading remain exact. Original '
    'function and native diagnostic line locations remain unchanged. First100-input native captures '
    'retain150 warm/150 cold rows with exact fresh-process recurrences before expectations or edits. '
    'The final identical762 assertions have154 original authority REDs/608 controls and all GREEN. '
    'Fourteen complete-source faults are effective, including the exact154-failure inverse. All78 '
    'ordered supplied suites/263 inputs/20232 assertions pass. Six deeper artifact corruption controls '
    'reject and restore; their unchanged original reader replays with an exact captured pending overlay '
    'and two recovery-integrity controls. Full original451 bindings/112004-byte publication and actual '
    'readonly baseline are preserved at accepted708c1afa04bb10aeacbdaf0a8133a95f380df434. Complete '
    'Knowledge1485 Markdown/1349 facts/seven overlays retains8384530 bytes under unchanged8388608 '
    'and every member limit. Full book89 inputs/four controls pass. Supplemental strict-vars/standard '
    'syntax, public Phase01035 and composed public guard pass. Defaults and independent admissions remain open.'
)
claim = {
    'name': 'optional-flowexpr-kind-private-boundaries',
    'statement': statement,
    'scope': (
        'Two guarded FlowExpr::_lower_is_empty_expr invocation seams and one appended private selector only. '
        'Required callback bindings, default maps/EmitContext, dispatch, parser/output mapping and pipeline '
        'activation are unchanged. Every native row/recurrence, complete TAP name/number, full source fault, '
        'consumer header/plan, original publication/binding, Knowledge member/header/route and book input '
        'is independently joined. The first source candidate failed48 diagnostic-line comparisons; the '
        'second failed266 checks because its if-condition lexical was unavailable to the remaining '
        'condition. Both whole sources/producers/channels and strict-vars/minimal scope diagnostics remain '
        'immutable. Only Unicode test-name display changes between the original/final fixture; the same154 '
        'original failures are independently reproduced. The original artifact inventory conservatively '
        'included an in-flight compat.json which its actual preflight never read; its exact1169 pending '
        'bytes and original manifest are retained, and unchanged-reader supplied recovery is separate from '
        'the current completed standard proof. No runtime observation is refreshed. System Perl/stdlib '
        'and mdBook are reused read-only without an immutable portable toolchain claim. Standard Phase0 '
        'and composed guard lack complete transitive input capsules and are supplemental; complete '
        'helper/private Phase0/parent/canonical and other-backend admission retain their existing owners.'
    ),
    'rederive': {
        'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly default). '
                   'review.py, book-review.py, validation.py and evidence-recovery.py under the same '
                   'wrapper/prefix are readonly. The original evidence.py requires its exact supplied '
                   'pending view. All capture, observation, paired, source-fault and preservation writers are retired.',
        'granularity': 'All300 first/current native rows and exact recurrences over100 complete parent inputs; '
                       'identical final762 TAP/154 original RED/608 controls;14 complete syntax-valid source '
                       'faults; complete78 ordered consumer plans/263 supplied inputs/20232 assertions; '
                       'six actual deeper artifact denials/restorations plus unchanged reader supplied '
                       'replay/two integrity controls; full accepted451 bindings/112004 publication and '
                       'baseline; all1485 Knowledge sources/1349 facts/seven overlays/member and8384530 '
                       'collection bytes under unchanged8388608; all89 book sources/four actual controls. '
                       'Supplemental strict-vars/standard syntax/1035 public Phase0 and composed public guard.',
        'result': statement,
    },
    'falsify': {
        'status': 'checked',
        'hypothesis': 'An optional callback could inherit its parent frame or donate equal-text publication; '
                      'names could receive actual CODE authority, or binding could alter two-read selection, '
                      'native aliases/effects/errors/diagnostic lines, lazy loading or public maps. A coherent '
                      'immediate rehash could conceal forged authority, inverse, consumer, book or source inputs.',
        'oracle': 'Unchanged first native complete observations and source, independently computed actual '
                  'CODE-versus-opaque frame expectations and explicit parent/known-child packet oracles; '
                  'same final fixture against accepted/current full source; exact original source inverse; '
                  'fixed-Git whole original claim and runtime namespace, complete ordered consumer TAP, '
                  'rendered book markers and exact Knowledge source/registry population.',
        'red_control': 'First762 TAP has154 authority REDs and608 passing compatibility controls. All14 '
                       'full-source variants fail154/77/77/56/24/156/184/8/156/450/2/284/48/266 assertions; '
                       'the sole full inverse exactly restores all original failure names/numbers. Both '
                       'rejected implementation candidates are retained; current strict-vars compilation '
                       'and all762 checks pass. Six coherently rehashed artifact forgeries reject for '
                       'actual selected authority, hidden original inverse, whole publication, ordered '
                       'consumer header, rendered teaching and substituted runtime-input reasons, then '
                       'restore exact PASS. The unchanged original artifact reader rejects altered pending '
                       'bytes and a missing real fixture in supplied recovery, then restores. Four book '
                       'controls cover missing SUMMARY, both removed rendered markers and missing include.',
    },
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}
record = {'version': 1, 'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.4.2', 'claims': [claim]}
raw = (json.dumps(record, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded optional FlowExpr publication', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot bounded claim publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly optional FlowExpr publication'
print('Optional FlowExpr publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
