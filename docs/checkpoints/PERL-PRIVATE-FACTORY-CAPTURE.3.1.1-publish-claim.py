"""One-shot bounded inference claim; readonly reviewers are resume entrypoints."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '429d0c6d959e883304bc06d8c569c76e7bdcedfc'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert not TARGET.exists(), 'one-shot claim already published'
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


runtime, book, final, evidence = [record(tail + '.json') for tail in ('review', 'book-review', 'final-review', 'evidence')]
preservation = record('preservation-control.json')
assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
assert runtime['assertions'] == 277 and runtime['cold_assertions'] == 4
assert runtime['actual_caller_modes'] == 25 and runtime['required_callback_roles'] == 8
assert runtime['paired_original_semantic_failures'] == 24 and runtime['paired_original_passing_controls'] == 253
assert runtime['semantic_source_faults'] == 9 and runtime['consumer_suites'] == 29 and runtime['supplied_files'] == 148
assert runtime['historical_bindings_preserved'] == 262
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
assert len(historical) == 262
historical.append({'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'})
statement = ('Three required MethodLowering assignment/declaration resolver seams pass 277 main/four cold assertions '
             'and nine effective syntax-valid source faults. All eight callback roles and 25 native/current caller '
             'ledgers match; the same complete fixture has exactly 24 original publication-isolation REDs, 253 '
             'original passing controls and 277 current GREEN. Twenty-nine suites in 148 supplied files, five actual '
             'reviewer REDs, original-binding RED/restoration and complete 57-source book/two controls pass. All 262 '
             'original trim-boundary bindings remain historical. An early missing consumer result is reproduced '
             'and restored by the fifth evidence control; production, fixtures and capture programs are unchanged.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'method-required-assignment-declaration-isolation', 'statement': statement,
     'scope': runtime['scope'],
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py. Capture/freezer/publisher are retained one-shot writers, not resume entrypoints.',
                  'granularity': 'Each actual eight-role invocation and 25 native/current full observation rows; exact paired 277-assertion names and 24-failure set; every coherent positive/fault TAP, supplied file, actual reviewer rejection channel/counterfactual, original binding and rendered teaching marker.', 'result': statement},
     'falsify': {'status': 'checked', 'hypothesis': 'An injected callback can donate publication to its enclosing caller, a private wrapper can replace actual callback identity, changed native behavior or incomplete evidence can masquerade as acceptance.',
                 'oracle': 'Exact clean-Git/current same-fixture names and native JSON ledgers; actual eligible-call identity and parent packet retrieval, actual parser-array aliases/public references, native context/value/error/fatal/effect controls; complete source-fault plans and source/population/channel identities.',
                 'red_control': 'Exactly 24 original publication-isolation REDs turn GREEN while 253 original controls pass. For each of three resolvers, boundary removal, actual-to-wrapper callback substitution and original missing/non-CODE validation removal independently produce nine complete semantic source REDs. Five actual reviewer controls reject a failed positive, missing reader input, omitted inverse, lost semantic reason despite rehashed index and missing consumer result. The latter reproduces an early review started before that capture finished; exact restoration passes. Original binding all-zero hash is rejected and restored. Missing SUMMARY fails the book build; removing the teaching marker builds without its rendered content.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-trim-boundary-preservation',
     'statement': 'All 262 original live trim-boundary input bindings and every proof/hash field remain exact; only mode/revision changes to historical at 429d0c6d. Already historical default-selection preservation is unchanged.',
     'scope': 'Exactly the original trim claim and its 262 live inputs at the clean activation commit. This preserves a historical boundary without refreshing old measurements.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                  'granularity': 'Every original Git-bound input and complete before/after JSON; only original live durability mode/revision may differ.',
                  'result': 'All 262 original Git input identities and proof/hash fields match clean 429d0c6d; already historical fields remain exact.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A historical-mode label can hide an altered original input hash.',
                 'oracle': 'Exact original claim from clean Git, complete mode/revision-only JSON comparison and all original input hashes.',
                 'red_control': 'Actual first-original-binding all-zero-SHA corruption fails beyond mode/revision; original bytes restore before readonly PASS. Actual channels and counterfactual bytes are retained.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
TARGET.write_bytes(serialized)
print('Inference claim published:', len(inputs), 'live;', len(historical), 'historical;', len(serialized), 'bytes')
