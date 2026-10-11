"""Current readonly container-target publication; --capture writes once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'native-review-final.py', 'book-review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 4
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
    'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for p in sorted(paths)]
statement = ('Private uniform binding target recognition uses the current literal container on every invocation. '
    'Only /o is removed from the interpolated regex. First224-input/four-process native/public observations '
    'precede assertions and source edits; after observations retain40 native rows with26 intended changes. '
    'All actual public lowering/live/independently executed emitted-source observations and full emitted '
    'bytes remain identical across changes and both first-container orders. Three223-input legacy probes '
    'change only five fields of target/container-empty; complete symbolic/object observations stay exact. '
    'Identical285 assertions retain98 original REDs/187 controls/all current GREEN; three syntax-valid '
    'full-source faults fail98/8/67. All70 ordered supplied suites/225 inputs/15378 assertions pass. '
    'Four actual semantic evidence RED/restorations reject beyond updated immediate hashes; full89-input '
    'book/four controls and current readonly routing pass. The complete original422-binding/97759-byte '
    'publication and actual accepted baseline remain exact except its historical mode/revision pair.')
scope = ('Bounded Perl private-helper guard repair. Defined container text remains literal, including empty '
    'literal and metacharacter cases; bare identifiers still return before kind lookup. Matching wrapped '
    'targets preserve selected callback identity, scalar context, actual local argument alias, once-only '
    'effects, successful error state, fatal object identity and line locations. Existing callback fixture '
    'migrates only the measured five-field empty-container row and independent authored result. Original '
    'native/capture/fault/consumer observations and producers remain immutable. Explicit private warm-up '
    'precedes actual public Toolbox call_spec_handler_subst, Get and standalone source load/execution of '
    'the adopted neutral fixture. Retired aggregate selectors remain rejected; no authored-language failure '
    'or new syntax is inferred. The first reviewer wrongly excludes legitimate0640/0750 modes; exact source, '
    'actual exit1/available merged outer channels are retained, separate outer channels unavailable. A '
    'distinct final reader checks the retained standard file modes and exact before/after mode identity. '
    'Original full predecessor publication and its422 binding list are reused rather than duplicated; all '
    'original hashes are independently checked against acceptedde02b83a1a794370b4071bb53677ab675745acc2 '
    'and preserved historically there before bound writes. Original claim membership comes from that same '
    'fixed Git population. Current record binds its retained preservation/review producer, full original '
    'record and every current proof/input; no retired producer is rerun as a resume command. Supplemental '
    'standard syntax/public Phase0 commands retain complete channels but have no complete transitive input '
    'capsule and confer no new admission. Independent full guarded private Phase0 remains with '
    'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5. No immutable toolchain, cross-version '
    'HTML, all-helper/private/parent/canonical or other-backend claim. Thirteen original ingress sites '
    '.3-.8, FlowExpr/ControlFlow, complete canonical fixture registration .7 before pipeline .6 and '
    'independent admissions/TYPE-REFERENCE-BOOK remain separately owned.')
claim = {'name': 'current-literal-container-target-recognition', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; review.py, native-review-final.py, book-review.py and evidence.py under the same wrapper/prefix are readonly defaults. Original --capture/observe/preserve/run/legacy/compat/book writers are one-shot and retired.',
        'granularity': 'Each40 native row and26 changed complete observations; both actual public warm-up orders/full emitted source/live and standalone results; every original legacy field and sole five-field row; all285 paired assertion names and actual98/8/67 source RED sets/full syntax/source/input modes; every70 ordered supplied suite/header/numeric plan/15378 assertion and225 inputs; every original422 binding/full97759 publication/baseline/fixed claim member; four actual evidence corruptions/restorations and89 full book inputs/four controls.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'The first container may govern later target recognition, quoting or current-container matching is unnecessary, or proof failures/member names/original publications/book sources may be forged after updating immediate hashes.',
        'oracle': 'First complete native observations, current-argument authored results, exact accepted Git source/full original publication, identical regression, effective whole-source inverse/unquoted/hardcoded variants, actual public diagnostic and independently executed emitted source, complete ordered consumer plans, and independent full-book source/include/render review.',
        'red_control': 'Original285 fixture fails98 while187 controls pass; current all285 GREEN. Exact source inverse restores98 named failures; unquoted and hardcoded source variants fail8/67. Four actual reviewer denials reject hidden inverse RED, forged consumer header despite unchanged aggregate, forged original beyond preservation hash and changed teaching beyond report hash; every exact restoration passes. Book missing-summary, both removed chapter markers despite exit0 and missing-include controls are retained.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication bytes', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('Container-target publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
