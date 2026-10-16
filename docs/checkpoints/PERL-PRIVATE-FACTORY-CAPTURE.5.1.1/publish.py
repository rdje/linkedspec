"""Readonly exact attached-parser publication; --capture writes the claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
first = json.loads((ROOT / (PREFIX + 'review-final.json')).read_bytes())
assert first['result'] == 'PASS'
for path, identity in first['inputs'].items():
    current = ROOT / path
    assert sha(current.read_bytes()) == identity['sha256'], ('first root-only candidate retained', path)
    assert current.stat().st_mode & 0o7777 == identity['mode'], ('first candidate mode retained', path)
for name in ('review-accepted.py', 'evidence-final.py'):
    p = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert p.returncode == 0 and not p.stderr, ('actual readonly attached-parser proof', name, p.stderr)
review = json.loads((ROOT / (PREFIX + 'review-accepted.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence-final.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 8
p = review['population']
assert (p['required_validators'], p['required_roles'], p['paired_assertions'], p['original_red'],
        p['passing_controls'], p['source_fault_cases'], p['distinct_fault_sources'], p['consumer_suites'],
        p['consumer_inputs'], p['consumer_assertions']) == (1, 2, 920, 194, 726, 10, 9, 82, 291, 22770)
paths = set(review['inputs']) | set(evidence['inputs']) | {
    PREFIX + name for name in ('review-accepted.json', 'evidence-final.py', 'evidence-final.json',
                              'evidence-final-data.json.gz', 'evidence-final-baseline.json', 'publish.py', 'compat.json')}
inputs = []
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    inputs.append({'path': path, 'sha256': sha(source.read_bytes()),
                   'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'})
statement = (
    'ControlFlow optional attached-block parsing privately binds the two selected trim/parser roles through '
    'one original required-validator return. Both direct parser calls and the head substring trim gain '
    'actual scalar callback frames; the nested marker trims were already isolated. Public maps and callback '
    'references, eager validation/selection, original diagnostic lines, native arguments and retained aliases, '
    'once-only effects, ordinary values, successful errors, fatal object identities and cold loading remain '
    'unchanged. The head substring is a writable LVALUE with a clear readonly flag on the retained Perl5.34.1; '
    'its mutation changes the scalar held by the earlier parser call. Copying arguments loses that relationship '
    'and reference type. Actual call and argument-array references, attached body text, typed source_method '
    'reconstruction, marker aliases, quote/bracket/slash scanning and truthy injected parser returns remain '
    'native. First executable100-input observation retains188 warm/156 cold rows, all scalar callback sites '
    'and exact fresh-process recurrences before assertions/source edits; every344 original ordinary row '
    'matches current code. The identical920 assertions reproduce194 original authority REDs/726 controls '
    'and all GREEN. Ten syntax-valid full-source fault cases are effective, with nine distinct source byte '
    'variants because inverse and sole-validator bypass coincide. The inverse reproduces every original194 '
    'failure name/number; copied arguments reject the warm555/cold896 head-mutation checks. All82 ordered '
    'supplied suites/291 inputs/22770 assertions pass with unchanged predecessor headers/plans/stderr. Eight '
    'coherent artifact corruptions reject beyond immediate hashes and restore exact source bytes/modes. '
    'Both original publications,456/full108786 and22/full9417, and all478 original bindings remain historical '
    'at a4a9e5c503460a8bd7db06e57b827dd053724d00 after actual readonly baselines. Complete dated Knowledge1485 '
    'Markdown/1349 facts/ten overlays and full book89/four actual controls pass. Knowledge' + str(p['knowledge_bytes']) +
    ' bytes remains below unchanged8388608. Supplemental strict-vars/standard syntax/public Phase01035 and '
    'composed public guard pass. Single-statement and later ControlFlow/default/pipeline owners and independent '
    'helper/private/parent/canonical admissions remain open.')
claim = {
    'name': 'controlflow-attached-parser-required-capture',
    'statement': statement,
    'scope': (
        'Only the required-validator return in ControlFlow::_parse_method_expr_with_optional_attached_block '
        'changes. Existing private forwarding helper, four prior bindings, AST implementation/reconstruction, '
        'remaining seventeen raw validators, optional kind, direct dispatch/rule apply, defaults and branch '
        'semantics remain unchanged. Native callbacks are scalar under scalar/list/void helper calls. The '
        'head trim receives the original substring lvalue; first parser and head trim observe its shared '
        'storage. Truthy injected scalar/array/blessed/CODE results are forwarded without a new hash guard. '
        'The first instrument had an invalid brace-delimited quoted fixture; its100-input source capsule '
        'and all five compiler failures remain exact. Copy/hash/mode verification retains a readable text '
        'archive before removing only that untracked invalid executable test copy. A distinct fixed '
        'instrument changes the delimiter and initializes retained argument/return collections before the '
        'first executable observations. Neither native ledger is refreshed. The first independent reader '
        'mistakenly required the callback claim, which the hygiene claim binds, to keep its live bytes after '
        'intentional historical preservation. Its source, rejection and distinct readonly replay remain '
        'retained. A distinct final reader checks that exact mode/revision-only overlay for both claims '
        'and every other original binding at its accepted Git revision. The next root-only PASS read78 historical live artifacts outside its449-file supplied inventory; the first isolated artifact baseline exposed that missing dependency. Exact reported child channels and a distinct fresh replay retain the rejection. A distinct accepted reader resolves the478 historical bindings through Git, while current runtime inputs remain bound to the new capsules. The corrected artifact producer persists baseline and reached denial/restoration channels before adjudication. Its input inventory is explicit and excludes its own result '
        'and supplemental compat.json from preflight. Complete original Knowledge headers/bodies remain '
        'recoverable at accepted Git plus ten current overlays; only the framework body changes, with no '
        'new card or budget increase. System Perl/stdlib/mdBook are reused read-only without an immutable '
        'portable toolchain claim. Public Phase0/guard retain complete actual channels without complete '
        'transitive input capsules. No broader runtime/helper/private/parent/canonical or other-backend '
        'admission is inferred.'),
    'rederive': {
        'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly default). '
                   'review-accepted.py, book-review.py, validation.py and evidence-final.py under this wrapper/prefix '
                   'are readonly. Preservation/native/archive/paired/fault/consumer/Knowledge/book/standard '
                   'and artifact capture writers are one-shot and retired. The rejected review.py/review-final.py/evidence.py '
                   'and diagnose-review.py/diagnose-evidence.py retain their original source/capture identities. '
                   'The final publisher independently verifies every first root-only candidate input byte/mode.',
        'granularity': 'Every100 original/current native supplied input and188+156 row; exact actual scalar '
                       'identity/registration and head LVALUE/shared mutation; one validator/two selected '
                       'roles; complete920 paired TAP/194 RED/726 controls;10 actual full-source fault '
                       'cases/nine unique sources and exact inverse;82 complete ordered consumer '
                       'headers/plans/291 inputs/22770 assertions; eight coherent artifact denials and '
                       'restorations; both complete original publications/all478 bindings/baselines; '
                       'first100-input invalid instrument/five compiler channels and exact archive; '
                       'dated1485 Knowledge Markdown/1349 facts/ten overlays;89 book inputs/four controls. '
                       'Supplemental strict-vars/standard syntax/1035 public Phase0/composed guard.',
        'result': statement,
    },
    'falsify': {
        'status': 'checked',
        'hypothesis': 'A dependency could borrow enclosing eligibility or hide its actual identity; wrappers '
                      'could copy the substring or parser argument slots, localize errors, repeat effects, '
                      'rebind public maps, delay selection, disable validation or eagerly load private '
                      'channels. Coherent rehashes could conceal a changed native head alias, parent '
                      'donation, an inverse failure, changed whole accepted publication, forged consumer '
                      'headers, missing rendered alias/return teaching or a wrong runtime path.',
        'oracle': 'Original native-first complete source/input/channel ledger and accepted Git definitions; '
                  'independent actual CODE-frame/current-registration/publication assertions in the '
                  'identical fixture; retained argument references and shared mutation; typed source_method '
                  'and actual returned references; complete original source inverse and actual syntax-valid '
                  'source-fault TAP; fixed predecessor command/header/plan/stderr population; complete '
                  'dated Knowledge custody; independently enumerated full book config/source/includes '
                  'and rendered semantic controls; exact original historical-claim projections.',
        'red_control': 'The identical original fixture observes194 authority REDs/726 controls before '
                       'implementation and all920 GREEN after. Ten full-source fault cases reach920 with '
                       'failure counts194,194,182,172,330,532,2,6,340,8; inverse and sole-validator bypass '
                       'share one byte variant. The exact inverse reproduces every original failure. '
                       'Argument copying rejects warm555/cold896 head mutation and native alias checks. '
                       'Eight coherent artifact forgeries reject changed LVALUE, parent donation, hidden '
                       'inverse failure, whole accepted hygiene publication, full consumer headers, '
                       'rendered head/return teaching and runtime path population, then restore exact '
                       'bytes/modes and PASS. The hidden inverse forgery also adjusts its diagnostic '
                       'stderr block, failure summary and exit; book forgeries refresh their review '
                       'capture hash before semantic rejection. Four actual book controls retain '
                       'missing SUMMARY, removed workflow/parser markers and missing recursive include. '
                       'First invalid instrument compiler REDs and the first reader historical-overlay '
                       'rejection are preserved with distinct corrections; no observation is refreshed.',
    },
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}
record = {'version': 1, 'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.5.1.1', 'claims': [claim]}
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072, ('bounded attached-parser publication', len(value))
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value, 'exact current readonly attached-parser publication'
print('ControlFlow attached-parser publication PASS:', len(inputs), 'live inputs;', len(value), 'bytes')
