"""Apply only the demonstrated finite member/manifest and sole-decision overhead."""
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '736c6a43efab526fe898ed5c72b061479955fc5c'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.5.1.3'
REG = 'doctrine/readme_stability/routes.jsonl'
INDEX = 'docs/decisions/INDEX.md'
ADR = 'docs/decisions/0135-finite-engineering-notes-member.md'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
TARGET = ROOT / (PREFIX + 'plan.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
decode = lambda value: base64.b64decode(value, validate=True)
compact = lambda value: json.dumps(value, sort_keys=True, separators=(',', ':'))
raw = lambda path: (ROOT / path).read_bytes()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert not TARGET.exists() and not (ROOT / ADR).exists(), 'one-shot finite proposal'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
measurement_raw = raw(PREFIX + 'measurement.json')
measurement = json.loads(measurement_raw)
completion_raw = raw(PREFIX + 'complete-inputs-root.json')
completion = json.loads(completion_raw)
assert measurement['result'] == completion['result'] == 'PASS', 'complete original-project input leg before deltas'
assert completion['original_measurement_sha256'] == sha(measurement_raw)
rolled_raw = raw(PREFIX + 'rolled-inputs.json.gz')
assert sha(rolled_raw) == measurement['captures']['rolled']['sha256']
rolled = json.loads(gzip.decompress(rolled_raw))
for path in ('CHANGES.md', 'DEVELOPMENT_NOTES.md', MANIFEST, REG, INDEX):
    assert raw(path) == decode(rolled[path]['bytes_base64']), ('unchanged actual rolled input', path)
assert all(sha(raw(p)) == identity == sha(old(p)) for p, identity in measurement['preserved'].items())

rows = [json.loads(line) for line in old(REG).splitlines()]
before = {row['id']: row for row in rows if 'id' in row}
changed_rows = copy.deepcopy(rows)
after = {row['id']: row for row in changed_rows if 'id' in row}

def metrics(paths):
    values = [raw(p) for p in paths]
    return {'files': len(values), 'lines': sum(v.count(b'\n') for v in values), 'bytes': sum(map(len, values))}

engineering_paths = ['DEVELOPMENT_NOTES.md', MANIFEST] + sorted(
    p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/history/development-notes').glob('*.md'))
engineering = metrics(engineering_paths)
assert engineering['files'] == before['engineering_notes']['limits']['max_files'] + 1
assert engineering['lines'] <= before['engineering_notes']['limits']['max_total_lines']
assert engineering['bytes'] <= before['engineering_notes']['limits']['max_total_bytes']
manifest_lines = raw(MANIFEST).count(b'\n')
manifest_bytes = len(raw(MANIFEST))
old_member = before['engineering_notes']['member_limits'][MANIFEST]
assert manifest_lines == old_member['max_lines'] + 1 and manifest_bytes > old_member['max_bytes']
after['engineering_notes']['limits']['max_files'] = engineering['files']
after['engineering_notes']['member_limits'][MANIFEST] = {'max_lines': manifest_lines, 'max_bytes': manifest_bytes}

prior_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/decisions'], cwd=ROOT, text=True).splitlines()
assert all(path.endswith('.md') for path in prior_paths)
assert max(int(Path(path).name[:4]) for path in prior_paths if Path(path).name[:4].isdigit()) == 134
index_row = ('| [0135](0135-finite-engineering-notes-member.md) | One finite engineering-history '
    'member and exact manifest/decision overhead | 2026-10-17 | accepted engineering maintenance; '
    'canonical admission required | history, capacity, verification |\n').encode()
index_before = old(INDEX)
last = re.findall(rb'^\| \[0134\].*\n', index_before, re.M)
assert len(last) == 1 and index_row not in index_before
index_after = index_before.replace(last[0], last[0] + index_row, 1)
assert index_after.count(b'\n') - index_before.count(b'\n') == 1
assert index_after.index(index_row) < index_after.index(b'\n## How to add a record')
prior_lines = sum(old(path).count(b'\n') for path in prior_paths)
after['decisions']['limits']['max_files'] = len(prior_paths) + 1

def contract(row):
    fields = ('authority', 'control', 'lifecycle', 'member_limits', 'members', 'owner', 'route_targets', 'state', 'verifier')
    return {**{name: row.get(name) for name in fields}, 'transition_owners': row.get('transition', {}).get('owners')}

def decision():
    text = ('# ADR 0135: One finite engineering-notes archive member\n\n'
        '- Date: 2026-10-17\n'
        f'- Status: accepted engineering maintenance under `{LEAF}`; exact canonical admission required\n'
        '- Tags: history, capacity, continuity, verification\n\n')
    for surface in ('engineering_notes', 'decisions'):
        text += (f'## Exact {surface} authorization\n\n- Routed surface: `{surface}`\n'
            f'- Previous routed limits: `{compact(before[surface]["limits"])}`\n'
            f'- New routed limits: `{compact(after[surface]["limits"])}`\n\n')
        if surface == 'engineering_notes':
            text += (f'- Previous routed contract: `{compact(contract(before[surface]))}`\n'
                f'- New routed contract: `{compact(contract(after[surface]))}`\n\n')
    text += ('## Context and decision\n\n'
        'The next complete engineering note crosses the mandatory byte rollover threshold. '
        'Actual production rollover preserves one complete clean-source suffix; unchanged routing '
        'limits reject its new member and exact manifest line/byte growth. The accepted single-statement '
        'callback slice stayed below the trigger. ADR0133 grants no further archive reserve.\n\n'
        'Under the current full-PNT instruction and ADR0128/0129/0131/0132/0133/0134 engineering-maintenance '
        'precedent, admit exactly that one archive member and its measured manifest growth. '
        'This is an engineering decision, not a newly asserted or reused director grant. '
        'Deleting, repacking or shortening immutable accepted history cannot create the missing slot.\n\n'
        'The decision collection admits only this sole new file and its exact physical line overhead '
        'plus one index row. Every other registry field stays exact: root, aggregate, per-file, byte '
        'and unrelated controls. Stable storage responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 '
        'under ADR0069. No future member reserve is granted.\n\n'
        '## Verification and consequences\n\n'
        'Independently reconstruct the complete clean-source suffix, source blob/range/digest, current '
        'root and prior manifest rows. Preserve all prior history/decision bytes and the complete '
        'accepted callback publication with its actual baseline. Retain first incomplete supplied '
        'snapshots and failures; complete helper/config/directory/attribute inputs through accepted Git and retain the original-project Git-root guard. '
        'Execute unchanged production threshold and accepted/indexed/exact-object authority controls, '
        'retain distinguishing corruptions and require exact staged canonical CI/receipt plus normal hooks.\n\n'
        'Existing history tools, runtime/test/checker implementations, dependency pins and other '
        'repositories remain unchanged. Public documentation describes the finite current scope. '
        f'Owner: docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md; readonly review: `{PREFIX}publish.py` '
        'through tools/run_python_project_data.sh. If/while callbacks .5.2 resume after commit.\n')
    return text.encode()

for _ in range(5):
    adr_bytes = decision()
    limit = prior_lines + adr_bytes.count(b'\n') + index_after.count(b'\n') - index_before.count(b'\n')
    if after['decisions']['limits']['max_total_lines'] == limit:
        break
    after['decisions']['limits']['max_total_lines'] = limit
else:
    raise AssertionError('finite sole-authority fixed point')
adr_bytes = decision()
assert after['decisions']['limits']['max_total_lines'] > before['decisions']['limits']['max_total_lines']

changed_ids = {key for key in before if before[key] != after[key]}
assert changed_ids == {'engineering_notes', 'decisions'}
registry_after = b''.join((compact(after[row['id']]).encode() + b'\n')
    if row.get('id') in changed_ids else line
    for line, row in zip(old(REG).splitlines(True), rows))
plan = {'result': 'prepared', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'measurement_sha256': sha(measurement_raw), 'completion_sha256': sha(completion_raw),
    'old_limits': {name: before[name]['limits'] for name in ('engineering_notes', 'decisions')},
    'new_limits': {name: after[name]['limits'] for name in ('engineering_notes', 'decisions')},
    'old_contract': contract(before['engineering_notes']), 'new_contract': contract(after['engineering_notes']),
    'index_row_base64': encode(index_row), 'decision_lines': adr_bytes.count(b'\n'),
    'index_line_growth': index_after.count(b'\n') - index_before.count(b'\n'),
    'inputs': {PREFIX + 'measurement.json': sha(measurement_raw), PREFIX + 'complete-inputs-root.json': sha(completion_raw)},
    'originals': {path: {'sha256': sha(old(path)), 'bytes_base64': encode(old(path))} for path in (REG, INDEX)},
    'outputs': {path: {'sha256': sha(value), 'bytes_base64': encode(value)} for path, value in (
        (REG, registry_after), (INDEX, index_after), (ADR, adr_bytes))}}
TARGET.write_text(json.dumps(plan, indent=2) + '\n')
(ROOT / ADR).write_bytes(adr_bytes)
(ROOT / INDEX).write_bytes(index_after)
(ROOT / REG).write_bytes(registry_after)
assert all(sha(raw(p)) == identity for p, identity in measurement['preserved'].items())
plan['measured'] = {'engineering_notes': metrics(engineering_paths),
    'decisions': metrics(sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/decisions').glob('*.md'))),
    'manifest': {'lines': manifest_lines, 'bytes': manifest_bytes}}
assert plan['measured']['decisions']['files'] == after['decisions']['limits']['max_files']
assert plan['measured']['decisions']['lines'] == after['decisions']['limits']['max_total_lines']
plan['result'] = 'PASS'
plan['scope'] = ('Only one actual engineering-history member, exact manifest line/byte growth and the sole '
    'new decision/index physical overhead are proposed. All228 prior history/decision identities remain '
    'unchanged. Existing root/aggregate/per-file and all unrelated limits are unchanged. This writer '
    'grants no canonical admission; production controls, independent review, public documentation and '
    'exact staged receipt remain required.')
TARGET.write_text(json.dumps(plan, indent=2) + '\n')
print('Finite proposal applied:', plan['measured'], '; sole decision lines:', plan['decision_lines'])
