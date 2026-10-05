"""Apply only the director-granted finite rollover prerequisite at its exact base."""
from pathlib import Path
import copy
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
ADR = 'docs/decisions/0127-legacy-diagnosis-note-capacity.md'
proposal = json.loads((ROOT/(PREFIX+'capacity-proposal.json')).read_bytes())
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == proposal['revision']
original = subprocess.check_output(['git', 'show', 'HEAD:'+REGISTRY], cwd=ROOT)
assert (ROOT/REGISTRY).read_bytes() == original
rows = original.decode().splitlines(keepends=True)
index = next(i for i, row in enumerate(rows) if json.loads(row).get('id') == 'engineering_notes')
old = json.loads(rows[index])
assert old['limits'] == proposal['old_limits'] and old['member_limits'] == proposal['old_member_limits']
new = copy.deepcopy(old)
new['limits'] = proposal['new_limits']
new['member_limits'] = proposal['new_member_limits']
canonical = lambda value: json.dumps(value, sort_keys=True, separators=(',', ':'))
def contract(row):
    keys = ('authority', 'control', 'lifecycle', 'member_limits', 'members', 'owner',
            'route_targets', 'state', 'verifier')
    return dict({key: row[key] for key in keys}, transition_owners=row['transition'].get('owners'))
assert not (ROOT/ADR).exists()
text = (ROOT/(PREFIX+'capacity-decision.md')).read_text()
for marker, value in (('Previous routed limits', old['limits']), ('New routed limits', new['limits']),
                      ('Previous routed contract', contract(old)), ('New routed contract', contract(new))):
    assert '- '+marker+': `'+canonical(value)+'`' in text, 'exact approved decision template'
(ROOT/ADR).write_text(text)
p = ROOT/'docs/decisions/INDEX.md'
index_text = p.read_text()
assert '(0127-' not in index_text
index_text = index_text.replace('## How to add a record', '| [0127](0127-legacy-diagnosis-note-capacity.md) | Finite engineering-note rollover capacity for original Legacy diagnosis | 2026-10-05 | accepted; explicit director grant | history, capacity, verification |\n\n## How to add a record')
p.write_text(index_text)
rows[index] = canonical(new)+'\n'
(ROOT/REGISTRY).write_text(''.join(rows))
p = ROOT/'DEVELOPMENT_NOTES.md'
raw = p.read_bytes()
assert raw == subprocess.check_output(['git', 'show', 'HEAD:DEVELOPMENT_NOTES.md'], cwd=ROOT)
start = re.search(rb'^## ', raw, re.M).start()
p.write_bytes(raw[:start]+(ROOT/(PREFIX+'proposed-note.md')).read_bytes()+b'\n'+raw[start:])
subprocess.run(['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--apply'], cwd=ROOT, check=True)
raw = p.read_bytes()
assert raw.endswith(b'\n\n'), 'governed final blank separator'
p.write_bytes(raw[:-1])
print('Applied exactly the Granted three-scalar prerequisite and governed clean suffix rollover')
