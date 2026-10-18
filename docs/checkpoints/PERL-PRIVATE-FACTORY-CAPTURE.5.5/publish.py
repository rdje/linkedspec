"""Readonly optional-kind publication; --capture writes the claim once."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.5/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.5.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for name in ('review.py', 'evidence.py'):
    result = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, (name, result.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
assert review['population'] == {'warm_rows': 88, 'cold_rows': 88, 'paired_assertions': 452,
    'original_red': 77, 'passing_controls': 375, 'source_faults': 12, 'consumer_suites': 88,
    'consumer_inputs': 339, 'consumer_assertions': 28214, 'knowledge_bytes': 8388480,
    'book_sources': 89, 'book_controls': 4}
compat = json.loads((ROOT / (PREFIX + 'compat.json')).read_bytes())
assert compat['result'] == 'PASS' and len(compat['rows']) == 5, 'standard commands must finish before publication'
assert compat['producer_sha256'] == sha((ROOT / (PREFIX + 'compat.py')).read_bytes())
assert all(row['returncode'] == 0 for row in compat['rows'])
phase0 = base64.b64decode(compat['rows'][-1]['stdout_base64'], validate=True)
assert b'Files=1, Tests=1035' in phase0 and b'1..1035\nok\nAll tests successful.' in phase0 and b'Result: PASS' in phase0
paths = set(review['inputs']) | {PREFIX + name for name in (
    'review.json', 'evidence.py', 'evidence.json', 'evidence-originals.json.gz', 'evidence-reached.json', 'publish.py', 'compat.py', 'compat.json')}
bindings = []
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    bindings.append({'path': path, 'sha256': sha(source.read_bytes()),
        'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'})
statement = (
    'ControlFlow print_each optional kind calls now isolate actual CODE second selections and opaque '
    'native dispatch separately. The original two map reads, guarded scalar invocation, match-alias '
    'write rejection, diagnostic lines, public references, ordinary returns/effects/errors and cold '
    'loading remain native. All176 complete-instrument ordinary rows and fresh-process recurrences '
    'stay exact. Identical452 assertions retain77 original authority REDs/375 controls and all GREEN. '
    'Twelve syntax-valid complete-source faults have distinguishing witnesses; the exact inverse '
    'restores all77 original failure names/numbers. All88 supplied suites/339 inputs/28214 top-level '
    'assertions pass with predecessor87 headers/plans/stderr unchanged. Dedicated public diagnostic '
    'before/after336-input captures each pass16 top-level assertions. Five artifact denials, including '
    'three coherently rehashed native-data controls, restore byte/mode-exact PASS. Full '
    'Knowledge1486 Markdown/1349 facts/twelve overlays/8388480 '
    'bytes, complete book89/four actual controls, composed public guard and supplemental public '
    'Phase01035 pass. The complete117562-byte two-claim predecessor and actual readonly baseline '
    'remain historical at dadce45ac8 before bound writes; its kernel sample is not refreshed.')
record = {'version': 1, 'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.5.5', 'claims': [{
    'name': 'controlflow-print-each-optional-kind-capture',
    'statement': statement,
    'scope': 'Only the optional invocation condition and an appended private selector helper change. '
        'The opening condition retains its original line for native noncallable errors. An actual '
        'unblessed CODE carries only its own registration; symbolic/blessed/overloaded selections '
        'remain opaque. Controlled dependencies delegate actual MethodExpr parsing; separate public '
        'diagnostics cover native/generated/CLI output. The first tied-map snapshot failure and its '
        'one-condition correction remain retained, without refreshing the first observations. The '
        'first Knowledge capacity candidate fails final input-integrity after a concurrent source '
        'refinement and is not passing evidence; a distinct final producer retains complete stable '
        'source custody. Earlier framework prose is condensed with original bodies recoverable in '
        'Git. System Perl/stdlib/mdBook are reused read-only without immutable portable toolchain '
        'claims. Public guard/standard commands are supplemental without full transitive capsules. '
        'Direct/rule/default/fixture/pipeline/full-private/parent/canonical admissions remain open. '
        'Existing wrapper process-group repair and recovery/purge restrictions remain startup.7-owned.',
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly default). '
            'review.py, evidence.py, book-review.py and validation.py are readonly by default. '
            'All capture/source-fault/preservation producers are retired one-shot instruments.',
        'granularity': 'Every88 warm/88 cold original/current native row and recurrence; complete452 '
            'TAP and77 original failures; each12 full-source variants; all88 supplied suites/339 '
            'inputs/28214 assertions; separate336-input public before/after diagnostics; complete '
            'prior117562-byte two-claim publication/495 affected bindings and actual baseline; '
            'complete Knowledge and recursively included book populations; five artifact denials.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'An optional callback could inherit the parent identity, donate nested publication, '
            'lose its own matching packet, change native two-read selection, copy the match alias, '
            'repeat effects, alter error state, rebind the public map or load the private channel eagerly. '
            'Rehashed evidence could conceal native changes, parent donation, lost child packets, '
            'altered predecessor claims or an omitted consumer.',
        'oracle': 'Original native ordinary ledger captured before expectations/source edits, fixed '
            'accepted Git source/claim namespace, identical paired callback/packet fixture, independent '
            'exact source reconstruction and exact inverse, predecessor ordered suite/header/plan '
            'population, separately rendered complete book and full current Knowledge custody.',
        'red_control': 'Before77 of452 assertions fail;375 controls pass; afterward all452 pass. '
            'Twelve complete-source variants fail77,28,30,4,107,78,122,144,1,4,27,112 assertions '
            'with complete plans. Five artifact controls reject changed native alias observations, '
            'parent donation, matching own-packet loss, altered whole prior claim and a missing '
            'consumer, then restore exact readonly PASS. Four actual book controls distinguish '
            'missing SUMMARY, two absent rendered markers and a missing recursive include.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings},
}]}
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value
print('Optional-kind publication PASS:', len(bindings), 'live inputs;', len(value), 'bytes')
