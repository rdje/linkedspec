"""Readonly exact branch-expansion publication; --capture writes once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for name in ('review-accepted.py', 'evidence-final.py'):
    process = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly expansion proof', name, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review-accepted.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence-final.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
assert len(evidence['rows']) == 7, 'derive complete actual artifact control population'
assert evidence['scope'].startswith('Six actual semantic artifact denials'), 'retained first scope-label typo is disclosed below'
p = review['population']
assert (p['required_validators'], p['required_roles'], p['paired_assertions'], p['original_red'],
        p['passing_controls'], p['source_faults'], p['consumer_suites'], p['consumer_inputs'],
        p['consumer_assertions']) == (1, 2, 368, 82, 286, 10, 81, 284, 21850)
paths = set(review['inputs']) | set(evidence['inputs']) | {
    PREFIX + name for name in ('review-accepted.json', 'evidence-final.py', 'evidence-final.json',
                              'evidence-final-data.json.gz', 'publish.py', 'publish-final.py', 'compat.json')}
inputs = []
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    inputs.append({'path': path, 'sha256': sha(source.read_bytes()),
                   'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'})
statement = (
    'ControlFlow branch expansion selects trim and splitter dependencies through one original required validator '
    'and isolates their actual scalar callback identities. Public maps and callback references, eager validation '
    'and selected references, original diagnostic locations, argument aliases, once-only effects, ordinary values, '
    'successful error effects, fatal object identities and cold loading remain unchanged. Plain input returns one '
    'element; a whole brace block returns the actual unblessed splitter array, including an empty array; other '
    'splitter result types decline. The splitter receives the native named match argument with a clear readonly '
    'flag and actual write rejection. The retained independent four-case Perl5.34.1 oracle distinguishes match '
    'slots from copied lexicals; the actual copied-argument source fault rejects exactly the warm and cold '
    'match-mutation rows. First100-input native capture precedes assertions/source edits and retains74 warm/60 '
    'cold rows with exact fresh-process recurrences. Every134 original ordinary row remains exact. The identical '
    '368 assertions reproduce82 original authority REDs/286 controls and all GREEN. All10 syntax-valid complete '
    'source faults are effective, including the exact82-failure original inverse. All81 ordered supplied '
    'suites/284 inputs/21850 assertions pass, with every accepted predecessor header/plan/stderr unchanged. '
    'Seven coherent artifact corruptions reject beyond immediate hashes and restore exact inputs. Full original '
    '428 bindings/100775-byte foundation publication and its actual readonly baseline remain historical at '
    '9f9b47973f0d0be2ee5e048dd71a28f91e8016ed. Complete dated Knowledge1485 Markdown/1349 facts/ten current '
    'overlays and full book89/four actual controls pass. Knowledge' + str(p['knowledge_bytes']) +
    ' bytes remains below unchanged8388608. Supplemental strict-vars/standard syntax/public Phase01035 and '
    'composed public guard pass. Attached parsing, single-statement and later ControlFlow/default/pipeline '
    'owners and independent helper/private/parent/canonical admissions remain open.')
claim = {
    'name': 'controlflow-branch-expansion-required-capture',
    'statement': statement,
    'scope': (
        'Only the original ControlFlow::_expand_flow_branch_action_exprs required-validator return changes; '
        'the existing private forwarding helper and three foundation bindings remain exact. The remaining '
        'eighteen raw validators, optional kind calls, direct dispatch/rule apply, default construction, '
        'OwnerDispatch, AST bridge, attached parser and branch semantics remain unchanged. Both selected '
        'callbacks run in scalar context under scalar/list/void helper calls. Trim receives a local scalar '
        'copy; replacing the splitter map entry does not replace its eagerly selected reference. The actual '
        'brace body is passed as $+{body}; a clear readonly flag does not imply that writes succeed. The '
        'original native instrument, all observations, paired fixture, source faults and consumer results '
        'remain immutable. The independent Perl oracle is reused through its accepted Git producer/input '
        'and complete retained channels; its one-shot writer is not replayed. Knowledge retains every '
        'dated original header/body plus ten current overlays, with only framework and match-alias bodies '
        'changed and no added card or pressure increase. The first full review omitted its own result exclusion, so the first publication failed after capture; the original full445-input candidate and producer remain preserved. Its first isolated replay omitted four declared guard-tool inputs; the distinct complete450-input replay retains the actual self-census RED. A distinct accepted reader explicitly binds these sources and excludes its own result; the default route calls a distinct final publisher. Original captures stay exact. The artifact capture retains/verifies seven actual controls but its inherited scope-label prefix says Six; this current publication derives the full seven-row population and corrects that label without relabeling its original producer or refreshing channels. The first book wording incorrectly treated whitespace decline as intrinsic; its whole436-input candidate and unchanged preflight remain preserved. A distinct book/review/evidence producer checks native trim-result wording and rejects a coherent wrong-teaching artifact. Runtime, native observations, fixture, faults and consumers stay exact. System Perl/stdlib/mdBook are reused read-only '
        'without an immutable portable toolchain claim. Supplemental public Phase0/composed guard retain '
        'actual channels without complete transitive input capsules. Full pipeline activation/output '
        'composition and all broader admissions retain separate owners.'),
    'rederive': {
        'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly default). '
                   'review-accepted.py, book-review-accepted.py, validation.py and evidence-final.py under the same wrapper/prefix '
                   'are readonly. All preservation/native/paired/fault/consumer/Knowledge/book/standard '
                   'and artifact capture writers are one-shot and retired.',
        'granularity': (
            'Every100 original/current native supplied input and74+60 row; exact scalar callback identity '
            'and authority; one validator/two selected roles; complete368 paired TAP/82 original RED/286 '
            'controls;10 actual full-source faults and exact inverse;81 complete ordered consumer '
            'headers/plans/284 inputs/21850 assertions; seven coherent artifact denials/restorations; '
            'complete original428 bindings/100775 publication/baseline; first436-input book candidate and first445/complete450 full-review custody/self-census RED; retained four-case alias oracle '
            'and actual warm/cold argument-copy failures; dated1485 Knowledge Markdown/1349 facts/ten '
            'overlays;89 book inputs/four controls. Supplemental syntax/strict-vars/1035 public Phase0/guard.'),
        'result': statement,
    },
    'falsify': {
        'status': 'checked',
        'hypothesis': (
            'A dependency could borrow enclosing eligibility or hide its actual identity; a wrapper could '
            'copy the native match argument, localize errors, repeat effects, change public maps, delay '
            'selection, disable validation or eagerly load the private channel. Coherent artifact rehashes '
            'could conceal parent donation, an original inverse failure, altered complete accepted '
            'publication, forged consumer headers, missing rendered teaching or a wrong runtime path.'),
        'oracle': (
            'Original native-first complete source/input/channel ledger and accepted Git definitions; '
            'independent actual CODE-frame/current registration/publication assertions in the identical '
            'fixture; complete source inverse and actual syntax-valid source-fault TAP; complete retained '
            'four-case pure-Perl alias producer/input/channels; fixed predecessor command/header/plan/stderr '
            'population; full dated Knowledge original headers/bodies; independently enumerated full '
            'book config/source/recursive includes and actual rendered controls.'),
        'red_control': (
            'Identical original fixture observes82 authority REDs/286 controls before implementation and '
            'all368 GREEN after. Ten actual syntax-valid complete sources reach368 with failure counts '
            '82,82,68,2,120,202,2,2,130,8. The full inverse reproduces every original failure name/number. '
            'The argument-copy variant fails exactly warm239/cold361 named match-mutation controls. '
            'Seven coherent artifact corruptions reject for parent packet donation, exact inverse82, '
            'whole accepted publication custody, full consumer headers, rendered expansion teaching '
            'and native runtime path population; each restores exact bytes/modes and PASS. Four actual '
            'book controls retain missing SUMMARY, removed workflow/expansion rendered markers and '
            'missing recursive include. The complete450-input original-reader replay also retains the actual self-census RED after preserving its incomplete445-input predecessor. No original observation is refreshed.'),
    },
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}
record = {'version': 1, 'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.5.1.0', 'claims': [claim]}
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072, ('bounded expansion publication', len(value))
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value, 'exact current readonly expansion publication'
print('ControlFlow expansion publication PASS:', len(inputs), 'live inputs;', len(value), 'bytes')
