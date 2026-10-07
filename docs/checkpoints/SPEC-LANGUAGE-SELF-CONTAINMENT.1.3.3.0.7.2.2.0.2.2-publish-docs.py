"""Prepare the reviewed membership handoff; exact staged canonical proof gates landing."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PARENT = OWNER.rsplit('.', 1)[0]
NEXT = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3'
SUBJECT = OWNER + ' - accept committed compiler membership'


def replace(pattern, replacement, text):
    result, count = re.subn(pattern, lambda match: replacement, text, flags=re.M)
    assert count == 1, (pattern, count)
    return result


def node(text, owner, change):
    start = text.index('- ID: `' + owner + '`')
    end = text.index('\n- ID:', start + 1)
    return text[:start] + change(text[start:end]) + text[end:]


def main():
    proof = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
    history = json.loads((ROOT / (PREFIX + 'freeze.json')).read_bytes())
    book = json.loads((ROOT / (PREFIX + 'book-verification.json')).read_bytes())
    assert proof['complete'] and history['complete'] and proof['overlays'] == []
    statement = (f"Immutable{proof['revision'][:9]} supplies{proof['regular_git_inputs']} regular inputs/no "
                 f"overlays and{proof['commands']} guarded commands. Compiler regression passes {proof['compiler_groups']} "
                 f"groups under seeds0/1/42; original{proof['public_cases']} public sources retain"
                 f"{proof['public_seed_observations']} complete channel observations and"
                 f"{proof['authored_value_pairs']} original source/seed value pairs "
                 f"({proof['authored_route_values']} native/fresh route checks). "
                 "unsupported_nested/raw_operand remain unassessed. Fifteen unchanged consumers pass"
                 f"{proof['direct_consumers']['groups']} groups/Phase0{proof['direct_consumers']['plans'][-1]}. "
                 "Original compiler38 RED recurs under all three seeds; " + str(len(proof['controls'])) +
                 " evidence/five historical/five publication controls reject. Original" +
                 str(history['bound_inputs']) + " historical hashes remain exact. Book render passes (" +
                 str(book['book_inputs']) + " inputs / " + str(book['exact_examples']) +
                 " examples). Exact staged canonical receipt and normal hooks gate membership .0.2 "
                 "closeout; production/Perl fixtures/CI/hooks/dependencies unchanged. The exact historical scanner-mock inverse and original auditor RED/source controls are retained in this leaf. Replacement, diagnostic "
                 "origin, comments and broader quote scope stay separate.")
    next_action = ('Activate ' + NEXT + ' from clean committed HEAD. Diagnose exact selected residual '
                   'replacement through original Toolbox/source-frame oracles; preserve quoted twins, '
                   'literal bytes, genuine raw spans and occurrence/family order. Recurring .0.4, '
                   'diagnostic origin .7.2.2.1 and source comments .7.3 remain separate.')
    path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
    text = path.read_text()
    def complete_leaf(block):
        assert '  Status: `in_progress`' in block
        block = block.replace('  Status: `in_progress`', '  Status: `done`', 1)
        block += '\n  Verified focused result: ' + statement
        block += '\n  Canonical landing condition: Exact staged canonical CI receipt and normal hooks are mandatory before this intended done state lands; no canonical measurement is inferred from the focused capture.'
        block += '\n  Commit: `' + SUBJECT + '` (derive identity from Git after landing).'
        block += '\n  Next: ' + next_action + '\n\n'
        for label, detail in [
            ('REPRODUCE / ISSUE', 'Original independently authored literal/argument/occurrence and public-source oracles recur without overlays; original38-group compiler RED retains all three seeds.'),
            ('ROOT CAUSE (WHY + WHERE)', 'Compiler selection uses actual source-bound producer origins; original literal arguments, receiver openers, order, dependencies and caller errors remain fixture authority.'),
            ('FIX', 'Acceptance preserves production/Perl tests and adds only the exact historical scanner-mock inverse; original historical source/hash authority remains exact.'),
            ('ADDRESSED (verified)', f"Complete compiler{proof['compiler_groups']} and original{proof['public_cases']} public sources recur under seeds0/1/42; all{proof['authored_value_pairs']} source/seed value pairs match on both routes ({proof['authored_route_values']} native/fresh checks); two no-oracle cases remain explicit."),
            ('NO REGRESSION', f"Fifteen unchanged suites reach{proof['direct_consumers']['groups']} ordered groups including complete Phase0{proof['direct_consumers']['plans'][-1]}; {len(proof['controls'])} evidence controls reject. Exact staged canonical receipt and normal hooks gate membership landing."),
            ('LOCKSTEP', f"Book{book['book_inputs']}/{book['exact_examples']} examples/{len(book['controls'])} RED; original{history['bound_inputs']} historical hashes/{len(history['controls'])} RED; claim/Knowledge/task/index/roadmaps/live/resume and bounded histories align. Later source repairs remain owned."),
        ]:
            block += '- [x] **' + label + '** — ' + detail + '\n'
        return block
    text = node(text, OWNER, complete_leaf)
    def close_parent(block):
        assert '  Status: `active`' in block
        block = block.replace('  Status: `active`', '  Status: `done`', 1)
        return block + '\n  Closeout: Independent committed recurrence ' + OWNER + ' and exact staged canonical receipt/normal hooks close only membership. Selected replacement .0.3, recurring .0.4, diagnostic origin and comments retain their owners.\n'
    text = node(text, PARENT, close_parent)
    text = replace(r'^\| 43\.4\.2\.0\.2\.2 \|.*$',
                   '| 43.4.2.0.2.2 | `' + OWNER + '` | `done` | Immutable membership/compiler/public/direct-consumer proof; exact canonical parent acceptance. |', text)
    text = text.replace('## Verification Log\n', '## Verification Log\n\nOctober7 `' + OWNER + '`: ' + statement + '\n', 1)
    text = text.replace('## Commit Log\n', '## Commit Log\n\n- `' + SUBJECT + '` — exact staged canonical receipt and normal hooks gate membership closure; Git owns identity.\n', 1)
    text = text.replace('## Changelog\n', '## Changelog\n\n- `2026-10-07`: .0.2.2 accepts immutable committed compiler membership; original source/fixture/evidence boundaries preserved. Precise replacement .0.3 follows clean landing.\n', 1)
    path.write_text(text)
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        path = ROOT / name
        path.write_text(replace(r'^\| Expressive `\.spec` self-containment \|.*$',
            '| Expressive `.spec` self-containment | `active: precise replacement next` | ' + statement + ' | ' + next_action + ' |', path.read_text()))
    path = ROOT / 'docs/TASK_TREE.md'
    path.write_text(replace(r'^\| `SPEC-LANGUAGE-SELF-CONTAINMENT` \|.*$',
        '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: precise replacement next` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | ' + statement + ' Next: ' + next_action + ' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |', path.read_text()))
    for name, title, content in (
        ('CHANGES.md', '2026-10-07 — Accept committed compiler source membership', statement),
        ('DEVELOPMENT_NOTES.md', '2026-10-07 — Immutable membership acceptance preserves original source authority',
         'Acceptance compares every original public channel against committed integration evidence, preserving source/AST/lowering/metadata/emitted/value/error and callback observation. It does not promote correct values to readiness acceptance. The hygiene leaf already froze the compiler claim; the initial live-boundary review assertion is retained and corrected by checking its exact prior boundary, never refreshing old hashes. ' + statement)):
        path = ROOT / name
        text = path.read_text()
        offset = text.index('\n## ')
        path.write_text(text[:offset] + '\n## ' + title + '\n\n' + content + '\n' + text[offset:])
    path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'
    text = path.read_text()
    text = re.sub(r'(## Current Activity\n\n).*?(\n## Latest Completed Slice)',
                  lambda m: m[1] + 'Full PNT: committed compiler membership accepted; exact selected residual replacement follows the clean canonical boundary.\n' + m[2], text, flags=re.S)
    text = re.sub(r'(## Latest Completed Slice\n\n).*?(\n## Next Action)',
                  lambda m: m[1] + '`' + OWNER + '` — ' + statement + '\n' + m[2], text, flags=re.S)
    text = re.sub(r'(## Next Action\n\n).*?(\n## Recent Completions)',
                  lambda m: m[1] + next_action + '\n' + m[2], text, flags=re.S)
    recent = text.split('## Recent Completions\n\n', 1)[1].split('\n## History', 1)[0]
    rows = [line for line in recent.splitlines() if line.startswith('- `')]
    rows.insert(0, '- `' + OWNER + f"` — immutable{proof['regular_git_inputs']}/no overlays; compiler{proof['compiler_groups']}/public{proof['public_seed_observations']}/{proof['direct_consumers']['groups']} groups; canonical membership closeout.")
    text = re.sub(r'(## Recent Completions\n\n).*?(\n## History)',
                  lambda m: m[1] + '\n'.join(rows[:16]) + '\n' + m[2], text, flags=re.S)
    path.write_text(text)
    path = ROOT / 'MEMORY.md'
    text = path.read_text()
    for field, value in {
        'latest_completed_leaf': '`' + OWNER + ' - accept committed compiler membership`.',
        'active_work_unit': '`' + OWNER + '` (done) — immutable original membership acceptance.',
        'next_action': next_action,
        'in_flight_uncommitted': 'None; intended clean canonical post-landing handoff. Membership proof/docs complete; no required background job remains.',
    }.items():
        text = replace(r'^- ' + field + r':.*$', '- ' + field + ': ' + value, text)
    path.write_text(text)
    (ROOT / 'git_message_brief.txt').write_text(SUBJECT + '\n\n' + statement + '\n\n' + next_action + '\n')
    print(statement)


if __name__ == '__main__':
    main()
