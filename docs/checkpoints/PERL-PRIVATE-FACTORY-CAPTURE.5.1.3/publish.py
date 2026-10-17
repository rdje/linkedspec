"""Readonly finite-history publication; --capture creates its bounded claim once."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.5.1.3'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda b: hashlib.sha256(b).hexdigest()
raw = lambda p: (ROOT / p).read_bytes()
load = lambda n: json.loads(raw(PREFIX + n))
decode = lambda s: base64.b64decode(s, validate=True)
assert sys.argv[1:] in ([], ['--capture'])
failure = load('review-failure.json')
original_reader = raw(PREFIX + 'review.py')
assert failure['exit_code'] == 1 and failure['original_producer_sha256'] == sha(original_reader)
channel = decode(failure['output_base64'])
assert sha(channel) == failure['output_sha256'] and b"AssertionError: ('Git artifact'," in channel
assert b'complete_inputs.py' in channel and failure['observed_tool_chunk'] == '068d75'
old = decode(failure['correction']['old_base64']); new = decode(failure['correction']['new_base64'])
assert original_reader.count(old) == 1
corrected = original_reader.replace(old, new, 1).replace(
    b'book-review.json review.py', b'book-review.json review.py review-failure.json final-review.py')
assert raw(PREFIX + 'final-review.py') == corrected, 'only support-producer classification and failure/source inventory correction'
artifact_failure = load('evidence-failure.json')
original_evidence = raw(PREFIX + 'evidence.py')
assert artifact_failure['exit_code'] == 1 and artifact_failure['producer_sha256'] == sha(original_evidence)
assert artifact_failure['reached_data_sha256'] == sha(raw(PREFIX+'evidence-data.json.gz'))
assert artifact_failure['baseline_sha256'] == sha(raw(PREFIX+'evidence-baseline.json.gz'))
expected_evidence = original_evidence.replace(decode(artifact_failure['old_base64']), decode(artifact_failure['new_base64']), 1)
for first, final in (('evidence.json','final-evidence.json'), ('evidence-data.json.gz','final-evidence-data.json.gz'), ('evidence-baseline.json.gz','final-evidence-baseline.json.gz'), ('evidence-progress.json','final-evidence-progress.json')):
    expected_evidence = expected_evidence.replace(first.encode(), final.encode())
assert raw(PREFIX+'final-evidence.py') == expected_evidence, 'only extra-LF removal and separate evidence capture paths'
for name in ('final-review.py', 'final-evidence.py'):
    process = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly finite proof', name, process.stderr)
review = load('review.json'); evidence = load('final-evidence.json')
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 5
paths = set(review['inputs']) | set(evidence['inputs']) | {PREFIX + n for n in (
    'review.json', 'publish.py', 'evidence.py', 'evidence-data.json.gz',
    'evidence-baseline.json.gz', 'evidence-progress.json', 'evidence-failure.json',
    'final-evidence.py', 'final-evidence.json', 'final-evidence-data.json.gz',
    'final-evidence-baseline.json.gz', 'final-evidence-progress.json')}
inputs = []
for p in sorted(paths):
    source = ROOT / p
    assert source.is_file() and not source.is_symlink()
    inputs.append(dict(path=p, sha256=sha(source.read_bytes()),
        role='producer' if source.suffix in ('.py', '.pl', '.pm', '.sh', '.t') else 'input'))
statement = (
    'One complete engineering note reaches386 lines/59506 bytes and actual production rollover '
    'requires255, archives272 clean-source lines as segment4960 and retains113 lines/32492 bytes. '
    'Unchanged old routing caps reject exactly files48/47, manifest47/46 lines and28469/27857 bytes. '
    'ADR0135 admits only that member and exact manifest growth, plus its sole34 physical decision '
    'lines and one index row: decisions136 files/13285 lines. Engineering aggregates remain '
    '29512 lines/3407872 bytes; all root/per-file/byte/unrelated controls stay exact and no future '
    'archive reserve follows. Independent Git-backed reconstruction checks whole suffix/root, '
    'source blob/range/digest, all prior manifest rows and all228 unchanged history/decision files. '
    'Whole original449-input/105765-byte callback publication and its actual readonly baseline '
    'remain historical at736c6a43efab526fe898ed5c72b061479955fc5c; only durability mode/revision '
    'changes. Complete1978-input original-project replay reproduces whole original old-cap channels '
    'with bytes/modes unchanged, own Git-root guard and historical fixture inputs retained. '
    'Both incomplete copied-root experiments remain frozen and no whole-gate portability is claimed. '
    'Unchanged actual production functions pass30 numeric observations/23 authority REDs; five '
    'coherent artifact corruptions reject semantically with exact restorations. Full original1485 '
    'and current1486 Knowledge Markdown inputs retain1349 facts, eleven card overlays and8387290 '
    'card bytes under unchanged limits. Complete89-input book and four controls pass; stale '
    'attached-parser entrypoint prose is corrected to current finite admission and preserved '
    'single-statement evidence. Runtime/test/checker implementations and dependency pins stay '
    'unchanged. Exact staged canonical CI/receipt and normal hooks separately govern landing.')
claim = dict(name='finite-engineering-history-member-0135', statement=statement,
    scope=('Only the demonstrated history member/manifest and sole ADR/index overhead are admitted. '
        'The first1793/1794 snapshots omit delegated helper/config inputs. Supplied unions1978/1979 '
        'retain full failures, including file-snapshot directory presence and the intended own-Git-root '
        'contract. The accepted proof is a distinct original-project capture, not a portable copied '
        'repository replay. Full channels and Git fixture bytes/source/modes are retained. The first '
        'readonly reader wrongly classified the new support producer as accepted Git; its actual '
        'failure/source remain frozen beside the distinct corrected reader. The first four reached '
        'artifact rows remain retained: its index forgery changed an extra LF and hit census before '
        'the intended index rule. A distinct same-size counterfactual completes all five controls. Whole original dated '
        'Knowledge headers/bodies remain recoverable; ten bodies stay exact and the finite-history '
        'card prepends one current account. System Git/Perl/Python/mdBook are reused read-only as '
        'environmental dependencies, without immutable toolchain or cross-version HTML claims. '
        'No runtime semantics or broader callback/private/parent admission is inferred. Canonical '
        'logs/receipt remain separately governed and are excluded from the fixed evidence census.'),
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh '+PREFIX+'publish.py '
        '(readonly default). final-review.py, final-evidence.py and book-review.py are readonly by default. '
        'One-shot preservation/measurement/replay/admission/control/Knowledge/book writers remain retired.',
        granularity='Exact complete source suffix/current root/manifest and every228 prior file; '
        'all449 accepted callback bindings/whole publication/baseline; each1978 original-project '
        'input and four historical Git fixture artifacts; five changed registry scalar fields; '
        'all30 numeric/23 authority controls; five semantic artifact faults/restorations; full '
        '1485 original/1486 current Markdown and eleven overlays; full89 book inputs/four controls.',
        result=statement),
    falsify=dict(status='checked', hypothesis='Old capacity may admit another member without authority, '
        'finite admission may hide future reserve or altered archives, self-consistent metadata may '
        'forge original/resulting registry identities or whole accepted evidence, an index mention '
        'outside its table may masquerade as current authority, or omitted source inputs may hide '
        'the actual old-cap mechanism.',
        oracle='Independent accepted-Git namespace/bytes and complete-record arithmetic; unchanged '
        'production threshold and accepted/indexed/exact-object functions; distinct original-project '
        'full channel replay retaining the own-Git-root guard; independent complete book graph and '
        'actual rendered teaching, full historical/current Knowledge custody.',
        red_control='Actual next-record pressure255 and old routing1 with exactly three original '
        'denials precede deltas. Thirty numeric observations distinguish old/new/one-over bounds. '
        'Twenty-three production authority faults reject missing new ADR/index, proposed/missing/'
        'duplicate status, wrong old/new objects and unreviewed increases. Five actual subprocess '
        'artifact REDs reject an omitted prior file, coherently forged original/resulting registry, '
        'displaced index row and altered whole callback publication; all exact byte/mode restorations '
        'pass. Complete book controls retain missing SUMMARY, two removed rendered markers and '
        'missing recursive include. Both copied-root failures and first reader failure remain retained.'),
    durability=dict(status='checked', mode='live', inputs=inputs))
record = dict(version=1, owner=LEAF, claims=[claim])
value = (json.dumps(record, indent=2) + '\n').encode()
assert len(value) <= 131072, ('bounded finite-admission publication', len(value))
if sys.argv[1:]:
    with TARGET.open('xb') as output:
        output.write(value)
else:
    assert TARGET.read_bytes() == value, 'exact current readonly finite-admission publication'
print('Finite engineering-history publication PASS:', len(inputs), 'live inputs;', len(value), 'bytes')
