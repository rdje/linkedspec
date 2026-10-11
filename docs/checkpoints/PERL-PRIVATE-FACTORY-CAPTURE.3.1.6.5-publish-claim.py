"""Readonly hash-index claim publisher; --capture writes once after complete proof."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
BASE = '557a7d9e533710c6aae211f905ca2f231a8aedae'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7.json'
OLD_PUBLISHER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7/publish.py'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('review.py', 'admission-final.py', 'evidence.py', 'compatibility/run.py'):
    command = ['python3', PREFIX + tail]
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert result.returncode == 0 and not result.stderr, ('actual readonly proof', command, result.stderr)
report = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert report['result'] == evidence['result'] == 'PASS' and len(evidence['controls']) == 7
assert json.loads((ROOT / (PREFIX + 'evidence-reached.json')).read_bytes()) == {'healthy': evidence['healthy'], 'rows': evidence['controls']}
paths = set(report['input_metadata']) | set(evidence['inputs'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / (PREFIX + 'compatibility')).rglob('*') if p.is_file())
paths.update('docs/knowledge/' + name + '.md' for name in ('perl-method-ast-assignment-capture',
    'guarded-ast-change-history-capacity', 'aggregate-selector-self-test-concurrency-boundary'))
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t') else 'input'} for path in sorted(paths)]
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in report['input_metadata'].items())
statement = ('Two required hash-index parser/lowerer resolver returns isolate trim and key callbacks while preserving '
    'actual eager/nested selection, regex capture/parsed-slot aliases, contexts, maps, successful error effects and '
    'fatal/result identities. First205-input native observations retain12 callback outcomes/96 branches/6 authority/'
    '3 public-source/4 cold rows before assertions and production edits. Identical413 TAP retains9 original isolation '
    'REDs/404 controls/all413 current GREEN. Ten syntax-valid whole-source faults fail4/2/6/4/6 for parser and '
    '6/2/39/4/14 for lowerer. Supplied66 actual suite paths/plans/207 inputs/13361 assertions, seven actual evidence '
    'RED/restorations and full book89/three controls pass.')
scope = ('Only required resolver returns in _parse_hash_index_assignment_operator_statement and '
    '_lower_hash_index_assignment_operator_statement. Actual nested legacy parser integration remains active under '
    'explicit AST/payload/assembly controls. Parser selects trim once; lowerer selects key before trim; nested parser '
    'reselects trim at its own invocation. RHS magic rejects mutation despite SvREADONLY zero; actual parsed key/value '
    'slots and caller scalar copies stay native. Authority control explicitly serializes the parser structured result; '
    'its return type does not change. Public Toolbox rows retain typed nested_write generated source only. Original '
    'native command completed0 with a scalar-slice warning, so outer no-diagnostics assertion exited1; exact source/'
    'channels remain retained. Sole spelling correction removes that warning; its original byte-equality assertion '
    'also exits1 because ten diagnostic temporary prefixes/two HASH addresses differ. Those raw observations remain '
    'exact and only those representations normalize. Overbroad reviewer predicate, named-constant reader and inherited '
    'capture-flag failures retain exact sources/available raw channels and separately reproduced readonly failures. '
    'Original admission-repair source binding resolves to exact review-draft02.py; no old source/hash/observation is '
    'refreshed. First evidence preflight never reaches controls. Original tool transport limits are disclosed. '
    'All392 primary/12 selector bindings/full108215-byte predecessor record are exact with actual accepted publisher '
    'baseline; only its two live mode/revision pairs become historical at557a7d9e5. Supplemental standard syntax/public '
    'Phase0 passes1035 with complete channels but no full transitive input capsule or private/canonical admission. '
    'Complete secondary helpers/AST/language, optional/direct, full-private, pipeline/output/mapping/parent and canonical '
    'admissions remain separately owned; TYPE-REFERENCE-BOOK stays queued.')
primary = {'name': 'hash-index-required-callback-isolation', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; '
        'separately review.py, native-review.py, admission-final.py, consumer-review.py, book-review.py and evidence.py '
        'through the same prefix/wrapper. Defaults readonly; every capture/freezer/fault/correction writer is one-shot '
        'and retired after its retained execution.',
        'granularity': 'Every205 native/current and207 paired input,12 native callback outcomes,96 controlled branches, '
            'six actual authority/three public-source/four cold rows; all413 paired TAP names/nine original REDs and '
            'ten complete source faults; every66 consumer path/header/plan/13361 assertions;89 book inputs/three '
            'actual controls; seven damaged/restored input populations with complete channels; all original392+12 '
            'bindings/full record and exact instrument corrections/raw failure boundaries.', 'result': statement},
    'falsify': {'status': 'checked', 'hypothesis': 'Equal-text children may donate publication; wrapper or late-map '
        'selection may preserve actual callback identity; copied arguments may preserve regex magic/parsed-slot '
        'effects; immediate artifact hashes may conceal missing semantic reasons, checkpoint suites or original fields.',
        'oracle': 'Immutable first-native observations plus authored results/actual slot and callback identities, '
            'known eligibility and enclosing publication lookup; independent complete source reconstruction, paired '
            'TAP/full mutant sources, every ordered consumer path and complete recursive book. Exact original '
            'source/channel/claim preservation distinguishes instrument repairs from runtime changes.',
        'red_control': 'Exactly9 original isolation failures become GREEN while404 controls remain. Ten actual '
            'syntax-valid faults retain named failures4/2/6/4/6 and6/2/39/4/14. Seven actual evidence REDs reject '
            'failed positive, stale fault artifact, missing semantic reason beyond rehashed index, changed native '
            'slot flag, omitted checkpoint header beyond updated immediate review hash, forged original binding '
            'beyond updated freeze after-SHA, and changed book source; every exact restoration passes. Three book '
            'controls reject missing SUMMARY, remove rendered teaching despite exit0, and diagnose missing include. '
            'Native warning/comparison/predicate and admission-reader failures remain explicit rather than counted '
            'as successful original instruments.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
historical_inputs = []
for path in (OLD_CLAIM, OLD_PUBLISHER, 'perl/LinkedSpec/ActionIR/MethodLowering.pm',
             'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-consumers.json'):
    raw = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    historical_inputs.append({'path': path, 'sha256': sha(raw),
        'role': 'producer' if Path(path).suffix in ('.py', '.pm') else 'input'})
historical = {'name': 'original-change-history-selector-boundary-preservation',
    'statement': 'All392 primary/12 selector accepted bindings and full108215-byte four-claim publication remain exact; '
        'only two live durability mode/revision pairs become historical at557a7d9e5. Both earlier historical claims '
        'and all original fields, producers, hashes and outcomes remain unchanged.',
    'scope': 'Accepted Git predecessor full publication/publisher and all its original bindings, accepted native '
        'module/consumer seed, exact before-copy and actual accepted publisher baseline. No previous runtime, '
        'book, failed canonical or recovery observation refresh.',
    'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; '
        'separately evidence.py through that wrapper.', 'granularity': 'Full original claim and every392/12 accepted '
        'Git input, exact two-mode conversion, accepted original module/203-input supplied consumer seed.',
        'result': 'All original fields/bindings and actual accepted baseline remain exact. Forged original binding '
        'rejects beyond coherently updated immediate freeze SHA; exact restoration passes.'},
    'falsify': {'status': 'checked', 'hypothesis': 'Historical labeling may conceal replaced original fields/hashes.',
        'oracle': 'Accepted Git full record/blobs and exact JSON equality permitting only two live mode/revision pairs.',
        'red_control': 'Actual zeroed first original SHA plus updated freeze after-SHA rejects frozen original claim '
        'fields; exact original restoration passes.'},
    'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical_inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [primary, historical]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'hash-index publication drift'
print('Hash-index publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes; original392+12/full108215 exact')
