"""Write the intended clean handoff after selected proof, before canonical admission."""
import re
import common as c
import context
import review

SUBJECT = 'TYPE-REFERENCE-BOOK.1.2.10 - execute callable count and first'


def main():
    result = review.check(fresh=False)
    paths = ['MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','ROADMAP_V2.md','docs/TASK_TREE.md',
        'docs/tasks/TYPE-REFERENCE-BOOK.md',c.PREFIX+'README.md']
    before = {path:c.read(path) for path in paths}
    text = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    c.write_new('final-docs-inputs.json.gz',context.snapshot())
    proof = (f"{result['cases']} fixed cases/{result['accepted_red']} accepted RED/"
        f"{result['accepted_controls']} controls;{len(result['faults'])} restored source faults;"
        f"{result['direct_suites']}/{result['direct_tap']} TAP;history{result['historical_controls']};"
        f"book{result['book_inputs']}/{result['book_examples']} and actual heading RED")
    text['MEMORY.md'] = f'''# MEMORY

- activation_commit: `{c.BASE}` — clean count/first10 base; derive current identity from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.10` — subject `{SUBJECT}`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.10` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean committed Git, activate TYPE-REFERENCE-BOOK.1.2.11; reproduce registered sorted receiver pipelines and ordinary length continuation through public tools before repairing that bounded contract.
- in_flight_uncommitted: none — intended clean post-landing state; exact canonical receipt and normal hooks govern admission.
- proof: docs/checkpoints/type-array-count-first/publish.py;{proof}. Free harray guards and terminal/effect/kind/callable behavior are covered.
- custody: Whole accepted13 physical10857/logical3/images10860/full modes/actual clean readonly0 survives at real a8bd8620a. Producer/preflight/refused-loader and root-LF reconstruction corrections remain exact; corrected distinct proofs pass.
- continuity: ADR0137 admits only two actual required history members/manifests and its sole decision/index overhead. Every older immutable byte is preserved; no future reserve.
- owners:11 registered sorted/ordinary length ->12 deferred indexed writes ->14 deferred last ->inventory1/mapping2/layout3/legacy8/private metadata QA/references. Reducer95, Boolean35 and constructor94 remain separate.
- limits: No full pipeline/inventory or cross-backend admission. Other repositories/RGX/PGEN remain read-only black boxes. Project data stays on the repository volume. No push until PNT is exhausted.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; frozen proof/chunks remain retained.
'''
    live = text['LIVE_ACHIEVEMENT_STATUS.md']
    sections = {
        'Current Activity':'Count/first10 selected proof complete; exact canonical receipt and normal landing required. Next clean activation11, then12/14 before complete inventory.\n',
        'Latest Completed Slice':'TYPE-REFERENCE-BOOK.1.2.10 executes deferred count/first and fixes ordinary free harray guards. '+proof+'. Source-closed custody preserves whole accepted13 and original rejected producer epochs. Both required history rollovers reconstruct exactly, including mutable root separators; finite ADR0137 grants no future reserve. Three artifact denials and the actual validator fault restore. No complete inventory/backend admission.\n',
        'Next Action':'Finish required exact canonical/normal landing, then activate11 from clean Git. Continue12/14 before inventory1/mapping2/layout3. No push yet.\n',
    }
    for heading,value in sections.items():
        live,count = re.subn(r'(## '+heading+r'\n\n).*?(?=\n## )',lambda match:match[1]+value,live,count=1,flags=re.S)
        assert count == 1
    start,end = live.index('## Recent Completions\n'),live.index('\n## History\n')
    rows = [line for line in live[start:end].splitlines() if line.startswith('- ')]
    rows.insert(0,'- `TYPE-REFERENCE-BOOK.1.2.10` —'+proof+'; finite history0137;11 next.')
    text['LIVE_ACHIEVEMENT_STATUS.md'] = live[:start]+'## Recent Completions\n\n'+'\n'.join(rows[:16])+'\n'+live[end:]
    lines = text['ROADMAP_V2.md'].splitlines()
    lines[2] = 'October21 current PNT boundary: TYPE-REFERENCE-BOOK.1.2.10 executes callable count/first and guards free harray inputs: '+proof+'. Whole accepted13 custody survives at real a8bd8620a; finite history0137 preserves all prior bytes. Exact canonical receipt/normal hooks govern admission. Next11/12/14 before inventory; no complete pipeline/reference admission.'
    lines[4] = lines[4].replace('Continue active10 and the owned11/12/14 repairs','After10 landing, continue the owned11/12/14 repairs')
    text['ROADMAP_V2.md'] = '\n'.join(lines)+'\n'
    lines = text['docs/TASK_TREE.md'].splitlines()
    for index,line in enumerate(lines):
        if line.startswith('| `TYPE-REFERENCE-BOOK` |'):
            lines[index] = '| `TYPE-REFERENCE-BOOK` | `active` / next .1.2.11 | `.spec documentation / per-type reference` | Count/first10:'+proof+'; finite history0137. Exact canonical admission required. Next11/12/14 before inventory1/mapping2/layout3/legacy8/private QA. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |'
    text['docs/TASK_TREE.md'] = '\n'.join(lines)+'\n'
    tree = text['docs/tasks/TYPE-REFERENCE-BOOK.md']
    tree = tree.replace('- Status: `active` / deferred count/first .1.2.10; before enumeration',
        '- Status: `active` / next registered pipeline .1.2.11; before enumeration',1)
    start,end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.10`'),tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.11`')
    leaf = tree[start:end].replace('Status: `active` / activationa8bd8620a','Status: `done` / selected proof; exact canonical admission required',1)
    leaf = leaf.replace('- [ ] **','- [x] **')
    leaf += '  Verified:'+proof+'. Eight faults cover dispatch, arity, terminal effects, selection and both emitted kind guards. Permanent fixture is exact; full book/Knowledge follow current behavior.\n'
    leaf += '  Documentation defect fixed: two first-selection result rows called every result scalar. The nested/callable fixed cases and worked selection example demonstrate stored values; both rows now say stored value. Distinct final doc2 proof renders all89 inputs and executes all five bodies.\n'
    leaf += '  Corrections closed: duplicate-key plan/warning; shared fault marker; ordinary-only unused-interpreter loader; known root-LF reconstruction; rejected fact-budget proposal; reviewer keyword syntax; one stale AST emitted-source golden. Thirteen original suites pass; the sole AST source expectation is repaired and all23 AST groups independently pass. Production identities remain unchanged. Original sources and observations survive; distinct controls pass. First interrupted change apply channels were not retained; exact published state and later no-op/check channels reconstruct the real source without archive edits.\n'
    leaf += '  Custody/claim: docs/checkpoints/type-array-count-first/publish.py; full prior13 and all supplied epochs recover. ADR0137 is solely the measured commit-continuity prerequisite. Commit subject: `'+SUBJECT+'`. Next11 only after clean canonical/normal landing.\n\n'
    tree = tree[:start]+leaf+tree[end:]
    tree = tree.replace('| `TYPE-REFERENCE-BOOK.1.2.10` | `active` | Fresh accepted13 four-case RED retained; define contract before dispatch repair. |',
        '| `TYPE-REFERENCE-BOOK.1.2.10` | `done` |232/107 RED/eight faults; direct consumers/book and finite history0137; canonical admission mandatory. |',1)
    old = 'No director input required. Kind13 is accepted at a8bd8620a after canonical/normal hooks. Active10 owns count/first; then11/12 before inventory1. No dirty pivot.'
    assert old in tree
    tree = tree.replace(old,'No director input required. Count/first10 selected proof is complete; exact canonical/normal landing is mandatory. Activate11 only from clean Git, then12/14 before inventory1. No dirty pivot.',1)
    tree = tree.replace('## Verification Log\n','## Verification Log\n\n- `2026-10-21` — `.1.2.10`:'+proof+'; whole accepted13 custody; exact finite history0137 and artifact controls; canonical admission mandatory.\n',1)
    tree = tree.replace('## Commit Log\n','## Commit Log\n\nCount/first10 subject: `'+SUBJECT+'`; derive its accepted identity from Git.\n',1)
    text['docs/tasks/TYPE-REFERENCE-BOOK.md'] = tree
    text[c.PREFIX+'README.md'] = '''# Callable count and first — bounded Perl repair

Owner: TYPE-REFERENCE-BOOK.1.2.10. Clean activation: a8bd8620a4e545b3e472561bfea90c656ab69923.
Readonly current review: `bash tools/run_python_project_data.sh docs/checkpoints/type-array-count-first/publish.py`.
Exact staged canonical receipt and normal hooks govern landing; Git owns admission identity.

'''+proof+'''. Ordinary/deferred free/receiver values, arity, terminal/effect rules,
nonarrays, scalar/container/callable kinds, lexical helper precedence and independent
length/index/copy controls are covered. The permanent fixture equals the fixed plan.
Last14, registered pipeline11, deferred indexed writes12, reducer95, full inventory
and other backends remain separate.

prior.json.gz retains whole accepted13 claim/publication,10857 physical inputs,
three logical aliases/10860 independently Git-verified full-mode images and actual
clean readonly0. Four fresh public baseline cases precede tracked changes. Every
supplied epoch retains changed plain sources whole and immutable evidence identities;
unchanged sources recover at the real accepted Git. Three logical aliases derive
from accepted chunks. Other repositories/Gitlinks remain read-only black boxes;
all project data stays on the repository volume.

Rejected producer epochs remain explicit: duplicate-key plan and Python warning,
shared fault marker, ordinary-only routes not loading the deferred interpreter,
the known trimmed root-LF separator, reviewer syntax and a fact-budget preflight. None changes the
product contract or counts as a successful original proof. The original direct run
passes thirteen suites but rejects one stale AST emitted-source golden. Its sole
literal correction passes all23 AST groups independently; production stays exact.
No successful original14-suite run is claimed. Six original faults
and two distinct ordinary-only repeats provide the final eight controls. The
interrupted seventh original run has its supplied mutant but not retained raw
observer channels; the corrected repeat retains raw output before assertions.
The first change rollover's apply channels were likewise not retained before its
review assertion; exact published state, real Git and actual later no-op/check
channels prove recovery. Original sources and failed assertions stay recoverable.

Both required rollovers preserve every old immutable byte, source range/blob/digest
and manifest row. Mutable root separators recover from clean Git. Actual old-cap
production refusals cover all six member/manifest limits; finite ADR0137 admits
only two measured members/manifests and its sole decision/index overhead. No future
reserve or unrelated/root/per-file/aggregate limit changes. The historical65,536-byte
task capture guard is not policy: actual task_evidence uses1MiB, with no TYPE override.
Its actual guard RED and collection/metadata GREEN remain retained.

Mutation/capture actors are one-shot historical producers; do not rerun them on a
changed tree. publish.py/review.py/custody.py are readonly. Three missing/byte/mode
artifact declarations reject; the actual return-only validator admits them, then
exact restoration rejects all three. Canonical admission remains mandatory.
'''
    for path,value in text.items():
        c.source(path).write_text(value)
        c.source(path).chmod(before[path]['mode'])
    c.write_new('final-docs.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
        result=result,scope='Selected proof complete; intended clean handoff. Exact staged canonical receipt and normal hooks remain required before landing. No history/card/book input is rewritten here.'))
    print('Continuity aligned; exact canonical admission remains mandatory')


if __name__ == '__main__':
    main()
