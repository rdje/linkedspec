"""Current readonly source/assignment kind publication; --capture writes once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'native-review.py', 'book-review.py', 'evidence.py'):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 5
assert review['paired_assertions'] == 286 and review['original_red'] == 56 and review['original_controls'] == 230
assert review['consumer_suites'] == 72 and review['consumer_inputs'] == 233 and review['consumer_assertions'] == 15893
assert review['original_claim_bindings'] == 531 and review['original_claim_bytes'] == 125217
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if path.is_file())
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
    'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for path in sorted(paths)]
statement = ('Exactly two optional kind invocation boundaries in source-slot bare reads and assignment '
    'are isolated. Actual CODE identity binds directly; tied-selected symbolic/blessed CODE values '
    'retain native opaque caller-local dispatch. All other source bytes/global lines and invalid-call '
    'locations6883/7156 remain unchanged. First231-input loaded156/cold6 observations precede assertions '
    'and source edits; current complete rows differ only in20 intended authority cases. The identical286 '
    'assertion fixture has56 original isolation REDs/230 passing controls/all current GREEN. Nine '
    'syntax-valid full-source variants fail28/28/8/52/37/8/6/75/18. Every72 ordered supplied suite/233 '
    'input/15893 assertion passes. Five semantic evidence RED/restorations and full89-input book/four '
    'controls pass. Original531 bindings/full125217 publication and actual readonly baseline are '
    'preserved before bound writes, with only historical mode/revision changed.')
scope = ('Bounded source-slot read and assignment optional kind calls. Read selection precedes trim '
    'and input rejection; assignment selection follows trim and target guards. All eighteen reserved '
    'source names stop before kind invocation. Bare, migration and nonmatching assignment targets stop '
    'before optional lookup. Eager required validation, missing/non-CODE defaults, two actual tied-map '
    'reads/second selected values, local name aliases/mutations, caller copies, once-only effects, '
    'scalar context, native results/coercion/successful errors/fatal objects, actual map references '
    'and cold loading stay exact. Downstream assignment value/tracked-write helpers are explicit '
    'controls; complete helper behavior is not admitted. Registered CODE eligibility survives, and '
    'every child packet remains separate from its parent; symbolic names/blessed CODE acquire no '
    'authority by resolving a name. Original native producers/observations and the unchanged first '
    'regression remain immutable; no fixture or instrument correction. Full original531 bindings '
    'are reused through the unchanged full125217-byte publication with accepted '
    'dd82f9cbced8311dca8ea8610282780e0c0adf3e provenance rather than duplicated. Fixed original Git '
    'claim membership, exact original claim bytes/mode pair/baseline, complete native/source-fault '
    'and consumer plans, actual book/evidence controls and four current Knowledge routes are checked. '
    'Supplemental standard syntax/public Phase01035 retains actual channels without a full transitive '
    'input capsule and confers no new admission; full guarded private Phase0 remains with '
    'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5. No new authored-language failure '
    'or syntax, immutable toolchain/cross-version HTML, all-helper/private/parent/canonical or '
    'other-backend claim. Nine original ingress sites .5-.8, FlowExpr/ControlFlow, complete fixture '
    'registration root .7 before pipeline .6 and independent admissions/TYPE-REFERENCE-BOOK remain owned.')
claim = {'name': 'source-assignment-optional-kind-private-boundaries', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults. All --capture/observe/preserve/run/compat/book writers are one-shot and retired.',
        'granularity': 'Every156 loaded/six cold native row and20 complete authority changes; all286 paired assertion names/56 REDs/230 controls; each nine complete variant sources/modes/syntax/actual channels/named failures; every72 ordered consumer header/numeric plan/15893 assertion and233 supplied inputs; fixed original claim namespace/531 original bindings/full125217 publication/baseline; five actual semantic corruptions/restorations and full89 book inputs/four controls.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Either injected kind call may inherit parent publication authority; symbolic selection may gain registered CODE authority; selected callbacks, local aliases/context or early guards may change; or proof rows/member names/original publication/teaching may be forged beyond updated immediate hashes.',
        'oracle': 'Complete first native populations and exact accepted Git source/full original publication; unchanged child-packet ownership fixture; independently reconstructed full-source faults; every complete actual consumer plan, actual book/source/include/render controls and readonly composed reviewer.',
        'red_control': 'Original unchanged286 fixture fails56 while230 controls pass; all current GREEN. Each exact source inverse restores28 disjoint failures whose union is the original56. Opaque/direct/timing/copy/context/reserved faults fail8/52/37/8/6/75/18. Five actual reviewer denials reject hidden inverse RED, forged consumer header despite unchanged aggregate, forged original beyond preservation hash, changed teaching beyond report hash and altered native channels beyond updated report/reached hashes; every exact restoration passes. Actual book missing-summary, removed workflow/new kind markers despite exit0 and missing-include controls remain retained.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication bytes', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication capture'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('Source-assignment publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
