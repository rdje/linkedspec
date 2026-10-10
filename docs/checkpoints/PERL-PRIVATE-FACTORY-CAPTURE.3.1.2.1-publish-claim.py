"""One-shot bounded block component claim; readonly reviewers are resume entrypoints."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '65bd00faa0b10abc106a6da2283391c268ee88fa'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert not TARGET.exists(), 'one-shot claim already published'
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


runtime, book, final, evidence = [record(tail + '.json') for tail in ('review', 'book-review', 'final-review', 'evidence')]
preservation = record('preservation-control.json')
assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
assert runtime['assertions'] == 223 and runtime['cold_assertions'] == 4
assert runtime['actual_caller_modes'] == 20 and runtime['required_callback_roles'] == 6
assert runtime['paired_original_semantic_failures'] == 18 and runtime['paired_original_passing_controls'] == 205
assert runtime['semantic_source_faults'] == 6 and runtime['consumer_suites'] == 33 and runtime['supplied_files'] == 152
assert runtime['historical_bindings_preserved'] == 242 and runtime['validation_only_roles'] == 1
assert book['source_count'] == 57 and book['actual_controls'] == 2 and len(evidence['rows']) == 5
assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0 and preservation['restored']['returncode'] == 0
paths = set(runtime['checked']) | set(book['source_inputs']) | set(final['checked'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': path, 'sha256': digest((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pm', '.t') else 'input'} for path in sorted(paths)]
freeze = record('freeze.json')
before = (ROOT / freeze['before']).read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
original = json.loads(before)
historical = [entry for claim in original['claims'] if claim['durability'].get('mode') == 'live'
              for entry in claim['durability']['inputs']]
assert len(historical) == 242
historical.append({'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'})
statement = ('Two required MethodLowering block component/side-effect resolver seams pass 223 main/four cold '
             'assertions and six effective syntax-valid source faults. Six invoked roles, one separate validation-only '
             'flow requirement and 20 native/current caller ledgers preserve fallback/reference/context/alias/error '
             'behavior. The identical complete fixture has exactly 18 original publication-isolation REDs, 205 '
             'original passing controls and 223 current GREEN. Thirty-three suites in 152 supplied files, five actual '
             'reviewer REDs, original-binding RED/restoration and complete 57-source book/two controls pass. '
             'All 242 original inline-boundary bindings remain historical.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'method-required-block-component-side-effect-isolation', 'statement': statement,
     'scope': runtime['scope'],
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py. Capture/freezer/publisher are retained one-shot writers, not resume entrypoints.',
                  'granularity': 'Each actual six-role invocation and 20 native/current full observation rows, separate never-invoked validation requirement; exact paired 223-assertion names and 18-failure set; every coherent positive/fault TAP, supplied file, actual reviewer rejection channel/counterfactual, original binding and rendered teaching marker.', 'result': statement},
     'falsify': {'status': 'checked', 'hypothesis': 'An injected callback can donate publication to its enclosing caller, a private wrapper can replace actual callback identity, changed native behavior or incomplete evidence can masquerade as acceptance.',
                 'oracle': 'Exact clean-Git/current same-fixture names and native JSON ledgers; actual eligible-call identity and parent packet retrieval, actual parser-array aliases/public references, native context/value/error/fatal/effect controls; complete source-fault plans and source/population/channel identities.',
                 'red_control': 'Exactly 18 original publication-isolation REDs turn GREEN while 205 original controls pass. Each of two resolvers independently yields complete semantic REDs for boundary removal, actual-to-wrapper substitution and original required diagnostic validation removal. The component diagnostic fault specifically rejects loss of its validation-only missing-flow requirement. Five actual reviewer controls reject failed positive, missing reader input, omitted inverse, lost semantic reason with rehashed index and missing consumer result; exact restoration passes. Original binding all-zero hash rejects and restores. Missing SUMMARY fails the book build; removing the teaching marker builds without rendered content.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-inline-boundary-preservation',
     'statement': 'All 242 original live inline-boundary input bindings and every proof/hash field remain exact; only mode/revision changes to historical at 65bd00faa. Already historical inference-boundary preservation is unchanged.',
     'scope': 'Exactly the original inline claim and its 242 live inputs at the clean activation commit. This preserves a historical boundary without refreshing old measurements.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                  'granularity': 'Every original Git-bound input and complete before/after JSON; only original live durability mode/revision may differ.',
                  'result': 'All 242 original Git input identities and proof/hash fields match clean 65bd00faa; already historical fields remain exact.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A historical-mode label can hide an altered original input hash.',
                 'oracle': 'Exact original claim from clean Git, complete mode/revision-only JSON comparison and all original input hashes.',
                 'red_control': 'Actual first-original-binding all-zero-SHA corruption fails beyond mode/revision; original bytes restore before readonly PASS. Actual channels and counterfactual bytes are retained.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
TARGET.write_bytes(serialized)
print('Block component claim published:', len(inputs), 'live;', len(historical), 'historical;', len(serialized), 'bytes')
