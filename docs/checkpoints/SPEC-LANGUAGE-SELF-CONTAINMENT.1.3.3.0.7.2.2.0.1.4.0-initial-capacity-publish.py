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
text = f'''# ADR 0127: Finite engineering-note capacity for the original Legacy diagnosis

- Date: 2026-10-05
- Status: accepted under `{OWNER}`; explicit director Granted disposition
- Tags: documentation, history, capacity, continuity, verification

## Routing-limit authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{canonical(old['limits'])}`
- New routed limits: `{canonical(new['limits'])}`

## Routing-contract authorization

- Routed surface: `engineering_notes`
- Previous routed contract: `{canonical(contract(old))}`
- New routed contract: `{canonical(contract(new))}`

## Context

The verified original Legacy diagnosis adds one complete618-byte engineering note
to the clean58975-byte hot shard. The unchanged90% rollover boundary requires an
exact clean suffix archive. Existing43-file history and42-line/25410-byte manifest
controls are full. ADR0069 prohibits rewriting, deleting or repacking accepted
history; routing this record already uses its canonical engineering-note owner.
The exact retained proposal was presented to the director, who answered Granted.
ADR0122 excluded later runtime/PNT growth from its earlier conformance reserve.

## Decision

Admit exactly one additional archive member (43→44), one manifest row (42→43)
and the exact resulting manifest bytes (25410→26021). All other route fields,
root/per-segment/aggregate controls and other surfaces remain exact. Stable store
responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069.
This prerequisite is owned by the already-active Legacy diagnosis leaf to avoid
a dirty task-tree pivot. That leaf escalates to canonical infrastructure admission.

The governed rollover selects clean da3d34945d5067410b79f51782395f15b5184ff4
lines142–342:201 lines/27233 bytes, segment4964 with SHA-256
8783c6d63164ded0745e6fd2e9cd9a440d71e3d5b682635b1b5573e126507f0e.
The resulting root is145 lines/32360 bytes, within unchanged50% retention controls.
Independent reconstruction and the actual production threshold/authorization
functions must verify these predictions before acceptance.

## Consequences

Prior archive bytes and manifest records remain immutable. This finite allowance
has no reserve for unlimited PNT or authority for a later threshold increase.
An exact staged canonical CI receipt, normal hooks and strict claim identities
remain mandatory; no verification or push exception is granted. Parser behavior
and the separately owned quoted-boundary repair remain outside this admission.

## Links

- Store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0122-approved-conformance-evidence-capacity.md`
- Owner: `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`
- Exact proposal: `{PREFIX}capacity-proposal.json`
- Actual producers and controls: `{PREFIX}capacity-review.py`
'''
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
p.write_bytes(raw[:start]+(ROOT/(PREFIX+'proposed-note.md')).read_bytes()+raw[start:])
subprocess.run(['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--apply'], cwd=ROOT, check=True)
print('Applied exactly the Granted three-scalar prerequisite and governed clean suffix rollover')
