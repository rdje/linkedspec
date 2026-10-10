"""One-shot claim assembly; reviewers are the repeatable verification entrypoints."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2d878478028fc417ac5b7790c016543c18c1f48b'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.2.1.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert not TARGET.exists(), 'one-shot claim already published'
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


runtime = record('review.json')
book = record('book-review.json')
final = record('final-review.json')
evidence = record('evidence.json')
preservation = record('preservation-control.json')
assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
assert runtime['assertions'] == 312 and runtime['cold_assertions'] == 6 and runtime['semantic_source_faults'] == 16
assert runtime['native_differential_modes'] == 15 and runtime['consumer_suites'] == 21 and runtime['supplied_files'] == 140
assert runtime['historical_bindings_preserved'] == 235 and runtime['dependency_slots'] == 27 and runtime['draft_failed_lifetime_checks'] == 1 and runtime['lifetime_probe_modes'] == 4
assert book['source_count'] == 57 and book['actual_controls'] == 2 and len(evidence['rows']) == 4
assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0 and preservation['restored']['returncode'] == 0
paths = set(runtime['checked']) | set(book['source_inputs']) | set(final['checked'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': path, 'sha256': digest((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pm', '.t') else 'input'}
          for path in sorted(paths)]
freeze = record('freeze.json')
before = (ROOT / freeze['before']).read_bytes()
original = json.loads(before)
historical = [entry for claim in original['claims'] if claim['durability'].get('mode') == 'live'
              for entry in claim['durability']['inputs']]
assert len(historical) == 235
original_claim = subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
assert original_claim == before
historical.append({'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'})
statement = ('Contracts private dependency/default integration passes312 main/six cold assertions,15 exact '
             'native/current observation ledgers and16 effective semantic source faults;21 direct suites in140 '
             'supplied files, four actual reason-sensitive reviewer REDs and complete57-source book/two controls '
             'pass. Required/optional/bare calls have separate boundaries while public maps and callbacks remain '
             'actual. All235 original EmitContext bindings are preserved by mode/revision only. The failed '
             'no-lexical-state lifetime premise is retained and diagnosed at original/current source boundaries; '
             'its lexical fixture correction leaves production bytes unchanged.')
record_data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'actual-contracts-private-bindings-and-native-default-selection', 'statement': statement,
     'scope': 'Contracts private required/optional/bare dependency bindings and native built-in default selection only. Public maps/default results/callback fields keep actual references. Complete15-mode observations preserve contexts, first/extra caller aliases, shared references, once-only effects, values, successful error effects and fatal identity. All27 required/optional slots, dropped fallback, actual input_slice and both bare child-call push paths have distinguishing publication controls. Cold require and Trace remain compatible; original138 supplied inputs retain all three JSON reader artifacts, only Contracts is overlaid plus two fixtures. Standard read-only core/toolchain outputs reused in same-volume scratch. No actual contract lower construction registration, other owner, pipeline/output/mapped/full-private/canonical/parent admission or universal native closure-lifetime rule.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py. Capture/freezer/claim publisher programs are retained one-shot writers, not resume commands.',
                  'granularity': 'Each actual callback identity and native call observation, every coherent312-main/six-cold positive/fault TAP, exact supplied file and command channel, reviewer counterfactual/rejection reason, rendered teaching marker and bounded original binding.', 'result': statement},
     'falsify': {'status': 'checked', 'hypothesis': 'Custom default targets or public-name replacements, dynamic nested publication or changed native contexts/aliases/map identities/effects/errors can masquerade as native facade behavior; incomplete or altered evidence can masquerade as acceptance.',
                 'oracle': 'Actual native default references versus custom targets/same-name replacement, exact original/current15 JSON observation ledgers from one instrument, authored slot/input_slice/bare/fallback and weak-reference observations, coherent complete TAP, exact Git/input/channel identities and actual rendered marker.',
                 'red_control': 'Sixteen syntax-valid effective source faults have complete312-main/six-cold plans and named semantic REDs. Four actual reviewer corruptions reject failed positive, missing reader input, omitted inverse and lost semantic reason even with a rehashed index. One frozen original-binding corruption is rejected and restored. Missing SUMMARY fails the book command; removing the new teaching marker builds but loses rendered content. One actual failed draft lifetime assertion and failed direct-consumer run are retained with original instrument/fixture/source. The exact lifetime block fails at original/current boundaries with no lexical state; a lexical-state control passes both. This reverifies the retained native shared-closure finding and is not a production retention RED.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-emitcontext-boundary-preservation',
     'statement': 'All235 original live EmitContext bindings and every proof field/hash remain exact; only mode/revision changes to historical at2d8784780. Already historical framework preservation stays unchanged.',
     'scope': 'Exactly the original EmitContext claim and its235 live inputs at the clean activation commit. This preserves a historical boundary; it does not refresh old observations or assert collection-wide claim selection.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                  'granularity': 'Every original235 Git-bound input and complete before/after JSON value; only original live durability mode/revision may differ.',
                  'result': 'Original235 input byte identities and all original proof/hash fields match clean2d8784780; historical scope and already historical fields are preserved.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A frozen claim may silently change an old input hash while retaining a historical mode label.',
                 'oracle': 'Exact original claim from clean Git, bounded mode/revision-only JSON comparison and all original Git input hashes.',
                 'red_control': 'Actual first-original-binding all-zero-SHA corruption fails for original claim changed beyond mode/revision; exact restoration passes the readonly reviewer. Actual channels/counterfactual bytes are retained.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
TARGET.write_text(json.dumps(record_data, indent=2) + '\n')
assert TARGET.stat().st_size <= 131072
print('Contracts claim published:', len(inputs), 'live inputs;', len(historical), 'historical original inputs/claim')
