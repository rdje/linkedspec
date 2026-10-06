"""Prepare the measured, canonical-gated post-landing continuity state."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PARENTS = ['SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6',
           'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1']


def replace(pattern, replacement, text):
    result, count = re.subn(pattern, replacement, text, flags=re.M)
    assert count == 1, (pattern, count)
    return result


def node(text, owner, change):
    start = text.index('- ID: `' + owner + '`')
    end = text.index('\n- ID:', start + 1)
    return text[:start] + change(text[start:end]) + text[end:]


def main():
    evidence = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
    book = json.loads((ROOT / (PREFIX + 'book-verification.json')).read_bytes())
    freeze = json.loads((ROOT / (PREFIX + 'supplement-verification.json')).read_bytes())
    assert evidence['complete'] and book['complete'] and freeze['complete']
    assert len(evidence['controls']) == 320 and len(book['controls']) == 63 and len(freeze['controls']) == 5
    statement = 'Fresh immutable56c8f38 supplies4745 regular committed inputs/no overlays and26 guarded commands. All174 disjoint selected IDs retain436 events/origins and46 MethodExpr/CSV frames per seed with exact complete previous compiler/callback/origin channels. Seven representatives retain49 ordered nested pairs/42 off-diagonal pairs/seven fatal routes per seed. All29 unchanged suites pass1440 ordered groups;320 effective evidence RED. Original151 hashes freeze mode/revision only with five supplemental RED; book58/32/four chapters/63 RED. Exact staged canonical receipt and normal hooks gate .1.6/private .0.1 closeout; no production/spec/test/policy change.'
    next_action = 'Activate executable quoted/pattern membership .0.2 from the clean canonical committed boundary. Retrieve original quote/mapping counterexamples and exact private producer spans; diagnose/implement only a safely bounded membership slice preserving original arguments, literal receivers, real dependencies and family order. Selected replacement .0.3 and recurring executable repair acceptance .0.4 remain separate; retain other runtime/diagnostic defect owners.'
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
    text = path.read_text()
    def complete_leaf(block):
        assert '  Status: `active`' in block
        block = block.replace('  Status: `active`', '  Status: `done`', 1)
        block += '\n  Verified focused result: ' + statement
        block += '\n  Canonical landing condition: Exact staged canonical CI receipt and normal hooks are mandatory before this intended done state lands; required Phase0 belongs to that canonical execution, not a repeated focused capture claim.'
        block += '\n  Commit: `' + OWNER + ' - accept all producer source provenance` (derive identity from Git after landing).'
        block += '\n  Next: ' + next_action + '\n\n'
        for label, detail in [
            ('REPRODUCE / ISSUE', 'Original complete selected and corrected nested channels recur from immutable4745-file Git input without overlays.'),
            ('ROOT CAUSE (WHY + WHERE)', 'Actual producer coordinates and returned references preserve source authority; rejected earlier instruments and historical adjudications stay unchanged.'),
            ('FIX', 'Acceptance changes retained evidence/teaching/current pointers only; production/spec/standard-test bytes remain activation-exact.'),
            ('ADDRESSED (verified)', '174 selected IDs/436 origins per seed;49 representative nested pairs/seven fatal routes;320 effective exact-reason RED and complete earlier channel recurrence.'),
            ('NO REGRESSION', '29 unchanged suites reach1440 ordered groups with complete TAP/no nested failures. Exact canonical receipt, required Phase0 and normal hooks gate private parent landing.'),
            ('LOCKSTEP', 'Book58/32/four/63,151 original hashes/five supplemental RED, claim/Knowledge/task/index/roadmaps/live/resume/history align; membership/replacement/runtime owners remain.'),
        ]: block += '- [x] **' + label + '** — ' + detail + '\n'
        return block
    text = node(text, OWNER, complete_leaf)
    def complete_parent(block):
        assert '  Status: `active`' in block
        return block.replace('  Status: `active`', '  Status: `done`', 1) + '\n  Closeout: Immutable .1.6.1 original/representative recurrence plus exact staged canonical receipt and normal hooks gate this intended private done state. Quoted/comment membership, replacement and other runtime defects remain open.\n'
    for parent in PARENTS: text = node(text, parent, complete_parent)
    for ordinal, owner in [('43.4.2.0.1.6.1', OWNER), ('43.4.2.0.1.6', PARENTS[0]), ('43.4.2.0.1', PARENTS[1])]:
        pattern = r'(\| ' + re.escape(ordinal) + r' \| `' + re.escape(owner) + r'` \| )`(?:active|in_progress)`'
        text = replace(pattern, r'\1`done`', text)
    text += '\n- `2026-10-06`: .1.6.1 immutable4745/no-overlay recurrence174 IDs/436 origins,49 representative pairs/seven fatal routes/1440 groups/320 RED; exact canonical receipt gates private .1.6/.0.1 closeout. Executable membership .0.2 follows clean landing.\n'
    path.write_text(text)
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        path = ROOT / name
        row = '| Expressive `.spec` self-containment | `active: executable membership next` | ' + statement + ' | ' + next_action + ' |'
        path.write_text(replace(r'^\| Expressive `\.spec` self-containment \|.*$', lambda _: row, path.read_text()))
    path = ROOT / 'docs/TASK_TREE.md'
    row = '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: executable membership next` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | ' + statement + ' Next: ' + next_action + ' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |'
    path.write_text(replace(r'^\| `SPEC-LANGUAGE-SELF-CONTAINMENT` \|.*$', lambda _: row, path.read_text()))
    path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'
    text = path.read_text()
    for heading, value in [
        ('Current Activity', 'Full PNT: immutable all-producer provenance independently verified; exact canonical receipt/normal hooks gate private parent closeout. Executable quoted/pattern membership .0.2 is next; replacement and separately owned runtime defects remain open.'),
        ('Latest Completed Slice', '`' + OWNER + '` — ' + statement), ('Next Action', next_action),
    ]:
        pattern = r'(## ' + heading + r'\n\n).*?(?=\n## )'
        text, count = re.subn(pattern, lambda match: match[1] + value + '\n', text, count=1, flags=re.S)
        assert count == 1
    start = text.index('## Recent Completions\n\n') + len('## Recent Completions\n\n')
    end = text.index('\n## History', start)
    rows = ['- `' + OWNER + '` — immutable4745/no overlays,174 IDs/436 origins/1440 groups/320 RED; canonical private closeout.'] + text[start:end].strip().splitlines()
    path.write_text(text[:start] + '\n'.join(rows[:16]) + '\n' + text[end:])
    path = ROOT / 'MEMORY.md'
    text = path.read_text()
    fields = {
        'latest_completed_leaf': '`' + OWNER + ' - accept all producer source provenance`.',
        'active_work_unit': '`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2` (pending activation) — executable quoted/pattern membership.',
        'next_action': next_action,
        'in_flight_uncommitted': 'none after canonical .1.6.1 landing; immutable runtime/book/freeze/claim proof and exact staged canonical receipt/normal hooks enforce intended private parent closeout. Derive current commit from Git; activate .0.2 only from clean committed HEAD.',
    }
    for field, value in fields.items(): text = replace(r'^- ' + field + r': .*$', lambda _, field=field, value=value: '- ' + field + ': ' + value, text)
    path.write_text(text)
    for name, title, body in [
        ('CHANGES.md', OWNER + ' - accept all producer source provenance', statement + ' Next: executable membership .0.2 after exact canonical landing.'),
        ('DEVELOPMENT_NOTES.md', 'Immutable complete-producer source authority (.1.6.1)', 'Original literal oracles and corrected committed nested instrumentation recur without overlays. Selected174 IDs/436 origins per seed and representative seven-family49 nested pairs stay distinct; exact previous full channels and effective controls preserve authority without raw-text inference. ' + statement + ' Prior151 hashes/rejected instruments remain historical. See docs/knowledge/perl-all-producer-source-acceptance.md.'),
    ]:
        path = ROOT / name; text = path.read_text(); first = re.search(r'^## ', text, re.M); assert first
        path.write_text(text[:first.start()] + '## 2026-10-06 — ' + title + '\n\n' + body + '\n\n' + text[first.start():])
    print(statement)
    print('Prepared intended canonical handoff; exact receipt and normal hooks must pass before private done states land')


if __name__ == '__main__': main()
