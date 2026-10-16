"""Readonly exact single-statement publication; --capture writes the claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.2/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for name in ('review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly single-statement proof', name, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 9
population = review['population']
assert tuple(population[key] for key in (
    'required_validators', 'required_roles', 'native_inputs', 'warm_rows', 'cold_rows',
    'paired_assertions', 'original_red', 'passing_controls', 'source_fault_cases',
    'distinct_fault_sources', 'consumer_suites', 'consumer_inputs', 'consumer_assertions',
    'knowledge_bytes')) == (1, 1, 100, 87, 79, 439, 94, 345, 10, 9, 83, 298, 23209, 8387900)
paths = set(review['inputs']) | set(evidence['inputs']) | {
    PREFIX + name for name in ('review.json', 'evidence.py', 'evidence.json',
        'evidence-data.json.gz', 'evidence-baseline.json', 'publish.py', 'compat.json')}
inputs = []
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    inputs.append({'path': path, 'sha256': sha(source.read_bytes()),
        'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'})
statement = (
    'ControlFlow single-statement lowering privately binds its selected trim through one original required '
    'validator return. Actual CODE identity and own registration replace enclosing eligibility without '
    'changing public callback maps/references, native scalar context, writable local trim slots, original '
    'diagnostic lines, guard/trace order, selected references, ordinary values, once-only effects, errors '
    'or fatal objects. Mutation changes the lowered path while the caller remains intact. First native '
    '100-input observation retains87 warm/79 cold rows with exact fresh-process recurrences before '
    'assertions/source edits; all166 current ordinary rows match. All379 warm/355 cold supplied dependency '
    'calls are scalar; cold SourceEmissions and Trace remain unloaded. Closure prefixes, direct control, '
    'typed reconstruction/fallback and shallow rule-candidate state stay native. Rejected candidate '
    'counters/stack-entry changes do not commit; nested references stay shared, and a nonempty changed '
    'zero result commits. Tied map reads preserve eager original selection. Identical439 assertions '
    'retain94 original authority REDs/345 controls and all GREEN. Ten effective full-source fault cases '
    'have nine byte variants because inverse and sole-validator bypass coincide; inverse reproduces '
    'every original94 failure name/number. All83 ordered supplied suites/298 inputs/23209 assertions '
    'pass with unchanged predecessor headers/plans/stderr. Nine coherent artifact corruptions reject '
    'beyond immediate hashes and restore exact supplied bytes/modes. Whole prior461-input/110981-byte '
    'publication, its actual readonly baseline and all original bindings remain historical at '
    'c7570b71642e1889ab03ee07c29273dabdf16989. Full Knowledge1485 Markdown/1349 facts/ten overlays/8387900 '
    'bytes and book89/four actual controls pass without card/budget growth. Supplemental strict-vars, '
    'standard syntax, public Phase01035 and composed public guard pass. Later ControlFlow/direct/rule '
    'defaults/pipeline and independent helper/private/parent/canonical admissions remain open.')
claim = {
    'name': 'controlflow-single-statement-required-trim-capture',
    'statement': statement,
    'scope': (
        'Only _lower_flow_branch_single_statement required-validator return changes; the existing private '
        'helper, five prior bindings, AST/trace implementation, direct dispatch, rule application, '
        'candidate clone/commit, closures and remaining sixteen raw validators stay exact. The probe '
        'uses injected callbacks with real MethodExpr parsing. Its typed-empty case has a whitespace '
        'splitter that returns a blank statement, so native nested lowering declines and retains the '
        'original typed reference; no facade typed-success claim follows. Global helper source faults '
        'also touch previously bound nested parser/head aliases. The18-failure argument-copy fault is '
        'not an independent observable identity claim for the single private local expression. All '
        'historical bindings resolve at accepted Git; current runtime inputs remain bound by new '
        'capsules. Fixed explicit preflight inventory excludes its own result and supplemental '
        'compat.json; final publication separately binds the completed standard record. Baseline and '
        'each reached denial/restoration channel are retained before artifact adjudication. Complete '
        'dated Knowledge original bytes/modes and ten overlays retain one framework-body addition, '
        'nine unchanged bodies and unchanged limits. Three rendered-book semantic controls cover local '
        'trim, zero-rule and shallow-candidate teaching. System Perl/stdlib/mdBook are reused read-only '
        'without immutable portable toolchain claims. Public Phase0/guard are supplemental without '
        'complete transitive input capsules. No broader runtime/private/parent/canonical admission.'),
    'rederive': {
        'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly default). '
            'review.py, evidence.py, book-review.py and validation.py are readonly by default. Native, '
            'paired, fault, consumer, Knowledge, book, standard and artifact capture writers are '
            'one-shot and retired; original observations and actual producers remain immutable.',
        'granularity': 'Every100 original/current native input and87+79 row; actual scalar callback '
            'identity/registration, local writable slot/caller preservation, tied reads, closures and '
            'candidate contexts; complete439 TAP/94 original RED/345 controls; ten full-source faults '
            'and exact inverse;83 ordered full consumer suites/298 inputs/23209 assertions; nine '
            'coherent artifact denials/restorations; whole original461 bindings/publication/baseline; '
            'dated1485 Knowledge Markdown/1349 facts/ten overlays; full89 book inputs/four controls. '
            'Supplemental strict-vars/standard syntax/1035 public Phase0/composed public guard.',
        'result': statement,
    },
    'falsify': {
        'status': 'checked',
        'hypothesis': 'A selected trim could inherit parent authority, hide its CODE identity, repeat '
            'effects, localize errors, replace public maps, delay tied selection, disable validation '
            'or eagerly load private channels. Coherent artifact hashes could hide changed native '
            'aliases/parent packets/inverse failures, whole accepted claims, consumer populations, '
            'rendered teaching or runtime paths.',
        'oracle': 'First complete original-source native input/channel ledger and accepted Git '
            'definitions; unchanged fixture independently checks actual invocation identity and '
            'registration plus parent/child packets. Complete original/current ordinary rows retain '
            'arguments/maps/effects/errors and branch state. Exact full-source inverse, syntax-valid '
            'fault TAP, fixed predecessor command/header/plan/stderr population, full Knowledge '
            'custody, independently enumerated book config/source/includes and rendered controls '
            'provide distinguishing comparisons.',
        'red_control': 'Identical original439 observes94 authority REDs/345 controls before the '
            'one-line validator change and all439 GREEN afterward. Ten complete-source fault cases '
            'reach439 with failure counts94,94,86,18,156,250,2,6,160,4; the inverse reproduces every '
            'original failure, and inverse/bypass share one source byte variant. Nine coherent '
            'artifact forgeries reject local slot type, parent donation, a hidden inverse failure, '
            'whole accepted publication, consumer header, rendered local/zero/shallow teaching and '
            'same-byte wrong runtime path. Each restores exact bytes/modes and PASS. Hidden inverse '
            'also adjusts stderr block/summary/exit; rendered forgeries refresh their review hash '
            'before semantic rejection. Four actual book controls retain missing SUMMARY, removed '
            'workflow/current target markers and missing recursive include.',
    },
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}
record = {'version': 1, 'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.5.1.2', 'claims': [claim]}
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072, ('bounded single-statement publication', len(value))
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value, 'exact current readonly single-statement publication'
print('ControlFlow single-statement publication PASS:', len(inputs), 'live inputs;', len(value), 'bytes')
