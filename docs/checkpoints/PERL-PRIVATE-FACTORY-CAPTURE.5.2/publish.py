"""Readonly exact if/while publication; --capture writes the bounded claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.2/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.2.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for name in ('review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly if/while proof', name, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 9
population = review['population']
assert tuple(population[key] for key in (
    'required_validators', 'required_roles', 'native_inputs', 'current_native_inputs', 'warm_rows', 'cold_rows',
    'paired_assertions', 'original_red', 'passing_controls', 'source_faults', 'consumer_suites',
    'consumer_inputs', 'consumer_assertions', 'knowledge_bytes')) == (
    6, 7, 105, 110, 356, 314, 1750, 294, 1456, 16, 84, 310, 24959, 8388171)
paths = set(review['inputs']) | set(evidence['inputs']) | {
    PREFIX + name for name in ('review.json', 'evidence.py', 'evidence.json', 'evidence-data.json.gz',
                               'evidence-baseline.json', 'publish.py', 'compat.json')}
inputs = []
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    inputs.append({'path': path, 'sha256': sha(source.read_bytes()),
        'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'})
statement = (
    'ControlFlow if/while lowering privately binds seven required callback roles through six original '
    'validator returns: local method parser plus scope normalizer in if, and scope normalizer in elseif, '
    'else, endif, inline-if and while. Public callback maps/references, eager validation and selected '
    'references, scalar context, original diagnostic lines, argument and array-element aliases, returned '
    'references, once-only effects, successful errors, original fatal objects, branch state and cold '
    'loading remain native. Complete original105-input and current110-input observations retain356 warm '
    'and314 cold rows with exact fresh-process recurrences; every670 ordinary row remains unchanged. '
    'All4110 observed callback calls are scalar. Actual eligible parser HASH/normalizer ARRAY returns '
    'cannot retain an ordinary scalar emission packet; opaque nested calls cannot donate equal-text '
    'parent publications. Inline-if normalizes the original parser array and its second parser call '
    'aliases an element; inline-action bypass shallow-copies that array. Else attached-action rejection '
    'leaves else_seen set. Controlled empty-split while allocates guard8 from7; nested while allocates8/9, '
    'while a whitespace-statement splitter declines without increment. Identical1750 assertions retain '
    '294 original authority REDs/1456 controls and all GREEN. Sixteen distinct complete source faults '
    'are effective, and the inverse reproduces every original failure name/number. All84 ordered '
    'supplied suites/310 inputs/24959 assertions pass, preserving predecessor83 headers/plans/stderr. '
    'Nine coherent artifact corruptions reject beyond their immediate hashes and restore exact bytes '
    'and modes. Whole prior155-input/40701-byte publication, actual readonly baseline and every binding '
    'remain historical at a60764c11ae9bc59242b0220b7ef843a4e579b80. Full Knowledge1486 Markdown/1349 facts/'
    'twelve overlays/8388171 bytes and book89/four actual controls pass. Supplemental strict-vars, '
    'standard syntax, public Phase01035 and composed public guard pass. Later ControlFlow, defaults, '
    'direct/rule/pipeline and independent helper/private/parent/canonical admissions remain open.')
claim = {
    'name': 'controlflow-ifwhile-required-callback-capture',
    'statement': statement,
    'scope': (
        'Only six required-validator return lines change. The private helper, prior six bound validators, '
        'ten remaining raw validators, defaults, dispatch, algorithms and global line count remain exact. '
        'First100-input350/308 observations and source remain immutable. A distinct complete instrument '
        'renames two overwritten literal case labels and adds a duplicate guard; its exact source delta '
        'and original input custody are independently checked before using its105-input356/314 ledger. '
        'These controlled injected dependencies delegate real MethodExpr parsing but do not establish '
        'facade DSL execution. Global late-map-selection, public-map-rebinding, disabled-validation and '
        'array-copy faults have observed witnesses, not exhaustive per-owner mutation coverage. '
        'All historical bindings resolve from the fixed accepted Git namespace. Complete original/current '
        'Knowledge bytes and separate tar/filesystem mode fields remain retained; eleven card bodies '
        'are unchanged and the existing framework card receives current facts. No card or budget grows '
        'beyond its accepted limit. Fixed preflight inventory excludes its own result and in-flight '
        'compat.json; final publication binds the completed standard record separately. System Perl/'
        'stdlib/mdBook are reused read-only without immutable portable toolchain claims. Standard '
        'Phase0 and public guard are supplemental without full transitive input capsules. No broader '
        'runtime/private/parent/canonical admission follows.'),
    'rederive': {
        'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly default). '
            'review.py, evidence.py, book-review.py and validation.py are readonly by default. Native, '
            'paired, fault, consumer, Knowledge, book, standard and artifact capture writers are '
            'one-shot and retired; original observations and actual producer identities remain immutable.',
        'granularity': 'Every first100 and complete105/current110 native input and350/308 then356/314 row; '
            'actual callback identity/own registration, scalar contexts and reference-valued packet refusal; '
            'complete1750 TAP/294 original RED/1456 controls;16 full-source faults and exact inverse; '
            '84 ordered full consumer suites/310 inputs/24959 assertions; nine coherent artifact denials/'
            'restorations; whole original155 bindings/publication/baseline;1486 Knowledge Markdown/'
            '1349 facts/twelve overlays; full89 book inputs/four controls. Supplemental strict-vars/'
            'standard syntax/1035 public Phase0/composed public guard.',
        'result': statement,
    },
    'falsify': {
        'status': 'checked',
        'hypothesis': 'A selected required dependency could inherit parent authority, hide its actual '
            'identity, copy argument aliases or returned arrays, repeat effects, localize errors, '
            'replace public maps, delay selection, disable validation or eagerly load private channels. '
            'Coherent hashes could conceal altered native aliases/parent packets/inverse failures, '
            'whole accepted claims, consumer population, rendered teaching or runtime input paths.',
        'oracle': 'First complete original-source native input/channel ledger and accepted Git source; '
            'unchanged fixture independently checks complete ordinary rows plus actual identity/own '
            'registration and parent/child packets. Independently reconstructed six-line source delta, '
            'complete-source inverse/semantic fault TAP, fixed predecessor command/header/plan/stderr '
            'population, full Knowledge custody and independently enumerated book config/source/includes '
            'and actual rendered controls provide distinguishing comparisons.',
        'red_control': 'Original1750 has294 authority failures/1456 passing controls before the six '
            'return edits and all1750 GREEN afterward. Sixteen complete-source faults fail294,96,39,45,'
            '36,54,45,306,472,606,948,2,12,636,28,50 assertions with complete coherent1750 plans and '
            'valid syntax. Exact inverse restores all294 original failures. Nine rehashed artifact '
            'forgeries reject a changed parser-element alias, parent donation, hidden inverse failure, '
            'whole accepted publication, consumer header, rendered reference/else/counter teaching and '
            'same-byte wrong runtime path. Every case restores exact bytes/modes and PASS. Hidden '
            'inverse adjusts its full stderr block/summary consistently; exit254 remains the native '
            'Test::More capped status. Rendered forgeries refresh their immediate review hash before '
            'semantic rejection. Four actual book controls retain missing SUMMARY, removed workflow/'
            'target markers and missing recursive include.',
    },
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}
record = {'version': 1, 'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.5.2', 'claims': [claim]}
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072, ('bounded if/while publication', len(value))
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value, 'exact current readonly if/while publication'
print('ControlFlow if/while publication PASS:', len(inputs), 'live inputs;', len(value), 'bytes')
