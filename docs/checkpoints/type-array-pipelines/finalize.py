"""Record verified final sources and write the intended clean handoff before canonical staging."""
import json
import re
import common as c

def main():
    focused=c.load('focused2-run.json.gz');assert focused['inputs_unchanged']
    assert all(focused[key]['returncode']==0 for key in ('history','tests','scanner'))
    tap=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(focused['tests']['stdout_base64']))
    assert tap and int(tap[1])==14
    count=int(tap[2]);task='docs/tasks/TYPE-REFERENCE-BOOK.md';fact='docs/knowledge/terse-type-method-surface-inventory.md'
    chapter='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
    paths=[task,fact,chapter,'MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','ROADMAP_V2.md','docs/TASK_TREE.md',
        'CHANGES.md','DEVELOPMENT_NOTES.md',c.PREFIX+'README.md',c.PREFIX+'publish.py',c.PREFIX+'review.py','KNOWLEDGE_MAP.md']
    before={p:c.read(p) for p in paths};after={p:c.decode(packet['base64']).decode() for p,packet in before.items()}
    text=after[c.PREFIX+'review.py']
    marker="    focused=c.load('focused2-run.json.gz');assert focused['inputs_unchanged']"
    addition="""    earlier=c.load('focused1-run.json.gz')
    assert earlier['inputs_unchanged'] and earlier['tests']['returncode']==1
    assert b\"Failed test 'aggregate7/deferred/chain'\" in c.decode(earlier['tests']['stderr_base64'])
    assert b'Files=14, Tests=1948,' in c.decode(earlier['tests']['stdout_base64'])
    advanced=c.load('existing-expectation-change.json.gz')
    assert advanced['advanced']==['aggregate7/deferred/chain'] and advanced['after']==c.read(advanced['path'])
    original=json.loads(c.decode(advanced['before']['base64']))
    repaired=json.loads(c.decode(advanced['after']['base64']))
    expected=json.loads(json.dumps(original))
    chosen=next(case for case in expected['cases'] if case['id']=='aggregate7/deferred/chain')
    assert chosen.pop('error')==dict(code='unknown_helper',name='sorted')
    chosen['expected']=4
    assert repaired==expected
"""
    assert text.count(marker)==1;after[c.PREFIX+'review.py']=text.replace(marker,addition+marker,1)
    text=after[c.PREFIX+'publish.py']
    text=text.replace('85 permanent cases. Three artifact denials', '85 permanent cases/one advanced earlier expectation/75 malformed assertions. Three artifact denials')
    text=text.replace('Exact staged canonical receipt governs landing.',
        'Six aggregate-availability faults retain their exact pre-argument-guard source; a distinct final guard removal/restoration plus final85/final14 suites covers the sole typed-list-validation delta. The earlier14-suite1948-TAP run fails only its intentional old sorted-unknown expectation; that one case advances to independently verified4. Exact staged canonical receipt governs landing.',1)
    text=text.replace('source-mutation faults each reject and restore.',
        'source-mutation faults each reject and restore at the retained pre-guard epoch. A separate actual final argument-guard removal reproduces nine raw host errors and six invalid-list acceptances; restoring it yields15 typed errors and unchanged records/callers.')
    after[c.PREFIX+'publish.py']=text
    text=after[chapter].replace('Registered `fn` bodies containing `sorted` also remain limited;',
        'Registered `fn` receiver pipelines containing `sorted` also remain limited;',1)
    marker='shapes return `undef` before operands run.'
    assert text.count(marker)==1
    text=text.replace(marker,marker+' Malformed serialized fluent argument lists raise\ntyped `invalid_codeblock_body` errors and preserve the record and caller values.',1)
    after[chapter]=text
    text=after[fact];marker='date: 2026-10-21\n';assert text.count(marker)==1
    text=text.replace(marker,'  - "why do malformed fluent arguments leak a Perl array-reference error"\n'+marker,1)
    marker='No family/backend admission.\n';assert text.count(marker)==1
    text=text.replace(marker,'Serialized fluent args require arrays before preflight.\n'+marker,1)
    after[fact]=text
    text=after[task];start=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.9`\n');end=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.13`\n',start)
    node=text[start:end].replace('Status: `in_progress` / activation49ce3fb','Status: `done` / activation49ce3fb')
    node=node.replace('- [ ]','- [x]')
    node+=f'''  Verified scope:85 fixed values/41 actual accepted RED/44 controls; six retained pre-argument-guard source faults plus one final guard fault. Final14/{count} TAP/history650/scanner pass.85 new permanent/one advanced old expectation/75 malformed assertions. First14/1948 failure retains only the old intentional unknown sorted expectation; no other failure is discarded. Book89/3/anchor RED is rerun on final docs/source before publication.
  Custody/admission: Whole accepted7 physical10608/logical3/images10611/full modes/actual clean readonly0 survives at real49ce. All rejected fixture/instrument/metadata epochs stay retained; closed publication/three artifact denials/actual validator fault and exact staged canonical receipt govern landing. No complete inventory/backend or kind13/95 admission.
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.9 - execute deferred sorted take pipelines`.

'''
    text=text[:start]+node+text[end:]
    text=text.replace('| 6 | `TYPE-REFERENCE-BOOK.1.2.9` | `in_progress` | Owned deferred sorted/take pipeline after7. |','| 6 | `TYPE-REFERENCE-BOOK.1.2.9` | `done` | Callable sorted/take; bounded proof/typed argument guard; kind13 next. |',1)
    text=text.replace('Pipeline9 verification/normal landing is active; owned P1 kind13 then10/11/12 precede complete inventory1.','Pipeline9 selected proof is complete; exact canonical/normal landing is mandatory. P1 kind13 then10/11/12 precede complete inventory1.',1)
    after[task]=text
    after['MEMORY.md']=f'''# MEMORY

- activation_commit: `{c.BASE}` — normal post-commit requires HEAD^1; derive current identity from Git.
- latest_completed_leaf: `{c.OWNER}` — subject `{c.OWNER} - execute deferred sorted take pipelines`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.13` (pending clean activation); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: Run docs/checkpoints/type-array-pipelines/publish.py source-readonly and preserve the complete accepted9 claim/publication/input manifest/full modes/actual clean baseline and Git images before any13-bound write. Then repair the already diagnosed sorted/copy scalar-kind P1. Continue full PNT after each normal commit.
- in_flight_uncommitted: none; intended clean post-landing handoff. No verification job belongs to the committed state.
- current_proof:85 final public values/41 accepted RED/44 controls; six pre-argument-guard faults plus separate final guard fault/15 typed cases. Final14/{count} TAP;85 new permanent/one advanced earlier expectation/75 malformed assertions. Book89/3/heading RED; exact canonical receipt and normal hooks govern landing.
- checkpoint: docs/checkpoints/type-array-pipelines/README.md; claim docs/claims/{c.OWNER}.json. publish.py is the current source-readonly gateway; it verifies/reconstructs three ignored aggregate logical inputs from tracked chunks.
- prior: Accepted7 whole claim/publication/10608 physical/3 logical/full modes/10611 Git-verified images and clean readonly0 survive before writes. Its claim is historical only at real49ce. Source contexts retain changed plain bytes, immutable gzip/chunk identities and real accepted Git recovery without recursive embedding.
- rejected_epochs: Original88 has wrong child-push syntax, scalar-kind and separate helper gaps; second85 has unsupported body indexed writes. Both remain exact. First kind instrument fails blessed-error serialization; corrected16 rows diagnose flags/clone/real index failure. First14/1948 rejects only the old expected unknown sorted; final14 passes after that one expectation and the typed argument guard.
- next_kind13: Lexical comparison adds POK alongside IOK; Storable cloning drops IOK and serializes strings. Numeric-literal controls retain IOK alone; ordinary/deferred selected numeric indexes reject array writes. Actual sources/16 rows are retained; no kind repair admitted by9. Keep reducer95 separate.
- next_owned:13 P1 -> count/first10 -> registered sorted/ordinary length11 -> deferred indexed-write12 -> inventory1 -> book mapping2 -> layout3 -> legacy8 -> private metadata QA13 -> references/closeout. See findings.md for exact reproductions and schedule.
- standing_defects: Startup20/32/35/87.4, constructor94 and reducer95 remain owned. No general pipeline, complete inventory, arbitrary host-object deep-copy or cross-backend admission.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; less than24h at this slice. Frozen proof inputs/chunks are required; generated checkpoint caches stay ignored.
- standing_limit: Other repositories and RGX/PGEN are read-only black boxes. All project data stays on the repository volume. No push until PNT is exhausted; full CI before every push.
'''
    text=after['LIVE_ACHIEVEMENT_STATUS.md'];history=text[text.index('## History\n'):]
    recent=text.split('## Recent Completions\n',1)[1].split('## History\n',1)[0]
    rows=[line for line in recent.splitlines() if line.startswith('- `')]
    rows=[f'- `{c.OWNER}` —85/41 accepted RED;7 restored fault epochs;14/{count};85+1 permanent/75 malformed;book89/3;kind13 next.']+rows[:15]
    after['LIVE_ACHIEVEMENT_STATUS.md']=f'''# LIVE ACHIEVEMENT STATUS

## Current Activity

Pipeline9 completes bounded Perl callable sorted/take and typed fluent-list validation. P1 sorted/copy kind13 is next after clean landing;10/11/12 precede complete inventory.

## Latest Completed Slice

{c.OWNER}:85 final values through descriptor/native Get-dump/fresh generated execution;41 real accepted RED/44 controls. Six faults retain their pre-argument-guard source, and the final guard has a separate actual removal/restoration. Final14/{count} TAP/history650/scanner;85 new permanent/one advanced prior expectation/75 malformed assertions. Book89/3/heading RED, three artifact denials/actual validator fault, complete source custody and exact staged canonical receipt govern acceptance. Whole accepted7 physical10608/logical3/images10611/full modes/actual clean readonly0 survives.

Rejected88/85 and first kind/metadata writer epochs remain exact. The first14/1948 failure exposes only the intentional old unknown sorted expectation, advanced to independently verified4. Numeric sort/copy flags remain P1 kind13; missing count/first10, registered sorted/ordinary length11 and deferred indexed-write12 are owned and scheduled. No whole-family/backend,95 or complete reference admission.

## Next Action

From clean Git, run the pipeline publisher readonly and preserve its whole accepted claim/publication/physical and logical manifest/full modes/actual clean baseline and Git images before13. Repair sorted/copy scalar kinds, then continue full PNT through the remaining owned frontier. No push yet.

## Recent Completions

'''+ '\n'.join(rows)+'\n\n'+history
    text=after['ROADMAP_V2.md'];start=text.index('\nOctober21 current');end=text.index('\nOctober21 type-reference',start)
    after['ROADMAP_V2.md']=text[:start]+f'''
October21 current PNT boundary: TYPE-REFERENCE-BOOK.1.2.9 completes bounded callable sorted/take and typed fluent-list validation:85 values/41 accepted RED, six pre-guard faults plus a final guard fault,14/{count} direct TAP and complete book/source custody. Exact staged canonical receipt governs landing. Whole accepted7 survives before writes. Sorted/copy kind13 is next P1; count/first10, registered sorted/ordinary length11 and indexed-write12 follow before enumeration. No dirty pivot or complete pipeline/reference admission.
'''+text[end:]
    text=after['docs/TASK_TREE.md'];old=next(line for line in text.splitlines(keepends=True) if line.startswith('| `TYPE-REFERENCE-BOOK` |'))
    after['docs/TASK_TREE.md']=text.replace(old,f'| `TYPE-REFERENCE-BOOK` | `active` / kind .1.2.13 next clean | `.spec documentation / per-type reference` | Pipeline9:85 values/41 accepted RED/seven fault epochs,14/{count},85+1 permanent/75 malformed,book89/3; exact canonical receipt governs landing. Whole accepted7 custody retained. P1 kind13 then10/11/12 precede inventory1/mapping2/layout3/legacy8. Full reference admission stays pending. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |\n',1)
    change=f'''## 2026-10-21 — {c.OWNER}: callable sorted/take

Perl codeblocks execute lexical sorted and integer-prefix take in free/receiver forms, with lazy count evaluation, independent arrays and compatible terminal reducers. Canonical fluent arguments require arrays and preserve typed errors/records/caller values. Final85 values/41 accepted RED/44 controls; six pre-guard faults plus one final guard fault;14/{count} TAP/history650/scanner;85 new permanent/one advanced expectation/75 malformed assertions;book89/3/anchor RED. Exact staged canonical receipt governs landing. Whole accepted7 and all rejected epochs remain recoverable; source-closed publication and actual artifact validator controls bind the result. P1 kind13 and10/11/12 stay owned. See docs/checkpoints/type-array-pipelines/README.md.

'''
    note='''## 2026-10-21 — deferred selection

Perl sorted/take execute in codeblocks; malformed fluent lists fail with typed errors. Proof and kind13 follow-up: docs/checkpoints/type-array-pipelines/.

'''
    for p,record in [('CHANGES.md',change),('DEVELOPMENT_NOTES.md',note)]:
        text=after[p];index=text.index('\n## ')+1;after[p]=text[:index]+record+text[index:]
    text=after[c.PREFIX+'README.md']
    text=text.replace('six actual final-runtime faults','six actual pre-argument-guard runtime faults')
    text=text.replace('all85 authored values/effect traces pass on three\n  public routes.', 'all85 authored values/effect traces pass on three\n  public routes; candidate4 repeats them on the final argument-guard source.')
    text=text.replace('`permanent-migration.json.gz`: before/after runner and85 permanent fixtures.\n  `focused1-*` retains direct consumer/history/scanner results.',
        '`permanent-migration.json.gz`: runner/85 permanent fixtures; existing-expectation-change.json.gz advances only the old intended sorted error. `focused1-*` retains its actual one-failure1948-TAP epoch; `focused2-*` passes final14/'+str(count)+'. argument-guard-change.json.gz retains the sole late runtime delta,15 typed cases,75 assertions and an actual guard-removal RED/restoration.')
    text=text.replace('`doc-*`: three actual book action','`doc-*` / `doc2-*`: three actual book action')
    text+='\nFinal source epochs: six initial runtime faults precede the typed argument guard; the separate final guard fault and candidate4/final14 suites cover that exact delta. Canonical admission is receipt-bound to the staged candidate.\n'
    after[c.PREFIX+'README.md']=text
    assert len(after[task].encode())<=65536
    for p,t in after.items():(c.ROOT/p).write_text(t)
    generated=c.run(['bash','knowledge-map/scripts/gen_knowledge_map.sh'])
    assert generated['returncode']==0
    c.write_new('finalization.json.gz',dict(before=before,after={p:c.read(p) for p in paths},producer=c.read(c.PREFIX+'finalize.py'),knowledge_generation=generated,
        scope='Verified source finalization writes intended post-landing handoff before final book/publication and exact staged canonical CI. No production or test behavior changes here. Normal hooks prevent landing without the selected gates.'))
    print('Final14/'+str(count)+' recorded; final book/artifact/publication/canonical staging next')

if __name__=='__main__':main()
