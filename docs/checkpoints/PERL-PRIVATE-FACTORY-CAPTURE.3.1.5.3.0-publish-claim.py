"""Publish once, or readonly-reconstruct, bounded set-key required claims."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'ea6926fefee33cbf77fe512a821d7ba2a4ffc14f'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2-publish-claim.py'
CARDS = {'docs/knowledge/perl-method-set-key-required-capture.md',
         'docs/knowledge/perl-method-assignment-required-capture.md'}
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail + '.json')).read_bytes())


runtime, book, final, evidence = [record(t) for t in ('review', 'book-review', 'final-review', 'evidence')]
assert all(r['result'] == 'PASS' for r in (runtime, book, final, evidence))
expected = {'assertions':539,'cold_assertions':17,'actual_caller_modes':15,
            'bounded_branch_modes':37,'required_callers':1,'required_callback_roles':5,
            'actually_invoked_roles':5,'actual_path_role_targets':5,'validated_only_roles':0,
            'paired_original_semantic_failures':15,'paired_original_passing_controls':524,
            'semantic_source_faults':3,'consumer_suites':56,'supplied_files':176,
            'historical_bindings_preserved':300,'public_toolbox_rows':3}
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
assert len(bindings) == 300
historical = [
    {'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
    {'path': OLD_PRODUCER,
     'sha256': digest(subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)),
     'role': 'producer'},
]
statement = ('One set-key required resolver passes539 main/17 cold assertions,15 exact native-current '
             'callback rows,37 enumerated controlled branches and three named public Toolbox observations. '
             'Five invoked required roles preserve eager validation, actual parser/normalizer arrays and readonly '
             'literal arities, normalized trim slots versus local target/key/value copies, shared extractor/binding '
             'local target, actual maps, contexts/effects/errors/fatal/reference identities. Identical539 TAP '
             'retains15 original publication REDs/524 controls/all539 current GREEN. Three syntax-valid source '
             'faults, supplied56 suites/176 files, five evidence corruptions, original300-binding '
             'corruption/restoration and complete book89/three controls pass.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'set-key-required-isolation', 'statement': statement, 'scope': runtime['scope'],
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/--capture are one-shot writers.',
                  'granularity': 'Every15 native callback row,37 independently enumerated controlled branch rows, three named public Toolbox rows, all539 paired TAP names/exact original15-failure set, all176 supplied inputs, the five-role required acquisition inventory, three complete mutants, five evidence counterfactuals, every300 original binding and full89 book/include/rendered controls.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'Required children can donate publication or borrow identity; eager validation, actual parser/normalizer arrays, readonly arity literals, trim slots versus local copies and native guards/results can change, or incomplete/ineffective evidence can be admitted.',
                 'oracle': 'Accepted Git/current complete native observations, actual child eligibility/parent packet lookup, actual maps/reference/scalar-slot identities, independent required-role/branch inventories and exact one-seam source reconstruction. Named public observations distinguish statement update, pure-value copy and selector rejection.',
                 'red_control': 'Exactly15 original publication failures become GREEN with524 controls preserved. The owner independently has boundary removal, wrapper-identity substitution and diagnostic removal, yielding three syntax-valid complete539 TAP and named semantic REDs. Five actual evidence corruptions and one original-binding corruption reject/restore. Missing SUMMARY fails; removed teaching disappears from rendered HTML; omitted include reports ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-assignment-boundary-preservation',
     'statement': 'All300 original assignment live input identities and every original proof/hash field remain exact. Only that live durability mode/revision changes to historical at ea6926fef; the already historical generalized-return preservation claim stays exact.',
     'scope': 'Complete accepted assignment claim and every300 original live binding at clean ea6926fef. Compact historical binding retains the complete original record and actual publisher. Original assignment runtime replays require accepted ea6926fef inputs; no original observation is refreshed.',
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately preservation-control.py under that wrapper.',
                  'granularity': 'Every original Git input hash and complete before/after JSON with only one live mode/revision change permitted.',
                  'result': 'All300 original hashes, every original proof field and existing historical fields remain exact; actual original-binding RED/restoration pass.'},
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
    assert TARGET.read_bytes() == serialized, 'set-key required publication drift'
print('Set-key required publication PASS:', len(inputs), 'live inputs;', len(serialized), 'bytes; original300 preserved')
