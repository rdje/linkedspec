"""Publish verified private membership with an intended clean handoff."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
Q = chr(96)
read = lambda suffix: json.loads((ROOT / (PREFIX + suffix)).read_bytes())
evidence, book, supplement = [read(suffix) for suffix in
    ('verification.json', 'book-verification.json', 'supplement-verification.json')]
assert all(value['complete'] for value in (evidence, book, supplement))
assert evidence['metrics'] == {'cases': 36, 'original_events_per_seed': 68,
    'selected_events_per_seed': 47, 'membership_groups': 41,
    'original_red_groups': 20, 'direct_consumer_groups': 321}
assert len(evidence['evidence_controls']) == 17 and len(book['controls']) == 68
assert supplement['bound_inputs'] == 141 and supplement['actual_producer_red_controls'] == 4
statement = ('Private SourceMembership selects47 of68 original syntactic events per seed across36 authored sources. '
    'Complete baseline20 RED groups become41 GREEN groups; eight unchanged consumers pass321 groups. '
    'Original event/argument/origin references, source, order, numeric slash/literal receiver authority and caller errors persist. '
    'Seventeen evidence controls/four actual bad producers/five supplemental controls reject; '
    '141 prior hashes freeze mode/revision only with five RED. Book58 inputs/35 examples/four chapters/68 RED. '
    'Initial setpgid warning and actual reviewer rejection retained; unchanged host remeasurement accepted. '
    'Compiler discovery, existing scanners/spec/tests/CI and public substitution remain unchanged.')
next_action = ('Activate compiler membership integration .0.2.1 from clean committed HEAD. '
    'Read original Toolbox quote/mapping records and EmitContext/Diagnostics consumers; connect actual source-bound selection '
    'without changing original arguments or family order. Reproduce public native/fresh improvements and retain '
    'exact replacement .0.3, comments .7.3 and other runtime/startup owners. Canonical .2.2 accepts membership afterward.')


def replace(pattern, value, text, flags=re.M):
    result, count = re.subn(pattern, value, text, flags=flags)
    assert count == 1, (pattern, count)
    return result


path = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
text = path.read_text()
start = text.index('- ID: ' + Q + OWNER + Q)
end = text.index('\n- ID:', start + 1)
block = text[start:end]
assert '  Status: ' + Q + 'in_progress' + Q in block
block = block.replace('  Status: ' + Q + 'in_progress' + Q, '  Status: ' + Q + 'done' + Q, 1)
block += '\n  Verified focused result: ' + statement
block += '\n  Commit: ' + Q + OWNER + ' - select private executable source occurrences' + Q + ' (derive identity from Git after landing).'
block += '\n  Next: ' + next_action + '\n\n'
for label, detail in [
    ('REPRODUCE / ISSUE', 'Actual unfiltered syntactic baseline has20 failed groups from complete original producer channels.'),
    ('ROOT CAUSE (WHY + WHERE)', 'Producer spans are syntactic; quote interiors need original reference-bound membership, while literal receiver openers remain eligible.'),
    ('FIX', 'New unused private selector reuses existing lexical contracts and retains original source, event/argument/origin objects and producer order.'),
    ('ADDRESSED (verified)', '36 authored sources/41 groups,47 selected of68 original events per seed; seventeen evidence RED/four actual producer RED; no compiler/public fix claimed.'),
    ('NO REGRESSION', 'Eight unchanged direct consumers reach321 ordered groups; complete original producer/private/public intake channels and source inputs recur under seeds0/1/42.'),
    ('LOCKSTEP', 'Book58/35/four/68; original141 hashes/five freeze RED and warning/rejection preserved; claim/Knowledge/task/index/roadmaps/live/resume/history agree.'),
]: block += '- [x] **' + label + '** — ' + detail + '\n'
text = text[:start] + block + text[end:]
text = replace(r'(\| 43\.4\.2\.0\.2\.0 \| ' + re.escape(Q + OWNER + Q) + r' \| )' + re.escape(Q + 'in_progress' + Q),
               lambda match: match[1] + Q + 'done' + Q, text)
text += '\n- ' + Q + '2026-10-06' + Q + ': .0.2.0 private selector47/68 events per seed; RED20/GREEN41,321 direct groups and four actual producer RED. Compiler integration .2.1 follows clean landing.\n'
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = ROOT / name
    row = '| Expressive ' + Q + '.spec' + Q + ' self-containment | ' + Q + 'active: compiler membership next' + Q + ' | ' + statement + ' | ' + next_action + ' |'
    path.write_text(replace(r'^\| Expressive ' + re.escape(Q + '.spec' + Q) + r' self-containment \|.*$', lambda _: row, path.read_text()))
path = ROOT / 'docs/TASK_TREE.md'
row = '| ' + Q + 'SPEC-LANGUAGE-SELF-CONTAINMENT' + Q + ' | ' + Q + 'active: compiler membership next' + Q + ' | ' + Q + '.spec language evolution / expressive self-containment and alternate authoring profiles' + Q + ' | ' + statement + ' Next: ' + next_action + ' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |'
path.write_text(replace(r'^\| ' + re.escape(Q + 'SPEC-LANGUAGE-SELF-CONTAINMENT' + Q) + r' \|.*$', lambda _: row, path.read_text()))
path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'
text = path.read_text()
for heading, value in [
    ('Current Activity', 'Full PNT: private executable source selector verified; compiler integration .2.1 next. Public quoted-source replacement, comments and other owned defects remain open.'),
    ('Latest Completed Slice', Q + OWNER + Q + ' — ' + statement), ('Next Action', next_action),
]:
    text = replace(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda match: match[1] + value + '\n', text, re.S)
start = text.index('## Recent Completions\n\n') + len('## Recent Completions\n\n')
end = text.index('\n## History', start)
rows = ['- ' + Q + OWNER + Q + ' — private47/68 events, RED20/GREEN41/321 groups; four actual producer RED; compiler integration next.'] + text[start:end].strip().splitlines()
path.write_text(text[:start] + '\n'.join(rows[:16]) + '\n' + text[end:])
path = ROOT / 'MEMORY.md'
text = path.read_text()
for field, value in {
    'latest_completed_leaf': Q + OWNER + ' - select private executable source occurrences' + Q + '.',
    'active_work_unit': Q + OWNER.removesuffix('.0') + '.1' + Q + ' (pending activation) — compiler source membership integration.',
    'next_action': next_action,
    'in_flight_uncommitted': 'none after focused .2.0 landing; private selector remains unused by compiler discovery. Original warning/rejection and approved host remeasurement are retained; startup .7 remains open, recovery/purge prohibited.',
}.items():
    text = replace(r'^- ' + field + r': .*$', lambda _, field=field, value=value: '- ' + field + ': ' + value, text)
path.write_text(text)
for name, title, body in [
    ('CHANGES.md', OWNER + ' - select private executable source occurrences', statement + ' Next: compiler integration .2.1.'),
    ('DEVELOPMENT_NOTES.md', 'Original source authority for private membership (.2.0)', 'Select only actual reference-bound scalar occurrences; literal receiver openers are executable and numeric slash calls retain their discriminator. No masked argument parsing or equal-raw pairing. ' + statement + ' See docs/knowledge/perl-executable-source-membership.md.'),
]:
    path = ROOT / name; text = path.read_text(); first = re.search(r'^## ', text, re.M); assert first
    path.write_text(text[:first.start()] + '## 2026-10-06 — ' + title + '\n\n' + body + '\n\n' + text[first.start():])
print(statement)
