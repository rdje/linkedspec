"""Own actual public defects and keep the task root within its existing budget."""
import re
import common as c


def main():
    paths=['docs/tasks/TYPE-REFERENCE-BOOK.md','docs/TASK_TREE.md','MEMORY.md',c.PREFIX+'README.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    task=paths[0]
    tree=after[task]
    old=next(line for line in tree.splitlines() if line.startswith('  Impact extension before runtime writes:'))
    tree=tree.replace(old,'  Impact extension: Full original evaluated-value intake and rejected alias/kind oracles remain in type-evaluated-values/ and accepted efad62 task bytes; numeric5 and boolean35 retain separate ownership.',1)
    start=tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.7`\n')
    end=tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.1`\n',start)
    node=tree[start:end]
    node=node.replace('  Verification tier: `focused`','  Verification tier: `canonical`')
    node=node.replace('  Canonical trigger: Escalate for contract/infrastructure changes or cross-cutting uncertainty.',
        '  Canonical trigger: Public callback availability and emitted invalid-shape diagnostics; exact staged receipt.')
    node=node.replace('  Acceptance Checklist','  Intake: baseline176/dump3 retain42 deferred and6 ordinary arity failures; fix dispatch/shapes here. Next9 owns sorted. Rejected instruments and exact sources survive in the checkpoint.\n  Acceptance Checklist',1)
    node+='''- ID: `TYPE-REFERENCE-BOOK.1.2.9`
  Status: `pending` / P2 defect owned
  Goal: Execute deferred sorted/take aggregate pipelines.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.7`
  Reproduce/impact: items.sorted().take(2).sum() yields4 for [3,1,8] outside; deferred raises unknown_helper:sorted. Source/error: type-aggregate-codeblocks/inspection.json.gz.
  Schedule: Next after7, before inventory1. Fix supported sorted/take contracts with arity/effect/kind/terminal controls and worked book examples.
  Planned tier: `canonical`
  Claim verification: none: Intake only; bind actual producer/inputs before repair measurement.

'''
    tree=tree[:start]+node+tree[end:]
    tree=tree.replace('  Dependencies: `TYPE-REFERENCE-BOOK.1.2.7`\n  Planned tier: `focused`; reclassify before public/mechanical movement.',
        '  Dependencies: `TYPE-REFERENCE-BOOK.1.2.9`\n  Planned tier: `focused`; reclassify before public/mechanical movement.',1)
    marker='| 6 | `TYPE-REFERENCE-BOOK.1.2.1`'
    pos=tree.index(marker)
    end=tree.index('\n## Decisions',pos)
    frontier=tree[pos:end]
    frontier=re.sub(r'^\| (\d+) \|',lambda match:'| '+str(int(match[1])+1)+' |',frontier,flags=re.M)
    tree=tree[:pos]+'| 6 | `TYPE-REFERENCE-BOOK.1.2.9` | `pending` | Owned deferred sorted/take pipeline after7. |\n'+frontier+tree[end:]
    assert len(tree.encode())<=65536,len(tree.encode())
    after[task]=tree
    after['docs/TASK_TREE.md']=after['docs/TASK_TREE.md'].replace(
        'Deferred aggregates7 precedes inventory1/book mapping2/layout3/legacy8;',
        'Aggregates7 then owned deferred pipeline9 precedes inventory1/book mapping2/layout3/legacy8;',1)
    after['MEMORY.md']=after['MEMORY.md'].replace(
        'Bind the complete aggregate authority and fixed public accepted baseline through descriptor/Get/dump/fresh routes before inspecting the tool-identified runtime owner. Then implement only deferred availability/overloads with bounded effect/kind controls.',
        'Finish final accepted baseline214, then apply aggregate dispatch/terminal/arity repair and verify source faults, direct consumers, book and canonical candidate. Pipeline9 is owned next; do not pivot dirty.')
    after['MEMORY.md']=after['MEMORY.md'].replace(
        'Aggregate7 preservation/activation metadata; no production change or mutant.',
        'Aggregate7 public baseline176/dump3 captured; final214 accepted run in flight. No production change or mutant.')
    after['MEMORY.md']=after['MEMORY.md'].replace('aggregate7 -> inventory','aggregate7 -> pipeline9 -> inventory')
    after[c.PREFIX+'README.md']+='''
Public baseline:176 cases retain42 deferred fixed-value failures and6 ordinary
receiver-arity failures. The initial probe omitted dump_parser_source; its failed
review and corrected independent dump3 epoch are retained, as is a rejected
global quietness assumption. No accepted observations are rewritten. Final214
fixtures add visible effect/capture/kind controls before runtime writes.

Owned repair7: missing aggregate dispatch/array overloads and invalid aggregate
receiver shapes that fall through to raw host calls. Owned next9: sorted/take
inside a deferred aggregate pipeline, reproduced as unknown_helper:sorted.
Ordinary Perl validates every term with its legacy decimal-looking regexp;
sum([]) is0 and other empty reducers return undef. The card's generic-filter
paragraph describes Rust, not a Perl aggregate authority. Selected capture-string
results remain95; do not claim homogeneous JSON kinds from literal-only probes.
'''
    c.write_new('planning.json.gz',dict(before=before,after={path:c.encode(raw.encode()) for path,raw in after.items()},
        producer=c.read(c.PREFIX+'plan_repairs.py'),scope='Current7 owns intake and bounded arity repair; '
        'new9 owns reproduced pipeline defect and is scheduled next. Prior3 narrative compaction retains '
        'whole before bytes and accepted Git; no budget is raised or other formal declaration changed.'))
    for path,raw in after.items():(c.ROOT/path).write_text(raw)
    print('Owned7/next9; task bytes',len(tree.encode()),'; canonical candidate required')


if __name__=='__main__':main()
