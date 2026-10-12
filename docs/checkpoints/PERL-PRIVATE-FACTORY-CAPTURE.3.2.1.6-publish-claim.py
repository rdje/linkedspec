"""Readonly predicate publication; --capture writes once after complete proof."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6'
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
assert review['paired_assertions'] == 516 and review['original_red'] == 156 and review['original_controls'] == 360
assert review['consumer_suites'] == 74 and review['consumer_inputs'] == 240 and review['consumer_assertions'] == 16681
assert review['original_claim_bindings'] == 517 and review['original_claim_bytes'] == 119899
outer = json.loads((ROOT / (PREFIX + 'before-outer-completion.json')).read_bytes())
assert outer['observed_outer_transport_exit'] is None
assert outer['producer_sha256'] == sha((ROOT / (PREFIX + 'observe.py')).read_bytes())
assert outer['native_sha256'] == sha((ROOT / (PREFIX + 'before-native.json')).read_bytes())
assert base64.b64decode(outer['merged_log_base64'], validate=True) == b'Tracking-predicate before native commands retained: 238 inputs; 2 fresh processes\n'
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if path.is_file())
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
    'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for path in sorted(paths)]
statement = ('Exactly two tracking predicate invocation expressions isolate their children, preserving '
    'every other production byte/global line. First238-input native280 loaded/16 cold rows repeat '
    'byte-exactly before expectations/source edits; afterward only64 complete authority rows change. '
    'The identical516 fixture has156 original authority REDs/360 passing controls/all GREEN. Ten '
    'syntax-valid complete-source faults fail78/78/72/198/56/24/40/230/76/80. All74 ordered supplied '
    'suites/240 inputs/16681 assertions, six actual semantic evidence RED/restorations and complete '
    'book89/four controls pass. Original517 bindings/full119899 publication and actual readonly '
    'baseline are preserved before bound writes, with only historical mode/revision changed.')
scope = ('Both actual predicate validators, one dependency-map FETCH after validation, CODE guards, '
    'selected actual CODE references, writable helper-local target slots and boolean1-or-0 results '
    'execute together with the real receiver guard and scalar-assignment consumers, without secondary '
    'stubs. Readonly core B active-pad inspection distinguishes the original local slot from a copied '
    'callback argument; no address is persisted. Caller target copies, next-call replacement, tied '
    'map selection, once-only effects, native truthiness including false-word/reference results, '
    'scalar boolean context under list/void callers, boolean overload effects, target coercion, '
    'successful errors, fatal object identity and cold loading remain exact. Actual registered CODE '
    'keeps child eligibility; child publication cannot donate a parent packet. Named and blessed '
    'callables retain rejection. All517 original bindings are recoverable through the unchanged '
    '119899-byte full publication and accepted99f2939ac1d5e543bc2aa7f9c38b8166d5d510cc Git inputs, '
    'without duplicating their list. Fixed original claim membership, full native populations, plans '
    'and six current Knowledge routes are checked. First preservation byte-substitution and run '
    'semicolon-constant guards failed before their intended mutation or regression execution; original '
    'producers and actual merged channels stay exact, with separate outer channels unavailable. '
    'Distinct corrected producers are retained and checked. No native observation or fixture '
    'expectation is refreshed. The first native outer transport session id and independently observed outer exit were lost at compaction; '
    'its final completed producer record/log and both inner actual0 channels remain, and distinct '
    'recurrence has an observed outer0. The transient task-count transcription is corrected from '
    'complete actual TAP before acceptance. Supplemental standard syntax/public Phase01035 retains '
    'actual channels without a complete transitive capsule. Full guarded private Phase0 remains with '
    'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5. No public syntax, other-backend, '
    'immutable toolchain/cross-version HTML, complete-helper/private/parent/canonical admission is '
    'claimed. Five remaining original MethodLowering sites .7-.8, FlowExpr/ControlFlow, fixture '
    'registration root .7 before pipeline .6 and independent admissions/TYPE-REFERENCE-BOOK remain owned.')
claim = {'name': 'tracking-predicate-private-boundaries', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults. All --capture/observe/preserve/run/compat/book writers are one-shot and retired.',
        'granularity': 'Every280 loaded/16 cold native row, exact same-source recurrence channels and64 complete authority changes; all516 paired names/156 REDs/360 controls; all ten complete source variants/modes/syntax/channels/named failures; every74 ordered consumer header/numeric plan/16681 assertions and240 supplied inputs; fixed original claim namespace/517 bindings/full119899 publication/baseline; six actual semantic corruptions/restorations and89 book inputs/four controls.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Tracking children may donate parent publication; opaque wrapping may lose actual CODE identity; copied local arguments, repeated map reads, changed validation/CODE guards/context/boolean results may look superficially equivalent; or retained native/recurrence/member/original/book records may be forged beyond rehashed immediate reports.',
        'oracle': 'Complete first native population and exact accepted Git source/full original publication; unchanged child-packet ownership fixture and readonly B local-slot observation; independently reconstructed whole-source variants; complete actual consumer plans, book/source/include/render controls and readonly composed/native/book reviewers.',
        'red_control': 'Identical516 fixture fails156 on original source while360 controls pass; all current GREEN. Exact receiver/nested inverses each restore78 disjoint failures whose union is156. Opaque/copy-target/CODE-guard/early-lookup/reread/context/raw-return/defined-truth faults fail72/198/56/24/40/230/76/80. Six actual reviewer denials reject hidden inverse RED, forged consumer header, forged full original publication, changed teaching, changed native result and changed recurrence beyond updated immediate report/reached/native hashes; exact restorations pass. Book missing-summary, removed workflow/predicate markers despite exit0 and missing-include controls retain actual REDs.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication bytes', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication capture'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('Tracking predicate publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
