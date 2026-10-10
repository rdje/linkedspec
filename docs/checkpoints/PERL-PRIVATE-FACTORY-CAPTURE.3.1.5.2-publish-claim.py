"""Publish once, or readonly-reconstruct, bounded assignment required claims."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2b1f949b897cc8fac8f87f7652ad67eb90241479'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-publish-claim.py'
CARDS = {'docs/knowledge/perl-method-assignment-required-capture.md',
         'docs/knowledge/perl-method-general-return-required-capture.md'}
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail + '.json')).read_bytes())


runtime, book, final, evidence = [record(t) for t in ('review', 'book-review', 'final-review', 'evidence')]
assert all(r['result'] == 'PASS' for r in (runtime, book, final, evidence))
expected = {'assertions': 938, 'cold_assertions': 17, 'actual_caller_modes': 27,
            'bounded_branch_modes': 60, 'required_callers': 3, 'required_callback_roles': 8,
            'actually_invoked_roles': 8, 'actual_path_role_targets': 9, 'validated_only_roles': 0,
            'paired_original_semantic_failures': 27, 'paired_original_passing_controls': 911,
            'semantic_source_faults': 9, 'consumer_suites': 54, 'supplied_files': 174,
            'historical_bindings_preserved': 306, 'public_toolbox_rows': 5}
assert all(runtime[key] == value for key, value in expected.items())
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
assert len(bindings) == 306
historical = [
    {'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
    {'path': OLD_PRODUCER,
     'sha256': digest(subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)),
     'role': 'producer'},
]
statement = ('Three assignment required resolvers pass938 main/17 cold assertions,27 exact native-current '
             'callback rows,60 enumerated controlled branch rows and five named public Toolbox observations. '
             'Eight invoked owner/role pairs across nine path/role targets preserve native eager validation, '
             'local copies, readonly initializer kind/writable source, repeated operator trim slots and actual '
             'RHS helper alias, actual maps, context/effects/errors/fatal/reference identities. Identical938 TAP '
             'retains27 original publication REDs/911 controls/all938 current GREEN. Nine syntax-valid source '
             'faults, supplied54 suites/174 files, five evidence corruptions, original306-binding '
             'corruption/restoration and complete book89/three controls pass.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'assignment-required-isolation', 'statement': statement, 'scope': runtime['scope'],
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/--capture are one-shot writers.',
                  'granularity': 'Every27 native callback row,60 independently enumerated controlled branch rows, five named public Toolbox rows, all938 paired TAP names/exact original27-failure set, all174 supplied inputs, three required acquisition inventories, nine complete mutants, five evidence counterfactuals, every306 original binding and full89 book/include/rendered controls.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'Required children can donate publication or borrow identity; eager validation, local scalar slots, readonly kind, native guards/results or repeated trim behavior can change, or incomplete/ineffective evidence can be admitted.',
                 'oracle': 'Accepted Git/current complete native observations, actual child eligibility/parent packet lookup, actual maps/reference/scalar-slot identities, independent required-role/branch inventories and exact three-seam source reconstruction. Private legacy aggregate controls remain distinct from actual public selector rejection.',
                 'red_control': 'Exactly27 original publication failures become GREEN with911 controls preserved. Each of three owners independently has boundary removal, wrapper-identity substitution and diagnostic removal, yielding nine syntax-valid complete938 TAP and named semantic REDs. Five actual evidence corruptions and one original-binding corruption reject/restore. Missing SUMMARY fails; removed teaching disappears from rendered HTML; omitted include reports ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-general-return-boundary-preservation',
     'statement': 'All306 original generalized-return live input identities and every original proof/hash field remain exact. Only that live durability mode/revision changes to historical at2b1f949b8; the already historical bare/mutation preservation claim stays exact.',
     'scope': 'Complete accepted generalized-return claim and every306 original live binding at clean2b1f949b8. Compact historical binding retains the complete original record and actual publisher. Original generalized-return runtime replays require accepted edc9165a4 inputs; no original observation is refreshed.',
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately preservation-control.py under that wrapper.',
                  'granularity': 'Every original Git input hash and complete before/after JSON with only one live mode/revision change permitted.',
                  'result': 'All306 original hashes, every original proof field and existing historical fields remain exact; actual original-binding RED/restoration pass.'},
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
    assert TARGET.read_bytes() == serialized, 'assignment required publication drift'
print('Assignment required publication PASS:', len(inputs), 'live inputs;', len(serialized), 'bytes; original306 preserved')
