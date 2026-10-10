"""Publish once, or readonly-reconstruct, the bounded generalized-return required claims."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2c5f84092d91c808ab82b4b886b51e65fc1ac864'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-publish-claim.py'
CARDS = {'docs/knowledge/perl-method-general-return-required-capture.md',
         'docs/knowledge/perl-method-slot-required-capture.md',
         'docs/knowledge/perl-method-local-return-capture.md'}
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail + '.json')).read_bytes())


runtime, book, final, evidence, instrument = [record(t) for t in
                                      ('review', 'book-review', 'final-review', 'evidence', 'instrument-review')]
assert all(r['result'] == 'PASS' for r in (runtime, book, final, evidence))
assert runtime['public_toolbox_rows'] == 9
assert (runtime['assertions'], runtime['cold_assertions'], runtime['actual_caller_modes'],
        runtime['bounded_branch_modes']) == (574, 15, 9, 52)
assert (runtime['required_callers'], runtime['required_callback_roles'], runtime['actually_invoked_roles'],
        runtime['validated_only_roles']) == (2, 3, 3, 0)
assert (runtime['paired_original_semantic_failures'], runtime['paired_original_passing_controls'],
        runtime['semantic_source_faults']) == (9, 565, 6)
assert (runtime['consumer_suites'], runtime['supplied_files'], runtime['historical_bindings_preserved']) == (52, 172, 307)
assert book['source_count'] == 89 and book['actual_controls'] == 3
assert len(evidence['rows']) == 5 and len(final['rows']) == 4 and len(instrument['rows']) == 4 and instrument['result'] == 'retained-replay'
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
assert len(bindings) == 307
old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
historical = [{'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
              {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
statement = ('Two generalized-return required resolvers pass574 main/15 cold assertions,9 exact native-current '
             'callback rows,52 enumerated branch rows and9 named public Toolbox observations. Three invoked '
             'owner/role pairs preserve native eager/lazy validation, scalar copies versus parser-array slots, '
             'actual maps and context/effects/errors/results. Identical574 TAP retains9 original publication '
             'REDs/565 controls/all574 current GREEN. Six syntax-valid faults, supplied52 suites/172 files, '
             'five evidence corruptions, original307-binding corruption/restoration and complete book89/three '
             'controls pass. Original partial28 loading draft and initial565 instrument remain unchanged; four '
             'supplied172-file historical replays retain full raw channels, with only the draft Test::More '
             'expected HASH address normalized and all stdout/other stderr exact.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'general-return-required-isolation', 'statement': statement, 'scope': runtime['scope'] + ' Instrument refinements preserve original observations; no production loading change or complete type/method inventory is inferred.',
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/--capture are one-shot writers.',
                  'granularity': 'Every9 native required callback row,52 independently enumerated controlled branch rows,9 named public Toolbox rows, all574 paired TAP names/exact original9-failure set, all172 supplied inputs, two required acquisition inventories, six complete mutants, five evidence counterfactuals, every307 original binding, full89 book/include/rendered controls and four historical instrument replay channels.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'Required children can donate publication or borrow identity; validation/lazy guards, source copies/parser-array aliases and native fallbacks can change, or incomplete/ineffective proof and instrument refinements can be admitted.',
                 'oracle': 'Accepted Git/current complete native observations, actual child eligibility/parent packet lookup, actual maps/reference/scalar-slot identities, independent role/branch inventories and exact two-seam source reconstruction. Original loading draft/import correction and initial565-to574 alias augmentation reconstruct exactly; actual supplied replay preserves raw channels and limits normalization to one expected HASH address line.',
                 'red_control': 'Exactly9 original publication failures become GREEN with565 controls preserved. Each owner independently has boundary removal, wrapper-identity substitution and diagnostic removal, yielding six syntax-valid complete574 TAP and named semantic REDs. Five evidence corruptions and one original-binding corruption reject/restore. Rejected loading draft remains partial28/no-plan/exit255; public Toolbox lazy-loading control distinguishes that fixture premise from runtime behavior. Original565 instrument observations remain exact after adding9 alias controls. Missing SUMMARY fails, removed teaching disappears and omitted include reports ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-bare-mutation-boundary-preservation',
     'statement': 'All307 original bare/mutation live input identities and every original proof/hash field remain exact. Only that live durability mode/revision changes to historical at2c5f84092; the already historical main preservation claim stays exact.',
     'scope': 'Complete accepted bare/mutation claim record and every307 original live binding at clean2c5f84092. Compact historical binding retains the complete original record and actual publisher; no original runtime/book observation is refreshed.',
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately preservation-control.py under that wrapper.',
                  'granularity': 'Every original Git input hash and complete before/after JSON with only one live mode/revision change permitted.',
                  'result': 'All307 original hashes, every original proof field and existing historical fields remain exact; actual original-binding RED/restoration pass.'},
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
    assert TARGET.read_bytes() == serialized, 'generalized-return required publication drift'
print('Generalized-return required publication PASS:', len(inputs), 'live inputs;', len(serialized), 'bytes; original307 preserved')
