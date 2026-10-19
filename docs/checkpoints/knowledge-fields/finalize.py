"""Finalize unbound live continuity after the exact metadata claim exists."""
import datetime
import json
from pathlib import Path
import common as c

claim_raw = (c.ROOT / c.CLAIM).read_bytes()
claim = json.loads(claim_raw)
assert claim['owner'] == c.OWNER and len(claim_raw) <= 131072
bindings = claim['claims'][0]['durability']['inputs']
count = len(bindings)
tree = 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md'
paths = [tree, 'MEMORY.md', 'docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md',
         'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md']
assert not set(paths) & {item['path'] for item in bindings}
assert not (c.ROOT / (c.HOME + 'continuity.json')).exists()
originals = {path: c.read(path) for path in paths}
values = {path: c.decode(item['base64']).decode() for path, item in originals.items()}
summary = (
    'Metadata .12 preserves evidence/reverify lists in authored order/multiplicity and keeps scalar '
    'presentation. Original full1487-source/1349-fact baseline accepts248 fields but omits897 entries; '
    'independent current source/code-span review restores all897 and10455 question rows. Original80 '
    'controls stay exact; corrected176 plan has38 projection REDs/138 controls then176 GREEN. Ten '
    'syntax-valid source faults retain all120 native controls and restore exact healthy state; '
    'three coherent map/report/graph forgeries reject and restore. Actual22596/22500 pressure RED '
    'precedes blank-only containment with identical actual mdBook main content and changed-heading '
    'control. Current fifteen routes, architecture/template/book and full89-input/four-control book '
    'pass. Knowledge8386908 bytes and map21249 lines fit unchanged budgets. Exact39-file/98579726-byte '
    'failed render output is archived, freshly byte/mode reproduced and removed with residue absent; '
    'first unsaved render channels remain explicitly unavailable. Whole711/full120239 .6 baseline '
    'and all inputs are preserved at real f7e8b292f by mode/revision only. '
    f'Current readonly publication binds{count} inputs/full{len(claim_raw)}. Exact staged canonical '
    'receipt and all normal hooks govern landing. TYPE-REFERENCE-BOOK.1 is next from clean Git. '
    'No full YAML/type-validator, runtime/DSL, allocator/selector/budget, lifecycle/recovery/purge or '
    'independent private/parent admission is inferred.'
)
live = values['LIVE_ACHIEVEMENT_STATUS.md']
old_summary = live.split('## Latest Completed Slice\n\n', 1)[1].split('\n\n## Next Action', 1)[0]
assert old_summary.startswith('Pipeline .6 opens fresh producer/input scopes')
for path in ('docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md'):
    assert old_summary in values[path]
    values[path] = values[path].replace(old_summary, summary)
values['docs/TASK_TREE.md'] = values['docs/TASK_TREE.md'].replace(
    '| `PERL-PRIVATE-FACTORY-CAPTURE` | `active` / metadata .12 next |',
    '| `PERL-PRIVATE-FACTORY-CAPTURE` | `active` / bounded frontier complete; original admissions open |')
value = values[tree]
value = value.replace('- Status: `active` / metadata .3.2.1.12',
                      '- Status: `active` / bounded frontier complete; original independent admissions open', 1)
start = value.index('- ID: `' + c.OWNER + '`')
end = value.index('\n## Current Frontier', start)
node = value[start:end]
assert 'Status: `active` / supported metadata projection' in node
node = node.replace('Status: `active` / supported metadata projection',
                    'Status: `done` / canonical boundary; exact staged receipt required for landing', 1)
node += ('  Result: ' + summary + '\n'
         '  Reverify: bash tools/run_python_project_data.sh ' + c.HOME + 'publish.py (readonly default). '
         'All one-shot captures/freezers/corrections remain retired; source faults run only in supplied '
         'fixtures, and semantic artifact controls have a separate explicit capture mode.\n'
         '  Verification: Complete current graph, original80/corrected176, ten effective source faults, '
         'three coherent artifact denials, actual render equivalence/control, full book89/four controls, '
         'unchanged public70/40 and pressure20/62/40 PASS. Exact staged canonical receipt and all10 '
         'normal doctrines are mandatory landing conditions; no push before the PNT boundary.\n'
         '  Commit: ' + c.OWNER + ' - preserve Knowledge list metadata; Git owns accepted identity.\n')
value = value[:start] + node + value[end:]
start = value.index('## Current Frontier\n')
end = value.index('\n## Handoff', start)
value = value[:start] + ('## Current Frontier\n\n'
    '| Order | Leaf | Status | Why next |\n| --- | --- | --- | --- |\n'
    '| 1 | `TYPE-REFERENCE-BOOK.1` | `pending` | From clean Git inventory actual type/operation contracts and book coverage; original private/mapping/admission owners stay open. |\n') + value[end:]
start = value.index('## Handoff\n')
end = value.index('\n## ', start+4)
value = value[:start] + '## Handoff\n\n' + summary + (' Preserve the complete current publication and actual readonly baseline before future bound writes. '
    'Activate TYPE-REFERENCE-BOOK.1 only after exact canonical/normal commit, brief0, explicit post checks and clean Git.\n') + value[end:]
value += ('\n## Acceptance Checklist — ' + c.OWNER + '\n\n'
    '- [x] Complete current/source-before populations and all intersecting live claims are preserved before bound writes; original observations and both input/assertion corrections remain exact.\n'
    '- [x] Original80/corrected176, all30 public rows, all897 entries/248 fields, every scalar and10455 question rows pass with complete producer/input/mode custody.\n'
    '- [x] Ten syntax-valid complete-plan source faults and three coherent artifact denials observe named REDs and exact healthy restoration.\n'
    '- [x] Actual pressure RED, blank-only containment, actual render equality/visible control and exact archived output recovery pass under unchanged policies.\n'
    '- [x] Current full supplied graph/book89/four controls, public70/40 and pressure20/62/40 pass. Exact staged canonical receipt plus normal hooks govern landing; broader owners remain open.\n')
values[tree] = value
live = live.replace(old_summary, summary, 1)
start = live.index('## Current Activity\n\n') + len('## Current Activity\n\n')
end = live.index('\n\n## Latest Completed Slice', start)
live = live[:start] + 'Metadata .12 implementation and source-bound proof are complete; TYPE-REFERENCE-BOOK.1 is next after canonical/normal clean landing.' + live[end:]
start = live.index('## Next Action\n\n') + len('## Next Action\n\n')
end = live.index('\n\n## Recent Completions', start)
live = live[:start] + (f'From clean Git activate TYPE-REFERENCE-BOOK.1. Preserve current{count}/full{len(claim_raw)} '
    f'and actual readonly baseline through {c.HOME}publish.py before bound edits. Inventory current '
    'public contracts/Toolbox examples and every relevant book section before choosing per-type '
    'coverage changes. Keep original output/mapping/private-parent admissions open; no dirty pivot or push.') + live[end:]
start = live.index('## Recent Completions\n\n') + len('## Recent Completions\n\n')
end = live.index('\n\n## History', start)
recent = [line for line in live[start:end].splitlines() if line.startswith('- `')]
recent.insert(0, f'- `{c.OWNER}` — lists897/248; original80/RED38/GREEN176; faults10/artifact3; current1487/1349/10455; knowledge8386908/map21249/book89/4; readonly{count}/{len(claim_raw)}; TYPE-REFERENCE-BOOK.1 next.')
live = live[:start] + '\n'.join(recent[:16]) + live[end:]
values['LIVE_ACHIEVEMENT_STATUS.md'] = live
entry = ('\n## 2026-10-19 — ' + c.OWNER + ' — Preserve supported Knowledge list metadata\n\n' + summary + '\n\n'
    'Actual raw source/header values and independent CommonMark decoding distinguish complete '
    'metadata from synchronized omission. Question rows link to complete reverify lists; separate '
    'code spans retain data without command execution. The original correct format and every failed '
    'instrument remain recoverable; a single blank separator change preserves actual rendered content '
    'under the unchanged cap. Complete focused evidence and readonly route: ' + c.HOME + 'publish.py. '
    'Claim: ' + c.CLAIM + '. Canonical tier; exact staged receipt and normal hooks govern landing.\n')
for path in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    index = values[path].index('\n## ')
    values[path] = values[path][:index] + entry + values[path][index:]
cleanup = json.loads((c.ROOT / (c.HOME + 'output-cleanup.json')).read_bytes())
values['MEMORY.md'] = f'''# MEMORY

- activation_commit: `{c.BASE}` — clean metadata .12 activation; derive current identity from Git.
- latest_completed_leaf: `{c.OWNER}` — subject `{c.OWNER} - preserve Knowledge list metadata`.
- active_work_unit: `{c.OWNER}` (done; canonical receipt and normal hooks govern landing).
- task_owner: `{tree}`; bounded frontier hands off to TYPE-REFERENCE-BOOK.1; original independent admissions remain open.
- next_action: From clean Git activate TYPE-REFERENCE-BOOK.1; preserve complete current{count}/full{len(claim_raw)} and actual readonly baseline through {c.HOME}publish.py before bound writes.
- in_flight_uncommitted: none; intended clean post-landing handoff. No required background result remains after landing.
- blockers: none requiring user input. Inventory actual contracts/Toolbox examples and relevant book coverage before type-reference changes; no unmeasured completeness claim.
- evidence: Original full1487/1349 accepts248 fields but omits897 entries. Independent current graph restores897/248/all10455 routes; original80 exact, correctedRED38/GREEN176/30 native, faults10 and coherent artifact3 restore exactly. Current knowledge8386908/map21249/book89/four controls/public70/40/pressure20/62/40 PASS.
- custody: Whole .6 claim711/full120239 and actual baseline precede mode/revision freeze at f7e8b292f. All original epochs, missing census/input correction,40-actual/32-named assertion failure and exact fixes stay immutable; no native observation is refreshed.
- format: Actual22596/22500 denial precedes blank-only containment; actual mdBook main bytes equal with changed-heading visible RED. First wrong-destination render retains39 files/98579726 bytes and disclosed unsaved channels; corrected full custody/fresh equivalence precede exact removal/residue.
- cleanup: Latest exact generated-output recovery{cleanup['cleanup_utc']};39 archived/freshly matched files removed. Prior full review remains REPO-HYGIENE.19. Preserve every cache and proof artifact.
- standing_limit: SESSION-STARTUP-READING.7 owns known wrapper/kernel gaps; no lifecycle/recovery/purge admission. Other repositories/submodules stay read-only black boxes; no dependency internal/build/pin changes.
- sequence: TYPE-REFERENCE-BOOK.1 next. Full PNT continues; no push yet. Output construction/composition, interval mapping, quoted-first repair and complete private/parent admissions remain separately owned.
'''
for path, text in values.items():
    (c.ROOT / path).write_text(text)
brief = (c.OWNER + ' - preserve Knowledge list metadata\n\n'
    'Project supported evidence/reverify lists in authored order with separate safe\n'
    'code spans and complete-list question pointers. Keep scalar presentation and\n'
    'existing header validation limits; metadata is never executed.\n\n'
    'Restore897 entries across248 accepted fields in the complete current graph.\n'
    'Retain original80 controls, corrected176 plan, ten effective source faults,\n'
    'three coherent artifact denials, full supplied Knowledge/book proof and every\n'
    'failed instrument. Compact only blank separators under unchanged limits,\n'
    'verify actual render equivalence and recover exact archived generated output.\n\n'
    'Preserve the full pipeline baseline by mode/revision only. Exact staged\n'
    'canonical CI and all normal doctrines govern landing; type-reference inventory\n'
    'follows the clean handoff. Broader runtime/private admissions remain open.\n')
(c.ROOT / 'git_message_brief.txt').write_text(brief)
report = dict(result='PASS', originals=originals, current={path: c.sha(text.encode()) for path, text in values.items()},
              claim_sha256=c.sha(claim_raw), input_count=count, claim_bytes=len(claim_raw),
              producer_sha256=c.sha(Path(__file__).read_bytes()),
              scope='Root continuity is deliberately unbound from its measured publication. '
                    'Whole before bytes are retained; counts derive from the actual bounded claim. '
                    'The report and preflight are excluded from publisher namespace. Staged docs '
                    'describe the intended clean post-landing state required by COMMIT.md.')
c.write_new(c.HOME + 'continuity.json', report)
print('Metadata continuity finalized:', count, 'inputs;', len(claim_raw), 'bytes;TYPE-REFERENCE-BOOK.1 next')
