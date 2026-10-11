"""Current readonly main-method kind publication; --capture writes once."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review-final.py', 'native-review.py', 'book-review-final.py', 'evidence-final.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review-final.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence-final.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 5
assert review['paired_assertions'] == 229 and review['original_red'] == 50 and review['original_controls'] == 179
assert review['consumer_suites'] == 71 and review['consumer_inputs'] == 230 and review['consumer_assertions'] == 15607
assert review['original_claim_bindings'] == 490 and review['original_claim_bytes'] == 113730
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if path.is_file())
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
    'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for path in sorted(paths)]
statement = ('Exactly two injected kind invocation boundaries in _lower_method_value_expr are isolated. '
    'The outer selected base callback and inner AST-assignment selection bind actual CODE identities '
    'directly; tied-selected symbolic names/blessed CODE retain native opaque caller-local dispatch. '
    'All other source bytes/global lines and invalid-call locations2550/3850 remain unchanged. '
    'First loaded91/cold6 and supplemental36 native observations precede assertions/source edits; '
    'the supplemental producer replays the first complete stdout exactly. Current observations '
    'change only20 complete authority rows. Corrected identical229 assertions have50 original '
    'isolation REDs/179 controls/all current GREEN. Nine syntax-valid full-source variants fail '
    '25/25/6/53/41/2/2/74/32. All71 ordered supplied suites/230 inputs/15607 assertions pass. '
    'Five semantic evidence RED/restorations and the complete89-input book/four controls pass. '
    'The full original490-binding/113730-byte publication and actual accepted baseline are preserved '
    'before bound writes, with only its historical mode/revision pair changed.')
scope = ('First normal commit exits1: nine doctrines pass and ROOT-PATHS rejects plaintext absolute tracebacks in two failure records. The complete original75-file staged candidate/full first511-binding119230 publication is preserved in a deterministic compressed capsule. Its first exit metadata anticipated1 while hooks ran; separate actual completion confirms1 and discloses timing. Exact raw diagnostic bytes are base64 encoded, original sources/observations/readers/reports stay immutable, and separate final readers check the sole representation change. The first complete512-input replay fails because nested-cwd Git pathspecs select the wrong claim population; its actual channels/source remain retained. A distinct reader supplies runtime-derived read-only Git directory/work-tree context. Actual complete512-input original publisher replay then passes, changed diagnostic input fails and exact restoration passes. Current book/evidence are separately captured after readonly route changes. ' 'Bounded Perl private dependency repair at two distinct injected bindings. The local outer '
    'kind helper and its22 calls remain local code. Outer selection precedes trim and scalar-function '
    'first refusal precedes its invocation; inner AST assignment reselects after trim. Missing/non-CODE '
    'optional defaults, actual tied-map reads/selected references, local argument aliases/mutations, '
    'scalar context, native values/coercion/errors/fatal identity, map references and cold loading '
    'retain the complete native observations. Existing inner effect/fallback may subsequently invoke '
    'the outer helper and is preserved. Actual registered CODE eligibility survives; no child '
    'donates a packet to its parent. Symbolic names and blessed CODE values acquire no authority by '
    'name. Secondary AST/receiver/value/guard helpers are explicit controls; complete successful '
    'helper behavior is not admitted. Original native producers/ledgers are unchanged. The first229 '
    'fixture wrongly expects known-parent donation: original44 failures and current six oracle '
    'failures, exact first fixture/run producer and first broader failed consumer result are retained. '
    'A sole packet expectation/label correction yields the final pair. Two original fault builders '
    'fail before execution on a global selector also present at old sites; their actual exit1 and '
    'available merged outer channels are retained, separate outer channels unavailable. A distinct '
    'final producer limits those replacements and the list-context fault to the two new call lines; '
    'all first completed source variants remain exact and provisional. Original490 bindings/full '
    'publication are reused with accepted61a73324f06238418301eac88fd3f908665ecbe3 provenance rather '
    'than duplicated; original claim membership comes from that fixed Git boundary. Current record '
    'retains every producer/input and independently checks full original bytes, actual baseline, '
    'complete plans/variant sources/native and teaching/evidence populations. Supplemental standard '
    'syntax/public Phase01035 retains actual channels without a full transitive capsule and confers '
    'no new admission; independent full guarded private Phase0 remains with '
    'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5. No new authored-language failure or '
    'syntax, immutable toolchain, cross-version HTML, all-helper/private/parent/canonical or '
    'other-backend claim. Eleven original ingress sites .4-.8, FlowExpr/ControlFlow, complete fixture '
    'registration .7 before pipeline .6 and independent admissions/TYPE-REFERENCE-BOOK remain owned.')
claim = {'name': 'main-method-optional-kind-private-boundaries', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim-final.py; review-final.py, native-review.py, book-review-final.py and evidence-final.py under the same wrapper/prefix are readonly defaults. Original --capture/observe/preserve/run/compat/book writers are one-shot and retired.',
        'granularity': 'Every91 main/36 supplemental/six cold row and20 complete authority changes; complete original supplemental replay; every229 paired assertion/name and50 REDs/179 controls; each nine full-source fault/source/mode/syntax/actual channels and named failures; every71 ordered consumer header/numeric plan/15607 assertion and230 supplied inputs; original490 bindings/full113730 publication/baseline/fixed claim namespace; first failed fixture/producers/consumers; five actual semantic evidence corruptions/restorations and all89 book inputs/four controls.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Either injected kind invocation may inherit enclosing publication authority, names may acquire actual CODE authority, known children may donate parent packets, selection timing/aliases/context/early refusal may change, or proof source failures/member names/original publications/teaching may be forged after updating immediate hashes.',
        'oracle': 'First complete native populations and exact accepted Git source/full original publication; corrected child-ownership contract with unchanged fixture pair; whole-source variants independently reconstruct each call-line mutation; exact complete consumer plans and actual book/source/include/render/evidence controls.',
        'red_control': 'Final229 fixture on original complete source fails50 while179 controls pass; current all GREEN. Each exact source inverse restores25 disjoint failures whose union is the original50. Opaque/direct/timing/copy/context/first-refusal variants fail6/53/41/2/2/74/32. Five actual reviewer denials reject hidden inverse RED, forged consumer header despite unchanged aggregate, forged original beyond preservation hash, changed teaching beyond report hash and altered encoded diagnostic bytes; every exact restoration passes. Actual book missing-summary, removed workflow/main-method markers despite exit0 and missing-include controls remain retained.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication bytes', len(raw))
if sys.argv[1:]:
    assert TARGET.exists(), 'first unaccepted publication must exist'
    packed = json.loads((ROOT / (PREFIX + 'portability-first-candidate.json')).read_bytes())
    first = json.loads(gzip.decompress(base64.b64decode(packed['data'], validate=True)))
    original = next(item for item in first['staged_files'] if item['path'] == TARGET.relative_to(ROOT).as_posix())
    assert TARGET.read_bytes() == base64.b64decode(original['data_base64'], validate=True), 'preserved first unaccepted publication before replacement'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('Method-kind publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
