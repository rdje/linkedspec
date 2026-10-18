"""Replay the first proof from its bytes; independently check the corrected book."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3/'
CHAPTER = 'docs/linkedspec-book/src/development/documentation-workflow.md'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
preflight = sys.argv[1:] == ['--preflight']
capsule_path = PREFIX + 'first-proof-inputs.json.gz'
capsule_raw = (ROOT / capsule_path).read_bytes()
files = json.loads(gzip.decompress(capsule_raw))
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert len(files) == 465 and evidence['inputs'] == {
    p: {k: v for k, v in item.items() if k != 'bytes_base64'} for p, item in files.items()}
for path, item in files.items():
    assert sha(decode(item['bytes_base64'])) == item['sha256']
    if path != CHAPTER:
        assert sha((ROOT / path).read_bytes()) == item['sha256'], ('unchanged first proof input', path)
        assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']

before = decode(files[CHAPTER]['bytes_base64']).decode()
start = before.index('The current verification entrypoint checks the bounded if/while callback repair,')
end = before.index('root and aggregate budgets stay fixed:', start) + len('root and aggregate budgets stay fixed:')
expected = before[:start] + '''The current verification entrypoint checks the bounded switch callback integration,
including unchanged ordinary observations, actual callback frames, full-source
faults and supplied consumers. Its immediate predecessor is the complete463-input
if/while publication at `09000223f`; the earlier155-input artifact publication
remains at `a60764c11`, and the finite engineering-history publication remains at
`e2ec1e96b`. No historical observation is refreshed. Existing root and aggregate
budgets stay fixed:''' + before[end:]
assert (ROOT / CHAPTER).read_text() == expected, 'only the identified workflow paragraph changes'

def run(command, cwd, environment=None):
    result = subprocess.run(command, cwd=cwd, env=environment, capture_output=True)
    record = {'command': command, 'returncode': result.returncode,
              'stdout_base64': base64.b64encode(result.stdout).decode(),
              'stderr_base64': base64.b64encode(result.stderr).decode()}
    assert result.returncode == 0 and not result.stderr, record
    return record

with tempfile.TemporaryDirectory(prefix='switch-first-proof-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, item in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(decode(item['bytes_base64']))
        destination.chmod(item['mode'])
    artifact_paths = {PREFIX + name for name in (
        'evidence.json', 'evidence-data.json.gz', 'evidence-baseline.json')}
    for path in artifact_paths:
        (supplied / path).write_bytes((ROOT / path).read_bytes())
    environment = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied))
    if preflight:
        proof = run(['python3', PREFIX + 'review-final.py', '--preflight'], supplied, environment)
    else:
        standard_raw = (ROOT / (PREFIX + 'compat.json')).read_bytes()
        standard = json.loads(standard_raw)
        assert standard['result'] == 'PASS' and len(standard['rows']) == 5
        assert all(row['returncode'] == 0 for row in standard['rows'])
        (supplied / (PREFIX + 'compat.json')).write_bytes(standard_raw)
        proof = run(['python3', PREFIX + 'review-final.py', '--capture'], supplied, environment)
        original_review = json.loads((supplied / (PREFIX + 'review.json')).read_bytes())
    artifact = run(['python3', PREFIX + 'evidence.py'], supplied, environment)
    for path, item in files.items():
        assert sha((supplied / path).read_bytes()) == item['sha256']
        assert (supplied / path).stat().st_mode & 0o7777 == item['mode']

book_command = ['python3', PREFIX + 'book-current-review.py']
book_channel = run(book_command, ROOT)
book = json.loads((ROOT / (PREFIX + 'book-current-review.json')).read_bytes())
assert book['source_count'] == 89 and book['actual_controls'] == 4
if preflight:
    print('Switch composition preflight PASS: first465 input bytes replay; corrected book89/four controls')
    raise SystemExit(0)

paths = set(files) | set(book['source_inputs']) | artifact_paths | {
    PREFIX + name for name in ('compose.py', 'first-proof-inputs.json.gz',
        'first-proof-snapshot.py',
        'book-current.py', 'book-current.json', 'book-current-review.py',
        'book-current-review.json', 'compat.json')}
report = {
    'result': 'PASS', 'base': original_review['base'],
    'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {p: {'sha256': sha((ROOT / p).read_bytes()),
                   'mode': (ROOT / p).stat().st_mode & 0o7777} for p in sorted(paths)},
    'original_review': original_review,
    'population': {**original_review['population'], 'book_epochs': 2},
    'channels': [proof, artifact, book_channel],
    'scope': 'The complete first465-input proof replays from its retained bytes on this repository volume. '
             'Only this repository Git objects/index are reused read-only. Every first runtime/proof input '
             'remains live-identical except the workflow chapter, whose exact single-paragraph correction '
             'is independently reconstructed. First rendered/source-control observations remain unchanged; '
             'a distinct current89-input book render checks corrected switch/predecessor teaching and four '
             'actual source/render controls. Standard Phase0/public guard stay supplemental without full '
             'transitive capsules. No original runtime observation or broader admission is refreshed.',
}
value = (json.dumps(report, indent=2) + '\n').encode()
target = ROOT / (PREFIX + 'review-composed.json')
if sys.argv[1:] == ['--capture']:
    with target.open('xb') as output:
        output.write(value)
else:
    assert target.read_bytes() == value
print('Switch composition PASS: original465-input proof and both89-input book epochs')
