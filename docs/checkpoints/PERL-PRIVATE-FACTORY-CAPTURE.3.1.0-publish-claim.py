"""One-shot bounded three-caller MethodLowering trim-binding claim assembly."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '89a4ede6fbbb0f3b7a4e4f98a4b477b79c0cfeb7'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert not TARGET.exists(), 'one-shot claim already published'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
record = lambda tail: json.loads((ROOT / (PREFIX + tail)).read_bytes())
runtime, book, final = (record(tail) for tail in ('review.json', 'book-review.json', 'final-review.json'))
evidence, preservation = (record(tail) for tail in ('evidence.json', 'preservation-control.json'))
assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
assert (runtime['assertions'], runtime['cold_assertions'], runtime['semantic_source_faults']) == (255, 5, 13)
assert (runtime['native_differential_modes'], runtime['actual_caller_modes'], runtime['consumer_suites'], runtime['supplied_files']) == (15, 9, 27, 146)
assert runtime['historical_bindings_preserved'] == 282 and runtime['retained_partial_attempt_captures'] == 18
assert runtime['paired_original_semantic_failures'] == 11 and runtime['paired_original_passing_controls'] == 244
assert book['source_count'] == 57 and book['actual_controls'] == 2 and len(evidence['rows']) == 4
assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0 and preservation['restored']['returncode'] == 0
paths = set(runtime['checked']) | set(book['source_inputs']) | set(final['checked'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': p, 'sha256': digest((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pm', '.t') else 'input'} for p in sorted(paths)]
freeze = record('freeze.json')
before = (ROOT / freeze['before']).read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
original = json.loads(before)
historical = [entry for claim in original['claims'] if claim['durability'].get('mode') == 'live'
              for entry in claim['durability']['inputs']]
assert len(historical) == 282
historical.append({'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'})
statement = ('Private MethodLowering trim bindings pass255 main/five cold assertions and13 effective '
             'syntax-valid semantic source faults. The same full fixture has exactly eleven original '
             'publication-isolation REDs and all255 current GREEN, with244 original controls passing. '
             'Fifteen native dependency and nine actual caller ledgers match. Twenty-seven supplied suites '
             'in146 files, evidence4, original-binding RED and complete57-source book/two controls pass. '
             'All282 original default-selection bindings remain historical. The partial attempt retains18 '
             'actual captures/producer; only two inherited assertion matcher labels change before recapture, '
             'with unchanged production/fixtures.')
result = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'method-required-trim-dependency-isolation', 'statement': statement,
     'scope': runtime['scope'] + ' Complete supplied144-file Git population retains all three JSON reader artifacts; only MethodLowering overlaid and two fixtures added. Standard read-only interpreter/core/toolchain outputs reused in repository-volume scratch.',
     'rederive': {'status': 'checked',
       'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py. Capture/freezer/publisher are retained one-shot writers, not resume entrypoints.',
       'granularity': 'Every actual three-caller required trim invocation, native scalar/list/void dependency mode, original/current full255-assertion population and exact11 failure-name difference; every coherent255-main/five-cold positive/source-fault TAP, supplied file and command channel, actual reviewer counterfactual/rejection reason, original binding and rendered teaching marker.',
       'result': statement},
     'falsify': {'status': 'checked',
       'hypothesis': 'A known enclosing caller can inherit opaque injected publication, context/argument copies can masquerade as native behavior, or incomplete/altered proof can masquerade as acceptance.',
       'oracle': 'Actual clean-Git/current same-fixture complete plans and exact eleven failure-name RED/GREEN difference; native direct callback/current private binding and actual three caller JSON ledgers; actual eligible-call/packet retrieval, original map/callback references and native effects/errors/fatal identities; coherent full TAP and exact source/input/channel hashes, plus actual rendered teaching marker.',
       'red_control': 'Original source has exactly eleven complete semantic isolation failures while other244 controls pass. Each of three required return seams and the primitive boundary is removed separately; alias copies, list/void coercion, repeated effects, changed incoming/successful error state, fatal-object stringification, global callback retention and eager cold loading produce thirteen effective named semantic source REDs with complete plans. Four actual reviewer corruptions reject failed positive, missing JSON reader input, omitted inverse and lost semantic reason even with a rehashed index. Original all-zero input hash is rejected beyond mode/revision and restored. Missing SUMMARY fails the book command; removing the new teaching marker builds but loses rendered content. The partial failed matcher attempt retains18 actual captures and its original producer; exact two-label correction and unchanged runtime input bytes are independently reconstructed.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-method-default-boundary-preservation',
     'statement': 'All282 original method-default live bindings and all proof/hash fields remain exact; only live durability mode/revision changes to historical at89a4ede6f. Already historical fields remain unchanged.',
     'scope': 'Exactly the original method-default claim and its282 live inputs at the clean activation boundary. Historical preservation does not refresh old observations or imply collection-wide claim admission.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
       'granularity': 'Every original282 Git-bound input and complete before/after claim value, permitting only original live durability mode/revision changes.',
       'result': 'Original282 Git input byte identities and all proof/hash fields match clean89a4ede6f; already historical content is preserved.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A historical label can hide a changed original input hash.',
       'oracle': 'Exact original claim from clean Git, mode/revision-only JSON comparison and every original Git input hash.',
       'red_control': 'Actual first-original-binding all-zero SHA mutation rejects for original claim changed beyond mode/revision; exact restoration passes. Actual counterfactual bytes/channels are retained.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
serialized = (json.dumps(result, indent=2) + '\n').encode()
assert len(serialized) <= 131072
TARGET.write_bytes(serialized)
print('Method trim claim published:', len(inputs), 'live inputs;', len(historical), 'historical original inputs/claim')
