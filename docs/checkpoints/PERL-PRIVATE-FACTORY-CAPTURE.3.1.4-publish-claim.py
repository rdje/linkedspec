"""Reconstruct bounded claims from actual source-bound proof; publish once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '049e1ba537f2bde635b2c0fed31fe83f6b3c129b'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.4'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3-publish-claim.py'
CARDS = {'docs/knowledge/perl-main-method-required-capture.md',
         'docs/knowledge/perl-method-ast-assignment-capture.md',
         'docs/knowledge/perl-factory-capture-framework.md'}
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail + '.json')).read_bytes())


runtime, book, final, evidence, draft = [record(t) for t in
                                       ('review', 'book-review', 'final-review', 'evidence', 'draft-replay-review')]
draft = draft['proof']
assert all(r['result'] == 'PASS' for r in (runtime, book, final, evidence, draft))
assert (runtime['assertions'], runtime['cold_assertions'], runtime['actual_caller_modes'],
        runtime['bounded_branch_modes']) == (518, 10, 42, 23)
assert (runtime['required_callback_roles'], runtime['actually_invoked_roles'],
        runtime['validated_only_roles']) == (15, 14, 1)
assert (runtime['paired_original_semantic_failures'], runtime['paired_original_passing_controls'],
        runtime['semantic_source_faults']) == (42, 476, 3)
assert (runtime['consumer_suites'], runtime['supplied_files'], runtime['historical_bindings_preserved']) == (48, 168, 291)
assert book['source_count'] == 89 and book['actual_controls'] == 3
assert len(evidence['rows']) == 5 and len(final['rows']) == 4 and len(draft['rows']) == 3
preservation = record('preservation-control')
assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0
assert preservation['restored']['returncode'] == 0
paths = set(runtime['checked']) | set(book['source_inputs']) | set(final['checked']) | CARDS
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': p, 'sha256': digest((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pm', '.t') else 'input'} for p in sorted(paths)]
freeze = record('freeze')
before = (ROOT / freeze['before']).read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
old = json.loads(before)
bindings = [entry for claim in old['claims'] if claim['durability'].get('mode') == 'live'
            for entry in claim['durability']['inputs']]
assert len(bindings) == 291
old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
historical = [{'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
              {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
statement = ('One main method/value required resolver passes518 main/10 cold assertions,42 exact native-current '
             'callback rows and23 controlled branch rows. Fourteen eager roles plus lazy initializer and key '
             'reacquisition retain15 distinct roles/16 acquisition sites; one role is locally validated-only. '
             'Identical518 assertions retain42 original publication REDs/476 passing controls/all518 current '
             'GREEN. Three syntax-valid faults, supplied48 suites/168 files, five actual evidence corruptions, '
             'original291-binding corruption/restoration, three native draft replays and complete book89/three controls pass.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'main-method-required-isolation', 'statement': statement, 'scope': runtime['scope'],
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/--capture are one-shot writers.',
                  'granularity': 'Every42 native callback row and23 independently enumerated branch row, all518 paired TAP names, exact original42-failure set, all168 supplied inputs, source acquisition inventory, three complete mutants, five evidence counterfactuals, three draft replays, every291 original binding and full book/include/rendered controls.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'Required children can donate publication or borrow identity, lazy selection/eager validation/aliases can move, or incomplete and ineffective evidence can be admitted.',
                 'oracle': 'Accepted Git/current complete native observations, actual child eligibility and parent packet lookup, readonly kind/local source and array-slot identities, eager order and lazy map replacement, source reconstruction and independently enumerated populations; actual retained counterfactual bytes and rendered teaching markers.',
                 'red_control': 'Exactly42 original publication failures become GREEN with476 controls preserved. Required-boundary removal, actual-to-wrapper substitution and diagnostic removal each produce syntax-valid complete518 TAP and named semantic REDs. Five evidence corruptions and one original-binding corruption reject and restore. Supplied native draft replays reproduce read-only literal failure, false CSV-alias assertion and mistaken original-seed count. Missing SUMMARY fails, removed teaching disappears and omitted include reports ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-assignment-boundary-preservation',
     'statement': 'All291 original assignment live input identities and every original proof/hash field remain exact. Only that live durability mode/revision changes to historical at049e1ba53; the already historical array-end preservation claim stays exact.',
     'scope': 'Complete accepted assignment claim record and every291 original live binding at clean049e1ba53. Compact historical binding retains the complete original record and its actual publisher; no runtime/book observation is refreshed.',
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately preservation-control.py under that wrapper.',
                  'granularity': 'Every original Git input hash and complete before/after JSON with only one live mode/revision change permitted.',
                  'result': 'All291 original hashes, every original proof field and existing historical fields remain exact; actual original-binding RED/restoration pass.'},
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
    assert TARGET.read_bytes() == serialized, 'main method/value publication drift'
print('Main method/value publication PASS:', len(inputs), 'live inputs;', len(serialized), 'bytes; original291 preserved')
