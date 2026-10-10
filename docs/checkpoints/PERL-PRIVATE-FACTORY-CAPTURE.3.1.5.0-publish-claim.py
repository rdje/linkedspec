"""Publish once, or readonly-reconstruct, the bounded bare/mutation required claims."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4b48593b59acb7aba4d616ae1bdc4320fbbf5364'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4-publish-claim.py'
CARDS = {'docs/knowledge/perl-method-slot-required-capture.md',
         'docs/knowledge/perl-main-method-required-capture.md',
         'docs/knowledge/perl-method-default-capture.md',
         'docs/knowledge/perl-method-block-component-capture.md'}
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail + '.json')).read_bytes())


runtime, book, final, evidence, flow = [record(t) for t in
                                      ('review', 'book-review', 'final-review', 'evidence', 'flow-review')]
assert all(r['result'] == 'PASS' for r in (runtime, book, final, evidence, flow))
assert (runtime['assertions'], runtime['cold_assertions'], runtime['actual_caller_modes'],
        runtime['bounded_branch_modes']) == (455, 11, 9, 58)
assert (runtime['required_callers'], runtime['required_callback_roles'], runtime['actually_invoked_roles'],
        runtime['validated_only_roles']) == (2, 3, 3, 0)
assert (runtime['paired_original_semantic_failures'], runtime['paired_original_passing_controls'],
        runtime['semantic_source_faults']) == (9, 446, 6)
assert (runtime['consumer_suites'], runtime['supplied_files'], runtime['historical_bindings_preserved']) == (50, 170, 299)
assert book['source_count'] == 89 and book['actual_controls'] == 3
assert len(evidence['rows']) == 5 and len(final['rows']) == 4 and len(flow['rows']) == 6
preservation = record('preservation-control')
assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0
assert preservation['restored']['returncode'] == 0
paths = set(runtime['checked']) | set(book['source_inputs']) | set(final['checked']) | CARDS
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': p, 'sha256': digest((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t') else 'input'} for p in sorted(paths)]
freeze = record('freeze')
before = (ROOT / freeze['before']).read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
old = json.loads(before)
bindings = [entry for claim in old['claims'] if claim['durability'].get('mode') == 'live'
            for entry in claim['durability']['inputs']]
assert len(bindings) == 299
old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
historical = [{'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
              {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
statement = ('Two bare/mutation required resolvers pass455 main/11 cold assertions,9 exact native-current '
             'required callback rows and58 enumerated branch rows. Three invoked owner/role pairs retain '
             'eager validation, local scalar copies, actual maps and native context/errors/results. Identical455 '
             'assertions retain9 original publication REDs/446 passing controls/all455 current GREEN. Six '
             'syntax-valid faults, supplied50 suites/170 files, five actual evidence corruptions, original299-binding '
             'corruption/restoration and complete book89/three controls pass. Historical legacy flow native16/169 '
             'and branch-removal RED retain the rejected compact-argument premise and six native replay channels; '
             'only one Test::More expected ARRAY address in mutant stderr is normalized, with raw channels retained.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'bare-mutation-required-isolation', 'statement': statement, 'scope': runtime['scope'] + ' ' + flow['scope'],
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/--capture are one-shot writers.',
                  'granularity': 'Every9 native required callback row and58 independently enumerated branch row, all455 paired TAP names, exact original9-failure set, all170 supplied inputs, two required acquisition inventories, six complete mutants, five evidence counterfactuals, every299 original binding, full book/include/rendered controls and six original/fixed legacy-flow replay channels.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'Required children can donate publication or borrow identity, eager validation/native guards/local copies/fallbacks can change, or incomplete and ineffective evidence can be admitted.',
                 'oracle': 'Accepted Git/current complete native observations, actual child eligibility and parent packet lookup, local source copies and actual reference/map identities, exact role/branch inventories and source reconstruction; original/fixed public Toolbox flow selection distinguishes package callback from map callback, retained raw channels locate the one process-address diagnostic difference.',
                 'red_control': 'Exactly9 original publication failures become GREEN with446 controls preserved. Each owner independently has required-boundary removal, actual-to-wrapper substitution and diagnostic removal, producing six syntax-valid complete455 TAP and named semantic REDs. Five evidence corruptions and one original-binding corruption reject and restore. Historical package-branch removal is syntax-valid complete16 TAP and semantically RED; original diagnostic argument-premise failure and rejected byte-exact address comparison remain retained. Missing SUMMARY fails, removed teaching disappears and omitted include reports ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-main-boundary-preservation',
     'statement': 'All299 original main method/value live input identities and every original proof/hash field remain exact. Only that live durability mode/revision changes to historical at4b48593b5; the already historical assignment preservation claim stays exact.',
     'scope': 'Complete accepted main method/value claim record and every299 original live binding at clean4b48593b5. Compact historical binding retains the complete original record and actual publisher; no original runtime/book observation is refreshed.',
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately preservation-control.py under that wrapper.',
                  'granularity': 'Every original Git input hash and complete before/after JSON with only one live mode/revision change permitted.',
                  'result': 'All299 original hashes, every original proof field and existing historical fields remain exact; actual original-binding RED/restoration pass.'},
     'falsify': {'status': 'checked',
                 'hypothesis': 'A historical label conceals refreshed or corrupted original input identities.',
                 'oracle': 'Complete original Git claim, all original Git input hashes and exact mode/revision-only comparison.',
                 'red_control': 'An all-zero SHA in the first original binding fails beyond mode/revision; original bytes restore before actual readonly PASS.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'bare/mutation required publication drift'
print('Bare/mutation required publication PASS:', len(inputs), 'live inputs;', len(serialized), 'bytes; original299 preserved')
