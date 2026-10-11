"""Readonly small optional-kind publication; --capture writes its record once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'evidence.py', 'consumer-review.py', 'book-review.py', 'compatibility/run.py'):
    result = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('actual readonly proof', tail, result.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 6
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / (PREFIX + 'compatibility')).rglob('*') if p.is_file())
assert PREFIX + 'publish-claim.py' in paths and PREFIX + 'compatibility/result.json' in paths
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t') else 'input'} for p in sorted(paths)]
statement = ('Isolate exactly three optional kind invocations in _infer_assignment_source_container_kind, '
    '_uniform_binding_target_symbol and _codeblock_variable_call_candidate. First216-input observations '
    'retain18 callback outcomes,105 guard cases,6 authority rows and9 cold cases. Separate first217/218-input '
    'probes retain42 symbolic-selection and10 object-name rows. The sole object-probe once-warning repair '
    'preserves all original stdout bytes. First1135 TAP has58 failures including one wrong authored cache '
    'oracle; its sole map-entry repair precedes final identical1135 TAP with57 isolation REDs and1078 '
    'passing controls, then all1135 current GREEN. Nine syntax-valid whole-source faults fail15/15/27/7/29/ '
    '34/19/12/70 for named reasons. Supplied69 suites/223 inputs/15093 assertions, six evidence RED/ '
    'restorations beyond immediate hashes, and complete89-input book/three controls pass. All339 original '
    'trim bindings/full78325-byte record and actual accepted publisher baseline remain preserved. '
    'Supplemental standard syntax/public Phase0 passes1035 with complete channels.')
scope = ('Only these three private boundaries change. Existing optional CODE guard reads and second '
    'selections, default behavior, actual CODE identity, function-inventory/parameter precedence, actual '
    'match versus local aliases, object identity/coercion/effects, scalar context, incoming/success/fatal '
    'errors, map replacement, native diagnostics and cold laziness remain exact. MethodLowering may '
    'execute a symbolic or blessed CODE second selection after a different first CODE check. Such '
    'non-CODE selections use caller-local opaque delegation at the original invalid-call source location '
    '272/1292/1509; resolving a name never grants authority. Actual unblessed CODE binds directly. Whole '
    'module and each owner retain native line counts; comment/blank placement solely preserves diagnostic '
    'locations. Required/secondary helpers are explicit controls, not complete helper admission. The '
    'first non-live-input census KeyError, object-probe once-warning rejection and wrong authored '
    'container-empty oracle remain byte-bound with available original merged parent channels and exact '
    'sole repairs. Separate216-input native diagnosis runs two fresh opposite array/hash orders: first '
    'container succeeds, second correct container declines before kind lookup because /o caches the '
    'first interpolation. This existing defect stays unchanged here; P2 .3.2.1.9 owns repair after due '
    'clean-boundary hygiene and before .3. No authored-language failure is inferred. Original trim '
    'claim retains all339 bindings historically at61cca1cccff6027461e120e4236431d1bc7d20b1; this publication '
    'reuses that full claim instead of duplicating its list. No original observation or producer hash '
    'is refreshed. Supplemental standard live-worktree compatibility has no complete transitive input '
    'capsule, benchmark or output-volume comparison. OS/toolchain immutability or cross-version identity '
    'is not claimed. Thirteen original ingress sites under .3-.8, FlowExpr/ControlFlow, fixture registration '
    'root .7 before pipeline root .6, full-private/output/mapped/parent/canonical admissions and '
    'TYPE-REFERENCE-BOOK retain separate owners.')
claim = {'name': 'three-small-optional-kind-private-boundaries', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; review.py, evidence.py, '
            'consumer-review.py, book-review.py and compatibility/run.py are also readonly by default. '
            'All --capture/native/freeze/fault/book writers are retired one-shot producers.',
        'granularity': 'Each native callback/guard/authority/cold/symbolic/object row and every actual '
            'complete216/217/218/223 input capsule; exact whole-module three-owner change and nine '
            'full-source counterfactuals; identical1135 TAP members; original58 versus final57 REDs and '
            'sole fixture/probe repairs; complete69 ordered suite paths/plans/15093 members; six damaged '
            'evidence records with actual rejection/restoration channels; original339 bindings/full78325 '
            'bytes/actual baseline; full89 book inputs/three controls; two fresh cache orders/four calls; '
            'supplemental three standard command results including1035 public assertions.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'The three raw invocations already isolate publication, or wrappers/copies/coercion/ '
            'guard removal/early-decision removal/name resolution preserve all native contracts and actual '
            'authority. Retained evidence can be censored or forged after updating immediate hashes.',
        'oracle': 'Immutable native complete observations, independently reconstructed accepted source '
            'and scoped full mutants, exact paired TAP populations, original Git/full publication, '
            'actual object/reference/alias/error/authority observations, independent supplied consumer '
            'population/command/member and complete rendered book/include/marker review.',
        'red_control': 'Final original57 isolation RED/1078 controls; first58 includes precisely the '
            'retained wrong container-empty oracle. Nine whole-source faults fail15/15/27/7/29/34/19/12/70 '
            'with named reasons. Six actual evidence controls reject false positive TAP, censored '
            'fault label, false map identity, omitted checkpoint command, forged original beyond freeze '
            'hash and changed book beyond report hashes, each followed by exact-restored healthy '
            'review. Full book controls retain missing SUMMARY, removed marker despite exit0 and '
            'missing include. Fresh cache diagnosis establishes first-versus-current container distinction '
            'but does not claim its repair in this leaf.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, 'bounded claim record'
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact readonly publication'
print('Small optional-kind publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
