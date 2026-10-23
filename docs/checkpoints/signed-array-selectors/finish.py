"""Finalize the bounded intake continuity; never rerun after capture."""
import common as c

SUMMARY = ('32 exact sources/192 native observations plus Perl descriptor/Get/fresh; '
    'eight signed-oracle RED routes; Perl CLI protocol RED/five other GREEN; '
    'book91/two native-fresh examples/three actual source denials; '
    'identity3/scope2 bypass-restoration; Knowledge -1824 bytes; no signed admission.')
PATHS = ['CHANGES.md','DEVELOPMENT_NOTES.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.md','docs/TASK_TREE.md','ROADMAP.md']


def main():
    before = {path:c.read(path) for path in PATHS}
    c.write_new('final-continuity-before.json.gz',dict(before=before,
        producer=c.read(c.PREFIX+'finish.py')))
    changes = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    def prepend(path,record):
        text = changes[path]
        position = text.index('\n## ')
        changes[path] = text[:position]+'\n'+record+'\n'+text[position:]
    prepend('CHANGES.md','## 2026-10-23 — TYPE-REFERENCE-BOOK.1.2.17.0 — freeze signed-selector baseline\n\n'+SUMMARY+
        '\n\nWhole accepted hygiene21 publication/claim and actual clean readonly0/55 Git-verified images precede writes. '
        'Retain all runtime observations, complete source epochs, Rust executable/Lua adapter bytes, independent oracles and public examples. '
        'Rust unsigned conversion clamps negative reads to zero; callable Perl requires digit-only reads. '
        'Perl CLI ignores context-only handler errors; P1 repair17.8 is first after clean intake, then signed neutral contract17.1. '
        'The original wrong bare-key comparison and rejected +947-byte document proposal remain qualified without product RED credit. '
        'Four cards preserve every question; current book explains dated backend differences and the CLI caveat. '
        'Frozen authorities/runtime/gates stay unchanged. Focused frozen-write/read consumers, Knowledge/history/memory/whitespace and normal hooks govern landing. '
        'Read-only: docs/checkpoints/signed-array-selectors/publish.py.')
    prepend('DEVELOPMENT_NOTES.md','## 2026-10-23 — signed-index baseline and both Perl failure channels\n\n'
        'A successful CLI null can conceal a handler failure. bin/linkedspec already supplies runtime_ctx_ref but checks only $@ after invocation; '
        'twelve invalid writes set last_error while the command exits0/null. The existing protocol oracle distinguishes this on two cases; '
        'five other native commands reject. Repair17.8 must check both channels while preserving legitimate null/false/no-match results. '
        'Do not reinterpret earlier successful null captures after repair.\n\n'
        'Rust eval_expr IndexedVar and eval_access_value cast a negative number directly to usize, producing element0; '
        'the public retained binary calibration returns [-2,10,10,10,10]. A historical unit explicitly pins -1 to the first element. '
        'Signed child17.3 must deliberately replace that expectation while preserving unrelated read-coercion scope. '
        'Perl ordinary guarded reads and CodeblockRuntime digit-only branches differ. Bare-variable harray reads are separately governed array indexes, '
        'so the original provisional key target was wrong; immutable observations and their qualification stay distinct. '
        'The new authority must preserve frozen write-v1 bytes and explicitly govern tail-relative existing positions. '
        'No new cross-backend effect-order or nonnumeric read policy follows from this finite baseline. '
        'Canonical facts and complete source/producer packets are linked by the intake README.')
    changes['MEMORY.md'] = '''# MEMORY

- activation_commit: `92c98fb3de0f8392abde59043bd6f67ba0199452` — clean intake17.0 base; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.17.0` — dated signed-selector intake; focused proof/normal hooks govern landing.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.17.8`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean Git activate P1 Perl CLI runtime-error repair17.8; check context last_error as well as thrown errors, preserve null/false/no-match, add permanent distinguishing CLI proof and run exact canonical CI before commit. Then neutral signed contract17.1.
- in_flight_uncommitted: none; no background job. Intake is committed; no runtime/contract/checker changes or signed admission. Never rerun historical capture writers.
- proof: docs/checkpoints/signed-array-selectors/publish.py is read-only by default:32 exact sources/192 native observations plus Perl Get/fresh, source/artifact/oracle/book and actual input/scope controls. Original wrong-key target and rejected document proposal stay qualified. Hygiene21 remains live/unchanged; deferred-write12 is historical at1e6096435.
- steering: [-n]=[size-n] only when size-n>=0; -1 is last and -size is first. P1 CLI17.8 precedes signed17.1–7, then14/16/19/raw-regex21/policy20 and complete inventory.
- limits: Frozen v1 authorities stay exact; signed support remains unadmitted. Other repositories/submodules are read-only black boxes; all data stays on-volume. No push until PNT exhausted.
'''
    live = changes['LIVE_ACHIEVEMENT_STATUS.md']
    history = live.split('## History\n',1)[1]
    rows = live.split('## Recent Completions\n',1)[1].split('## History\n',1)[0].strip().splitlines()
    rows = ['- `TYPE-REFERENCE-BOOK.1.2.17.0` — '+SUMMARY]+rows[:15]
    changes['LIVE_ACHIEVEMENT_STATUS.md'] = ('# LIVE ACHIEVEMENT STATUS\n\n## Current Activity\n\n'
        'Signed-selector17 remains active; bounded intake17.0 is complete. P1 Perl CLI17.8 precedes neutral contract17.1 and owned backend children.\n\n'
        '## Latest Completed Slice\n\nTYPE-REFERENCE-BOOK.1.2.17.0: '+SUMMARY+' Whole hygiene21 custody precedes writes. '
        'Current book/Knowledge match dated observations; no runtime/contract/checker change.\n\n## Next Action\n\n'
        'From clean Git activate/repair Perl CLI17.8 with both error channels and permanent null/false/no-match controls; '
        'run exact canonical candidate before landing. Signed17.1–7, then14/16/19/raw-regex21/policy20 precede complete inventory/reference work.\n\n'
        '## Recent Completions\n\n'+'\n'.join(rows)+'\n\n## History\n'+history)
    tree = changes['docs/tasks/TYPE-REFERENCE-BOOK.md']
    tree = tree.replace('- Status: `active` / signed-selector intake17.0','- Status: `active` / P1 CLI17.8 next before signed contract17.1',1)
    start = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.17.0`')
    end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.17.1`',start)
    node = tree[start:end].replace('Status: `active`','Status: `completed`',1)
    old = 'Owned paths: docs/checkpoints/signed-array-selectors/ public-interface observations/reviewers; relevant indexed-read/write Knowledge cards and two DSL book sections; normal continuity.'
    new = 'Owned paths: docs/checkpoints/signed-array-selectors/ public-interface observations/reviewers; four indexed-read/write/Perl-CLI Knowledge cards, DSL values/flow and public Perl integration book pages, two exact examples; normal continuity/roadmap/index. Full checked-live census and before packets precede these bounded documentation writes.'
    assert old in node
    node = node.replace(old,new)
    node = node.replace('Rust negative reads return the first element even for underflow; source/root-cause calibration is next under already-owned Rust child17.3.',
        'Rust negative reads return the first element even for underflow; actual public binary calibration/source packets identify the unsigned conversion and existing negative-coercion unit, owned by Rust child17.3.')
    node += ('  Completion: '+SUMMARY+' Whole retained Rust/Lua products, eight complete source epochs, independent Git source review and complete actual channels remain recoverable. '
        'Read-only: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-selectors/publish.py. '
        'Original comparison/proposal failures are instrument qualifications, without product RED credit. Frozen-v1 and current runtimes are unchanged.\n'
        '  Acceptance checklist:\n'
        '  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/dump_parser_source plus native/fresh32 and six public CLI routes retain exact signed gaps and context-only errors.\n'
        '  - [x] **ROOT CAUSE (WHY + WHERE)** — Source-bound Perl guarded/digit-only/write-selector branches, Rust unsigned cast and CLI exception-only branch explain the observed differences.\n'
        '  - [x] **FIX** — Intake resolves the provisional key-control expectation, documents current limits and owns separate canonical contract/backend/P1 repair leaves; no runtime repair is claimed here.\n'
        '  - [x] **ADDRESSED (verified)** — Independent13-case director oracle and CLI-protocol oracle observe diagnostic RED; three actual book-source denials and input3/scope2 bypass/restoration distinguish missing evidence.\n'
        '  - [x] **NO REGRESSION** — Unchanged frozen authority/checker and focused typed-write/read consumers pass; Knowledge/history/memory/whitespace and normal hooks govern landing.\n'
        '  - [x] **LOCKSTEP** — Two executed book examples/current qualifications, four canonical cards/derived map, roadmap/index/live pointer and source-bound claim agree. P1 CLI17.8 is first clean next action.\n'
        '  Commit: `TYPE-REFERENCE-BOOK.1.2.17.0 - record signed-index baseline and CLI repair priority`\n\n')
    tree = tree[:start]+node+tree[end:]
    start = tree.index('## Current Frontier\n')
    end = tree.index('## Decisions\n',start)
    rows = [('17.8','Owned P1: Perl CLI loses context-reported runtime failures; first clean repair.'),
        ('17.1','Freeze new signed authority/checker with historical-v1 boundary.'),
        ('17.2','Perl ordinary/deferred implementation.'),('17.3','Rust native/generated implementation.'),
        ('17.4','Dart native/generated implementation.'),('17.5','Julia native/generated implementation.'),
        ('17.6','Shared Lua; independently verify PUC and LuaJIT.'),('17.7','Recurring compatibility/public admission after all backends.'),
        ('14','Deferred last after signed17.'),('16','Deferred scoped with after14.'),('19','Grouped indexed assignment value after16.'),
        ('21','Raw assigned-regex payload fidelity after19.'),('20','Shared containment policy update reconciliation.'),
        ('1','Complete supported operations/spellings.'),('2','Map every item to actual book coverage.')]
    frontier = '## Current Frontier\n\n| Order | Leaf | Status | Why next |\n| --- | --- | --- | --- |\n'
    frontier += ''.join('| '+str(i)+' | `TYPE-REFERENCE-BOOK.1.2.'+leaf+'` | `pending` | '+why+' |\n' for i,(leaf,why) in enumerate(rows,1))
    tail = [('TYPE-REFERENCE-BOOK.1.3','Independent complete inventory/layout review.'),('TYPE-REFERENCE-BOOK.8','Relevant legacy metadata repair.'),
        ('PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.13','Deferred literal-rendering question.'),('TYPE-REFERENCE-BOOK.2','Inventory-backed family references and closeout.')]
    frontier += ''.join('| '+str(i)+' | `'+leaf+'` | `pending` | '+why+' |\n' for i,(leaf,why) in enumerate(tail,len(rows)+1))
    tree = tree[:start]+frontier+'\n'+tree[end:]
    tree = tree.replace('## Commit Log\n','## Commit Log\n\nSigned intake17.0 subject: `TYPE-REFERENCE-BOOK.1.2.17.0 - record signed-index baseline and CLI repair priority`; derive accepted identity from Git.\n',1)
    tree = tree.replace('## Changelog\n','## Changelog\n\n- `2026-10-23`: Complete bounded signed intake17.0; retain diagnostic/oracle/source/product/book proof and qualify instrument mistakes. P1 Perl CLI17.8 precedes signed contract17.1/backend/admission children.\n',1)
    changes['docs/tasks/TYPE-REFERENCE-BOOK.md'] = tree
    index = changes['docs/TASK_TREE.md'].splitlines()
    for i,line in enumerate(index):
        if line.startswith('Latest PNT slice:'):
            index[i] = 'Latest PNT slice: Signed intake TYPE-REFERENCE-BOOK.1.2.17.0 retains32 sources/192 native observations and Perl native/fresh proof, diagnostic REDs, complete book/examples and source/artifact controls. No signed admission. P1 Perl CLI17.8 is first clean repair before shared contract17.1; full references remain pending.'
        elif line.startswith('| `TYPE-REFERENCE-BOOK` |'):
            index[i] = '| `TYPE-REFERENCE-BOOK` | `active` / next .1.2.17.8 | `.spec documentation / per-type reference` | Signed intake17.0:32 sources/192 native observations plus Perl Get/fresh, diagnostic REDs and source/artifact/book proof. P1 Perl CLI17.8 precedes signed contract/backend/admission17.1–7, then owned gaps and complete references. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |'
    changes['docs/TASK_TREE.md'] = '\n'.join(index)+'\n'
    roadmap = changes['ROADMAP.md'].splitlines()
    for i,line in enumerate(roadmap):
        if line.startswith('October19 current PNT activity:'):
            roadmap[i] = 'October23 current PNT activity: [TYPE-REFERENCE-BOOK](docs/tasks/TYPE-REFERENCE-BOOK.md) signed intake17.0 retains32 exact sources/192 native observations and Perl native/fresh proof, source-bound diagnostic REDs, complete book inputs and actual artifact/scope controls. No signed-selector admission. P1 Perl CLI17.8 must report context-only handler errors before neutral signed contract17.1 and owned backend/admission17.2–7. Director rule: [-n] selects [size-n] only when size-n>=0; negative positions never create elements.'
        elif line.startswith('October19 type-reference work:'):
            roadmap[i] = 'October23 type-reference work: Deferred-write12 is committed; signed17.8/17.1–7, deferred last14/with16, grouped assignment19, raw-regex21 and policy20 precede complete operation/spelling inventory1.2.1, coverage mapping1.2.2 and independent layout review1.3. Full per-type references and structured-format campaign admission remain unclaimed; their task-tree prerequisites stay authoritative.'
    changes['ROADMAP.md'] = '\n'.join(roadmap)+'\n'
    for path,text in changes.items():
        c.source(path).write_text(text)
    c.write_new('finalization.json.gz',dict(before=before,
        after={path:c.read(path) for path in PATHS},producer=c.read(c.PREFIX+'finish.py')))
    print('Intake continuity finalized; P1 CLI17.8 is next after clean landing')


if __name__ == '__main__':
    main()
