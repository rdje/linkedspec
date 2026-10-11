"""Readonly optional AST publication; --capture writes once after complete proof."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'iterator-review.py', 'native-review.py', 'book-review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 6
assert review['paired_assertions'] == 272 and review['original_red'] == 44 and review['original_controls'] == 228
assert review['consumer_suites'] == 73 and review['consumer_inputs'] == 237 and review['consumer_assertions'] == 16165
assert review['original_claim_bindings'] == 498 and review['original_claim_bytes'] == 114980
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if path.is_file())
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
    'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for path in sorted(paths)]
statement = ('Exactly two optional AST invocation boundaries isolate pipeline and assignment children. '
    'Actual CODE identity stays direct; tied-selected symbolic/blessed assignment calls stay opaque '
    'and caller-local. All other production bytes/global lines/native2170 are unchanged. First '
    '234-input unordered diagnostic captures retain24 order-only differences; a distinct235-input '
    'sorted iterator changes only two probe bodies and repeats148 loaded/six cold rows/stdout bytes '
    'before authored assertions/source edits. After-change rows differ only in16 authority cases. '
    'The identical272 assertion fixture has44 original isolation REDs/228 passing controls/all GREEN. '
    'Eleven syntax-valid whole-source faults fail10/34/8/26/37/35/47/82/2/36/11. All73 ordered '
    'supplied suites/237 inputs/16165 assertions pass. Six actual semantic evidence RED/restorations '
    'and full89-input book/four controls pass. Original498 bindings/full114980 publication and actual '
    'readonly baseline are preserved before bound writes, with only historical mode/revision changed.')
scope = ('The real AST block pipeline owner reads once and guards the selected value as CODE before '
    'invocation. Its actual node source/span slots, span HASH and first nonempty result/fallback '
    'order remain exact. The AST assignment owner validates required dependencies and normalizes '
    'before optional selection; its CODE check/second map read, actual effective ARRAY slots and '
    'existing local fallback thunk/original map are preserved. The fallback thunk stays opaque '
    'even if its downstream helper is registered. Callback replacement timing, source/effective '
    'ARRAY mutation, ordinary values/undefined/empty/zero/reference/coercion/context/successful '
    'errors/fatal objects, native invalid-call locations and cold loading remain exact. Secondary '
    'parse/component/assignment/value/guard helper bodies are explicit controls, conferring no '
    'complete helper or authored-language admission. Every child packet stays separate from its '
    'parent; registered actual CODE remains eligible. Original first diagnostic producers/ledgers '
    'are immutable; the iterator fixture repair uses a distinct producer/input/native-first pair, '
    'rather than refreshing or normalizing original observations. All498 original bindings are '
    'recovered through the unchanged114980-byte full publication and accepted '
    '15197dfdf0f198a4eb25517e278edba491d12db7 Git inputs without duplicating that list. Fixed original '
    'claim membership, preservation baseline, complete plans/source faults/native rows and six '
    'current Knowledge routes are checked. Supplemental standard syntax/public Phase01035 has '
    'actual channels without a complete transitive capsule. Full guarded private Phase0 remains '
    'with SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5. No public syntax or other-backend '
    'change, immutable toolchain/cross-version HTML, full-helper/private/parent/canonical admission '
    'is claimed. Seven remaining MethodLowering sites .6-.8, FlowExpr/ControlFlow, fixture registration '
    'root .7 before pipeline .6 and independent admissions/TYPE-REFERENCE-BOOK remain owned.')
claim = {'name': 'ast-optional-pipeline-assignment-private-boundaries', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; review.py, iterator-review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults. All --capture/observe/preserve/run/compat/book writers are one-shot and retired.',
        'granularity': 'Every148 loaded/six cold native row and16 complete authority changes; both original unordered and distinct stable recurrence populations/channels; all272 paired names/44 REDs/228 controls; each eleven complete source variants/modes/syntax/channels/named failures; every73 ordered consumer header/numeric plan/16165 assertion and237 supplied input; fixed original claim namespace/498 bindings/full114980 publication/baseline; six actual semantic corruptions/restorations and89 book inputs/four controls.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Optional AST children may inherit parent publication; wrapping actual CODE may discard identity; copied arguments, altered map acquisition/guards/context/fallback may preserve superficially matching text; or native/recurrence/member/original/book records may be forged beyond rehashed immediate reports.',
        'oracle': 'Complete first native populations and exact accepted Git source/full original publication; unchanged child-packet ownership fixture; independently reconstructed complete-source variants; complete actual consumer plans, actual book/source/include/render controls and readonly composed/native/iterator reviewers.',
        'red_control': 'Original identical272 fixture fails44 while228 controls pass; all current GREEN. Exact pipeline/assignment inverses restore10/34 disjoint failures whose union is44. Opaque/direct/copy-source/copy-span/copy-effective/context/early-selection/CODE-guard/fallback-map variants fail8/26/37/35/47/82/2/36/11. Original unchanged-source probe has24 order-only differences; distinct stable recurrence is byte-exact. Six actual reviewer denials reject hidden inverse RED, forged consumer header, forged original publication, changed teaching, changed native result and changed iterator recurrence beyond updated immediate report/reached hashes; all exact restorations pass. Book missing-summary, removed workflow/AST markers despite exit0 and missing-include controls are retained.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication bytes', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication capture'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('AST optional publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
