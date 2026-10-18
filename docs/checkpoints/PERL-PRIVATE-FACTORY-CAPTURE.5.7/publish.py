"""Readonly mixed-default publication; --capture writes its bounded claim once."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for name in ('compose.py', 'evidence.py'):
    result = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, (name, result.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
assert review['population'] == dict(warm_rows=26, cold_rows=26, first_assertions=401,
    first_red=44, paired_assertions=445, original_red=53, passing_controls=392,
    source_faults=18, consumer_suites=90, consumer_inputs=356, consumer_assertions=29950,
    diagnostic_inputs=353, diagnostic_assertions=16, knowledge_bytes=8388133,
    book_sources=89, book_controls=4)
compat = json.loads((ROOT / (PREFIX + 'compat.json')).read_bytes())
assert compat['result'] == 'PASS' and len(compat['rows']) == 5
assert all(r['returncode'] == 0 for r in compat['rows'])
assert b'Files=1, Tests=1035' in base64.b64decode(compat['rows'][-1]['stdout_base64'], validate=True)
paths = set(review['inputs']) | {PREFIX + name for name in (
    'review.json', 'evidence.py', 'evidence.json', 'evidence-originals.json.gz',
    'evidence-reached.json', 'publish.py', 'compose.py', 'authority-shape.py')}
bindings = []
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    bindings.append(dict(path=path, sha256=sha(source.read_bytes()),
        role='producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'))
statement = (
    'ControlFlow defaults now select two independent definition-owned populations: seven '
    'EmitContext facades for its built-in target and ValueExpr\'s fixed native extractor, '
    'including custom targets. Actual public map/callback references, factory scalar/list/void '
    'contexts, values/errors/effects and existing diagnostic locations remain native. Same-name '
    'replacements, custom facade aliases and other provider definitions do not borrow selection; '
    'retained native references survive replacement. List calls select each actual returned map, '
    'scalar calls their actual result, and void calls no map. Source/producer scopes restore '
    'after fatal exits and completed registries release. All52 original ordinary native rows and '
    'fresh-process recurrences remain exact; registration bags recur without an ordered-event '
    'claim. Original401 assertions/44 REDs stay frozen. Identical extended445 assertions retain53 '
    'original REDs/392 controls and all GREEN. Eighteen complete three-owner source variants '
    'have distinguishing failures; the exact inverse restores all53 original names/numbers. '
    'All90 supplied suites/356 inputs/29950 top-level assertions pass. The predecessor FlowExpr '
    'dynamic foreign-definition fixture gains exactly one private-selector rejection; every '
    'original named assertion remains ordered and all other predecessor plans stay exact. '
    'Public diagnostic before/after353-input captures each pass16 assertions; standard public '
    'Phase01035 and the supplemental public guard pass. Seven semantic artifact denials restore '
    'byte/mode-exact PASS. Complete Knowledge1486 Markdown/1349 facts/thirteen overlays/8388133 '
    'bytes and full book89/four controls pass; its provider table is independently native-derived. '
    'Whole525-input/121708-byte predecessor and actual readonly baseline remain historical atce9eaf32e.')
record = dict(version=1, owner='PERL-PRIVATE-FACTORY-CAPTURE.5.7', claims=[dict(
    name='controlflow-mixed-provider-default-selection', statement=statement,
    scope='Only the two default-factory boundary lines change existing production; three owners '
        'append private selectors/helpers. Existing line counts/bytes and SourceEmissions remain '
        'unchanged. The fixed ValueExpr provider is independent of the facade target; no FlowExpr '
        'catalogue union is used. Controlled multi-map factory results distinguish contexts and '
        'selection without claiming a new public return shape. Native module definitions remain '
        'retained; registry release does not imply their release. The native probe logs registration '
        'attempts only inside its warm work-scope wrapper; outside rows check authority state, '
        'not a complete outside-attempt census. The original538-input review remains frozen; strict observation completeness is independently composed and omission-falsified before final publication. First native writer source/data remain frozen '
        'after its post-capture raw-INC/repository-namespace assertion failure. Separate actual '
        'predicate controls and corrected readonly review validate membership; original wrapper '
        'error channels are not reconstructed. Its initial syntax-failure source and actual rerun '
        'remain retained. Both mutation-builder preflight failures and actual reruns remain exact; '
        'the separately identified final producer corrects the expected variant count. The first '
        'supplemental public scan retains its old explicit fixture assertion list; the final scan '
        'explicitly checks and binds the two current staged fixtures. Three fact bodies change and '
        'ten route-only bodies stay exact; original statistical prose remains recoverable in Git. '
        'System Perl/stdlib/mdBook are read-only dependencies without immutable toolchain claims. '
        'Standard/public commands are supplemental without full transitive capsules. Finite '
        'continuity, fixture selection, pipeline and broader private/parent/canonical admissions '
        'remain separate. Startup.7 still owns wrapper/kernel gaps and recovery/purge restrictions.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + PREFIX +
        'publish.py (readonly default). compose.py, authority-shape.py, review.py, evidence.py, native-review.py, '
        'consumer-review.py, book-review.py and public-validation.py are readonly by default. '
        'Capture/source-fault/preservation/preparation producers are retired one-shot instruments.',
        granularity='Every26 warm/26 cold original/current row and recurrence; complete401/44 '
            'and445/53 paired TAP; each18 complete three-owner variants; all90 supplied suites/'
            '356 inputs/29950 assertions and exact one-row historical extension; separate353-input '
            'diagnostic captures; whole prior525-binding/121708-byte claim and actual baseline; '
            'full Knowledge/book populations; seven semantic artifact denials.', result=statement),
    falsify=dict(status='checked', hypothesis='Catalogue union, dynamic name lookup, custom-target '
        'facade aliases or the wrong fixed-provider guard could grant or lose authority. Factory '
        'context coercion, void cached selection, map copying, error localization, duplicate calls '
        'or eager loading could change native behavior. Rehashed artifacts could conceal ordinary '
        'effects, opaque grants, missing fixed registration attempts or selection observations, altered prior claims, omitted '
        'consumers or forged rendered provider keys.',
        oracle='Accepted Git source/claim namespace and whole prior publication; first native '
            'ordinary observations captured before expectations/production edits; actual retained '
            'reference comparisons with independent foreign-definition/copy-name/scope controls; '
            'identical paired fixture and three-owner exact inverse; disjoint-map and fresh-void '
            'controls; exact predecessor command/TAP population; rendered provider table derived '
            'from captured native keys/providers; complete original/current Knowledge custody.',
        red_control='Original53 of445 fail while392 controls pass; current all445 pass. Eighteen '
            'syntax-valid complete-source variants fail53,31,14,1,17,35,5,14,2,153,67,21,45,4,44,6,1,55 '
            'assertions with full445 plans. The exact inverse restores53 names/numbers. Seven '
            'artifact controls reject an altered successful error effect, opaque selection, '
            'missing fixed-provider attempt, changed whole prior claim, omitted consumer, missing selection observation and '
            'coherently rehashed rendered provider key, then restore exact PASS. The namespace '
            'predicate has actual original RED/normalized PASS/unsupplied-module RED. Four actual '
            'book controls distinguish missing SUMMARY, two absent rendered markers and a missing include.'),
    durability=dict(status='checked', mode='live', inputs=bindings))])
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072, (len(value), len(bindings))
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value
print('Mixed-default publication PASS:', len(bindings), 'live inputs;', len(value), 'bytes')
