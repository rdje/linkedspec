"""Readonly package-flow publisher; --capture writes the bounded record once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
BASE = '4cc0b5a2a39ef3eec8baafbf874e43bd855e8b31'
FLOW_BASE = '4b48593b59acb7aba4d616ae1bdc4320fbbf5364'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'evidence.py', 'compatibility/run.py'):
    command = ['python3', PREFIX + tail]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('actual readonly proof', command, result.stderr)
report = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert report['result'] == evidence['result'] == 'PASS' and len(evidence['controls']) == 7
assert json.loads((ROOT / (PREFIX + 'evidence-reached.json')).read_bytes()) == {'healthy': evidence['healthy'], 'rows': evidence['controls']}
paths = set(report['input_metadata']) | set(evidence['inputs'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / (PREFIX + 'compatibility')).rglob('*') if p.is_file())
paths.update('docs/knowledge/' + name + '.md' for name in ('perl-method-slot-required-capture', 'perl-method-ast-assignment-capture'))
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t') else 'input'} for path in sorted(paths)]
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in report['input_metadata'].items())
statement = ('The single reachable legacy package-flow invocation has a private emission boundary while actual '
    'package CODE selection, trimmed-slot aliases, scalar context, callback/maps/replacement/localization, ordinary '
    'values/effects/errors and public generated source remain native. First209-input observations retain4 outcomes/'
    '32 branches/2 authority/2 public/2 cold rows. Identical299 TAP retains3 original isolation REDs/296 controls and '
    'all299 current GREEN. Six syntax-valid full-source faults fail3/1/35/85/55/7. Final supplied67 actual suite '
    'paths/plans/211 inputs/13660 assertions, seven actual evidence RED/restorations and full book89/three controls pass.')
limits = ('Only the direct call in _lower_mutation_slot_value_expr changes. The package variable remains the '
    'selector; the same-named map callback stays uninvoked. Flow compares its result with the actual slot after '
    'effects and passes that slot to method/source fallback. Actual references, fatal object, successful error '
    'effect, zero/empty/undefined guards and cold laziness survive. Explicit secondary bare/primitive/method/'
    'migration controls and public Toolbox rows are bounded generated-source proof, not complete helper/DSL '
    'admission. First captures/faults remain exact. The first capture producer has a copied two-resolver scope '
    'phrase; its preserved source and sole descriptive correction are gated. Initial source indentation and '
    'consumer-review count denials retain exact instruments and complete merged channels; separate stdout/stderr '
    'were not retained for those two failed shell invocations. Distinct final current/fixture/consumer executions '
    'verify the sole whitespace correction, with original observations/hashes unchanged. The six source faults '
    'use the first semantically identical module and exact supplied inputs. Earlier public compact-argument '
    'premise rejection and all six historical replay channels stay explicit at4b48593b5. All350 accepted '
    'predecessor bindings/full84391-byte record and actual accepted publisher baseline stay exact; only one live '
    'mode/revision pair becomes historical at4cc0b5a2a. Standard syntax/public Phase01035 retains complete '
    'supplemental channels without a full transitive input capsule; that run began before the whitespace-only '
    'correction. Remaining optional/direct families, full-private, FlowExpr/ControlFlow, pipeline/output/mapping/'
    'parent/canonical admissions and TYPE-REFERENCE-BOOK remain separately owned.')
primary = {'name': 'legacy-package-flow-callback-isolation', 'statement': statement, 'scope': limits,
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX +
        'publish-claim.py; separately review.py, consumer-review.py, book-review.py and evidence.py through '
        'that wrapper/prefix. Defaults readonly; every capture/freezer/fault writer is one-shot and retired.',
        'granularity': 'Every209 native/current and211 paired input; all4/32/2/2/2 native rows,299 TAP names/'
            'three original REDs/six full source faults; all67 final consumer paths/plans/13660 assertions;89 book '
            'sources/three controls; seven complete damaged/restored evidence populations;350 original accepted '
            'bindings/full84391-byte claim; exact rejected instrument sources/merged channels and final runs.',
        'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'Equal-text children may donate publication; wrapper identities, '
        'copied arguments, dependency map substitution or caller-based equality may preserve native behavior; '
        'immediate artifact hashes may hide missing semantic reasons, checkpoint suites or original fields.',
        'oracle': 'Immutable native observations plus authored results, actual slot/object/callback identities, '
            'known eligibility and parent packet lookup; independent whole-source/mutant reconstruction and '
            'complete TAP/consumer/book census; accepted Git predecessor and historical diagnosis.',
        'red_control': 'Three exact original isolation failures become GREEN while296 controls survive. Six '
            'syntax-valid full-module faults retain named failures3/1/35/85/55/7. Seven actual evidence REDs '
            'reject failed positive, stale fault artifact, erased semantic reason beyond updated index, false '
            'native flag, omitted checkpoint beyond updated immediate review hash, forged original binding '
            'beyond updated freeze SHA and changed book source; every exact restoration passes. Three book '
            'controls reject missing SUMMARY, remove the rendered marker despite exit0 and diagnose omitted include.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}


def historical_inputs(revision, paths):
    rows = []
    for path in sorted(paths):
        raw = subprocess.check_output(['git', 'show', revision + ':' + path], cwd=ROOT)
        rows.append({'path': path, 'sha256': sha(raw),
                     'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t') else 'input'})
    return rows


predecessor = {'name': 'original-hash-index-publication-preservation',
    'statement': 'All350 accepted live bindings/full84391-byte two-claim record remain exact; only its first live mode/revision pair becomes historical at4cc0b5a2a. The prior historical preservation claim is unchanged.',
    'scope': 'Accepted Git full record/publisher/module/207-input consumer seed, exact before-copy and actual accepted publisher baseline. No old observation or hash refresh.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py',
        'granularity': 'Every350 accepted Git binding and all original JSON fields; exact one-mode conversion.',
        'result': 'All original fields/bindings and accepted baseline remain exact.'},
    'falsify': {'status': 'checked', 'hypothesis': 'Historical labeling may hide replaced original hashes.',
        'oracle': 'Full accepted Git JSON/blobs with exact equality except the single mode/revision pair.',
        'red_control': 'Actual zeroed first original SHA beyond updated freeze after-SHA rejects frozen original claim fields; exact restoration passes.'},
    'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE,
        'inputs': historical_inputs(BASE, ('docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5.json',
            'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-publish-claim.py',
            'perl/LinkedSpec/ActionIR/MethodLowering.pm', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-consumers.json'))}}
flow = json.loads((ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-flow-review.json').read_bytes())
flow_inputs = historical_inputs(FLOW_BASE, flow['original_files'])
assert {row['path']: row['sha256'] for row in flow_inputs} == flow['original_files'] and len(flow_inputs) == 168
diagnosis = {'name': 'original-package-flow-native-diagnosis',
    'statement': 'The accepted4b48593b5 package branch is reachable through public Toolbox; a map-only callback stays uninvoked. The original compact public argument premise fails; the sole spaced expectation correction passes16, and branch removal gives semantic RED. Six full replay channels remain retained.',
    'scope': 'Original historical168-file Git seed plus separately retained diagnostic probes/artifacts bound in the primary claim. No earlier diagnostic result is refreshed; exactly one Test::More expected ARRAY address normalizes only in failed historical stderr.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-flow-review.py',
        'granularity': 'All168 accepted Git source inputs and six original/fixed169-input replay channels.',
        'result': 'Readonly historical diagnosis passes with original failed premise and sole correction explicit.'},
    'falsify': {'status': 'checked', 'hypothesis': 'The map entry selects the package branch or authored compact text is the actual callback argument.',
        'oracle': 'Actual public Toolbox and controlled package/map calls, exact spaced argument and syntax-valid branch removal.',
        'red_control': 'Original public compact-argument assertion is RED; package-branch removal fails the distinguishing actual-package assertions.'},
    'durability': {'status': 'checked', 'mode': 'historical', 'revision': FLOW_BASE, 'inputs': flow_inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [primary, predecessor, diagnosis]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'package-flow publication drift'
print('Package-flow publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes; original350/full84391 and historical168 exact')
