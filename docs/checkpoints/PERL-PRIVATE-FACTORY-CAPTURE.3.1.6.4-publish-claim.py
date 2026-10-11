"""Readonly legacy array-end required-callback publication; --capture writes once after all proof."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
BASE = '98990ffbc4a7150b20d0e416be3ea4f9938cfd10'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
CARD = 'docs/knowledge/perl-method-ast-array-end-capture.md'
OLD_CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3.json'
OLD_PUBLISHER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3-publish-claim.py'
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
for tail in ('review.py', 'evidence.py', 'compatibility/run.py'):
    command = ['python3', PREFIX + tail]
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    assert result.returncode == 0 and not result.stderr, ('actual readonly proof', command, result.stderr)
report = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert report['result'] == evidence['result'] == 'PASS'
assert len(evidence['controls']) == 8
assert json.loads((ROOT / (PREFIX + 'evidence-reached.json')).read_bytes()) == {
    'healthy': evidence['healthy'], 'rows': evidence['controls']}
paths = set(report['input_metadata']) | set(evidence['inputs']) | {CARD}
paths.update(PREFIX + tail for tail in ('review.py', 'review.json', 'evidence.py', 'evidence.json',
    'evidence-reached.json', 'compatibility/run.py', 'compatibility/result.json', 'publish-claim.py'))
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t') else 'input'}
          for path in sorted(paths)]
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in report['input_metadata'].items())
statement = ('Three required legacy array-end parser callbacks retain eager actual-reference selection, maps, scalar '
    'contexts, splitter and actual returned payload-slot effects, successful error states and fatal identity while '
    'isolating child publication. Immutable201-input completed native12 callback/57 branch/6 authority/4 public-source/'
    '2 cold rows precede assertions and the exact one-return change. Paired325 TAP retains9 original authority REDs/'
    '316 controls/all325 current GREEN. Five syntax-valid whole-module faults fail9/3/36/9/18. Supplied65 suites/'
    '203 inputs/12948 assertions, eight actual evidence RED/restorations and full book89/three controls pass; every '
    'ordered command path/header/plan and predecessor diagnostic byte is checked.')
scope = ('Only required trim/parser/array-extractor callbacks of _parse_array_end_mutation_method_statement. '
    'Eager selection, receiver/fallback/method/arity/payload guards and actual structured results remain native. '
    'Authority controls explicitly serialize the actual structured result in an enclosing registered producer; '
    'they do not change the parser return type. The supplied greedy parser extra-tail control demonstrates delegated '
    'grammar, not public authored-language acceptance or a parser defect. Original321 hash proof bindings/full claim '
    'remain historical at98990ffbc with actual accepted publication baseline retained; only its live mode/revision '
    'changes. Raw diagnostics retain complete locations; comparisons normalize only supplied locations and check '
    'exact stems/source line7841. The first201-input instrument attempt failed compilation before runtime observations; '
    'exact original probe/full inner channels/input census and sole lexical-loop correction are retained. The original '
    'outer transport envelope is explicitly unavailable; its observed tool-return boundary is transcribed. A wrong '
    'consumer wrapper invocation exited126 before running the producer; corrected actual capture is distinct. No '
    'partial success or old runtime observation refresh is inferred. Public Toolbox rows are generated-source '
    'controls only. Supplemental standard syntax/public Phase0 passes1035 with full channels but no full transitive '
    'input capsule, benchmark or private/canonical admission. Optional/direct, complete helper/AST/language, full-private, '
    'output/mapping/parent/canonical admissions remain separate; fixture registration .7 precedes pipeline .6.')

primary = {'name': 'array-end-required-callback-isolation', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; '
        'independently review.py, consumer-review.py, book-review.py and evidence.py with that wrapper. Defaults '
        'readonly; capture/freezer/fault/evidence writers are one-shot.',
        'granularity': 'Every native callback/branch/authority/public/cold row and201 native/current/203 paired input; '
        'all325 assertion names/nine original REDs; five complete mutant sources/named failures; all65 suite paths/'
        'headers/plans; all89 book inputs/modes and three controls; eight damaged/restored populations/channels; '
        'original compile-failed201 inputs/full inner channels and exact sole loop correction, plus explicit original '
        'outer-transport limitation and wrong-wrapper preflight boundary.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Raw children may donate publication, wrapper identity may replace known callbacks, copied '
            'arguments may preserve native splitter/payload-slot effects, late map lookup may preserve eager selection, '
            'or immediate artifact hashes may conceal missing semantic reasons/checkpoint suites or failed instrumentation.',
        'oracle': 'Immutable completed first-native ledgers plus authored results, actual callback/argument/returned-slot '
            'identities, actual eligibility and parent publication lookup using explicit outer serialization, complete '
            'paired TAP, independently reconstructed whole mutants, full consumer census and recursive book, exact '
            'original compile-failed probe/result and sole corrected lexical-loop reconstruction.',
        'red_control': 'Exactly9 original authority failures become GREEN with316 controls unchanged. Five complete '
            'syntax-valid faults retain named failures9/3/36/9/18. Eight actual evidence RED/restorations reject '
            'concealed compile failure beyond updated immediate correction hash, false positive, inverse hash drift, '
            'missing semantic reason beyond rehashed immediate index, false native flag, omitted checkpoint header '
            'beyond updated immediate review hash, forged original binding beyond updated immediate freeze SHA and '
            'changed book source. Three book controls fail missing SUMMARY, lose changed prose in HTML and diagnose '
            'missing include despite exit0.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
historical_inputs = []
for path in (OLD_CLAIM, OLD_PUBLISHER):
    raw = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    historical_inputs.append({'path': path, 'sha256': sha(raw),
                              'role': 'producer' if path == OLD_PUBLISHER else 'input'})
historical = {'name': 'original-hash-required-boundary-preservation',
    'statement': 'All321 accepted predecessor input hashes and full claim/proof fields remain exact; only its one '
        'live mode/revision becomes historical at98990ffbc. Earlier original-review-command preservation fields stay unchanged.',
    'scope': 'Complete accepted required-hash claim, all321 original Git bindings, exact before-copy and actual '
        'original publication baseline. No earlier runtime/native/book/recovery observation is refreshed.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; '
        'independently evidence.py through that wrapper.',
        'granularity': 'Original accepted Git full claim, all321 original bindings and exact mode/revision-only conversion.',
        'result': 'All321 original Git hashes and fields remain exact; actual accepted publisher baseline passes. '
            'Forged original binding rejects beyond updated immediate freeze hash and exact restoration passes.'},
    'falsify': {'status': 'checked', 'hypothesis': 'A historical label can conceal changed original fields or hashes.',
        'oracle': 'Accepted Git blobs, exact original before-copy and full JSON equality allowing only mode/revision.',
        'red_control': 'An actual zeroed first original SHA with updated immediate freeze after-SHA fails frozen '
            'original claim fields; exact original bytes restore PASS.'},
    'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical_inputs}}
data = {'version': 1, 'owner': LEAF, 'claims': [primary, historical]}
raw = (json.dumps(data, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication already retained'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'array-end publication drift'
print('Array-end publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes; original321 preserved')
