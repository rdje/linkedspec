"""Readonly review of byte-exact diagnostic encoding and original recovery."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-'
BASE = '61a73324f06238418301eac88fd3f908665ecbe3'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
load = lambda path: json.loads((ROOT / path).read_bytes())
packed_raw = (ROOT / (PREFIX + 'portability-first-candidate.json')).read_bytes()
packed = json.loads(packed_raw)
raw = gzip.decompress(decode(packed['data']))
assert packed['encoding'] == 'gzip-base64' and packed['bytes'] == len(raw) and packed['sha256'] == sha(raw)
assert gzip.compress(raw, mtime=0) == decode(packed['data'])
candidate = json.loads(raw)
assert candidate['base'] == BASE and len(candidate['staged_files']) == 75
assert candidate['staged_diff_sha256'] == sha(decode(candidate['staged_diff_base64']))
captured = {}
for row in candidate['staged_files']:
    path = row['path']
    assert path not in captured and not path.startswith('/') and '..' not in Path(path).parts
    body = decode(row['data_base64'])
    assert len(body) == row['bytes'] and sha(body) == row['sha256']
    captured[path] = body
original_claim = json.loads(captured[CLAIM])
bindings = original_claim['claims'][0]['durability']['inputs']
assert len(bindings) == 511 and len(captured[CLAIM]) == 119230
logical = {}
for item in bindings:
    path = item['path']
    body = captured[path] if path in captured else subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    assert sha(body) == item['sha256'], ('complete first publication binding', path)
    logical[path] = item['sha256']
logical[CLAIM] = sha(captured[CLAIM])
assert len(logical) == 512
channels = ('first-run-failures.json', 'first-consumer-failure.json')
for tail in channels:
    path = PREFIX + tail
    expected = json.loads(captured[path])
    rows = expected['rows'] if 'rows' in expected else [expected]
    for row in rows:
        body = row.pop('available_merged_outer_channel').encode()
        row['available_merged_outer_channel_base64'] = base64.b64encode(body).decode()
        assert decode(row['available_merged_outer_channel_base64']) == body
    assert (ROOT / path).read_bytes() == (json.dumps(expected, indent=2) + '\n').encode(), 'sole byte-exact channel representation correction'
mutable = {'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md',
           'ROADMAP.md', 'ROADMAP_V2.md', 'KNOWLEDGE_MAP.md', 'docs/TASK_TREE.md',
           'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md', CLAIM,
           'docs/linkedspec-book/src/development/documentation-workflow.md',
           'docs/knowledge/perl-method-trim-capture.md',
           'docs/knowledge/perl-legacy-hash-kind-callback.md',
           'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'}
mutable.update(PREFIX + tail for tail in channels)
for path, body in captured.items():
    if path not in mutable:
        assert (ROOT / path).read_bytes() == body, ('original source/observation/report retained', path)
chapter = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert (ROOT / chapter).read_bytes() == captured[chapter].replace(
    (PREFIX + 'publish-claim.py').encode(), (PREFIX + 'publish-claim-final.py').encode()), 'sole public readonly route correction'
for path in sorted(p for p in mutable if p.startswith('docs/knowledge/')):
    expected = captured[path].replace(
        (PREFIX + 'publish-claim.py; review.py, native-review.py, book-review.py and evidence.py').encode(),
        (PREFIX + 'publish-claim-final.py; review-final.py, native-review.py, book-review-final.py and evidence-final.py').encode())
    assert (ROOT / path).read_bytes() == expected, 'sole current card route correction'
failure = load(PREFIX + 'portability-commit-failure.json')
assert failure['actual_returncode'] == 1 and failure['actual_tool_session'] == 7004
log = decode(failure['commit_log_base64'])
assert sha(log) == failure['commit_log_sha256'] and log.count(b'  PASS  ') == 9
assert log.count(b'  FAIL  ') == 1 and b'FAIL  REPO-ROOT-PATHS' in log
assert 'anticipated exit1' in failure['first_snapshot_status_note']
first_recovery = load(PREFIX + 'portability-recovery-first-failure.json')
assert first_recovery['actual_returncode'] == 1
assert first_recovery['producer_sha256'] == sha((ROOT / (PREFIX + 'portability-recover.py')).read_bytes())
assert first_recovery['reached_sha256'] == sha((ROOT / (PREFIX + 'portability-recovery-reached.json')).read_bytes())
first_reached = load(PREFIX + 'portability-recovery-reached.json')
assert len(first_reached['rows']) == 1 and first_reached['rows'][0]['returncode'] != 0
assert first_reached['rows'][0]['inputs'] == logical and first_reached['rows'][0]['unchanged']
assert b'complete fixed original claim population' in decode(first_reached['rows'][0]['stderr_base64'])
recovery = load(PREFIX + 'portability-recovery-final.json')
assert recovery['result'] == 'PASS' and recovery['base'] == BASE
assert recovery['producer_sha256'] == sha((ROOT / (PREFIX + 'portability-recover-final.py')).read_bytes())
assert recovery['candidate_sha256'] == sha(packed_raw) and recovery['logical_inputs'] == logical
assert recovery['original_bindings'] == 511 and recovery['original_claim_bytes'] == 119230
assert [row['name'] for row in recovery['rows']] == ['original', 'changed-diagnostic', 'restored']
for row in recovery['rows']:
    expected = dict(logical)
    if row['name'] == 'changed-diagnostic':
        expected[PREFIX + channels[0]] = sha((ROOT / (PREFIX + channels[0])).read_bytes())
    assert row['inputs'] == expected and row['unchanged']
    assert set(row['modes']) == set(logical) and row['modes'] == recovery['rows'][0]['modes']
    assert row['command'] == ['python3', PREFIX + 'publish-claim.py']
    if row['name'] == 'changed-diagnostic':
        assert row['returncode'] != 0 and decode(row['stderr_base64'])
    else:
        assert row['returncode'] == 0 and not decode(row['stderr_base64'])
        assert decode(row['stdout_base64']) == b'Method-kind publication PASS: 511 live inputs; 119230 bytes\n'
assert recovery['rows'][0] == dict(recovery['rows'][2], name='original')
print('Portable diagnostic review PASS:exact channels/original75 files; original512-input publication recovery and RED/restoration')
