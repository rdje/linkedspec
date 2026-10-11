"""Readonly hash required-callback publication; --capture writes once after all proof."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
BASE = 'e4507973aff0a4ebcd09299d971a8d78a86c10b1'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
CARD = 'docs/knowledge/perl-array-receiver-required-capture.md'
OLD_CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1.json'
OLD_PUBLISHER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1/publish.py'
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
for tail in ('review.py', 'evidence.py', 'compatibility/run.py'):
    command = ['python3', PREFIX + tail]
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    assert result.returncode == 0 and not result.stderr, ('actual readonly proof', command, result.stderr)
report = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert report['result'] == evidence['result'] == 'PASS'
assert len(evidence['controls']) == 7
assert json.loads((ROOT / (PREFIX + 'evidence-reached.json')).read_bytes()) == {
    'healthy': evidence['healthy'], 'rows': evidence['controls']}
paths = set(report['input_metadata']) | set(evidence['inputs']) | {CARD}
paths.update(PREFIX + tail for tail in ('review.py', 'review.json', 'evidence.py', 'evidence.json',
    'evidence-reached.json', 'compatibility/run.py', 'compatibility/result.json', 'publish-claim.py'))
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t') else 'input'}
          for path in sorted(paths)]
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in report['input_metadata'].items())
statement = ('Two required hash receiver callbacks retain eager actual-reference selection, maps, scalar contexts, '
    'substring effects, successful error states, fatal identity and shared parser-returned references without '
    'annotation, while isolating child publication. Immutable197-input native8 callback/52 branch/4 authority/'
    '2 public-source/2 cold rows precede assertions and the exact one-return change. Paired308 TAP retains6 '
    'original authority REDs/302 controls/all308 current GREEN. Five syntax-valid whole-module faults fail6/2/4/5/8. '
    'Supplied64 suites/199 inputs/12623 assertions, seven actual evidence RED/restorations and full book89/three '
    'controls pass; every ordered command path/header/plan and predecessor diagnostic byte is checked.')
scope = ('Only required trim/parser callbacks of _normalize_hash_receiver_value_chain_expr. Hash copy/kind/lookahead, '
    'arity, family transition and terminal guards remain native. The already repaired optional kind callback stays '
    'unchanged. Original115 current-review-command bindings/full claim remain historical at e4507973a with the '
    'actual accepted publication baseline retained; only its live mode/revision changes. Historical395-input '
    'recovery fields stay exact. Raw diagnostic locations remain retained; comparisons normalize only supplied '
    'locations while checking exact stems and source line7712. No native instrument or old observation refresh. '
    'Public Toolbox rows are generated-source controls only. Supplemental standard syntax/public Phase0 passes1035 '
    'with full channels but no full transitive input capsule, benchmark or private/canonical admission. Optional/'
    'direct, complete helper/AST/language, full-private, output/mapping/parent/canonical admissions remain separate. '
    'Canonical focused-fixture registration .7 precedes pipeline activation .6.')
primary = {'name': 'hash-required-callback-isolation', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; '
        'independently review.py, consumer-review.py, book-review.py and evidence.py with that wrapper. Defaults '
        'readonly; capture/freezer/fault/evidence writers are one-shot.',
        'granularity': 'Every native callback/branch/authority/public/cold row and197 native/current/199 paired input; '
        'all308 assertion names/six original REDs; five complete mutant sources/named failures; all64 suite paths/'
        'headers/plans; all89 book inputs/modes and three controls; seven damaged/restored populations and channels.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Raw children may donate publication, wrapper identity may replace known callbacks, copied '
            'arguments may preserve native substring effects, late map lookup may preserve eager selection, or '
            'hash-only artifact checks may conceal missing semantic reasons/checkpoint suite output.',
        'oracle': 'Immutable first-native ledgers plus authored results, actual callback/argument/returned-object '
            'identities, actual eligibility and parent publication lookup, complete original/current TAP, independent '
            'whole-mutant reconstruction, complete consumer command census and recursive book.',
        'red_control': 'Exactly6 original authority failures become GREEN with302 controls unchanged. Five full '
            'syntax-valid faults retain named failures6/2/4/5/8. Seven actual evidence RED/restorations reject '
            'false positive, inverse hash drift, missing semantic reason beyond a rehashed immediate index, false '
            'native flag, omitted checkpoint header beyond the updated immediate review hash, forged original '
            'binding beyond updated immediate freeze SHA, and changed book source. Three book controls fail missing '
            'SUMMARY, lose changed prose in HTML and diagnose missing include despite exit0.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
historical_inputs = []
for path in (OLD_CLAIM, OLD_PUBLISHER):
    raw = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    historical_inputs.append({'path': path, 'sha256': sha(raw),
                              'role': 'producer' if path == OLD_PUBLISHER else 'input'})
historical = {'name': 'original-review-command-boundary-preservation',
    'statement': 'All115 accepted predecessor input hashes and full claim/proof fields remain exact; only its one '
        'live mode/revision becomes historical at e4507973a. Separate395-input historical recovery stays unchanged.',
    'scope': 'Complete accepted review-command claim, all115 original Git bindings, exact before-copy and actual '
        'original publication baseline. No earlier runtime/native/book/recovery observation is refreshed.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; '
        'independently evidence.py through that wrapper.',
        'granularity': 'Original accepted Git full claim, all115 original bindings and exact mode/revision-only conversion.',
        'result': 'All115 original Git hashes and fields remain exact; actual accepted publisher baseline passes. '
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
    assert TARGET.read_bytes() == raw, 'hash publication drift'
print('Hash publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes; original115 preserved')
