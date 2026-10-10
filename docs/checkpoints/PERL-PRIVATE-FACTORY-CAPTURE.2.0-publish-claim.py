"""One-shot claim assembly; reviewers are the repeatable verification entrypoints."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'b21b3bb9f6a414d50c71468c3e4193d04ad9b56a'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.2.0'
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
assert runtime['assertions'] == 345 and runtime['cold_assertions'] == 5 and runtime['semantic_source_faults'] == 13
assert runtime['native_differential_modes'] == 30 and runtime['consumer_suites'] == 19 and runtime['supplied_files'] == 138
assert runtime['historical_bindings_preserved'] == 233 and runtime['definition_owned_callbacks'] == 28 and runtime['opaque_publication_modes'] == 6
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
assert len(historical) == 233
original_claim = subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
assert original_claim == before
historical.append({'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'})
statement = ('EmitContext passes345 main/five cold assertions,30 exact native/current observation ledgers and13 '
             'effective semantic source faults;19 direct suites in138 supplied files, four actual reason-sensitive '
             'reviewer REDs and complete57-source book/two controls pass. All233 original framework bindings '
             'are preserved by mode/revision only. Definition-owned actual callback references select28 native '
             'facades; six opaque owner/factory publication modes cannot donate nested packets. The initial '
             'duplicate Trace accounting preflight failure is retained separately from runtime observations.')
record_data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'actual-emitcontext-selection-and-native-dependency-boundaries', 'statement': statement,
     'scope': 'EmitContext prerequisite only: actual definition-owned native references and separate actual owner/default-factory calls. Scalar/list/void native observations preserve existing copied scalar arguments, shared references, once-only effects, return/error/fatal identities and actual factory maps. Cold require and Trace remain compatible. All original136 supplied consumer inputs retained with only EmitContext overlaid plus two fixtures; original three JSON reader inputs remain present. Standard read-only Perl/Python/prove/mdBook/core/toolchain outputs reused in same-volume scratch. No Contracts construction/dependency or other owner integration, pipeline/output/mapped/full-private/canonical/parent admission.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py. Capture/freezer/claim publisher programs are retained one-shot writers, not resume commands.',
                  'granularity': 'Each actual callback identity and native call observation, every coherent345-main/five-cold positive/fault TAP, exact supplied file and command channel, reviewer counterfactual/rejection reason, rendered teaching marker and bounded original binding.', 'result': statement},
     'falsify': {'status': 'checked', 'hypothesis': 'Public-name replacements, dynamic nested publication or changed native contexts/argument copies/map identities/effects/errors can masquerade as native facade behavior; incomplete or altered evidence can masquerade as acceptance.',
                 'oracle': 'Actual retained definition-owned references versus same-name replacement/copied metadata, exact original/current30 JSON observation ledgers from one instrument, explicit owner/factory eligibility ledgers, coherent complete TAP, exact Git/input/channel identities and actual rendered marker.',
                 'red_control': 'Thirteen syntax-valid effective source faults have complete345-main/five-cold plans and named semantic REDs. Four actual reviewer corruptions reject failed positive, missing reader input, omitted inverse and lost semantic reason even with a rehashed index. One frozen original-binding corruption is rejected and restored. Missing SUMMARY fails the book command; removing the new teaching marker builds but loses rendered content. Initial preflight accounting failure is retained separately and is not a product RED.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-framework-boundary-preservation',
     'statement': 'All233 original live framework bindings and every proof field/hash remain exact; only mode/revision changes to historical atb21b3bb9. Already historical input-composition preservation stays unchanged.',
     'scope': 'Exactly the original framework claim and its233 live inputs at the clean activation commit. This preserves a historical boundary; it does not refresh old observations or assert collection-wide claim selection.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                  'granularity': 'Every original233 Git-bound input and complete before/after JSON value; only original live durability mode/revision may differ.',
                  'result': 'Original233 input byte identities and all original proof/hash fields match cleanb21b3bb9; historical scope and already historical fields are preserved.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A frozen claim may silently change an old input hash while retaining a historical mode label.',
                 'oracle': 'Exact original claim from clean Git, bounded mode/revision-only JSON comparison and all original Git input hashes.',
                 'red_control': 'Actual first-original-binding all-zero-SHA corruption fails for original claim changed beyond mode/revision; exact restoration passes the readonly reviewer. Actual channels/counterfactual bytes are retained.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
TARGET.write_text(json.dumps(record_data, indent=2) + '\n')
assert TARGET.stat().st_size <= 131072
print('EmitContext claim published:', len(inputs), 'live inputs;', len(historical), 'historical original inputs/claim')
