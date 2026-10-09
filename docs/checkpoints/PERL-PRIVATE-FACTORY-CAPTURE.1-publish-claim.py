"""One-shot claim assembly; reviewers are the repeatable verification entrypoints."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '02345ee21f9cd674dea073b5e25f6200bd0a6ead'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.1'
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
assert runtime['assertions'] == 224 and runtime['semantic_source_faults'] == 11
assert runtime['native_differential_modes'] == 30 and runtime['consumer_suites'] == 17 and runtime['supplied_files'] == 136
assert runtime['historical_bindings_preserved'] == 232 and runtime['draft_failed_identity_checks'] == 4
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
assert len(historical) == 232
original_claim = subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
assert original_claim == before
historical.append({'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'})
statement = ('Private factory framework passes224 assertions,30 native differential modes and11 effective semantic '
             'source faults;17 direct suites in136 supplied files, four actual reason-sensitive reviewer REDs and '
             'the complete57-source book/two controls pass. All232 original input-composition bindings are preserved '
             'by mode/revision only. Four failed draft identity checks are diagnosed as a native shared callback '
             'reference; lexical fixture closures correct that assumption without changing production bytes.')
record_data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'actual-factory-registration-and-native-dependency-framework', 'statement': statement,
     'scope': 'Standalone private registration/dependency helpers only. Actual callback/source/producer identities, scalar/list/void contexts, first/extra aliases, once-only effects, scalar/reference/undefined/list values, successful error effects, fatal object identity and scope lifetime. All original135 supplied consumer inputs retained with only SourceEmissions overlaid plus the new fixture. Read-only standard Perl/Python/prove/mdBook/core/toolchain outputs reused on same-volume scratch. No production factory/pipeline/output integration, mapped replacement, full private Phase0, immutable toolchain/cross-version closure rule or canonical/parent admission.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py. Capture/freezer/claim publisher programs are retained one-shot writers, not resume commands.',
                  'granularity': 'Each actual callback/source/scope identity and native call observation, every coherent224-assertion positive/fault TAP, exact supplied file and command channel, reviewer counterfactual/rejection reason, rendered teaching marker and bounded original binding.', 'result': statement},
     'falsify': {'status': 'checked', 'hypothesis': 'Callback names/equal values, dynamic nested publication, changed contexts/aliases/effects or premature lifetime can masquerade as native behavior; incomplete or altered evidence can masquerade as acceptance.',
                 'oracle': 'Authored original source interval, actual callback reference and scope comparisons, native-versus-guarded complete observation ledgers, weak references/destructor ledger, complete source-fault TAP and exact Git/artifact/channel identities. Draft shared callback references are diagnosed through the extracted actual native factory body.',
                 'red_control': 'Eleven syntax-valid semantic source faults have complete224-assertion plans and named REDs. Four actual reviewer corruptions reject failed positive, missing reader input, omitted inverse and lost semantic reason even with a rehashed index. One actual frozen original-binding corruption is rejected and restored. Missing SUMMARY fails the book command; removing the new teaching marker builds but loses rendered content. Initial draft failures are retained and are not classified as production REDs.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-input-composition-boundary-preservation',
     'statement': 'All232 original live input-composition bindings and every proof field/hash remain exact; only mode/revision changes to historical at02345ee21. Already historical input-join preservation stays unchanged.',
     'scope': 'Exactly the original input-composition claim and its232 live inputs at the clean activation commit. This preserves a historical boundary; it does not refresh old observations or assert collection-wide claim selection.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                  'granularity': 'Every original232 Git-bound input and complete before/after JSON value; only original live durability mode/revision may differ.',
                  'result': 'Original232 input byte identities and all original proof/hash fields match clean02345ee21; historical scope and already historical fields are preserved.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A frozen claim may silently change an old input hash while retaining a historical mode label.',
                 'oracle': 'Exact original claim from clean Git, bounded mode/revision-only JSON comparison and all original Git input hashes.',
                 'red_control': 'Actual first-original-binding all-zero-SHA corruption fails for original claim changed beyond mode/revision; exact restoration passes the readonly reviewer. Actual channels/counterfactual bytes are retained.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
TARGET.write_text(json.dumps(record_data, indent=2) + '\n')
assert TARGET.stat().st_size <= 131072
print('Framework claim published:', len(inputs), 'live inputs;', len(historical), 'historical original inputs/claim')
