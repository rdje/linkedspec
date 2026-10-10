"""Publish once, or readonly-reconstruct, bounded push required claims."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'd74c534853832f6286813d924e018bd1bc6c2239'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0-publish-claim.py'
CARDS = {'docs/knowledge/perl-method-push-required-capture.md',
         'docs/knowledge/perl-method-set-key-required-capture.md'}
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail + '.json')).read_bytes())


runtime, book, final, evidence = [record(t) for t in ('review', 'book-review', 'final-review', 'evidence')]
assert all(r['result'] == 'PASS' for r in (runtime, book, final, evidence))
expected = {'assertions':850,'cold_assertions':15,'actual_caller_modes':24,
            'bounded_branch_modes':56,'required_callers':1,'required_callback_roles':4,
            'actually_invoked_roles':4,'actual_path_role_targets':8,'validated_only_roles':0,
            'paired_original_semantic_failures':24,'paired_original_passing_controls':826,
            'semantic_source_faults':3,'consumer_suites':58,'supplied_files':178,
            'historical_bindings_preserved':296,'public_toolbox_rows':6}
assert all(runtime[key] == value for key, value in expected.items())
assert runtime['instrument_correction'] == {'initial_callbacks':24,'initial_branches':56,'initial_public':4,'added_public':2,'callback_branch_observations_unchanged':True}
assert book['source_count'] == 89 and book['actual_controls'] == 3
assert len(evidence['rows']) == 5 and len(final['rows']) == 3
preservation = record('preservation-control')
assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0
assert preservation['restored']['returncode'] == 0
paths = set(runtime['checked']) | set(book['source_inputs']) | set(final['checked']) | CARDS
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': p, 'sha256': digest((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t') else 'input'}
          for p in sorted(paths)]
freeze = record('freeze')
before = (ROOT / freeze['before']).read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
old = json.loads(before)
bindings = [entry for claim in old['claims'] if claim['durability'].get('mode') == 'live'
            for entry in claim['durability']['inputs']]
assert len(bindings) == 296
historical = [
    {'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
    {'path': OLD_PRODUCER,
     'sha256': digest(subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)),
     'role': 'producer'},
]
statement = ('One push required resolver passes850 main/15 cold assertions,24 exact native-current callback rows '
             'across four invoked roles/two arities,56 independently enumerated branches and six named public Toolbox rows. '
             'Eager validation, actual raw versus copied effective arrays, repeated trim/extractor effects, local scalar slots '
             'and shared final extractor/binding target, actual maps/context/errors/fatal/reference identities remain native. '
             'Identical850 TAP retains24 original publication REDs/826 controls/all850 current GREEN. Three syntax-valid '
             'source faults, supplied58 suites/178 files, five evidence corruptions, original296-binding corruption/restoration '
             'and complete book89/three controls pass. Original initial producer/fixtures/native channels reconstruct the '
             'instrument-only56-case count, public-label/two added quoted-value probe and diagnostic-name correction.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'push-required-isolation', 'statement': statement, 'scope': runtime['scope'],
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/--capture are one-shot writers.',
                  'granularity': 'Every24 native callback row,56 independently enumerated branch rows, six named public Toolbox rows, all850 paired TAP names/exact original24-failure set, all178 supplied inputs, the four-role/two-arity acquisition inventory, three complete mutants, five evidence counterfactuals, every296 original binding, original instrument/capture correction and full89 book/include/rendered controls.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'Required children can donate publication or borrow identity; eager validation, actual raw/effective arrays, repeated callback effects, local copies, native guards/results or public child/index precedence can change, or incomplete/ineffective evidence and rewritten initial observations can be admitted.',
                 'oracle': 'Accepted Git/current complete native observations, actual child eligibility/parent packet lookup, actual maps/reference/scalar-slot identities, independent role/arity/branch inventories and exact one-seam source reconstruction. Named public rows distinguish child/index, ambiguous child/value, quoted-value append and selector rejection. Exact initial producer/fixture transformation and original native callback/branch equality reconstruct the instrument correction.',
                 'red_control': 'Exactly24 original publication failures become GREEN with826 controls preserved. Boundary removal, wrapper-identity substitution and diagnostic removal each yield syntax-valid complete850 TAP and named semantic REDs. Five actual evidence corruptions and one original-binding corruption reject/restore. Missing SUMMARY fails; removed teaching disappears from rendered HTML; omitted include reports ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-set-key-boundary-preservation',
     'statement': 'All296 original set-key live input identities and every original proof/hash field remain exact. Only that live durability mode/revision changes to historical at d74c53485; the already historical assignment preservation claim stays exact.',
     'scope': 'Complete accepted set-key claim and every296 original live binding at clean d74c53485. Compact historical binding retains the complete original record and actual publisher. Original set-key runtime replays require accepted d74c53485 inputs; no original observation is refreshed.',
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately preservation-control.py under that wrapper.',
                  'granularity': 'Every original Git input hash and complete before/after JSON with only one live mode/revision change permitted.',
                  'result': 'All296 original hashes, every original proof field and existing historical fields remain exact; actual original-binding RED/restoration pass.'},
     'falsify': {'status': 'checked',
                 'hypothesis': 'A historical label conceals refreshed or corrupted original input identities.',
                 'oracle': 'Complete original Git claim, all original Git input hashes and exact mode/revision-only comparison.',
                 'red_control': 'An all-zero SHA in the first original binding fails beyond mode/revision; original bytes restore before actual readonly PASS.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}},
]}
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'push required publication drift'
print('Push required publication PASS:', len(inputs), 'live inputs;', len(serialized), 'bytes; original296 preserved')
