"""One-shot bounded MethodLowering default-selection claim assembly."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '33e57deee73e27b97e9c21116bc70942f3f33772'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert not TARGET.exists(), 'one-shot claim already published'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
record = lambda tail: json.loads((ROOT / (PREFIX + tail)).read_bytes())
runtime, book, final = (record(tail) for tail in ('review.json', 'book-review.json', 'final-review.json'))
evidence, preservation = (record(tail) for tail in ('evidence.json', 'preservation-control.json'))
assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
assert (runtime['assertions'], runtime['cold_assertions'], runtime['semantic_source_faults']) == (426, 6, 24)
assert (runtime['maps'], runtime['callbacks_per_map'], runtime['consumer_suites'], runtime['supplied_files']) == (2, 19, 25, 144)
assert runtime['historical_bindings_preserved'] == 244 and runtime['initial_captures_preserved'] == 30
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
assert len(historical) == 244
historical.append({'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'})
statement = ('MethodLowering default native-reference selection passes426 main/six cold assertions, '
             'two exact native/current19-callback map ledgers and24 effective syntax-valid source faults. '
             'Twenty-five direct suites in144 supplied files, four actual reviewer REDs, one original-binding '
             'RED and complete57-source book/two controls pass. All244 original construction bindings remain '
             'historical by mode/revision only. Initial all-GREEN capture/producer retained before prose-only '
             'harness correction and successful actual recapture with unchanged production/fixtures.')
result = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'method-default-native-reference-selection', 'statement': statement,
     'scope': runtime['scope'] + ' Complete supplied142-file Git population retains all three JSON reader artifacts; only the two production owners overlaid and two fixtures added. Standard read-only interpreter/core/toolchain outputs reused in repository-volume scratch.',
     'rederive': {'status': 'checked',
       'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py. Capture/freezer/publisher are retained one-shot writers, not resume entrypoints.',
       'granularity': 'Every native default callback/map/ref/target, every coherent426-main/six-cold positive/fault TAP and actual command/input/channel identity; two complete native/current maps, all supplied direct suites, actual reviewer counterfactual/rejection reason, original binding and rendered teaching marker.',
       'result': statement},
     'falsify': {'status': 'checked',
       'hypothesis': 'Public names or custom aliases can masquerade as native callback construction, a copied map as the actual public result, and incomplete/altered evidence as acceptance.',
       'oracle': 'Original clean-Git native map ledger and actual OwnerDispatch map/ref snapshots; retained actual native definitions versus every same-name replacement, custom aliased target, scoped known-reference observation and actual opaque equal-text publication attempt; coherent complete TAP, exact source/input/channel hashes and actual rendered marker.',
       'red_control': 'All nineteen native reference entries removed individually; missing factory registration, custom target bypass, native reference comparison bypass, public map copying and eager cold loading produce24 effective syntax-valid named semantic REDs with complete plans. Four actual reviewer corruptions reject failed positive, missing JSON reader input, omitted inverse and lost semantic reason even with a rehashed index. Original all-zero input hash is rejected beyond mode/revision and restored. Missing SUMMARY fails the book command; removing the new teaching marker builds but loses rendered content. Initial30 all-GREEN captures and producer are preserved; the scope-label correction alone is independently reconstructed.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-constructor-boundary-preservation',
     'statement': 'All244 original construction live bindings and all proof/hash fields remain exact; only live durability mode/revision changes to historical at33e57deee. Already historical fields remain unchanged.',
     'scope': 'Exactly the original construction claim and its244 live inputs at the clean activation boundary. Historical preservation does not refresh old observations or imply collection-wide claim admission.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
       'granularity': 'Every original244 Git-bound input and complete before/after claim value, permitting only original live durability mode/revision changes.',
       'result': 'Original244 Git input byte identities and all proof/hash fields match clean33e57deee; already historical content is preserved.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A historical label can hide a changed original input hash.',
       'oracle': 'Exact original claim from clean Git, mode/revision-only JSON comparison and every original Git input hash.',
       'red_control': 'Actual first-original-binding all-zero SHA mutation rejects for original claim changed beyond mode/revision; exact restoration passes. Actual counterfactual bytes/channels are retained.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
TARGET.write_text(json.dumps(result, indent=2) + '\n')
assert TARGET.stat().st_size <= 131072
print('Method default claim published:', len(inputs), 'live inputs;', len(historical), 'historical original inputs/claim')
