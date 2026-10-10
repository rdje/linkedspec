"""One-shot claim assembly; reviewers are the repeatable verification entrypoints."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'be7d70719856e76b7cb5a427ad6061a7109028ea'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.2.1.1'
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
assert runtime['assertions'] == 447 and runtime['cold_assertions'] == 6 and runtime['semantic_source_faults'] == 20
assert runtime['catalogues'] == 2 and runtime['entries_per_catalogue'] == 174 and runtime['consumer_suites'] == 23 and runtime['supplied_files'] == 142
assert runtime['historical_bindings_preserved'] == 248 and runtime['local_construction_seams'] == 12 and runtime['substituted_factory_controls'] == 14
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
assert len(historical) == 248
original_claim = subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
assert original_claim == before
historical.append({'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'})
statement = ('Actual local/delegated constructor registration passes447 main/six cold assertions and20 '
             'effective semantic source faults. Two complete174-entry native/current catalogues match metadata, '
             'family order, ordinary values and callback reuse patterns. All174 actual returned callbacks select '
             'in scope; twelve local return seams preserve array/hash/lower references and fourteen substituted '
             'factories stay opaque. Twenty-three direct suites in142 supplied files, four reviewer REDs and '
             'complete57-source book/two controls pass. All248 original dependency bindings remain historical '
             'by mode/revision only. Scope selection/restoration/release and cold loading are bounded controls.')
record_data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'actual-local-and-delegated-constructor-registration', 'statement': statement,
     'scope': 'Contracts twelve local literal returns and StagedParseJob/ProgressiveSpanDispatch own constructor returns only. Native/current observations compare two live174-entry catalogues with complete metadata, order, ordinary scalar calls on opaque_literal with controlled undefined-returning dependencies and actual callback reuse patterns; local helper probes compare original/returned arrays, hashes and lower references. Actual registered callback order matches public returned lower fields. Substituted local/delegated factories keep actual public references and cannot register opaque callbacks. Nested source/producer scope restoration, one lexical callback retention/release case and cold construction are explicit bounded controls. All original140 supplied inputs retain three JSON reader artifacts; only the three production owners are overlaid plus two fixtures. Standard read-only core/toolchain outputs reused in same-volume scratch. No other dependency owner, automatic pipeline scopes, output composition, mapped/full-private/canonical/parent admission or universal closure-lifetime claim.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py. Capture/freezer/claim publisher programs are retained one-shot writers, not resume commands.',
                  'granularity': 'Each actual constructor/callback identity, two complete174-entry native/current metadata/value/reuse observations and every coherent447-main/six-cold positive/fault TAP, exact supplied file and command channel, reviewer counterfactual/rejection reason, rendered teaching marker and bounded original binding.', 'result': statement},
     'falsify': {'status': 'checked', 'hypothesis': 'Blind catalogue registration, missing individual seams, cloned public references or leaked scope authority can masquerade as actual native constructor registration; incomplete or altered evidence can masquerade as acceptance.',
                 'oracle': 'Exact original/current complete catalogue JSON ledgers with both actual returned catalogues kept live, local helper reference snapshots, actual eligible-call observations and opaque substituted-factory publication controls, coherent complete TAP, exact Git/input/channel identities and actual rendered marker.',
                 'red_control': 'Twenty syntax-valid effective source faults have complete447-main/six-cold plans and named semantic REDs. Four actual reviewer corruptions reject failed positive, missing reader input, omitted inverse and lost semantic reason even with a rehashed index. One frozen original-binding corruption is rejected and restored. Missing SUMMARY fails the book command; removing the new teaching marker builds but loses rendered content. Every local/delegated seam is removed separately; blind aggregate registration, wrong callback, array/callback copies, global callback retention and cold loading have distinguishing semantic REDs.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-contract-dependency-boundary-preservation',
     'statement': 'All248 original live dependency bindings and every proof field/hash remain exact; only mode/revision changes to historical atbe7d70719. Already historical EmitContext preservation stays unchanged.',
     'scope': 'Exactly the original dependency claim and its248 live inputs at the clean activation commit. This preserves a historical boundary; it does not refresh old observations or assert collection-wide claim selection.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                  'granularity': 'Every original248 Git-bound input and complete before/after JSON value; only original live durability mode/revision may differ.',
                  'result': 'Original248 input byte identities and all original proof/hash fields match cleanbe7d70719; historical scope and already historical fields are preserved.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A frozen claim may silently change an old input hash while retaining a historical mode label.',
                 'oracle': 'Exact original claim from clean Git, bounded mode/revision-only JSON comparison and all original Git input hashes.',
                 'red_control': 'Actual first-original-binding all-zero-SHA corruption fails for original claim changed beyond mode/revision; exact restoration passes the readonly reviewer. Actual channels/counterfactual bytes are retained.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
TARGET.write_text(json.dumps(record_data, indent=2) + '\n')
assert TARGET.stat().st_size <= 131072
print('Constructor claim published:', len(inputs), 'live inputs;', len(historical), 'historical original inputs/claim')
