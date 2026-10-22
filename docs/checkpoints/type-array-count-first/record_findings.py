"""Own measured count/first kind guards and the separate deferred-last gap."""
import json
import re
import common as c
import context


def main():
    observed = c.load('contract-grid-observed.json.gz')
    assert observed['inputs_unchanged'] and observed['run']['returncode'] == 0
    value = json.loads(c.decode(observed['run']['stdout_base64']))
    rows = {row['id']:row for row in value['rows']}
    for helper,neutral in (('count',0),('first',None)):
        free = rows['ordinary/'+helper+'/free/harray']
        receiver = rows['ordinary/'+helper+'/receiver/harray']
        assert 'Not an ARRAY reference' in free['native']['runtime_detail']['text']
        assert 'Not an ARRAY reference' in free['generated']['exception']['fields']['detail']
        for route in ('native','generated'):
            item = receiver[route]
            assert item['value'] == neutral and item['completed']
            assert not item['warnings'] and not item['last_error'] and not item['exception']
        assert 'defined($__ls_'+helper+')' in free['native']['dump']
        assert "ref($__ls_"+helper+") eq 'ARRAY'" not in free['native']['dump']
    for style in ('free','receiver'):
        ordinary = rows['ordinary/sentinel/last/'+style]
        deferred = rows['deferred/sentinel/last/'+style]
        for route in ('native','generated'):
            assert type(ordinary[route]['value']) is int and ordinary[route]['value'] == 1
            assert not ordinary[route]['warnings'] and not ordinary[route]['last_error'] and not ordinary[route]['exception']
        native = deferred['native']['runtime_detail']
        generated = deferred['generated']['exception']['fields']
        assert native['class'] == 'LinkedSpec::CodeblockRuntime::Error'
        assert native['fields']['code'] == generated['detail']['code'] == 'unknown_helper'
        assert native['fields']['name'] == generated['detail']['name'] == 'last'
    paths = ['docs/tasks/TYPE-REFERENCE-BOOK.md','MEMORY.md','ROADMAP_V2.md',
        'LIVE_ACHIEVEMENT_STATUS.md','docs/TASK_TREE.md',
        'docs/knowledge/terse-type-method-surface-inventory.md',
        'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md','KNOWLEDGE_MAP.md']
    supplied = context.snapshot()
    c.write_new('findings-inputs.json.gz',supplied)
    before = {path:c.read(path) for path in paths}
    text = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    tree = text[paths[0]]
    tree = tree.replace('Goal: Execute deferred count/first array receiver helpers.',
        'Goal: Execute deferred count/first and align their free harray kind guards.',1)
    tree = tree.replace('CodeblockRuntime count/first dispatch, permanent consumers, worked book/fact and continuity.',
        'CodeblockRuntime count/first dispatch and MethodLowering free-call array guards, permanent consumers, worked book/fact and continuity.',1)
    old = '- [ ] **ROOT CAUSE (WHY + WHERE)** — Get dump invokes CodeblockRuntime; identify the missing helper dispatch and accepted argument/continuation contract before edits.'
    new = '- [x] **ROOT CAUSE (WHY + WHERE)** — Public Get dumps and CodeblockRuntime::_eval_call/::_eval_fluent_chain show missing count/first dispatch. MethodLowering free harray count/first dereferences defined values without an ARRAY guard; accepted receiver forms give0/undef. The grid independently fixes terminal/arity/effect behavior.'
    assert tree.count(old) == 1
    tree = tree.replace(old,new,1)
    marker = '  Schedule: Finish10 before11/12, then inventory1/mapping2/layout3. Detailed proof lives in the checkpoint.\n'
    assert tree.count(marker) == 1
    tree = tree.replace(marker,marker+'  Additional defect owned/fixed here: ordinary count(items)/first(items), with items={"k":"v"}, leaks raw Not an ARRAY reference in native/fresh execution. Match the already quiet receiver0/undef and scalar/undefined controls with narrow array-kind guards.\n',1)
    node = '''- ID: `TYPE-REFERENCE-BOOK.1.2.14`
  Status: `pending` / P2 defect owned
  Goal: Execute deferred last array selectors.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.12`
  Reproduce/impact: Leaf10 contract-grid retains ordinary last(items)/items.last() returning1 for [2,10,1], while both deferred native/fresh routes report typed unknown_helper:last. Source bodies and loaded source identities survive in docs/checkpoints/type-array-count-first/.
  Schedule: After11/12, before inventory1. Establish shape, kind, empty, terminal/effect and copy/index controls; do not extend current10.
  Planned tier: `canonical`
  Claim verification: none: Pending repair; actual source-bound intake belongs to10, with no last admission.

'''
    marker = '- ID: `TYPE-REFERENCE-BOOK.1.2.1`'
    assert tree.count(marker) == 1 and '- ID: `TYPE-REFERENCE-BOOK.1.2.14`' not in tree
    tree = tree.replace(marker,node+marker,1)
    start = tree.index(marker)
    end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.2`',start)
    section = tree[start:end]
    assert 'Dependencies: `TYPE-REFERENCE-BOOK.1.2.12`' in section
    section = section.replace('Dependencies: `TYPE-REFERENCE-BOOK.1.2.12`',
        'Dependencies: `TYPE-REFERENCE-BOOK.1.2.14`',1)
    tree = tree[:start]+section+tree[end:]
    old = '`TYPE-REFERENCE-BOOK.1.2.12`, `TYPE-REFERENCE-BOOK.1.2.1`'
    assert tree.count(old) == 1
    tree = tree.replace(old,'`TYPE-REFERENCE-BOOK.1.2.12`, `TYPE-REFERENCE-BOOK.1.2.14`, `TYPE-REFERENCE-BOOK.1.2.1`',1)
    start,end = tree.index('## Current Frontier'),tree.index('## Decisions')
    section = tree[start:end]
    lines = section.splitlines()
    at = next(index for index,line in enumerate(lines) if '| `TYPE-REFERENCE-BOOK.1.2.12` |' in line)
    lines.insert(at+1,'| 0 | `TYPE-REFERENCE-BOOK.1.2.14` | `pending` | Deferred last after12; complete the owned selector gap before inventory. |')
    order = 0
    for index,line in enumerate(lines):
        if re.match(r'^\| \d+ \|',line):
            order += 1
            lines[index] = re.sub(r'^\| \d+ \|','| '+str(order)+' |',line,count=1)
    tree = tree[:start]+'\n'.join(lines)+'\n\n'+tree[end:]
    text[paths[0]] = tree
    memory = text['MEMORY.md']
    memory = re.sub(r'^- next_action:.*$',
        '- next_action: Declare the fixed count/first plan from the observed terminal/kind/effect contract, retain independent length/index controls, then repair only CodeblockRuntime dispatch and MethodLowering free harray guards.',memory,flags=re.M)
    memory = memory.replace('Leaf10 custody/intake and active metadata only; runtime and book behavior are unchanged.',
        'Leaf10 custody/contract grid and active metadata; runtime remains unchanged.')
    memory = memory.replace('11 registered sorted/ordinary length and12 deferred indexed writes remain separate. Then inventory1',
        '11 registered sorted/ordinary length,12 deferred indexed writes and14 deferred last remain separate. Then inventory1')
    text['MEMORY.md'] = memory
    text['ROADMAP_V2.md'] = text['ROADMAP_V2.md'].replace('Then11/12 before inventory;',
        'Then11/12/14 before inventory;',1).replace('the owned11/12 repairs','the owned11/12/14 repairs',1)
    text['LIVE_ACHIEVEMENT_STATUS.md'] = text['LIVE_ACHIEVEMENT_STATUS.md'].replace(
        '11/12 remain next before inventory.','11/12/14 remain next before inventory.',1)
    text['docs/TASK_TREE.md'] = text['docs/TASK_TREE.md'].replace(
        'Then11/12 before inventory1','Then11/12/14 before inventory1',1)
    fact = text['docs/knowledge/terse-type-method-surface-inventory.md']
    fact = fact.replace('which task owns deferred count first indexed writes and registered sorted',
        'which task owns deferred last count first indexed writes and registered sorted',1)
    fact = fact.replace('12 deferred indexed writes.','12 deferred indexed writes;14 last.',1)
    text['docs/knowledge/terse-type-method-surface-inventory.md'] = fact
    book = text['docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md']
    old = 'deferred `.count()` and `.first()` are not yet supported.'
    assert book.count(old) == 1
    text['docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'] = book.replace(
        old,'deferred `.count()`, `.first()`, and `.last()` are not yet supported.',1)
    for path,value in text.items():
        if path != 'KNOWLEDGE_MAP.md':
            c.source(path).write_text(value)
            c.source(path).chmod(before[path]['mode'])
    knowledge = c.run(['bash','knowledge-map/scripts/gen_knowledge_map.sh'])
    c.write_new('findings.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
        knowledge=knowledge,scope='Same-family free harray guard defect joins10 before code changes. Confirmed last gap is separately owned14 after12 and before inventory; current repair remains count/first.'))
    assert knowledge['returncode'] == 0
    print('Free harray guards owned10; deferred last owned14 after12; fixed contract next, runtime unchanged')


if __name__ == '__main__':
    main()
