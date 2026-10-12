"""Readonly named dispatch publication; --capture writes once after complete proof."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'native-review.py', 'book-review.py', 'headers-review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 7
assert review['paired_assertions'] == 487 and review['original_red'] == 132 and review['original_controls'] == 355
assert review['consumer_suites'] == 76 and review['consumer_inputs'] == 246 and review['consumer_assertions'] == 17675
assert review['original_claim_bindings'] == 522 and review['original_claim_bytes'] == 120245
outer = json.loads((ROOT / (PREFIX + 'before-outer-completion.json')).read_bytes())
assert outer['actual_tool_session'] == 61054 and outer['actual_returncode'] == 0
assert outer['producer_sha256'] == sha((ROOT / (PREFIX + 'observe.py')).read_bytes())
assert outer['native_sha256'] == sha((ROOT / (PREFIX + 'before-native.json')).read_bytes())
assert base64.b64decode(outer['merged_log_base64'], validate=True) == b'Named-dispatch before native commands retained: 244 inputs; 2 fresh processes\n'
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if path.is_file())
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
    'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for path in sorted(paths)]
statement = ('Exactly one selected named-helper invocation expression isolates child publication, '
    'preserving every other production byte/global line. Complete244-input native185 loaded/28 '
    'cold rows repeat byte-exactly before expectations/source edits; afterward only54 complete '
    'authority rows change. Identical487 fixture has132 original authority REDs/355 controls/all '
    'GREEN. Twelve syntax-valid complete-source faults fail132/60/203/205/238/12/41/264/228/7/3/6. '
    'All76 ordered supplied suites/246 inputs/17675 assertions, seven actual semantic evidence '
    'RED/restorations and book89/four controls pass. Original522 bindings/full120245 publication '
    'and actual readonly baseline remain exact before bound writes, with only historical mode/revision changed. '
    'Six current Knowledge headers have scalar readonly routing; original four-orphan RED and all '
    'historical routes/fact bodies are preserved.')
scope = ('The complete real block-side-effect owner executes with six explicit localized actual '
    'CODE callbacks and controlled secondary AST/assignment/component helpers. This is not '
    'complete implementation admission for those six helpers. Readonly core B active pads '
    'distinguish writable local trimmed/deps scalar slots from caller slots and record actual '
    'selected CODE identity without addresses. Six references are selected before iteration. '
    'Mid-call name replacement affects the next owner call; caller localization restores on '
    'success/fatal. Trimmed mutation reaches later helpers; map-content mutation is shared; '
    'replacing the local deps reference reaches subsequent callbacks/fallback while the caller '
    'reference stays exact. First defined nonempty/zero/reference results, scalar context under '
    'list/void owners, eager required669 diagnostics, AST-first/return guards, set-normalizer '
    'assignment/component fallback, coercions, successful errors, fatal identities and cold '
    'loading remain native. Known actual CODE children retain their own eligibility, while '
    'children cannot donate parent packets. Complete original claim membership/522 bindings/'
    'full120245 publication and accepted22132b2b0eccb5ac38ef3c756f1b1e5b08992947 Git inputs recover '
    'all original bindings without duplicating their list. First native/after/fault/consumer '
    'actual outer0 completions and exact merged logs/full inner channels are retained. No '
    'diagnostic/oracle/producer correction or observation refresh occurred. A transient JS '
    'orchestration quoting error occurred before any nested command executed and changed no '
    'artifact. Six-card original syntax census/four-orphan actual RED and current scalar '
    'routing retain every original fact body and archived historical route; ambiguous iterator '
    'routing names its actual .5/accepted99f inputs. Canonical Knowledge gate repair .11 remains '
    'owned immediately after .8 before FlowExpr; no full Knowledge grammar/gate admission is '
    'claimed. Supplemental standard syntax/public Phase01035 retains actual channels without '
    'a complete transitive capsule. Full guarded private Phase0 remains with '
    'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5. No public syntax, other-backend, '
    'immutable toolchain/cross-version HTML, complete-helper/private/parent/canonical admission '
    'is claimed. All17 original MethodLowering inventory sites have bounded repairs; static '
    'calls, FlowExpr/ControlFlow, fixture registration root .7 before pipeline .6 and independent '
    'admissions/TYPE-REFERENCE-BOOK remain owned.')
claim = {'name': 'selected-named-helper-private-boundary', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults. All --capture/observe/preserve/run/compat/book writers are one-shot and retired.',
        'granularity': 'All185 loaded/28 cold native rows and exact244-input recurrence;54 complete authority changes;487 paired names/132 REDs/355 controls; all12 full source variants/modes/syntax/channels/named failures; every76 ordered consumer header/numeric plan/17675 assertions and246 inputs; original namespace/522 bindings/full120245/baseline; seven semantic corruptions/restorations;89 book inputs/four controls; six original/current header populations/four orphan entries and exact original routes/bodies.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Selected helpers may borrow enclosing authority or donate parent packets. Opaque wrappers may lose actual CODE identity; copied arguments may lose local aliases; late name resolution/reordering/context/boolean or defined-only result tests/altered guards may appear equivalent. Native/recurrence/consumer/original/book/header records may be forged beyond immediate hashes.',
        'oracle': 'Complete first native population/exact recurrence, accepted Git source/full original publication and retained actual selected-reference/active-pad observations; identical child-packet ownership fixture, complete source faults and consumer plans; original/current constrained header populations, full book/source/include/render controls and composed/native/book/header reviewers.',
        'red_control': 'Identical487 fixture fails132 original authority assertions while355 controls pass; all current GREEN. Sole exact inverse restores all132 identical failures. Opaque/copy-trimmed/copy-deps/list/boolean/defined/reverse/late-name/AST-guard/return-guard/set-fallback faults fail60/203/205/238/12/41/264/228/7/3/6. Seven actual reviewer denials reject hidden inverse RED, forged consumer header, forged original publication, changed teaching, changed native result, changed recurrence and orphan current header beyond updated immediate hashes; exact restorations pass. Original four-orphan header RED precedes normalization. Book missing-summary, removed workflow/dispatch markers despite exit0 and missing-include controls retain actual REDs.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication bytes', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication capture'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('Named dispatch publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
