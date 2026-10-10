"""Publish once, or readonly-reconstruct, bounded regex/undefined-return required claims."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'ae65603bc5bee1f3abeab4d7a028546ddbc8da93'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1-publish-claim.py'
CARDS = {'docs/knowledge/perl-method-regex-undef-required-capture.md',
         'docs/knowledge/perl-method-push-required-capture.md'}
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail + '.json')).read_bytes())


runtime, book, final, evidence = [record(t) for t in ('review', 'book-review', 'final-review', 'evidence')]
assert all(r['result'] == 'PASS' for r in (runtime, book, final, evidence))
expected = {'assertions':619,'cold_assertions':23,'actual_caller_modes':24,
            'bounded_branch_modes':32,'required_callers':2,'required_callback_roles':5,
            'actually_invoked_roles':5,'actual_path_role_targets':8,'validated_only_roles':0,
            'paired_original_semantic_failures':24,'paired_original_passing_controls':595,
            'semantic_source_faults':6,'consumer_suites':60,'supplied_files':182,
            'historical_bindings_preserved':303,'public_toolbox_rows':4}
assert all(runtime[key] == value for key, value in expected.items())
assert runtime['native_capsule_files'] == 179 and runtime['fault_generator_boundary_control'] is True
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
assert len(bindings) == 303
historical = [
    {'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
    {'path': OLD_PRODUCER,
     'sha256': digest(subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)),
     'role': 'producer'},
]
statement = ('Two regex/undefined-return required resolvers pass619 main/23 cold assertions,24 exact native-current '
             'callback rows,32 independent branches and four public Toolbox rows. Five eager roles across three paths retain '
             'local scalar copies, defined/default flags and repeated stripping, actual parser/normalizer array and readonly0/0 '
             'arity literals, maps/context/errors/fatal/reference identities. Immutable179-file native probe precedes separate '
             '182-file paired assertions/consumer proof with the retained native JSON reader. Identical619 TAP retains24 '
             'original isolation REDs/595 controls/all619 current GREEN. Six syntax-valid faults, supplied60 suites/182 files, '
             'five evidence corruptions, original303-binding corruption/restoration and full book89/three controls pass. '
             'Native probe/assertions remain unchanged; original last-owner fault-generator failure and exact delimiter fix are retained.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'regex-undef-required-isolation', 'statement': statement, 'scope': runtime['scope'],
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/--capture are one-shot writers.',
                  'granularity': 'Every24 native callback row/32 independent branch/four named public rows, all619 paired TAP names/exact original24 failure set, every179 native and182 assertion/consumer input, five-role/three-path inventory, six complete mutants, original fault failure and exact producer fix, five evidence counterfactuals, all303 original bindings and full89 book/include/render controls.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'Required children can donate publication or borrow identity; eager selection, local copies, writable/default readonly flags, repeated strip calls, actual normalizer array/readonly zero arities or native guards/results can change, or incomplete/ineffective faults and altered original input identities can be admitted.',
                 'oracle': 'Complete immutable first-native/current observations, actual child eligibility/parent packet lookup, maps/reference/scalar-slot/readonly observations, independent role/path/branch inventories and exact two-seam source reconstruction. Native179/test182 populations differ only by main/cold tests and native reader. Original generator and actual failure reconstruct exactly one last-owner delimiter fix before six semantic faults.',
                 'red_control': 'Exactly24 original publication failures become GREEN with595 controls preserved. Each owner has boundary removal, wrapper-identity substitution and diagnostic removal, yielding six syntax-valid complete619 TAP and named semantic REDs. The original generator fails with ValueError at its missing final delimiter; corrected producer captures all six faults. Five evidence corruptions and one original-binding corruption reject/restore. Missing SUMMARY fails; removed marker is absent in HTML; omitted include reports ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-push-boundary-preservation',
     'statement': 'All303 original push live input identities and every original proof/hash field remain exact. Only that live durability mode/revision changes to historical at ae65603bc; the already historical set-key preservation claim stays exact.',
     'scope': 'Complete accepted push claim and every303 original live binding at clean ae65603bc. Compact historical binding retains the complete original record and actual publisher. Original push runtime replays require accepted ae65603bc inputs; no original observation is refreshed.',
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately preservation-control.py under that wrapper.',
                  'granularity': 'Every original Git input hash and complete before/after JSON with only one live mode/revision change permitted.',
                  'result': 'All303 original hashes, every original proof field and existing historical fields remain exact; actual original-binding RED/restoration pass.'},
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
    assert TARGET.read_bytes() == serialized, 'regex-undef required publication drift'
print('Regex/undefined-return required publication PASS:', len(inputs), 'live inputs;', len(serialized), 'bytes; original303 preserved')
