"""Publish the capacity slice and preserve original watched captures, once."""
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
BASE = 'e7674382295936a1d6d3dbd34272d9c6803a269d'

def original(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)

def read(path):
    return (ROOT / path).read_bytes()

def write(path, value):
    (ROOT / path).write_text(value)

def load(path):
    return json.loads(read(path))

plan = load(PREFIX + 'plan.json')
registry = 'doctrine/readme_stability/routes.jsonl'
# Keep every unrelated physical row byte-identical. Only two governed rows move.
replacement = {'change_history': plan['new_change'], 'decisions': plan['new_decisions']}
lines = []
for line in original(registry).splitlines(keepends=True):
    row = json.loads(line)
    lines.append((json.dumps(replacement[row['id']], sort_keys=True, separators=(',', ':')) + '\n').encode()
                 if row.get('id') in replacement else line)
(ROOT / registry).write_bytes(b''.join(lines))
index = 'docs/decisions/INDEX.md'
initial_index = read(PREFIX + 'index-initial.md')
new_row = initial_index[len(original(index)):]
assert new_row.count(b'\n') == 1
(ROOT / index).write_bytes(original(index).replace(b'## How to add a record', new_row + b'## How to add a record', 1))

subject = LEAF + ' - admit one residual-repair history rollover'
next_action = ('Select SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1: '
               'trace actual typed/raw lowering producers and establish bounded residual continuation authority '
               'before production edits. Repair .1.1.1.2, integrated mapping .1.1.2 and independent canonical '
               '.0.3.2 remain open; keep the rejected overlap candidate retired.')
old_next = ('From clean committed HEAD activate the finite change-history capacity prerequisite .3.1.1.1.0 before further writes; '
            'then select explicit producer-bound nested/raw residual authority .1.1.1.1 and repair .1.1.1.2. '
            'Integrated mapping .1.1.2 and independent canonical .0.3.2 remain open. '
            'Do not revive the rejected overlap-only candidate or relax family/callback/literal oracles.')
for path in ('docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md'):
    content = (ROOT / path).read_text()
    assert old_next in content, 'exact old frontier: ' + path
    write(path, content.replace(old_next, next_action))
task = 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
content = (ROOT / task).read_text()
start = content.index('- ID: `' + LEAF + '`')
end = content.index('\n- ID:', start + 1)
node = content[start:end].replace('Status: `in_progress`', 'Status: `done`')
node += ('\n  Verification: Actual rollover RED/GREEN; exact original suffix/range/hash/manifest and all prior '
         'archives/decisions reconstruct. Independent evidence corruptions and actual production '
         'threshold/accepted-state denials pass; exact measured five-scalar registry admission only. '
         'Initial publisher normalized unrelated JSON rows and appended the ADR outside the index table; '
         'exact initial producer/snapshots/review are retained. Final publication restores every unrelated '
         'row byte and inserts the single ADR row before the index instructions; strengthened review gates both. '
         'Normal doctrines and exact staged canonical receipt/hooks govern landing. Public book history '
         'teaching was reviewed and remains accurate; no parser/book behavior changes.\n'
         '  Commit: `' + subject + '` (Git owns identity).\n')
content = content[:start] + node + content[end:]
parent = '- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1`\n  Status: `pending`'
assert parent in content
content = content.replace(parent, parent.replace('`pending`', '`active`'), 1)
needle = '| 43.4.2.0.3.1.1.0 |'
pos = content.index('\n', content.index(needle)) + 1
rows = (f'| 43.4.2.0.3.1.1.1.0 | `{LEAF}` | `done` | One exact finite archive/manifest/decision admission; canonical receipt gates landing. |\n'
        '| 43.4.2.0.3.1.1.1.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1` | `pending` | Next: select exact typed/raw producer-bound residual authority. |\n'
        '| 43.4.2.0.3.1.1.1.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2` | `pending` | After selection: repair residual authority and full guarded Phase0. |\n')
write(task, content[:pos] + rows + content[pos:])
write('MEMORY.md', '# MEMORY\n\n'
      f'- activation_commit: `{BASE}` — clean capacity activation.\n'
      f'- latest_completed_leaf: `{subject}`.\n'
      f'- active_work_unit: `{LEAF}` (done) — finite capacity prerequisite; production unchanged.\n'
      f'- next_action: {next_action}\n'
      '- in_flight_uncommitted: none; exact admitted history, proof and continuity committed.\n'
      '- blockers: none for producer diagnosis. Wrapper startup .7 and subsequent repair/admission remain open; recovery/purge prohibited.\n'
      '- task_owner: `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`; use its precise node and frontier.\n'
      '- standing_contracts: `AGENTS.md`, `COMMIT.md`, `KNOWLEDGE_MAP.md`; all other repositories and submodules read-only.\n')
live = (ROOT / 'LIVE_ACHIEVEMENT_STATUS.md').read_text()
live = re.sub(r'(?<=## Current Activity\n\n).*?(?=\n\n## Latest Completed Slice)',
              'Full PNT: finite capacity prerequisite complete; producer-bound residual selection next.', live, flags=re.S)
live = re.sub(r'(?<=## Latest Completed Slice\n\n).*?(?=\n\n## Next Action)',
              f'`{LEAF}` — One exact clean-record rollover under ADR0129. Five finite scalars admit '
              'one archive/manifest row and indexed decision; prior history/decisions/other controls remain exact. '
              'Actual reconstruction and authority RED controls precede exact canonical admission. Production remains restored6fe.', live, flags=re.S)
live = live.replace(old_next, next_action)
live = live.replace('## Recent Completions\n\n', f'## Recent Completions\n\n- `{LEAF}` — finite change-history capacity; exact reconstruction and actual authority controls.\n', 1)
recent_start = live.index('## Recent Completions\n\n')
history_start = live.index('\n## History', recent_start)
recent = live[recent_start:history_start].splitlines()
recent_rows = [line for line in recent if line.startswith('- ')]
write('LIVE_ACHIEVEMENT_STATUS.md', live[:recent_start] + '## Recent Completions\n\n' + '\n'.join(recent_rows[:16]) + '\n' + live[history_start:])
notes = (ROOT / 'DEVELOPMENT_NOTES.md').read_text()
pos = re.search(r'^## ', notes, re.M).start()
record = ('## 2026-10-08 — Finite producer-residual history prerequisite\n\n'
          'ADR0129 follows the autonomous-PNT maintenance precedent of ADR0128 without asserting a new director grant. '
          'One exact clean suffix and actual manifest bytes supply the exhausted change-history archive slot. '
          'The single indexed decision receives only measured file/line capacity. All unrelated registry row bytes, '
          'prior archive rows/files and accepted decision bytes remain exact; actual accepted-state denials exercise '
          'the repaired routing functions. Parser behavior and public teaching do not change. '
          f'Exact sources, initial formatting correction and retained channels: `{PREFIX}plan.json` and `verification.json`.\n\n')
write('DEVELOPMENT_NOTES.md', notes[:pos] + record + notes[pos:])

# Preserve earlier captures at their existing owning boundary, without refreshing hashes.
changed = set(subprocess.check_output(['git', 'diff', '--name-only'], cwd=ROOT).decode().splitlines())
frozen = []
for path in sorted((ROOT / 'docs/claims').glob('*.json')):
    record = json.loads(path.read_bytes())
    changed_claim = False
    for claim in record['claims']:
        leg = claim['durability']
        if leg.get('mode') == 'live' and any(item['path'] in changed for item in leg['inputs']):
            for item in leg['inputs']:
                assert hashlib.sha256(original(item['path'])).hexdigest() == item['sha256'], 'actual original claim input'
            leg['mode'] = 'historical'
            leg['revision'] = BASE
            changed_claim = True
    if changed_claim:
        write(path.relative_to(ROOT).as_posix(), json.dumps(record, indent=2) + '\n')
        frozen.append(path.relative_to(ROOT).as_posix())
write(PREFIX + 'publication.json', json.dumps({'base': BASE, 'frozen_mode_revision_only': frozen,
      'public_book': 'development/documentation-workflow.md history contract reviewed; unchanged behavior requires no book edit',
      'initial_formatting_correction': 'exact initial sources/snapshots retained; unrelated registry bytes restored and ADR moved into index table'}, indent=2) + '\n')
write('git_message_brief.txt', subject + '\n\nAdmit one exact history rollover and its finite indexed decision under autonomous PNT.\nPreserve prior archive, decision and unrelated registry bytes; retain actual RED controls.\nExact staged canonical CI and normal hooks govern admission.\n')
print('Continuity published; prior live captures preserved mode/revision only.')
