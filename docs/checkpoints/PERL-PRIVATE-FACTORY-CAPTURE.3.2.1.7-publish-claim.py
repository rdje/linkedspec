"""Readonly formal trim publication; --capture writes once after complete proof."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'native-review.py', 'book-review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 6
assert review['paired_assertions'] == 507 and review['original_red'] == 144 and review['original_controls'] == 363
assert review['consumer_suites'] == 75 and review['consumer_inputs'] == 243 and review['consumer_assertions'] == 17188
assert review['original_claim_bindings'] == 519 and review['original_claim_bytes'] == 119936
outer = json.loads((ROOT / (PREFIX + 'before-outer-completion.json')).read_bytes())
assert outer['actual_tool_session'] == 87948 and outer['actual_returncode'] == 0
assert outer['producer_sha256'] == sha((ROOT / (PREFIX + 'observe.py')).read_bytes())
assert outer['native_sha256'] == sha((ROOT / (PREFIX + 'before-native.json')).read_bytes())
assert base64.b64decode(outer['merged_log_base64'], validate=True) == b'Formal-trim before native commands retained: 241 inputs; 2 fresh processes\n'
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if path.is_file())
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
    'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for path in sorted(paths)]
statement = ('Exactly four formal trim invocation expressions isolate child publication, preserving '
    'every other production byte/global line. Complete241-input native230 loaded/68 cold rows repeat '
    'byte-exactly before expectations/source edits; afterward only20 actual-CODE and32 symbolic '
    'authority rows change. Identical507 fixture has144 original authority REDs/363 controls/all '
    'GREEN. Fourteen syntax-valid complete-source faults fail36/80/78/76/24/86/232/12/9/250/7/3/3/2. '
    'All75 ordered supplied suites/243 inputs/17188 assertions, six actual semantic evidence '
    'RED/restorations and book89/four controls pass. Original519 bindings/full119936 publication '
    'and actual readonly baseline are preserved before bound writes, with only historical mode/revision changed.')
scope = ('Both complete real brace/dot helpers execute without stubs. Actual CODE references bind '
    'directly; selected named/blessed/amp-callable forms retain opaque local native dispatch. Readonly '
    'core B active pads distinguish writable helper-local expression slots from caller copies and '
    'shared substr lvalues from copied strings; no address is persisted. Receiver mutation changes '
    'the backing trimmed string before final call trim at the original index. Final call trim still '
    'runs before receiver-result validation. Callback snapshots survive caller replacement. Scalar '
    'context under list/void owners, guard order, quote/escape/depth/decimal scanning, reference '
    'identities, native errors at316/7306, coercions, successful errors, fatal objects, already-bound '
    'nesting and lazy cold loading remain exact. Known actual CODE children retain their own '
    'eligibility; opaque callables cannot borrow downstream authority, and children cannot donate '
    'parent packets. Complete original claim membership/519 bindings/full119936 publication and '
    'accepted b1133da422bbf19b54818c97c2b67a5e6a402012 Git inputs recover original bindings without '
    'duplicating their list. First native outer completion actual0 and full inner channels are '
    'retained. No diagnostic/oracle/producer correction or observation refresh occurred; provisional '
    'task source positions were corrected from actual source before assertions. Dot inverse failure '
    'sets overlap because whole-row assertions reach multiple trim sites; their complete union '
    'equals the original144 failures. Six current Knowledge routes and full book populations are '
    'checked. Supplemental standard syntax/public Phase01035 retains actual channels without a '
    'complete transitive capsule. Full guarded private Phase0 remains with '
    'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5. No public syntax, other-backend, '
    'immutable toolchain/cross-version HTML, complete-helper/private/parent/canonical admission is '
    'claimed. One named-helper dispatch ingress .8, FlowExpr/ControlFlow, fixture registration '
    'root .7 before pipeline .6 and independent admissions/TYPE-REFERENCE-BOOK remain owned.')
claim = {'name': 'formal-trim-private-boundaries', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults. All --capture/observe/preserve/run/compat/book writers are one-shot and retired.',
        'granularity': 'All230 loaded/68 cold native rows and exact recurrence;52 complete authority changes;507 identical paired names/144 REDs/363 controls; all14 complete source variants/modes/syntax/channels/named failures; every75 ordered consumer header/numeric plan/17188 assertions and243 supplied inputs; fixed original namespace/519 bindings/full119936/baseline; six semantic corruptions/restorations and89 book inputs/four controls.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Formal trim children may donate parent publication; opaque wrapping may lose actual CODE identity, or direct nonCODE binding may borrow downstream identity. Copies may lose local/substr aliases; altered context/guards/scans may appear equivalent. Retained native/recurrence/consumer/original/book records may be forged beyond immediate hashes.',
        'oracle': 'Complete first native population/exact recurrence and accepted Git source/full original publication; unchanged child-packet fixture with readonly B active pads; complete source faults, all consumer plans, native callable/error identity, full book/source/include/render controls and readonly composed/native/book reviewers.',
        'red_control': 'Identical507 fixture fails144 on original source while363 controls pass; all current GREEN. Four inverses restore36/80/78/76 failures, with overlapping dot whole-row failures and exact union144. Opaque/nonCODE/copy-expr/copy-receiver/copy-call/list/early-guard/depth/quote/decimal faults fail24/86/232/12/9/250/7/3/3/2. Six actual reviewer denials reject hidden inverse RED, forged consumer header, forged original full publication, changed teaching, changed native result and changed recurrence beyond updated immediate hashes; exact restorations pass. Book missing-summary, removed workflow/formal-trim markers despite exit0 and missing-include controls retain actual REDs.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication bytes', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication capture'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('Formal trim publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
