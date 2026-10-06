"""Align the recognition leaf's current documentation after its actual proof passes."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
REVISION = '34f687c09e197cf0798ed01c3c760e63a0203513'
B = chr(96)

def read(path):
    return (ROOT / path).read_text()

def write(path, text):
    (ROOT / path).write_text(text)

def replace_once(text, before, after):
    assert text.count(before) == 1, 'unique publication target: ' + before
    return text.replace(before, after, 1)

def section(text, title, value):
    pattern = r'(^## ' + re.escape(title) + r'\n\n).*?(?=^## |\Z)'
    assert len(re.findall(pattern, text, re.M | re.S)) == 1, 'one current section: ' + title
    return re.sub(pattern, lambda m: m.group(1) + value + '\n\n', text, count=1, flags=re.M | re.S)

runtime = json.loads(read(PREFIX + 'verification.json'))
book = json.loads(read(PREFIX + 'book-verification.json'))
freeze = json.loads(read(PREFIX + 'freeze.json'))
assert runtime['complete'] and book['complete']
assert runtime['revision'] == freeze['revision'] == REVISION
assert (runtime['regular_inputs'], runtime['source_origins'], runtime['fixture_groups'],
        len(runtime['controls']), book['rendered_examples'], len(book['controls']),
        freeze['bound_inputs']) == (4668, 42, 1671, 200, 29, 53, 122)
summary = ('Immutable34f687c09 supplies4668 regular inputs, one declared fixture replacement per epoch/'
           'one recognition-family owner delta after and ten guarded runtime commands. '
           'OriginalRED18 becomes GREEN191. Seven original contracts/22 cases preserve42 events/'
           '63 frames per seed and retain16 staged/progressive plus26 new recognition/observation '
           'origins, for42 total. Complete preceding staged/progressive and public callback/compiler '
           'channels remain exact under three seeds. Thirteen suites pass1671 groups including '
           'Phase01035;200 effective evidence controls RED. Actual-root recognition component '
           'PASS4668 guarded inputs/five retained byte deltas; separate filesystem/Git modes remain '
           'unchanged. Book58/29/four chapters/53 RED and122-hash mode/revision-only progressive '
           'freeze pass. No static policy/runtime/public event/carrier/admission change.')
next_action = ('Activate canonical dedicated-family acceptance .1.5.4 from clean committed HEAD. '
               'Replay all seven original producers through fresh immutable committed inputs without '
               'overlays; retain complete three-seed channels, constructor/callback/consumer and book '
               'proof, then exact staged canonical receipt and normal hooks before closing .1.5. '
               'All-producer composition, quoted/comment membership, precise replacement and separate '
               'runtime defects retain their owners.')
subject = LEAF + ' - retain recognition annotation statement origins'

card = '''---
id: perl-recognition-annotation-statement-origins
title: Recognition and observation retain private original statement origins
answers:
  - "how do recognition transaction statements retain their original authored source"
  - "does observe_recognition have a private whole-statement source origin"
  - "how are repeated recognition statements and malformed observation operands distinguished"
  - "do recognition source origins preserve token result and unevaluated callee fields"
  - "can copied foreign or transformed recognition callbacks borrow source coordinates"
  - "why does recognition source scanning retain a statement list snapshot"
  - "where is the original recognition producer RED and repaired proof"
date: 2026-10-06
status: recognition/observation original-repaired proof verified; canonical family acceptance remains separate
tags: [perl, actionir, recognition, observation, source-provenance, statement-frames]
evidence: "SUMMARY"
reverify:
  - "bash tools/run_python_project_data.sh PREFIXreview.py"
  - "bash tools/run_python_project_data.sh PREFIXbook.py --review"
---

RecognitionTransactionRules obtains canonical frames through its existing split
callback only during private recording. Its shared private input helper keeps the
original statement-list snapshot before trim and operand callbacks. Every physical
statement advances the frame index, including ignored quoted assignments. Each
selected checkpoint, attempt, commit, rollback or observation records the same
constructor event and argument objects when raw text still equals the original
source slice. Repeated equal statements retain independently authored intervals.

Token/result slots, unevaluated static callees and original malformed operand/arity
fields remain unchanged. A bare attempt operand gains no invented callee; missing
observation operands retain operand_kind=missing and argument_count=1, while extra
arguments retain argument_count=3. Existing policy sees and rejects invalid events.
The nested static call gains no duplicate generic call/assignment ownership.
Copied splitter arrays, foreign source and changed raw preserve event behavior
without invented coordinates. The recurring fixture covers actual constructor
references, exact callback effects/errors and independent real nested recorders.

Before uses committed34f687 plus the exact fixture replacement; after adds only the
recognition-family owner delta. The unchanged original case/probe/oracle and full
preceding staged/progressive channels remain retained. Probe identities are at
actual dispatcher return; the four Toolbox Get parsers are built with complete
substitution/descriptor/source channels without extra execution. The selected
consumers execute only their covered routes. Three seeds do not prove arbitrary
callback or host behavior; complete supplied Git supersets are not minimal IO.

The component gate requires actual tracked Git context. Its guarded parent input
snapshot retains five exact byte deltas and separate filesystem/Git modes; later
continuity edits do not refresh that snapshot. Historical progressive/mode-repair
claims preserve their original identities. [[project-root-evidence-filesystem-modes]]
explains the prior instrument correction. No project permissions change.

[[perl-staged-annotation-statement-origins]] and
[[perl-progressive-annotation-statement-origins]] preserve the earlier mechanisms.
Canonical family acceptance, all-producer composition, quoted/comment membership
and precise replacement remain separate. Existing token order, restoration,
boolean-kind, resource, marker-lifetime, mark-copy observation and wrapper-lifecycle
repairs remain owned; recovery/purge remain prohibited. Source origins add no
public event fields, policy, runtime, lowering, carrier, admission or dependency
change. All project data is repository-local; necessary OS/toolchain prerequisites
are read-only. RGX/PGEN remain black boxes and other repositories read-only.
'''.replace('SUMMARY', summary).replace('PREFIX', PREFIX)
write('docs/knowledge/perl-recognition-annotation-statement-origins.md', card)
for name in ('perl-staged-annotation-statement-origins', 'perl-progressive-annotation-statement-origins',
             'perl-dedicated-producer-source-diagnosis'):
    path = 'docs/knowledge/' + name + '.md'
    text = read(path)
    text = text.replace('.1.5.2-review.py', '.1.5.3-review.py')
    text = text.replace('.1.5.2-book.py', '.1.5.3-book.py')
    text = re.sub(r'^  - ".*\.1\.5\.2-component-review\.py"\n', '', text, flags=re.M)
    if name == 'perl-dedicated-producer-source-diagnosis':
        text = text.replace('staged/progressive verified; recognition remains owned',
                            'all three implementation families verified; canonical acceptance remains owned')
        text = text.replace('recognition remains separate.',
                            '[[perl-recognition-annotation-statement-origins]] retains both earlier repairs.')
    text += ('\nThe recognition repair [[perl-recognition-annotation-statement-origins]] retains the\n'
             'complete preceding channels after the shared fixture evolves. The commands above\n'
             'review that controlled comparison and current teaching; the original dated\n'
             'measurement remains historical rather than refreshed.\n')
    write(path, text)
path = 'docs/knowledge/project-root-evidence-filesystem-modes.md'
text = read(path)
text = replace_once(text, 'status: exact mode-instrument correction and healthy actual-root capture independently verified',
                    'status: historical mode correction hash-bound; current recognition input modes independently guarded')
text = replace_once(text, 'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.2-component-review.py"',
                    'reverify:\n  - "bash scripts/check_claim_verification.sh"\n  - "bash tools/run_python_project_data.sh ' + PREFIX + 'review.py"')
text = text.replace('The current component inputs retain five exact byte deltas',
                    'The original progressive component inputs retain five exact byte deltas')
text += ('\nAfter the recognition owner changes, the original progressive mode correction\n'
         'is reverified through its historical claim/input hashes at committed34f687;\n'
         'the current recognition comparison checks its own complete actual-root snapshot.\n'
         'The claim gate does not re-execute historical producers. Do not run the old\n'
         'current-source component comparison against later changed production bytes.\n')
write(path, text)

path = 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
text = read(path)
start = text.index('- ID: ' + B + LEAF + B)
end = text.index('\n- ID: ', start + 1)
node = text[start:end]
node = replace_once(node, '  Status: ' + B + 'in_progress' + B, '  Status: ' + B + 'done' + B)
node = re.sub(r'^  In-flight continuation:.*\n', '', node, flags=re.M)
node = node.replace('Broad consumer/Phase0 and final independent before/after review are still in flight; do not treat planned after counts as accepted.',
                    'Broad consumer/Phase0 and independent full comparison now pass; original producers/channels remain retained.')
node += ('  Verification: PASS; ' + summary + '\n'
         '  Historical reverify reconciliation: Preserve the prior mode-instrument correction as dated history; route its card through the122-hash frozen original claim and current component-input comparison rather than invoking an old current-source checker against changed recognition bytes.\n'
         '  Pre-landing continuation: If HEAD is34f687 and this verified candidate is dirty, finish focused publication checks and all normal hooks/commit before canonical .1.5.4. Runtime/component/book/freeze proofs are complete.\n'
         '  Commit: ' + B + subject + B + '.\n  Next: ' + next_action + '\n\n'
         '### ' + B + LEAF + B + ' Acceptance Checklist\n\n'
         '- [x] **REPRODUCE / ISSUE** — Actual191-group fixture observes exactly18 original recognition/nested RED; all preceding148 and other25 groups pass. Original seven-contract Toolbox/callback channels are complete.\n'
         '- [x] **ROOT CAUSE (WHY + WHERE)** — RecognitionTransactionRules loses canonical physical statement frames at its ordinary list splitter; five constructors have no private origin hook. Independent original scalar intervals distinguish repeated equal statements.\n'
         '- [x] **FIX** — Obtain frames only during recording, retain original list snapshot/index before callbacks and record unchanged raw through actual constructor objects. No original argument/regex/policy/runtime/lowering change.\n'
         '- [x] **ADDRESSED (verified)** — GREEN191,26 new recognition/observation plus16 retained staged/progressive origins per seed; actual constructors/callbacks/nesting/errors and200 effective evidence RED pass.\n'
         '- [x] **NO REGRESSION** — Thirteen direct/authority/generated/source/order consumers pass1671 groups including Phase01035; both syntax channels and complete preceding three-seed channels remain exact. Actual-root published recognition component gate passes4668 guarded inputs/five byte deltas.\n'
         '- [x] **LOCKSTEP** — Book58/29/four/53,122 original-hash mode/revision-only freeze, historical mode reverify/current source cards, derived Knowledge/task/index/roadmaps/live/resume and bounded histories agree. Canonical family/composition/membership/replacement and runtime defects retain owners.\n')
text = text[:start] + node + text[end:]
row = '| 43.4.2.0.1.5.3 | ' + B + LEAF + B + ' | ' + B + 'in_progress' + B + ' | Retain five recognition/observation producer origins with original operands and full prior channels. |'
text = replace_once(text, row, '| 43.4.2.0.1.5.3 | ' + B + LEAF + B + ' | ' + B + 'done' + B + ' | OriginalRED18/GREEN191;42 dedicated origins/1671 groups/200 RED; canonical acceptance next. |')
text = replace_once(text, '## Verification Log\n\n', '## Verification Log\n\nOctober6 ' + B + LEAF + B + ': ' + summary + '\n\n')
old_commit = B + 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.2 - retain progressive annotation statement origins' + B + ' — original/repaired progressive proof plus retained staged channels; normal focused hooks govern landing.'
text = replace_once(text, old_commit, old_commit.split(' — ')[0] + ' — committed34f687c09; all ten doctrines and first-parent pointer PASS.')
text = replace_once(text, '## Commit Log\n\n', '## Commit Log\n\n- ' + B + subject + B + ' — original/repaired recognition proof plus retained staged/progressive channels; normal focused hooks govern landing.\n')
text += '\n- ' + B + '2026-10-06' + B + ': .1.5.3 retains five recognition/observation origins; RED18/GREEN191/42 total/1671 groups/200 RED. Canonical .1.5.4 follows clean landing.\n'
write(path, text)

path = 'MEMORY.md'
text = read(path)
fields = {
    'latest_completed_leaf': B + subject + B + '.',
    'active_work_unit': B + LEAF.removesuffix('.3') + '.4' + B + ' (pending activation) — canonical dedicated-family acceptance.',
    'next_action': next_action,
    'in_flight_uncommitted': 'None; recognition and preserved staged/progressive channels, consumers/Phase0/component/book/freeze proof are complete; focused publication checks and normal hooks enforce this post-landing handoff.',
}
for key, value in fields.items():
    assert len(re.findall(r'^- ' + key + ':', text, re.M)) == 1
    text = re.sub(r'^- ' + key + r':.*$', '- ' + key + ': ' + value, text, count=1, flags=re.M)
write(path, text)
path = 'LIVE_ACHIEVEMENT_STATUS.md'
text = read(path)
text = section(text, 'Current Activity', 'Full PNT: all three dedicated annotation source-origin implementation families verified; canonical family acceptance next. Composition, executable membership/replacement and separately owned runtime defects remain open.')
text = section(text, 'Latest Completed Slice', B + LEAF + B + ' — ' + summary)
text = section(text, 'Next Action', next_action)
rows = re.search(r'^## Recent Completions\n\n(.*?)(?=^## )', text, re.M | re.S).group(1).strip().splitlines()
rows = ['- ' + B + LEAF + B + ' — recognitionRED18/GREEN191;42 origins/1671 groups/200 RED; complete earlier channels.'] + rows[:15]
text = section(text, 'Recent Completions', '\n'.join(rows))
write(path, text)
for path in ('ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md'):
    text = read(path)
    rows = [line for line in text.splitlines() if line.startswith('| Expressive ' + B + '.spec' + B + ' self-containment |') or line.startswith('| ' + B + 'SPEC-LANGUAGE-SELF-CONTAINMENT' + B + ' |')]
    assert len(rows) == 1, 'one current roadmap row'
    if path == 'docs/TASK_TREE.md':
        new = '| ' + B + 'SPEC-LANGUAGE-SELF-CONTAINMENT' + B + ' | ' + B + 'active: canonical dedicated acceptance next' + B + ' | ' + B + '.spec language evolution / expressive self-containment and alternate authoring profiles' + B + ' | ' + summary + ' Next: ' + next_action + ' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |'
    else:
        new = '| Expressive ' + B + '.spec' + B + ' self-containment | ' + B + 'active: canonical dedicated acceptance next' + B + ' | ' + summary + ' | ' + next_action + ' |'
    write(path, replace_once(text, rows[0], new))
for path, title, body in (
    ('CHANGES.md', '2026-10-06 — ' + subject, summary + ' Next: canonical dedicated-family acceptance .1.5.4 after clean landing.'),
    ('DEVELOPMENT_NOTES.md', '2026-10-06 — Recognition statement snapshots and unchanged policy (.1.5.3)',
     'The shared private frame input preserves the original list snapshot before trim/operand callbacks. Occurrence indexing includes ignored statements; hooks retain constructor objects and malformed token/callee/observation fields for unchanged validation. Copied/foreign/transformed data gains no invented origin; fatal/nested callbacks retain their channels. ' + summary + ' Historical mode repair is source-bound through its original frozen claim; later changed sources use the current component snapshot. See docs/knowledge/perl-recognition-annotation-statement-origins.md.'),
):
    text = read(path)
    at = re.search(r'^## ', text, re.M)
    assert at, 'line-anchored complete history record'
    write(path, text[:at.start()] + '## ' + title + '\n\n' + body + '\n\n' + text[at.start():])
print('Recognition Knowledge, book-independent continuity, task acceptance and histories aligned to actual proof')
