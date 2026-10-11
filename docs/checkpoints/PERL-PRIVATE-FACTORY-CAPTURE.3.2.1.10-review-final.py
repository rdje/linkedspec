"""Readonly fixed-population recovery, original preservation and current routing review."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '16c70eaab688a877053b1addde8f07bc548e1cbf'
ACCEPTED = 'fc96936fb64d27e692e66377b2e332641c2674fd'
ORIGIN = '61cca1cccff6027461e120e4236431d1bc7d20b1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10-'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
CLAIMS = ('docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json', 'docs/claims/REPO-HYGIENE.16.json')
CARDS = ('docs/knowledge/perl-legacy-hash-kind-callback.md', 'docs/knowledge/perl-method-trim-capture.md', 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md')
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
BODY = PREFIX + 'corrected-body.py'
EXECUTOR = PREFIX + 'execute.py'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda rev, p: subprocess.check_output(['git', 'show', rev + ':' + p], cwd=ROOT)
read = lambda p: (ROOT / p).read_bytes()
load = lambda tail: json.loads(read(PREFIX + tail))
assert sys.argv[1:] in ([], ['--capture'])


def channels(row):
    return tuple(base64.b64decode(row[key], validate=True) for key in ('stdout_base64', 'stderr_base64'))


def source_identity(row, tail):
    assert row['producer_sha256'] == sha(read(PREFIX + tail)), 'actual retained producer identity'


originals = {}
allowed = set(CARDS) | {BOOK, CLAIMS[0]}
current_inputs = {}
freeze = load('freeze.json')
assert freeze['base'] == BASE and [row['claim'] for row in freeze['records']] == list(CLAIMS)
source_identity(freeze, 'freeze.py')
for row, expected_count, expected_bytes in zip(freeze['records'], (366, 24), (85779, 9306)):
    path = row['claim']
    raw = old(BASE, path)
    assert read(row['before']) == raw and len(raw) == expected_bytes and sha(raw) == row['original_sha256'], 'exact original full publication'
    original = json.loads(raw)
    originals[path] = original
    entries = original['claims'][0]['durability']['inputs']
    assert len(entries) == expected_count
    assert row['affected'] == [{'index': 0, 'name': original['claims'][0]['name'], 'bindings': expected_count}]
    for entry in entries:
        assert sha(old(BASE, entry['path'])) == entry['sha256'], 'every original390 declared binding'
        actual = read(entry['path'])
        if entry['path'] not in allowed:
            assert sha(actual) == entry['sha256'], 'unchanged current runtime/proof input: ' + entry['path']
        current_inputs[entry['path']] = sha(actual)
    expected = copy.deepcopy(original)
    expected['claims'][0]['durability'].update(mode='historical', revision=BASE)
    expected_raw = (json.dumps(expected, indent=2) + '\n').encode()
    assert read(path) == expected_raw and sha(expected_raw) == row['after_sha256'], 'sole original mode/revision changes'
    current_inputs[path] = sha(expected_raw)
refusal = load('refusal.json')
source_identity(refusal, 'preserve.py')
assert refusal['command'] == ['python3', OLD + 'publish-claim.py'] and refusal['returncode'] == 1
assert refusal['claim_inputs_before'] == {p: sha(old(BASE, p)) for p in CLAIMS}
out, err = channels(refusal)
assert not out and b'docs/claims/REPO-HYGIENE.16.json' in err and b'exists on disk, but not in' in err and ORIGIN.encode() in err, 'actual original namespace refusal'
assert freeze['refusal_sha256'] == sha(read(PREFIX + 'refusal.json'))
baseline_raw = read(refusal['prior_baseline'])
assert sha(baseline_raw) == refusal['prior_baseline_sha256'] and baseline_raw == old(BASE, refusal['prior_baseline'])
baseline = json.loads(baseline_raw)
assert baseline['returncode'] == 0 and not channels(baseline)[1] and b'366 live inputs; 85779 bytes' in channels(baseline)[0]
first = load('first-preserve-failure.json')
source_identity(first, 'preserve.py')
assert first['returncode'] == 1 and b'AssertionError: actual unrelated-claim original refusal' in base64.b64decode(first['actual_merged_output_base64'], validate=True)
assert b"b'does not exist in' in result.stderr" in read(PREFIX + 'preserve.py')
original_source = old(ACCEPTED, OLD + 'review.py')
before = b"for path in sorted((ROOT / 'docs/claims').glob('*.json')):\n    relative = path.relative_to(ROOT).as_posix()"
after = b"original_claim_paths = subprocess.check_output(\n    ['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()\nfor relative in sorted(original_claim_paths):"
assert original_source.count(before) == 1
fixed = original_source.replace(before, after, 1)
assert read(OLD + 'review.py') == original_source and read(BODY) == fixed, 'sole historical population correction'
envelope = load('namespaces.json')
source_identity(envelope, 'historical.py')
raw = gzip.decompress(base64.b64decode(envelope['data'], validate=True))
assert envelope['encoding'] == 'gzip-base64' and len(raw) == envelope['bytes'] and sha(raw) == envelope['sha256']
snapshots = json.loads(raw)
assert set(snapshots) == {BASE, ACCEPTED, ORIGIN}
for revision, values in snapshots.items():
    paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', revision, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
    assert set(values) == set(paths), 'complete fixed claim population'
    assert all(base64.b64decode(values[p], validate=True) == old(revision, p) for p in paths), 'exact historical claim namespace bytes'
assert gzip.compress(raw, mtime=0) == base64.b64decode(envelope['data'], validate=True)
accepted_raw = old(ACCEPTED, CLAIMS[0])
accepted_entries = json.loads(accepted_raw)['claims'][0]['durability']['inputs']
files = {entry['path']: old(ACCEPTED, entry['path']) for entry in accepted_entries}
assert all(sha(files[entry['path']]) == entry['sha256'] for entry in accepted_entries)
for path, value in snapshots[ACCEPTED].items():
    value = base64.b64decode(value, validate=True)
    assert path not in files or files[path] == value
    files[path] = value
files[EXECUTOR] = read(EXECUTOR)
files[BODY] = fixed
initial_inputs = {p: sha(raw) for p, raw in files.items()}
draft = load('recovery-reached.json')
assert len(draft['rows']) == 1
draft_row = draft['rows'][0]
assert draft_row['name'] == 'accepted' and draft_row['inputs'] == initial_inputs and len(initial_inputs) == 499 and draft_row['unchanged'] and draft_row['returncode'] == 1
assert b'FileNotFoundError' in channels(draft_row)[1] and b'.3.2.1.1-consumers.json' in channels(draft_row)[1], 'retained incomplete replay boundary'
first_recovery = load('first-recovery-failure.json')
source_identity(first_recovery, 'recovery.py')
assert first_recovery['returncode'] == 1 and first_recovery['reached_sha256'] == sha(read(PREFIX + 'recovery-reached.json'))
assert b'actual historical recovery PASS' in base64.b64decode(first_recovery['actual_merged_output_base64'], validate=True)
published = json.loads(old(ACCEPTED, 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1.json'))['claims'][0]['durability']
assert published['mode'] == 'historical' and published['revision'] == ORIGIN and len(published['inputs']) == 339
additional = [entry for entry in published['inputs'] if entry['path'] not in files]
assert len(additional) == 33
for entry in additional:
    value = old(ORIGIN, entry['path'])
    assert sha(value) == entry['sha256']
    files[entry['path']] = value
recovery = load('recovery-final.json')
source_identity(recovery, 'recovery-final.py')
assert recovery['accepted'] == ACCEPTED and recovery['base'] == BASE and recovery['namespace'] == sorted(snapshots[ACCEPTED])
assert recovery['published_historical_inputs'] == additional
assert recovery['original_claim_sha256'] == sha(accepted_raw) and recovery['extra_claim_sha256'] == sha(old(BASE, CLAIMS[1]))
assert load('recovery-final-reached.json') == {'rows': recovery['rows']}
names = ('accepted', 'original-extra', 'fixed-extra', 'stale-body', 'omitted-origin', 'added-new', 'restored')
assert [row['name'] for row in recovery['rows']] == list(names)
mode_lines = subprocess.check_output(['git', 'ls-tree', '-r', ACCEPTED], cwd=ROOT, text=True).splitlines()
git_modes = {line.split('\t')[1]: int(line.split()[0], 8) & 0o777 for line in mode_lines if line.split()[0] != '160000'}
for row, name in zip(recovery['rows'], names):
    expected = dict(files)
    if name != 'accepted':
        expected[CLAIMS[1]] = old(BASE, CLAIMS[1])
    if name == 'stale-body':
        expected[BODY] = original_source
    elif name == 'omitted-origin':
        expected[BODY] = fixed.replace(b'for relative in sorted(original_claim_paths):', b"for relative in sorted(p for p in original_claim_paths if p != 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1.json'):", 1)
    elif name == 'added-new':
        expected[BODY] = fixed.replace(b'for relative in sorted(original_claim_paths):', b"original_claim_paths.append('docs/claims/REPO-HYGIENE.16.json')\nfor relative in sorted(original_claim_paths):", 1)
    assert row['inputs'] == {p: sha(raw) for p, raw in expected.items()} and row['modes'] == {p: git_modes.get(p, 0o644) for p in expected}, 'complete actual supplied recovery inputs'
    assert len(expected) == (532 if name == 'accepted' else 533) and row['unchanged']
    assert base64.b64decode(row['body_base64'], validate=True) == expected[BODY], 'exact retained executed body'
    command = ['python3', OLD + 'publish-claim.py'] if name == 'accepted' else ['python3', OLD + 'review.py'] if name == 'original-extra' else ['python3', EXECUTOR, sha(expected[BODY])]
    assert row['command'] == command and row['syntax']['returncode'] == 0 and channels(row['syntax']) == (b'', b'')
    out, err = channels(row)
    if name in ('original-extra', 'stale-body', 'added-new'):
        assert row['returncode'] != 0 and CLAIMS[1].encode() in err and b'not in' in err, 'actual namespace semantic RED'
    elif name == 'omitted-origin':
        assert row['returncode'] != 0 and b'complete original live intersection census' in err, 'actual original membership RED'
    else:
        assert row['returncode'] == 0 and not err, 'actual complete recovery must pass'
        assert (b'366 live inputs; 85779 bytes' if name == 'accepted' else b'Executed review body SHA256 ' + sha(fixed).encode()) in out
assert recovery['rows'][2]['stdout_base64'] == recovery['rows'][6]['stdout_base64']
for tail in ('historical.py', 'book-review.py'):
    result = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('actual readonly dependent', tail, result.stderr)
book = load('book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 3
command_text = (PREFIX + 'publish-claim.py').encode()
for path in CARDS:
    current = read(path)
    historic = old(BASE, path)
    assert command_text in current.split(b'\n---\n', 1)[0], 'current readonly routing pointer'
    assert current.split(b'\n---\n', 1)[1].startswith(historic.split(b'\n---\n', 1)[1]), 'original knowledge bodies retained'
assert command_text in read(BOOK) and b'Historical claim populations' in read(BOOK)
proofs = ('preserve.py', 'refusal.json', 'first-preserve-failure.json', 'freeze.py', 'freeze.json',
          'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json', 'before-REPO-HYGIENE.16.json', 'corrected-body.py', 'execute.py',
          'recovery.py', 'recovery-reached.json', 'first-recovery-failure.json', 'recovery-final.py', 'recovery-final.json', 'recovery-final-reached.json',
          'historical.py', 'namespaces.json', 'hygiene-recovery.json', 'hygiene-recovery-reached.json', 'book.py', 'book.json', 'book-review.py', 'book-review.json', 'review.py', 'first-reviewer-failure.json', 'review-final.py')
current_inputs.update(book['source_inputs'])
current_inputs.update({p: sha(read(p)) for p in CARDS})
current_inputs.update({PREFIX + tail: sha(read(PREFIX + tail)) for tail in proofs})
assert all(sha(read(p)) == digest for p, digest in current_inputs.items())
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'input_metadata': current_inputs,
          'original_declared_bindings': 390, 'original_record_bytes': [85779, 9306], 'accepted_recovery_inputs': 532, 'extended_recovery_inputs': 533,
          'recovery_cases': list(names), 'published_historical_supplement': 33, 'maintenance_recovery_inputs': 25, 'book_inputs': 89,
          'scope': 'Readonly historical claim-population correction only; every original binding/full publication and native/paired/fault/consumer observation preserved. Current runtime/proof inputs match accepted bytes; only related card/book routing and mode/revision preservation change. Full fixed historical claim bytes retained. Complete accepted publication and maintenance recovery, actual semantic population/binding controls and current book. First matcher and incomplete replay failures/sole repairs remain exact. Historical report retains its real original producer identity; executed corrected source is separately identified. No new runtime/private/parent/canonical admission.'}
target = ROOT / (PREFIX + 'review-final.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'exact readonly composed recovery review'
print('Fixed claim census review PASS: original390/full85779+9306; accepted532/extended533/seven cases; historical33; maintenance25; book89/3')
