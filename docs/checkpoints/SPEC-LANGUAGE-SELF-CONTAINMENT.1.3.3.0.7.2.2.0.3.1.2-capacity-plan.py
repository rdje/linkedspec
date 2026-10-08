"""Derive one finite clean-source rollover without mutating policy or history."""
from pathlib import Path
import copy
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
REVISION = '47444428a8ceb65cb0ced06625db4eb8a44b8209'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
CURRENT = 'DEVELOPMENT_NOTES.md'

def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)

def original(path):
    return git('show', REVISION + ':' + path)

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def encode(value):
    return (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()

assert git('rev-parse', 'HEAD').decode().strip() == REVISION, 'clean activation boundary'
for path in (REGISTRY, MANIFEST, CURRENT):
    assert (ROOT / path).read_bytes() == original(path), 'unmodified proposal input: ' + path
raw = original(CURRENT)
marks = [m.start() for m in re.finditer(rb'^## ', raw, re.M)]
assert marks, 'complete dated record boundaries'
preamble = raw[:marks[0]]
records = [raw[a:b] for a, b in zip(marks, marks[1:] + [len(raw)])]
note = (
    '## 2026-10-08 — Finite replacement-note history (.0.3.1.2)\n\n'
    'One governed engineering-note rollover preserves complete clean records before '
    'private occurrence handoff. The indexed decision admits one archive and exact '
    'manifest row; root, segment and aggregate budgets and prior history stay unchanged. '
    'Exact reconstruction and actual threshold/authority controls precede staged '
    'canonical acceptance.\n\n'
).encode()
assert len(raw + note) * 100 >= 65536 * 90, 'actual note requires governed rollover'
keep = len(records)
while keep and (len(preamble + note + b''.join(records[:keep])) > 32768
                or (preamble + note + b''.join(records[:keep])).count(b'\n') > 256):
    keep -= 1
assert keep, 'retained current records'
archive = b''.join(records[keep:])
assert archive and raw.endswith(archive), 'complete original clean suffix'
prefix = raw[:-len(archive)]
retained_with_separator = preamble + note + b''.join(records[:keep])
retained = re.sub(rb'\n{2,}\Z', b'\n', retained_with_separator)
old_manifest = original(MANIFEST)
rows = [json.loads(line) for line in old_manifest.splitlines()]
segment = f"{int(rows[1]['segment_id']) - 1:04d}"
digest = sha(archive)
target = 'docs/history/development-notes/segment-' + segment + '-' + digest[:12] + '.md'
row = {
    'byte_count': len(archive), 'current_path': CURRENT, 'immutable': True,
    'line_count': archive.count(b'\n'),
    'retrieval_command': 'perl tools/read_document_history.pl --surface engineering_notes --segment ' + segment,
    'segment_id': segment, 'sha256': digest,
    'source_blob': git('rev-parse', REVISION + ':' + CURRENT).decode().strip(),
    'source_commit': REVISION, 'source_end_line': raw.count(b'\n'),
    'source_path': CURRENT, 'source_start_line': prefix.count(b'\n') + 1,
    'surface': 'engineering_notes', 'target_path': target, 'type': 'segment',
}
metadata = copy.deepcopy(rows[0])
metadata['segment_count'] += 1
new_manifest = b''.join(encode(item) for item in [metadata, row, *rows[1:]])
assert new_manifest.splitlines(keepends=True)[2:] == old_manifest.splitlines(keepends=True)[1:], 'prior row bytes'
registry_rows = [json.loads(line) for line in original(REGISTRY).splitlines()]
old = next(item for item in registry_rows if item.get('id') == 'engineering_notes')
new = copy.deepcopy(old)
assert old['limits']['max_files'] == 44, 'original finite control'
assert old['member_limits'][MANIFEST] == {'max_bytes': 26021, 'max_lines': 43}, 'original manifest control'
new['limits']['max_files'] += 1
new['member_limits'][MANIFEST] = {'max_bytes': len(new_manifest), 'max_lines': len(rows) + 1}

def contract(route):
    result = {key: route[key] for key in (
        'authority', 'control', 'lifecycle', 'member_limits', 'members', 'owner',
        'route_targets', 'state', 'verifier')}
    result['transition_owners'] = route.get('transition', {}).get('owners')
    return result

prior_paths = [item['target_path'] for item in rows[1:]]
prior = {path: original(path) for path in prior_paths}
for path, value in prior.items():
    assert (ROOT / path).read_bytes() == value, 'original archive byte identity: ' + path
population = [retained, new_manifest, archive, *prior.values()]
metrics = {'files': len(population), 'lines': sum(value.count(b'\n') for value in population),
           'bytes': sum(map(len, population))}
assert metrics['files'] == new['limits']['max_files'] == 45
assert metrics['lines'] <= old['limits']['max_total_lines'], 'unchanged aggregate lines'
assert metrics['bytes'] <= old['limits']['max_total_bytes'], 'unchanged aggregate bytes'
assert all(value.count(b'\n') <= old['limits']['max_lines_per_file']
           and len(value) <= old['limits']['max_bytes_per_file'] for value in population), 'unchanged per-file limits'
result = {
    'complete': True, 'revision': REVISION, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'status': 'finite engineering maintenance decision; actual governed publication and canonical admission required',
    'old_limits': old['limits'], 'new_limits': new['limits'],
    'old_member_limits': old['member_limits'], 'new_member_limits': new['member_limits'],
    'old_contract': contract(old), 'new_contract': contract(new),
    'original_root': {'bytes': len(raw), 'lines': raw.count(b'\n'), 'sha256': sha(raw)},
    'new_note': {'bytes': len(note), 'lines': note.count(b'\n'), 'sha256': sha(note)},
    'retained_root': {'bytes': len(retained), 'lines': retained.count(b'\n'), 'sha256': sha(retained)},
    'original_manifest': {'bytes': len(old_manifest), 'lines': len(rows), 'sha256': sha(old_manifest)},
    'new_manifest': {'bytes': len(new_manifest), 'lines': len(rows) + 1, 'sha256': sha(new_manifest)},
    'archive_record': row, 'collection': metrics,
    'prior_archives': [{'path': path, 'sha256': sha(value), 'bytes': len(value), 'lines': value.count(b'\n')}
                       for path, value in prior.items()],
    'scope': 'One archive and one exact manifest row; three scalar changes only. No root, per-file, aggregate, '
             'other surface, history-byte, runtime, checker or dependency change; no unlimited PNT reserve. '
             'Autonomous full-PNT maintenance authorization, without a new explicit director grant claim.',
}
(ROOT / (PREFIX + 'proposed-note.md')).write_bytes(note[:-1])
(ROOT / (PREFIX + 'capacity-plan.json')).write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({key: result[key] for key in ('revision', 'original_root', 'retained_root', 'new_manifest',
                                             'archive_record', 'collection')}))
