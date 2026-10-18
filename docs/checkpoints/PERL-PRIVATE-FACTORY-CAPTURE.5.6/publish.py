"""Readonly selected-callback publication; --capture writes the claim once."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.6.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for name in ('review.py', 'evidence.py'):
    result = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, (name, result.stderr)
review = json.loads((ROOT / (PREFIX + 'review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS'
assert review['population'] == dict(original_warm_rows=210, original_cold_rows=210,
    warm_rows=213, cold_rows=213, first_assertions=1272, first_red=423,
    paired_assertions=1290, original_red=435, passing_controls=855, source_faults=14,
    cardinality_assertions=62, cardinality_red=1, consumer_suites=89, consumer_inputs=349,
    consumer_assertions=29504, diagnostic_inputs=343, diagnostic_assertions=16,
    knowledge_bytes=8388505, book_sources=89, book_controls=4)
compat = json.loads((ROOT / (PREFIX + 'compat.json')).read_bytes())
assert compat['result'] == 'PASS' and len(compat['rows']) == 5
assert compat['producer_sha256'] == sha((ROOT / (PREFIX + 'compat.py')).read_bytes())
assert all(row['returncode'] == 0 for row in compat['rows'])
phase0 = base64.b64decode(compat['rows'][-1]['stdout_base64'], validate=True)
assert b'Files=1, Tests=1035' in phase0 and b'Result: PASS' in phase0
paths = set(review['inputs']) | {PREFIX + name for name in (
    'review.json', 'evidence.py', 'evidence.json', 'evidence-originals.json.gz',
    'evidence-reached.json', 'publish.py', 'compat.py', 'compat.json')}
bindings = []
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    bindings.append(dict(path=path, sha256=sha(source.read_bytes()),
        role='producer' if source.suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'))
statement = (
    'ControlFlow direct selected lowerers and selected rule apply callbacks now receive separate '
    'private invocation frames through two original invocation lines. Direct tail scalar/list/void '
    'contexts, scalar rule calls, the one apply fetch after shallow candidate cloning, actual public '
    'references, aliases, ordinary returns/effects/errors and diagnostic lines remain native. All426 '
    'complete native ordinary rows and fresh-process recurrences remain exact, including all420 '
    'original rows. Identical1290 assertions retain435 original authority REDs/855 controls and all '
    'GREEN; the preserved first fixture has1272 assertions/423 REDs. Fourteen complete-source faults '
    'have distinguishing witnesses, including the exact inverse and six tied-fetch clone-order '
    'failures. The unchanged publication-cardinality implementation passes62 assertions and its '
    'allow-multiple mutant has exactly one RED. All89 supplied suites/349 inputs/29504 top-level '
    'assertions pass with predecessor88 headers/plans/stderr unchanged. Separate public diagnostic '
    'before/after343-input captures each pass16 top-level assertions. Six artifact denials restore '
    'byte/mode-exact PASS, including coherently rehashed native observations and a rendered counter '
    'forgery rejected against native data. Full Knowledge1486 Markdown/1349 facts/thirteen overlays/'
    '8388505 bytes, complete book89/four actual controls, public guard and supplemental public '
    'Phase01035 pass. Whole116166-byte/506-input predecessor and actual readonly baseline remain '
    'historical at2b35b77ea before bound writes.')
record = dict(version=1, owner='PERL-PRIVATE-FACTORY-CAPTURE.5.6', claims=[dict(
    name='controlflow-selected-callback-capture', statement=statement,
    scope='Only two invocation lines change; line counts and native noncallable diagnostic locations '
        'stay fixed. An actual unblessed CODE carries its own registration; symbolic, blessed and '
        'overloaded rule selections retain opaque native dispatch. Builtin names grant no authority. '
        'Controlled dependencies and actual builtin entry/context observations are distinct from '
        'the separate public native/generated/CLI diagnostic suite. Candidate state is shallow; '
        'two publications in one eligible frame are already ambiguous, so packet absence alone '
        'does not prove isolation. The first1272/423 source/proof and all420 observations stay frozen '
        'beside the three-case-per-mode extension; no initial data is refreshed. A failed after-reader '
        'path lookup remains unchanged with its actual retained failure rerun and separately '
        'identified correction. Condensed framework prose retains its original Git body. System '
        'Perl/stdlib/mdBook are reused read-only without immutable portable toolchain claims; standard '
        'and public guards are supplemental without full transitive capsules. Default registration, '
        'fixture selection, pipeline activation and broader private/parent/canonical admissions stay '
        'open. Existing wrapper process-group repair and recovery/purge restrictions remain startup.7-owned.',
    rederive=dict(status='checked',
        command='bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (readonly default). '
            'review.py, evidence.py, publication-cardinality.py, book-review.py and validation.py '
            'are readonly by default. Capture/source-fault/preservation producers are retired one-shot instruments.',
        granularity='Every213 warm/213 cold original/current native row and recurrence, all420 first '
            'rows, first1272/423 and complete1290/435 TAP, each14 full-source variants, cardinality62/1, '
            'all89 suites/349 inputs/29504 assertions, separate343-input diagnostic captures, complete '
            'prior116166-byte/506-binding claim and actual baseline, full Knowledge and recursive '
            'book populations, six semantic artifact denials.', result=statement),
    falsify=dict(status='checked',
        hypothesis='Selected callbacks could inherit parent authority, donate a nested packet, lose '
            'their own matching packet, force scalar tail context, select apply before cloning or '
            'reselect it, copy argument slots, alter errors/effects, rebind public rules or eagerly '
            'load the channel. Rehashed observations or rendered tables could conceal those changes; '
            'altered predecessor claims or omitted consumers could conceal lost coverage.',
        oracle='Original native ordinary ledger captured before expectations/source edits; actual '
            'callback references and invocation contexts; fixed accepted Git source/claim namespace; '
            'identical paired authority fixture and exact two-line reconstruction; exact inverse; '
            'existing cardinality test plus independent one-predicate mutant; predecessor ordered '
            'suite/header/plan population; rendered candidate table derived from retained native '
            'counter observations; full current Knowledge/book custody.',
        red_control='Before435 of1290 fail and855 controls pass; afterward all1290 pass. Fourteen '
            'syntax-valid full-source variants fail435,180,255,106,156,60,12,420,807,2,72,6,222,112 '
            'assertions with complete plans. Exact inverse reproduces435 original names/numbers. '
            'Allow-multiple cardinality mutant fails only the existing multiple-equal-publications '
            'ambiguity assertion out of62. Six artifact controls reject native argument change, '
            'parent donation, matching-packet loss, altered whole prior claim, missing consumer and '
            'coherently rehashed rendered candidate counter, then restore exact PASS. Four actual '
            'book controls reject missing SUMMARY, two absent rendered markers and a missing include.'),
    durability=dict(status='checked', mode='live', inputs=bindings))])
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value
print('Direct/rule publication PASS:', len(bindings), 'live inputs;', len(value), 'bytes')
