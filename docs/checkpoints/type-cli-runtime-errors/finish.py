"""Finalize verified CLI repair continuity before exact canonical admission."""
import json
import common as c
import control_review

PATHS = ['CHANGES.md','DEVELOPMENT_NOTES.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.md','docs/TASK_TREE.md','ROADMAP.md']
SUMMARY = ('11 source/input cases/10 source texts,22 quiet/routed commands;6 corrected-baseline CLI RED; '
    '7 successful controls and unchanged thrown-error protocol;6 permanent groups GREEN, '
    'actual old-predicate inverse2 failed groups/restored GREEN;book91/two executed commands/three source denials; '
    'identity3/scope2 bypass-restoration;Knowledge +263 bytes within unchanged limits.')


def main():
    measured = c.load('review-check.json.gz')
    assert measured['inputs_unchanged'] and measured['run']['returncode']==0
    result = json.loads(c.decode(measured['run']['stdout_base64']))
    assert (result['cases'],result['distinct_sources'],result['book_inputs'])==(11,10,91)
    assert control_review.check()['exact_restoration']
    before = {path:c.read(path) for path in PATHS}
    c.write_new('final-continuity-before.json.gz',dict(before=before,
        producer=c.read(c.PREFIX+'finish.py')))
    changes = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    def prepend(path,record):
        text = changes[path]
        position = text.index('\n## ')
        changes[path]=text[:position]+'\n'+record+'\n'+text[position:]
    prepend('CHANGES.md','## 2026-10-23 — TYPE-REFERENCE-BOOK.1.2.17.8 — propagate Perl CLI handler failures\n\n'
        'The primary Perl command checks runtime_ctx.last_error as well as immediately saved $@. '
        'Context-only ordinary/callable write failures now use the existing invocation-failure exit1, empty stdout, stable stderr heading and error trace. '
        'Legitimate falsey, initializer and real matched/no-match results remain successful. No library, selector or trace-schema change.\n\n'
        'Validation: '+SUMMARY+' Whole accepted signed intake/actual clean readonly0 and82 Git-verified images precede writes. '
        'Nine source epochs independently recover11504 Git blobs; the exact invocation predicate is the sole runtime overlay. '
        'Original nine-case baseline, wrong I-return target, failed original oracles/test and all source packets remain qualified without extra product RED credit. '
        'Current book examples/flow link, canonical CLI card/derived map and task continuity agree. '
        'Exact staged canonical CI and normal hooks govern landing; signed contract17.1 follows clean Git. '
        'Read-only: docs/checkpoints/type-cli-runtime-errors/publish.py.')
    prepend('DEVELOPMENT_NOTES.md','## 2026-10-23 — Perl CLI errors are independent of returned value\n\n'
        'The invocation boundary already passes runtime_ctx_ref. A rule handler can catch its failure, set last_error and return undef without setting the outer $@. '
        'The CLI must check both channels before invoke:ok and JSON serialization. Checking return-value truthiness would reject legitimate null, false and zero; '
        'the permanent and public controls distinguish that error. The original predicate inverse reproduces the two handler-error groups and exact restoration returns GREEN.\n\n'
        'The first no-match fixture incorrectly used I{return(42)}. Canonical action-and-lifecycle-placement and existing top-rule/I-return cards already explain '
        'that selection does not match an own regex and I return exits before matching. Native/fresh dumps confirm direct return42. '
        'A distinct explicit self-edge source has y:null/x:42; retain both twins and the valid initializer return. '
        'Original targets, rows, test, oracles and their actual failures remain immutable; only cases2/oracle2 earn current qualified proof. '
        'Source epochs are complete conservative main-project images, not dependency implementation or minimal-I/O claims. '
        'The accepted prior intake stays live and unchanged; current feature proof is dated to real329cee31c plus the exact retained overlay.')
    changes['MEMORY.md']='''# MEMORY

- activation_commit: `329cee31c566cfb054557b8a2ebab62bac015db1` — clean CLI repair17.8 base; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.17.8` — Perl CLI observes both failure channels; exact canonical workflow governs landing.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.17.1`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean Git activate/freeze the neutral signed-array selector authority/checker and historical-v1 transition17.1, then implement owned backends17.2–6 and independent admission17.7. Read TRANSITION.md and current shared/read contracts first.
- in_flight_uncommitted: none; no background job. CLI repair is committed; no signed-selector implementation/admission. Never rerun historical capture writers.
- proof: docs/checkpoints/type-cli-runtime-errors/publish.py is read-only by default:11 pairs/10 source texts/22 CLI observations, seven success controls, exact permanent inverse/restoration, source9/book91 and artifact/scope controls. Original I-return expectation error remains qualified. Prior signed intake publication remains live/unchanged.
- steering: [-n]=[size-n] when size-n>=0; -1 is last, -size first, and negative selectors never create entries. After signed17 come14/16/19/raw-regex21/policy20 and complete inventory/references.
- limits: Frozen write-v1 stays exact until the explicit transition; other repositories/submodules are read-only black boxes; all data stays on-volume. No push until PNT exhausted.
'''
    live=changes['LIVE_ACHIEVEMENT_STATUS.md']
    history=live.split('## History\n',1)[1]
    rows=live.split('## Recent Completions\n',1)[1].split('## History\n',1)[0].strip().splitlines()
    rows=['- `TYPE-REFERENCE-BOOK.1.2.17.8` — '+SUMMARY]+rows[:15]
    changes['LIVE_ACHIEVEMENT_STATUS.md']=('# LIVE ACHIEVEMENT STATUS\n\n## Current Activity\n\n'
        'Signed-selector17 remains active. P1 CLI17.8 is complete; neutral contract/checker17.1 is next before the owned backend/admission children.\n\n'
        '## Latest Completed Slice\n\nTYPE-REFERENCE-BOOK.1.2.17.8: '+SUMMARY+' '
        'Whole accepted intake custody precedes writes; original control mistake remains qualified. '
        'Exact staged canonical CI/normal hooks govern admission. No signed support is inferred.\n\n## Next Action\n\n'
        'From clean Git activate signed contract/checker17.1 with historical-v1 bytes preserved, then owned17.2–7. '
        'Deferred last14/with16, grouped assignment19, raw-regex21 and policy20 precede complete inventory/reference work.\n\n'
        '## Recent Completions\n\n'+'\n'.join(rows)+'\n\n## History\n'+history)
    tree=changes['docs/tasks/TYPE-REFERENCE-BOOK.md']
    tree=tree.replace('- Status: `active` / P1 CLI17.8 next before signed contract17.1','- Status: `active` / signed contract17.1 next',1)
    tree=tree.replace('Status: `active` / signed-selector transition; intake17.0 first','Status: `active` / intake17.0 and CLI17.8 complete; contract17.1 next',1)
    start=tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.17.8`')
    end=tree.index('- ID: ',start+5)
    node=tree[start:end].replace('Status: `active` / owned P1 public-command defect','Status: `completed` / P1 public-command defect repaired',1)
    node=node.replace('  Reproduce:','  Original reproduce at329cee31c:',1).replace('  Impact:','  Original impact:',1)
    node=node.replace('  Mechanism:','  Original mechanism:',1)
    node=node.replace('Current diagnostic capture finishes unchanged and is committed before repair; no dirty pivot or silent baseline replacement.',
        'Intake17.0 finished unchanged and committed before this repair; no dirty pivot or silent baseline replacement.')
    node=node.replace('No CLI/runtime change has occurred; only the three typed failures and their trace earn product RED credit.',
        'At that capture boundary no CLI/runtime change had occurred; only the three typed failures and their trace earn product RED credit.')
    node+=('  Completion: '+SUMMARY+' Read-only: bash tools/run_python_project_data.sh docs/checkpoints/type-cli-runtime-errors/publish.py. '
        'Full public scope is the separate green epoch; inverse/restored scope is the actual permanent consumer. '
        'Nine complete source epochs/11504 unique accepted Git blobs, exact one-condition source overlay, prior82-image custody, actual source packets/channels and qualified failures remain recoverable. '
        'No library/selector/trace-schema or wider backend admission. Exact canonical proof and normal hooks govern landing.\n'
        '  Acceptance checklist:\n'
        '  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/dump_parser_source/native/fresh identify three typed handler failures; corrected baseline22 CLI commands has six actual protocol RED observations.\n'
        '  - [x] **ROOT CAUSE (WHY + WHERE)** — Already supplied runtime_ctx_ref receives last_error while bin/linkedspec checked only saved $@. Canonical lifecycle teaching and exact dumps separately resolve the mistaken original no-match target.\n'
        '  - [x] **FIX** — Check either failure channel before invoke:ok/JSON, using the unchanged invocation error exit/heading/trace.\n'
        '  - [x] **ADDRESSED (verified)** — Full fixed11-pair public population passes. Actual exact old-predicate inverse restores two permanent failing groups; exact restoration passes all six. Identity3/scope2 and three actual book-source denials distinguish missing/stale proof.\n'
        '  - [x] **NO REGRESSION** — Seven clear-channel controls and the existing thrown error remain compatible; six permanent groups pass. Exact staged canonical CI and normal hooks are required for admission.\n'
        '  - [x] **LOCKSTEP** — Current book/two executed CLI commands/flow link, canonical card/derived map, roadmap/index/live pointer and source-bound claim agree. Signed contract17.1 follows clean landing.\n'
        '  Commit: `TYPE-REFERENCE-BOOK.1.2.17.8 - report context-only Perl CLI runtime failures`\n\n')
    tree=tree[:start]+node+tree[end:]
    start=tree.index('## Current Frontier\n')
    end=tree.index('## Decisions\n',start)
    lines=tree[start:end].splitlines()
    lines=[line for line in lines if '`TYPE-REFERENCE-BOOK.1.2.17.8`' not in line]
    number=0
    for i,line in enumerate(lines):
        if line.startswith('| ') and '`' in line:
            number+=1
            parts=line.split('|')
            parts[1]=' '+str(number)+' '
            lines[i]='|'.join(parts)
    tree=tree[:start]+'\n'.join(lines).rstrip()+'\n\n'+tree[end:]
    tree=tree.replace('## Commit Log\n','## Commit Log\n\nCLI17.8 subject: `TYPE-REFERENCE-BOOK.1.2.17.8 - report context-only Perl CLI runtime failures`; derive accepted identity from Git.\n',1)
    tree=tree.replace('## Changelog\n','## Changelog\n\n- `2026-10-23`: Complete P1 CLI17.8 with both error channels, permanent source inverse/restoration and accurate current book; preserve original control qualification and accepted intake. Signed contract17.1 is next.\n',1)
    changes['docs/tasks/TYPE-REFERENCE-BOOK.md']=tree
    index=changes['docs/TASK_TREE.md'].splitlines()
    for i,line in enumerate(index):
        if line.startswith('Latest PNT slice:'):
            index[i]='Latest PNT slice: TYPE-REFERENCE-BOOK.1.2.17.8 repairs context-only Perl CLI failures with11 pairs/10 source texts/22 commands, actual permanent inverse/restoration, book91/two executed commands and source/artifact controls. Exact canonical workflow governs landing; signed contract17.1 follows clean Git. No signed-selector admission.'
        elif line.startswith('| `TYPE-REFERENCE-BOOK` |'):
            index[i]='| `TYPE-REFERENCE-BOOK` | `active` / next .1.2.17.1 | `.spec documentation / per-type reference` | P1 CLI17.8 observes both failure channels; fixed11-pair/22-command proof, actual permanent inverse/restoration and current book/source controls. Signed neutral contract17.1 then owned backend/admission17.2–7 precede remaining gaps and complete references. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |'
    changes['docs/TASK_TREE.md']='\n'.join(index)+'\n'
    roadmap=changes['ROADMAP.md'].splitlines()
    for i,line in enumerate(roadmap):
        if line.startswith('October23 current PNT activity:'):
            roadmap[i]='October23 current PNT activity: [TYPE-REFERENCE-BOOK](docs/tasks/TYPE-REFERENCE-BOOK.md) P1 CLI17.8 repairs context-only handler failures with exact source/command/inverse/book proof, preserving legitimate falsey and matched/no-match results. Signed neutral contract/checker17.1 is next, then owned backend/admission17.2–7. Director rule: [-n] selects [size-n] only when size-n>=0; negative positions never create entries. No signed-selector admission yet.'
        elif line.startswith('October23 type-reference work:'):
            roadmap[i]='October23 type-reference work: Deferred-write12, signed intake17.0 and P1 CLI17.8 are complete. Signed17.1–7, deferred last14/with16, grouped assignment19, raw-regex21 and policy20 precede complete operation/spelling inventory1.2.1, coverage mapping1.2.2 and independent layout review1.3. Full per-type references and structured-format campaign admission remain unclaimed; task-tree prerequisites stay authoritative.'
    changes['ROADMAP.md']='\n'.join(roadmap)+'\n'
    for path,text in changes.items():
        c.source(path).write_text(text)
    c.write_new('finalization.json.gz',dict(before=before,
        after={path:c.read(path) for path in PATHS},producer=c.read(c.PREFIX+'finish.py')))
    print('CLI17.8 continuity finalized; exact canonical admission precedes clean signed17.1 activation')


if __name__ == '__main__':
    main()
