"""One-shot publication of the verified dated maintenance observation."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.13-'
BASE = '60e8ef2ab571bab5d951e0d6f701daf1752df36e'
NEXT = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1'
freeze = json.loads((ROOT / (PREFIX + 'freeze.json')).read_bytes())
bindings = sum(entry['verified_bindings'] for entry in freeze['records'])
census = json.loads((ROOT / (PREFIX + 'artifact-review.json')).read_bytes())
verified = json.loads((ROOT / (PREFIX + 'actual-verification.json')).read_bytes())
assert verified['complete'] and all(control['rejected'] for control in verified['controls'])
assert census['removed_files'] == census['removed_bytes'] == 0
summary = ('Dated ' + census['at_utc'] + ' census retains ' + str(census['artifact_files']) +
    ' parent candidates/' + str(census['artifact_bytes']) + ' bytes; three Rust log/bin locations are '
    'observed separately. Fresh metadata and independent lstat agree; size/boundary fixtures and four '
    'actual-channel RED controls pass. Zero removals; proof data and caches remain retained. The capacity '
    'claim preserves all' + str(bindings) + ' original hashes at clean60e8ef2ab; the original legacy-mode preparation '
    'failure is retained. Public retention guidance is unchanged; focused checks and normal doctrines govern landing.')

path = ROOT / 'CHANGES.md'
text = path.read_text()
assert '## 2026-10-08 — REPO-HYGIENE.13' not in text
start = text.index('## ')
text = text[:start] + '## 2026-10-08 — REPO-HYGIENE.13 - retain due artifact review\n\n' + summary + '\n\n' + text[start:]
path.write_text(text)
path = ROOT / 'DEVELOPMENT_NOTES.md'
text = path.read_text(); start = text.index('## ')
path.write_text(text[:start] + '## 2026-10-08 — Due metadata review (REPO-HYGIENE.13)\n\n'
    'Validate the supplied census start and its ancestors before traversal as well as child entries. '
    'The dated review keeps all artifacts; age, size and a passing metadata check do not prove disposal '
    'safety. Current standalone controls cover symlink starts/ancestors, nested Git markers, mock submodules '
    'and outside-root starts. Earlier producers and snapshots stay immutable. Unqualified legacy '
    'durability records are not implicitly live; preserve the actual preparation failure before correcting '
    'the current selector. The existing public teaching and retained .11 example remain accurate.\n\n' + text[start:])
(ROOT / 'docs/ARTIFACT_CLEANUP.md').write_text('# Latest artifact cleanup\n\n' + census['at_utc'] +
    ' — REPO-HYGIENE.13: zero files removed after verified parent/Rust metadata census; retained proof '
    'inputs/logs/outputs/caches; excluded submodules/other repositories, symlinks, other volumes and managed '
    'runs. Exact dated rows, actual producers/channels and controls: docs/checkpoints/REPO-HYGIENE.13-artifact-review.json, actual.json and verification.json.\n')
(ROOT / 'MEMORY.md').write_text('# MEMORY\n\n'
    '- activation_commit: `' + BASE + '` — clean daily-review activation.\n'
    '- latest_completed_leaf: `REPO-HYGIENE.13 - retain due artifact review`.\n'
    '- active_work_unit: `REPO-HYGIENE.13` (done) — dated metadata review; zero removals.\n'
    '- next_action: Select ' + NEXT + ': trace actual typed/raw lowering producers and establish bounded '
    'residual continuation authority before production edits. Repair .1.1.1.2, integrated mapping .1.1.2 '
    'and independent canonical .0.3.2 remain open; keep the rejected overlap candidate retired.\n'
    '- in_flight_uncommitted: none; dated proof and continuity committed.\n'
    '- blockers: none for producer diagnosis. Wrapper startup .7 remains open; recovery/purge prohibited.\n'
    '- task_owner: `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`; completed maintenance: `docs/tasks/REPO-HYGIENE.md`.\n'
    '- standing_contracts: `AGENTS.md`, `COMMIT.md`, `KNOWLEDGE_MAP.md`; other repositories/submodules read-only.\n')
path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'
text = path.read_text()
recent = text.split('## Recent Completions\n\n', 1)[1].split('\n## History', 1)
rows = [line for line in recent[0].splitlines() if line.startswith('- ')][:15]
text = '# LIVE ACHIEVEMENT STATUS\n\n## Current Activity\n\nFull PNT: daily artifact review complete; producer-bound residual selection next.\n\n'
text += '## Latest Completed Slice\n\n`REPO-HYGIENE.13` — ' + summary + '\n\n'
text += '## Next Action\n\nSelect ' + NEXT + ': trace actual typed/raw lowering producers and establish bounded residual continuation authority before production edits.\n\n'
text += '## Recent Completions\n\n- `REPO-HYGIENE.13` — due retained census; zero removals; original capacity claim preserved.\n' + '\n'.join(rows) + '\n\n## History' + recent[1]
path.write_text(text)
path = ROOT / 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
text = path.read_text().replace('date: 2026-10-07', 'date: 2026-10-08')
position = text.index('reverify:')
text = text[:position] + 'evidence_update_2026_10_08: "REPO-HYGIENE.13 retains the dated October8 parent/Rust snapshot and complete actual producer channels. Fresh metadata, independent lstat and effective size/traversal/evidence controls pass. All artifacts remain retained; current start-path guards reject symlink ancestors, nested repositories, mock submodules and outside-root starts before traversal. Earlier snapshots are immutable; no concurrent adversarial filesystem guarantee is inferred."\n' + text[position:]
path.write_text(text)
path = ROOT / 'docs/tasks/REPO-HYGIENE.md'
text = path.read_text().replace('- Status: `active`', '- Status: `completed`', 1)
text = text.replace('  Status: `active`', '  Status: `completed`', 1)
start = text.index('- ID: `REPO-HYGIENE.13`')
end = text.index('## Current Frontier', start)
node = text[start:end].replace('Status: `active`', 'Status: `done`')
node += '  Verification: PASS; ' + summary + '\n'
node += '  Commit: `REPO-HYGIENE.13 - retain due artifact review` (Git owns identity).\n'
node += '  Handoff: Activate ' + NEXT + ' from clean committed HEAD.\n\n'
text = text[:start] + node + text[end:]
text = text.replace('| `REPO-HYGIENE.13` | `active` |', '| `REPO-HYGIENE.13` | `done` |')
marker = '| `2026-10-08` | `REPO-HYGIENE.12`'
position = text.index(marker)
text = text[:position] + '| `2026-10-08` | `REPO-HYGIENE.13` | Actual census/live lstat/source guards/boundary fixtures/claim preservation; memory/Knowledge/history/diff and normal doctrines | PASS — dated retained snapshot; zero removals. |\n' + text[position:]
text = text.replace('## Changelog\n', '## Changelog\n\n- 2026-10-08: `.13` completes the due retained metadata review and resumes private residual-producer diagnosis.\n', 1)
path.write_text(text)
path = ROOT / 'docs/TASK_TREE.md'
text = path.read_text()
old = 'Latest maintenance: REPO-HYGIENE.12 qualifies the dated Phase0 record. REPO-HYGIENE.11 remains the October7 zero-removal artifact census.'
assert old in text
text = text.replace(old, 'Latest maintenance: REPO-HYGIENE.13 retains the October8 due artifact census with zero removals; residual-producer diagnosis follows.')
old = '| `REPO-HYGIENE` | `completed: historical Phase0 qualification` | `Overall roadmap — repository maintenance` | .12 preserves the June12 observations as historical; .11 remains the latest daily census. Resume private replacement handoff after history-capacity check. |'
assert old in text
text = text.replace(old, '| `REPO-HYGIENE` | `completed: due retained artifact review` | `Overall roadmap — repository maintenance` | .13 retains the dated October8 artifact census; zero removals. Resume private residual-producer diagnosis. |')
path.write_text(text)
(ROOT / 'git_message_brief.txt').write_text('REPO-HYGIENE.13 - retain due artifact review\n\n'
    'Retain the dated scoped census with independent metadata and boundary controls.\n'
    'Preserve source-guarded actual channels and the prior capacity claim at its original revision.\n'
    'Record zero deletions, update bounded continuity and resume residual-producer diagnosis.\n')
print(summary)
