"""Align bounded current surfaces to the gated Flow family acceptance candidate."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
BASE = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1'
OWNER = BASE + '.3.3'
SUMMARY = ('Fresh Flow family .1.3.3 verifies4233 immutable inputs/no overlays, all16 contracts/'
           '147 origins/138 argument frames/48 unchanged compiler pairs under three seeds;'
           '16 suites837 groups plus authority3,31 evidence/19 book controls reject. '
           'Exact canonical receipt gates family acceptance; Legacy safe-slice diagnosis follows.')

def change(path, transform):
    target = ROOT / path
    before = target.read_text()
    after = transform(before)
    assert after != before, path
    target.write_text(after)

def memory(text):
    updates = {
        'latest_completed_leaf': '`' + OWNER + ' - accept Flow source family`.',
        'active_work_unit': '`' + OWNER + '` (done) — complete Flow source family; Legacy `.1.4` next.',
        'next_action': 'Activate Legacy `.1.4` from clean HEAD; diagnose the original large producer inventory through LinkedSpec tools and split safe owned families before implementation.',
        'in_flight_uncommitted': 'None after landing; exact staged canonical receipt required by this acceptance commit.'}
    for key, value in updates.items():
        text, count = re.subn(r'^- ' + key + r':.*$', '- ' + key + ': ' + value, text, count=1, flags=re.M)
        assert count == 1
    return text
change('MEMORY.md', memory)

def live(text):
    replacements = {
        'Current Activity': 'Full PNT: all sixteen Flow source producers have fresh independent whole-family acceptance, gated by exact staged canonical CI. Next Legacy .1.4 diagnoses and splits its large original inventory. Other producers/membership/comments/replacement/global audits remain owned.',
        'Latest Completed Slice': '`' + OWNER + '` — ' + SUMMARY + ' Ten fully guarded commands preserve complete prior Flow/MethodExpr channels. Complete58-input book renders19 examples/three chapters;51 prior hashes verify before historical freeze. No production or standard test changes.',
        'Next Action': 'Activate Legacy .1.4 from clean HEAD; recover original producer contracts, exact source authority and public compiler channels with LinkedSpec tools, then define safe coherent implementation children. Engineering notes58975 bytes remains below rollover58983; capacity work must be owned before a required rollover.'}
    for heading, body in replacements.items():
        text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda m: m.group(1) + body + '\n', text, count=1, flags=re.S)
        assert count == 1
    head, rest = text.split('## Recent Completions\n\n', 1)
    recent, history = rest.split('## History', 1)
    rows = ['- `' + OWNER + '` — immutable Flow acceptance;16 contracts/147 origins/138 frames/837 groups/31 RED controls.']
    rows += [row for row in recent.splitlines() if row.startswith('- ')]
    return head + '## Recent Completions\n\n' + '\n'.join(rows[:16]) + '\n\n## History' + history
change('LIVE_ACHIEVEMENT_STATUS.md', live)

def changes(text):
    record = ('## 2026-10-05 — Complete Flow source family acceptance (.1.3.3)\n\n'
              + SUMMARY + '\n\nFresh immutable committed producers retain all original event/argument references, '
              'scalar coordinates, marker-first traversal and exact complete prior callback/compiler channels. '
              'Ten guarded commands include selected source/frame/AST/order/trace/composition consumers and '
              'custom authority denials. Complete58-input book renders19 examples/three chapters; all51 prior '
              'claim hashes verify before historical freeze. Production/tests are unchanged; executable '
              'membership and global audits remain separate. Existing engineering mechanism notes remain '
              'current and unchanged.\n\n')
    pos = text.index('## ')
    return text[:pos] + record + text[pos:]
change('CHANGES.md', changes)

def tree(text):
    for suffix in ('.3', '.3.3'):
        pattern = '(\n- ID: `' + re.escape(BASE + suffix) + '`\n  Status: )`(?:active|pending)`'
        text, count = re.subn(pattern, r'\1`done`', text, count=1)
        assert count == 1
    marker = '\n- ID: `' + BASE + '.4`'
    assert text.count(marker) == 1
    block = ('\n  Final verification: PASS4233 immutable regular Git inputs/no overlays/ten guarded commands. '
             'All16 contracts retain147 full-source origins and actual returned/constructor/args identities; '
             'MethodExpr retains138 CSV/parser frames under three seeds. All48 complete Flow compiler pairs '
             'and three MethodExpr channels equal exact previous committed bytes. Sixteen selected suites '
             'pass837 ordered groups; separate three-group authority fixture recurs under all seeds. '
             '31 reason-specific evidence controls RED;58 book inputs/19 examples/three chapters/19 controls '
             'and51-hash prior historical freeze PASS. Production/spec/standard tests unchanged. '
             'Exact staged canonical receipt must match before this candidate lands or parent closes.\n'
             '  Commit: `' + OWNER + ' - accept Flow source family`.\n\n'
             '### `' + OWNER + '` Acceptance Checklist\n\n'
             '- [x] **REPRODUCE / ISSUE** — Fresh immutable all16-contract Toolbox and original argument authority recurrence; LinkedSpec::Get return_descriptor/dump_parser_source and call_spec_handler_subst retain full compiler channels.\n'
             '- [x] **ROOT CAUSE (WHY + WHERE)** — Original direct and recursive producers required match/block and verified argument occurrence bases; committed direct, MethodExpr and recursive children supply those mechanisms without equal-text lookup or lexical sort.\n'
             '- [x] **FIX** — Preserve committed production/test bytes and bind complete Git object/content/mode/membership, full channels, actual imported original oracles and producers; independently review scalar/value/traversal/reference and authority contracts.\n'
             '- [x] **ADDRESSED (verified)** — PASS147 origins/138 frames/three seeds/48 compiler pairs,837 selected groups and authority3;31 reason-specific evidence controls RED distinguish omitted origins, forged identities/scalars, lost inputs/commands/channels and failed authority.\n'
             '- [x] **NO REGRESSION** — Complete previous Flow and MethodExpr channels remain exact; all selected AST/order/source/pipeline/Basic/binding/composition consumers pass. Exact canonical receipt gates landing.\n'
             '- [x] **LOCKSTEP** — Complete58-input book19 examples/three chapters/19 controls and51-hash freeze pass. Knowledge/task/frontier/index/roadmaps/live/resume/change history/claim align; other producers and membership/global audit remain separately owned.\n')
    text = text.replace(marker, block + marker)
    rows = {
        '.3': ('done', 'All16 Flow source contracts independently accepted through exact canonical .1.3.3 landing.'),
        '.3.2': ('done', 'Original argument authority, private bridge and recursive case/default consumers verified.'),
        '.3.2.0': ('done', 'Original MethodExpr/CSV authority diagnosis verified; bridge and recursive consumers committed.')}
    for suffix, (status, note) in rows.items():
        pattern = r'^(\| [^|]+ \| `' + re.escape(BASE + suffix) + r'` \| )`[^`]+` \|.*$'
        text, count = re.subn(pattern, lambda m: m.group(1) + '`' + status + '` | ' + note + ' |', text, count=1, flags=re.M)
        assert count == 1
    rowmarker = '| 43.4.2.0.1.4 |'
    additions = ('| 43.4.2.0.1.3.2.0.1 | `' + BASE + '.3.2.0.1` | `done` | Private argument frames verified;138 original occurrences/RED10-GREEN15. |\n'
                 '| 43.4.2.0.1.3.2.1 | `' + BASE + '.3.2.1` | `done` | Recursive Flow verified;147 origins/RED6-GREEN7/1180 groups. |\n'
                 '| 43.4.2.0.1.3.3 | `' + OWNER + '` | `done` | Immutable4233/no overlays;16 contracts/837 groups; canonical receipt gates acceptance. |\n')
    assert text.count(rowmarker) == 1
    text = text.replace(rowmarker, additions + rowmarker)
    for heading, entry in (('## Verification Log', '- `2026-10-05` — `' + OWNER + '` — ' + SUMMARY),
                           ('## Commit Log', '- `' + OWNER + ' - accept Flow source family` — fresh immutable all16 recurrence; exact canonical receipt gates landing.')):
        assert text.count(heading + '\n') == 1
        text = text.replace(heading + '\n', heading + '\n\n' + entry + '\n', 1)
    return text
change('docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md', tree)

for path in ('docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md'):
    def roadmap(text):
        lines = text.splitlines(keepends=True)
        targets = [i for i, line in enumerate(lines) if ('Flow canonical acceptance next' in line or
                    ('Recursive Flow .1.3.2.1 verifies4197' in line))]
        assert len(targets) == 1, (path, targets)
        i = targets[0]
        if path == 'docs/TASK_TREE.md':
            lines[i] = '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: Legacy source diagnosis next` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | ' + SUMMARY + ' Other repairs remain owned. | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |\n'
        else:
            cells = lines[i].split('|')
            assert len(cells) == 6
            cells[2] = ' `active: Legacy source diagnosis next` '
            cells[3] = ' ' + SUMMARY + ' '
            cells[4] = ' .1.4 original Legacy inventory and safe family partition before implementation. Other producers/membership/comments/replacement and audits remain owned. '
            lines[i] = '|'.join(cells)
        return ''.join(lines)
    change(path, roadmap)

def knowledge(text):
    text = text.replace('status: all sixteen Flow producer source contracts verified; canonical family acceptance owned',
                        'status: all sixteen Flow source contracts independently accepted through exact canonical landing')
    text = text.replace('evidence: "Recursive', 'evidence: "Fresh .1.3.3 verifies4233-input/no-overlay recurrence,16 contracts/147 origins/138 frames/837 groups/48 pairs/31 controls plus58-input book19 examples/three chapters/19 controls; exact canonical receipt gates landing. Recursive', 1)
    text = text.replace('  - "After final recursive acceptance:', '  - "Current family: bash tools/run_python_project_data.sh docs/checkpoints/' + OWNER + '-review.py"\n  - "At frozen1d450522afb79aa87e579db148224ad6ed2c11e0 replay recursive .1.3.2.1-review.py; do not refresh its current-source boundary after later producer changes."\n  - "Original recursive acceptance:')
    text = text.replace('The existing statement-frame bridge handles `next_stmt`; argument authority is\nseparately owned by `.1.3.2.0` before any new bridge is implemented.',
                        'The existing statement-frame bridge handles `next_stmt`; original argument\nauthority was diagnosed under `.1.3.2.0`, and its private bridge is implemented\nunder `.1.3.2.0.1` before recursive Flow consumption.')
    return text + ('\nFresh immutable whole-family recurrence under `.1.3.3` uses4233 regular committed\n'
                   'Git inputs with no overlays. All sixteen contracts retain147 origins and138\n'
                   'MethodExpr argument frames across three seeds. Complete prior Flow compiler\n'
                   'and MethodExpr channels remain byte-identical;837 selected compatibility\n'
                   'groups and separate authority fixtures pass.31 reason-specific evidence\n'
                   'controls reject corruptions. Exact staged canonical receipt gates family\n'
                   'landing; executable membership and other producer families remain separate.\n')
change('docs/knowledge/perl-flow-recursive-source-provenance.md', knowledge)
print('Published bounded Flow acceptance candidate; canonical receipt still required')
