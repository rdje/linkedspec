"""Close the preserved draft with the separately verified historical admission."""
import common as c
import context
import review


def proof(result):
    return (f"{result['cases']} fixed cases/{result['accepted_red']} accepted RED/"
        f"{result['accepted_controls']} controls;{len(result['faults'])} restored source faults;"
        f"{result['direct_suites']}/{result['direct_tap']} TAP;history{result['historical_controls']};"
        f"book{result['book_inputs']}/{result['book_examples']} and actual heading RED")


def main():
    result = review.check(fresh=False)
    draft = c.load('final-docs.json.gz')
    old,new = proof(draft['result']),proof(result)
    paths = list(draft['after'])
    before = {path:c.read(path) for path in paths}
    c.write_new('final-docs2-inputs.json.gz',context.snapshot())
    values = {path:c.decode(packet['base64']).decode().replace(old,new)
        for path,packet in draft['after'].items()}
    tree = c.decode(before['docs/tasks/TYPE-REFERENCE-BOOK.md']['base64']).decode().replace(old,new)
    tree = tree.replace('- Status: `active` / final count/first .1.2.10 admission; before enumeration',
        '- Status: `active` / next registered pipeline .1.2.11; before enumeration',1)
    start,end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.10`'),tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.11`')
    leaf = tree[start:end].replace('Status: `active` / final Phase0 guard-golden/inverse admission',
        'Status: `done` / selected proof; exact canonical admission required',1)
    leaf = leaf.replace('Distinct final doc2 proof','Distinct final doc3 proof',1)
    p = result['phase0']
    leaf += (f"  Final historical admission verified: {p['selected']} real Phase0 roots reject old expectations and pass all{p['goldens']} guard corrections;{p['skipped']} roots explicitly skipped. "
        f"The complete historical audit preserves{p['previous']} older controls and adds{p['added']}={p['current']} denials. Actual inverse removal and table-byte/hash-check faults reject, admit under bypass, and restore exactly. "
        'The original unpublished draft1 remains whole and independently recoverable; publication2 governs this resulting tree. Older inverse tables and runtime producer bytes remain exact.\n\n')
    tree = tree[:start]+leaf+tree[end:]
    tree = tree.replace('| `TYPE-REFERENCE-BOOK.1.2.10` | `active` | Final ten Phase0 source-golden and exact historical inverse admission; draft1 preserved. |',
        '| `TYPE-REFERENCE-BOOK.1.2.10` | `done` |232/107 RED/eight faults; ten Phase0 goldens/history680; book/finite history0137; canonical admission mandatory. |',1)
    values['docs/tasks/TYPE-REFERENCE-BOOK.md'] = tree
    values['MEMORY.md'] = values['MEMORY.md'].replace('- custody:',
        '- historical: Ten Phase0 guard corrections pass three selected real roots with explicit skips. All650 older audit controls survive;30 new controls and actual inverse/hash-check faults pass. Unpublished draft1 remains whole; publication2 owns the final tree.\n- custody:',1)
    values[c.PREFIX+'README.md'] += '''
The first publication was an unpublished review draft. Before editing any bound
Phase0 source, draft1.json.gz preserved its whole11015-input closure, full modes,
claim/publication/instrument and an actual readonly0 observation. It never
represents an accepted Git revision. Original publication.json and its manifest
remain immutable; publication2.json and its manifest govern the final candidate.

Ten stale Phase0 generated-source goldens (eight count/two first) reject all three
selected real roots, then pass after literal guard repairs. Other roots are
explicit skips; only canonical CI establishes complete Phase0 admission. A
separate hash-gated inverse restores real a8bd8620a source before unchanged older
layers; every previous650 historical control keeps its original source stage.
Ten hunks add omission/duplication/corruption controls:680 actual denials total.
The new table is an explicit driver input. Actual inverse-call removal rejects;
an inert table byte rejects, a real hash-check bypass admits it, and exact
restoration restores both rejection and healthy observations. This is current
historical evidence integrity, never a replay of historical runtime producers.
'''
    for path,value in values.items():
        c.source(path).write_text(value)
        c.source(path).chmod(before[path]['mode'])
    c.write_new('final-docs2.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
        result=result,scope='Intended clean post-landing handoff. Exact staged canonical receipt and normal hooks govern admission. Earlier draft and all historical sources remain retained. No book/card/history member changes here.'))
    print('Final continuity aligned:',new)


if __name__ == '__main__':
    main()
