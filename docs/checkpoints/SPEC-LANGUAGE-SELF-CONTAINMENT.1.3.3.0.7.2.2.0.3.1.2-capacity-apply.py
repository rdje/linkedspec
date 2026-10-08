"""Publish the single planned governed rollover and exact indexed maintenance decision."""
from pathlib import Path
import base64
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
CURRENT = 'DEVELOPMENT_NOTES.md'
ADR = 'docs/decisions/0128-replacement-note-history-capacity.md'
plan = json.loads((ROOT / (PREFIX + 'capacity-plan.json')).read_bytes())
revision = plan['revision']

def original(path):
    return subprocess.check_output(['git', 'show', revision + ':' + path], cwd=ROOT)

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def compact(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

def channel(raw):
    return {'base64': base64.b64encode(raw).decode(), 'bytes': len(raw), 'sha256': sha(raw)}

assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == revision
for path in (REGISTRY, MANIFEST, CURRENT):
    assert (ROOT / path).read_bytes() == original(path), 'unmodified publication input: ' + path
assert not (ROOT / ADR).exists(), 'new decision path'
assert not (ROOT / plan['archive_record']['target_path']).exists(), 'new immutable target'
note = (ROOT / (PREFIX + 'proposed-note.md')).read_bytes() + b'\n'
assert sha(note) == plan['new_note']['sha256'], 'actual authored note identity'
raw = original(CURRENT)
start = raw.index(b'## ')
(ROOT / CURRENT).write_bytes(raw[:start] + note + raw[start:])
guarded = [REGISTRY, 'tools/roll_document_history.pl', 'tools/read_document_history.pl',
           PREFIX + 'capacity-plan.py', PREFIX + 'capacity-plan.json', PREFIX + 'proposed-note.md',
           *[row['path'] for row in plan['prior_archives']]]
initial_guard = {path: sha((ROOT / path).read_bytes()) for path in guarded}
commands = []
for option in ('--check', '--apply'):
    args = ['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', option]
    before = {path: sha((ROOT / path).read_bytes()) for path in guarded}
    before_mutable = {path: channel((ROOT / path).read_bytes()) for path in (CURRENT, MANIFEST)}
    process = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    after = {path: sha((ROOT / path).read_bytes()) for path in guarded}
    assert before == after == initial_guard, 'guarded producer and original input bytes'
    commands.append({'args': args, 'exit_code': process.returncode,
                     'stdout': channel(process.stdout), 'stderr': channel(process.stderr),
                     'input_hashes_before': before, 'input_hashes_after': after,
                     'mutable_before': before_mutable,
                     'mutable_after': {path: channel((ROOT / path).read_bytes()) for path in (CURRENT, MANIFEST)}})
    if option == '--check':
        assert process.returncode != 0 and b'document-history rollover required for engineering_notes:' in process.stderr, 'actual pressure RED'
    else:
        assert process.returncode == 0, 'actual governed rollover GREEN'
for path, expected in ((CURRENT, plan['retained_root']), (MANIFEST, plan['new_manifest'])):
    value = (ROOT / path).read_bytes()
    assert sha(value) == expected['sha256'] and len(value) == expected['bytes'] and value.count(b'\n') == expected['lines'], 'actual planned publication: ' + path
record = plan['archive_record']
assert sha((ROOT / record['target_path']).read_bytes()) == record['sha256'], 'actual immutable archive'

# Preserve every unrelated registry row's bytes; only the selected canonical row changes.
registry_lines = original(REGISTRY).splitlines(keepends=True)
changed = 0
for index, line in enumerate(registry_lines):
    route = json.loads(line)
    if route.get('id') != 'engineering_notes':
        continue
    assert route['limits'] == plan['old_limits'] and route['member_limits'] == plan['old_member_limits']
    route['limits'] = plan['new_limits']
    route['member_limits'] = plan['new_member_limits']
    registry_lines[index] = (compact(route) + '\n').encode()
    changed += 1
assert changed == 1
(ROOT / REGISTRY).write_bytes(b''.join(registry_lines))
tick = chr(96)
def marker(label, value):
    return '- ' + label + ': ' + tick + value + tick + '\n'
body = (
    '# ADR 0128: Finite engineering-note capacity before selected replacement repair\n\n'
    '- Date: 2026-10-08\n'
    '- Status: accepted engineering maintenance decision under ' + tick + LEAF + tick + '; exact canonical admission required\n'
    '- Tags: documentation, history, capacity, continuity, verification\n\n'
    '## Routing-limit authorization\n\n'
    + marker('Routed surface', 'engineering_notes')
    + marker('Previous routed limits', compact(plan['old_limits']))
    + marker('New routed limits', compact(plan['new_limits']))
    + '\n## Routing-contract authorization\n\n'
    + marker('Routed surface', 'engineering_notes')
    + marker('Previous routed contract', compact(plan['old_contract']))
    + marker('New routed contract', compact(plan['new_contract']))
    + '\n## Context\n\n'
    'The clean engineering-note root is 58,977 bytes. Its next complete maintenance record crosses the unchanged '
    '90% rollover boundary. The existing 44-file history and 43-line/26,021-byte manifest controls are full. '
    'The root already routes to the canonical owner; shortening unrelated records or rewriting, deleting or '
    'repacking accepted history cannot meet ADR0069. README_POLICY requires a new exact indexed decision '
    'rather than a threshold change inside an ordinary feature leaf.\n\n'
    'The current full-PNT instruction delegates routine engineering decisions and requires continued maintenance '
    'and per-leaf commits. This separately owned canonical infrastructure leaf makes the finite decision under '
    'that authority. Earlier finite director grants are not reused, and no new explicit director grant is asserted.\n\n'
    '## Decision\n\n'
    'Admit only files 44→45, manifest lines 43→44 and manifest bytes 26,021→26,633. '
    'Preserve every other control, surface, field and prior immutable byte. Stable responsibility remains '
    'LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069.\n\n'
    'The actual governed rollover retains clean ' + revision + ' lines 155–256, blob '
    + record['source_blob'] + ', as 102 lines/27,567 bytes under SHA-256 ' + record['sha256'] + '. '
    'The retained root is 157 lines/31,811 bytes; the resulting collection is 45 files/28,934 lines/3,225,109 bytes. '
    'The unchanged root, per-file and aggregate budgets fit. Independent reconstruction, actual threshold and '
    'authority denials, full retained command channels and exact staged canonical proof govern admission.\n\n'
    '## Consequences\n\n'
    'One archive member and one exact row are admitted. This does not grant unlimited PNT reserve or future '
    'threshold changes. Existing history stays queryable and immutable; parser behavior, public teaching, '
    'tests, dependencies, hooks and checker implementations stay unchanged. Private occurrence handoff '
    '.3.1.0 resumes from the clean admitted commit.\n\n'
    '## Links\n\n'
    '- Policy: README_POLICY.md; docs/decisions/0069-bounded-change-and-notes-history.md\n'
    '- Previous finite decision: docs/decisions/0127-legacy-diagnosis-note-capacity.md\n'
    '- Owner: docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md\n'
    '- Exact plan and actual channels: ' + PREFIX + 'capacity-plan.json and ' + PREFIX + 'capacity-actual.json\n'
)
(ROOT / ADR).write_text(body)
p = ROOT / 'docs/decisions/INDEX.md'
index = p.read_text()
assert '(0128-replacement-note-history-capacity.md)' not in index
entry = '| [0128](0128-replacement-note-history-capacity.md) | One finite engineering-note rollover before selected replacement repair | 2026-10-08 | accepted engineering maintenance; canonical admission required | history, capacity, verification |\n\n'
assert '\n## How to add a record\n' in index
p.write_text(index.replace('\n## How to add a record\n', '\n' + entry + '## How to add a record\n', 1))
result = {'complete': True, 'revision': revision, 'producer_sha256': sha(Path(__file__).read_bytes()),
          'plan_sha256': sha((ROOT / (PREFIX + 'capacity-plan.json')).read_bytes()),
          'commands': commands, 'new_record': record,
          'scope': 'Actual pressure RED and governed rollover GREEN; complete distinct stdout/stderr channels and exact guarded original producers/inputs. Three-scalar indexed maintenance decision; canonical admission still required.'}
(ROOT / (PREFIX + 'capacity-actual.json')).write_text(json.dumps(result, indent=2) + '\n')
print('Actual pressure RED, governed rollover GREEN and exact finite indexed decision retained; canonical admission pending.')
