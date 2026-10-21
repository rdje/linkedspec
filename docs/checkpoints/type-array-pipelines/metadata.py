"""Own diagnosed follow-ups and keep the current canonical fact within its existing budget."""
import re
import common as c

def main():
    task='docs/tasks/TYPE-REFERENCE-BOOK.md';fact='docs/knowledge/terse-type-method-surface-inventory.md'
    paths=[task,fact,'docs/TASK_TREE.md','ROADMAP_V2.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md']
    before={p:c.read(p) for p in paths};after={p:c.decode(packet['base64']).decode() for p,packet in before.items()}
    text=after[task];marker='- ID: `TYPE-REFERENCE-BOOK.1.2.1`\n';assert text.count(marker)==1
    nodes=''
    tasks=[
      ('13','P1','Preserve numeric kinds through lexical sorting and container copies.','TYPE-REFERENCE-BOOK.1.2.9',
       'Actual ordinary/deferred sorted scalars retain IOK+POK; Storable cloning drops IOK and emits strings. Selected numeric indexes reject array writes. kind-investigation2.json.gz retains16 native/fresh rows and literal controls.',
       'Next after9, before10. Audit pure-sort/copy kind authority, fix source preservation and cloning, and verify flags, serialized kinds, public numeric indexes and direct consumers. Existing reducer95 stays separately owned.'),
      ('10','P2','Execute deferred count/first array receiver helpers.','TYPE-REFERENCE-BOOK.1.2.13',
       'sorted().take(2).count()/first() work outside but deferred raises unknown_helper. baseline-run.json.gz retains the actual cases.',
       'After13, before11/inventory. Fix existing count/first forms with shape/empty/kind/terminal/effect controls.'),
      ('11','P2','Repair registered sorted receiver pipelines and ordinary length continuation.','TYPE-REFERENCE-BOOK.1.2.10',
       'Registered fn select_items marks sorted unresolved, returning[] ordinarily and user_function_body_unsupported from a codeblock. Ordinary sorted().take(2).length() stays raw and calls an undefined host sorted; deferred length works. candidate1/inspection retain sources.',
       'After10, before12/inventory. Use public lowering to identify both bounded owners; split at clean activation if necessary.'),
      ('12','P2','Execute typed indexed writes inside deferred codeblocks.','TYPE-REFERENCE-BOOK.1.2.11',
       'chosen[0]="changed" in a callable body raises unsupported_codeblock_actionir:assign_nested_access; ordinary caller-side indexed writes succeed. candidate2 retains the typed failures.',
       'After11, before inventory. Fix the typed write family with key validation, copy/alias/caller-slot/effect/malformed-record controls.'),
    ]
    for ident,priority,goal,dependency,reproduce,schedule in tasks:
        nodes+=f'''- ID: `TYPE-REFERENCE-BOOK.1.2.{ident}`
  Status: `pending` / {priority} defect owned
  Goal: {goal}
  Dependencies: `{dependency}`
  Reproduce/impact: {reproduce}
  Schedule: {schedule}
  Evidence: docs/checkpoints/type-array-pipelines/findings.md; whole source epochs remain retained.
  Planned tier: `canonical`
  Claim verification: none: Pending repair; actual intake diagnosis is bound to claim9.

'''
    text=text.replace(marker,nodes+marker,1).replace('  Dependencies: `TYPE-REFERENCE-BOOK.1.2.9`\n  Planned tier: `focused`; reclassify before public/mechanical movement.', '  Dependencies: `TYPE-REFERENCE-BOOK.1.2.12`\n  Planned tier: `focused`; reclassify before public/mechanical movement.',1)
    old='| 7 | `TYPE-REFERENCE-BOOK.1.2.1` |'
    position=text.index(old);end=text.index('\n## Decisions',position)
    tail=text[position:end]
    tail=re.sub(r'^\| (\d+) \|',lambda m:'| '+str(int(m[1])+4)+' |',tail,flags=re.M)
    rows=''.join(f'| {index} | `TYPE-REFERENCE-BOOK.1.2.{ident}` | `pending` | {reason} |\n' for index,(ident,reason) in enumerate([
        ('13','P1 sorted/copy scalar-kind repair next after9.'),('10','Deferred count/first after13.'),('11','Registered sorted/ordinary length after10.'),('12','Deferred indexed writes before inventory.')],7))
    text=text[:position]+rows+tail+text[end:]
    start=text.index('## Blockers\n');end=text.index('## Verification Log\n',start)
    text=text[:start]+'## Blockers\n\nNo director input required. Pipeline9 verification/normal landing is active; owned P1 kind13 then10/11/12 precede complete inventory1. No dirty pivot.\n\n'+text[end:]
    assert len(text.encode())<=65536
    after[task]=text
    text=after[fact];head,body=text.split('\n---\n',1)
    head=head.replace('date: 2026-10-21','  - "can Perl sorted and take run inside a deferred codeblock"\n  - "why do sorted numbers become strings after a container copy"\n  - "which task owns deferred count first indexed writes and registered sorted"\ndate: 2026-10-21',1)
    head=re.sub(r'^status:.*$', 'status: bounded Perl helpers; sorted-kind13 and inventory pending',head,flags=re.M)
    head=re.sub(r'^evidence:.*$', 'evidence: "Type3-.9 retain exact epochs;9 admits only callable sorted/take. kind13/10/11/12 remain owned."',head,flags=re.M)
    head=re.sub(r'^reverify:.*$', 'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-array-pipelines/publish.py"',head,flags=re.M)
    body='''
# Value model and bounded Perl helper execution

Bindings hold scalar/array/harray/codeblock; deferred bodies read caller slots.
Constructors, keys and arguments retain evaluated values; updates use copy-on-write.
Scoped with: [[perl-generic-final-codeblock-normalization]].

Scalar/aggregate Numeric policies differ. Shape checks precede effects;
comparisons/reducers terminate. Aggregates take one array; receiver reducers no
operands. Explicit scalar min/max evaluates operands before rejection. Legacy
Perl checks every decimal term: empty sum0, othersundef; Rust filtering differs.
[[perl-numeric-reducer-string-result-kinds]] owns reducer95. Boolean35,
Unicode20/constructor94 remain separate.

Perl callable sorted/take now execute free/receiver forms. Sort is lexical;
take defaults1, integer spelling only, negative/invalid0, oversized counts clamp.
Non-arrays yield[] and skip count; sources stay independent.13 owns sorted/copy
kinds next: comparison adds POK; Storable
clone drops numeric flags. Actual array-index writes reject.10 owns deferred
count/first,11 registered sorted/ordinary length,12 deferred indexed writes.
No family/backend admission.

drop_keys copies keys/splices, stays FATAL-warning quiet and retains null
diagnostics. c053c9dcf inventoried substr/typed receivers; references remain pending.

Accepted7 builds reproduce both pages except their search-index reference.
Decoded indexes differ only in15 body-whitespace strings; other fields match.
The strict rejection survives. Verify payloads before normalizing that reference;
this grants no general asset normalization.

Context hash-gates immutable gzip/chunks without embedding.37 verified32MiB parts
restore three exact byte/mode aliases with nested-repository guards. Old recursive
snapshots survive at accepted49ce.
'''
    after[fact]=head+'\n---\n'+body
    assert len(after[fact].encode())<=len(c.decode(before[fact]['base64'])), (len(after[fact].encode()),len(c.decode(before[fact]['base64'])))
    text=after['docs/TASK_TREE.md'];old=next(line for line in text.splitlines(keepends=True) if line.startswith('| `TYPE-REFERENCE-BOOK` |'))
    after['docs/TASK_TREE.md']=text.replace(old,'| `TYPE-REFERENCE-BOOK` | `active` / pipeline .1.2.9 verification | `.spec documentation / per-type reference` | Aggregate7 committed49ce; whole accepted10608 physical/3 logical/10611 images/readonly0 retained. Pipeline9 fixed85/41 accepted RED/six restored faults. P1 kind13 follows clean9, then count/first10, registered/length11, indexed-write12, inventory1/mapping2/layout3/legacy8. Complete reference admission remains pending. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |\n',1)
    text=after['ROADMAP_V2.md'];start=text.index('\nOctober20 current');end=text.index('\nOctober4 selected',start)
    after['ROADMAP_V2.md']=text[:start]+'''
October21 current PNT boundary: TYPE-REFERENCE-BOOK.1.2.7 is committed49ce with canonical admission. Deferred sorted/take9 passes its bounded public plan and distinguishing faults; book/direct/canonical landing follows. Whole accepted7 evidence survives before changes. Sorted/copy numeric-kind13 is the next P1 repair; deferred count/first10, registered sorted/ordinary length11 and deferred indexed-write12 follow before enumeration. No dirty pivot or complete pipeline/reference admission.

October21 type-reference direction: [TYPE-REFERENCE-BOOK](docs/tasks/TYPE-REFERENCE-BOOK.md) retains completed model/evaluated-value/scoped/numeric/drop/aggregate work. Finish9 and the owned bounded follow-ups, then operation/spelling inventory1, book mapping2 and independent layout3. Legacy metadata8 and private metadata QA remain owned; complete per-type references and coverage closeout remain pending.
'''+text[end:]
    text=after['MEMORY.md'];lines=text.splitlines()
    lines=[('- next_action: Finish pipeline9 book/permanent/direct checks, source-closed publication and exact staged canonical CI, then normal commit/empty brief/clean check. Next clean leaf is P1 kind13, followed by10/11/12 before inventory1.' if line.startswith('- next_action:') else '- in_flight_uncommitted: Pipeline9 runtime, complete proof epochs, follow-up ownership, permanent/book/fact work. Accepted source and all six faults are restored. No runtime mutant is active.' if line.startswith('- in_flight_uncommitted:') else line) for line in lines]
    after['MEMORY.md']='\n'.join(lines)+'\n'
    text=after['LIVE_ACHIEVEMENT_STATUS.md'];start=text.index('## Current Activity\n');end=text.index('## Latest Completed Slice\n',start)
    text=text[:start]+'## Current Activity\n\nTYPE-REFERENCE-BOOK.1.2.9 is in verification: callable sorted/take, fixed85/41 accepted RED/six restored faults. P1 sorted/copy kind13 follows its clean landing;10/11/12 precede inventory.\n\n'+text[end:]
    start=text.index('## Next Action\n');end=text.index('## Recent Completions\n',start)
    after['LIVE_ACHIEVEMENT_STATUS.md']=text[:start]+'## Next Action\n\nFinish9 book/permanent/direct checks and source-closed publication, then exact staged canonical CI and the normal commit workflow. Clear the brief and verify clean Git before activating13. Full PNT continues; no push yet.\n\n'+text[end:]
    c.write_new('metadata-change.json.gz',dict(before=before,after={p:c.encode(t.encode()) for p,t in after.items()},producer=c.read(c.PREFIX+'metadata.py'),first_writer=c.read(c.PREFIX+'metadata-first.py'),first_result='First writer failed its pre-write fact-size assertion; no tracked source mutation. Compact current prose within the same existing budget.'))
    for p,t in after.items():(c.ROOT/p).write_text(t)
    print('Four follow-ups owned/scheduled; canonical fact bounded; task',len(after[task].encode()),'bytes')

if __name__=='__main__':main()
