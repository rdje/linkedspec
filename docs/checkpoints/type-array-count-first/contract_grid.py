"""Observe the public contract grid before choosing the bounded helper repair."""
import json
from pathlib import Path
import common as c
import context


def plan():
    cases = []
    def add(name,setup,expression,mode):
        body = setup+' '
        if mode == 'deferred':
            body += 'cb = {|| return('+expression+') }; return(cb());'
        else:
            body += 'return('+expression+');'
        cases.append(dict(id=mode+'/'+name,body=body))
    kinds = {
        'integers':'[2,10,1]', 'strings':'["b","a"]', 'null-first':'[undef,2]',
        'nested-array':'[[2,1],3]', 'nested-harray':'[{"k":"v"},3]',
        'booleans':'[true,false]', 'empty':'[]', 'undefined':'undef',
        'number':'7', 'text':'"abc"', 'harray':'{"k":"v"}',
    }
    for mode in ('ordinary','deferred'):
        for helper in ('count','first'):
            for style in ('free','receiver'):
                for kind,value in kinds.items():
                    expression = helper+'(items)' if style == 'free' else 'items.'+helper+'()'
                    add(helper+'/'+style+'/'+kind,'items = '+value+';',expression,mode)
            add(helper+'/free/no-args','',helper+'()',mode)
            add(helper+'/free/extra-arg','items = [2,10,1];',helper+'(items,9)',mode)
            add(helper+'/receiver/extra-arg','items = [2,10,1];','items.'+helper+'(9)',mode)
        for name,expression in {
            'count/free/abs':'count(items).abs()',
            'count/receiver/abs':'items.count().abs()',
            'count/free/comparison':'count(items).gt(0)',
            'count/receiver/comparison':'items.count().gt(0)',
            'first/free/cat':'first(items).cat("!")',
            'first/receiver/cat':'items.first().cat("!")',
        }.items():
            add(name,'items = [2,10,1];',expression,mode)
        for style,expression in (('free','first(items).sorted()'),('receiver','items.first().sorted()')):
            add('first/'+style+'/array-continuation','items = [[2,10,1],[]];',expression,mode)
        setup = 'seen = ""; items = [2,10,1]; tap = {|tag,value| seen = cat(seen,tag); return(value) };'
        for helper in ('count','first'):
            for name,call in {
                'free/once':helper+'(tap("r",items))',
                'receiver/once':'tap("r",items).'+helper+'()',
                'free/extra':helper+'(tap("a",items),tap("b",9))',
                'receiver/extra':'tap("r",items).'+helper+'(tap("a",9))',
                'receiver/continuation':'tap("r",items).'+helper+'().abs()',
            }.items():
                add(helper+'/effects/'+name,setup,'['+call+',seen]',mode)
        # Adjacent documented selector sentinel, observed without expanding the
        # current repair: classify and own a confirmed gap separately.
        add('sentinel/last/free','items = [2,10,1];','last(items)',mode)
        add('sentinel/last/receiver','items = [2,10,1];','items.last()',mode)
    return dict(cases=cases,scope='Observation-only grid; independent accepted contract and final fixed expectations follow. No runtime or oracle repair occurs here.')


def main():
    selected = plan()
    c.write_new('contract-grid-cases.json',selected)
    supplied = context.snapshot()
    c.write_new('contract-grid-inputs.json.gz',supplied)
    run = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(selected).encode())
    stable = c.unchanged(supplied['inputs'])
    c.write_new('contract-grid-observed.json.gz',dict(run=run,inputs_unchanged=stable))
    assert stable and run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    observed = json.loads(c.decode(run['stdout_base64']))
    assert [row['id'] for row in observed['rows']] == [case['id'] for case in selected['cases']]
    loaded = {}
    for path in ['perl/LinkedSpec.pm']+c.SOURCES:
        key = path.removeprefix('perl/')
        assert Path(observed['inc'][key]).resolve() == c.ROOT/path
        loaded[path] = c.identity(path)
        assert loaded[path] == supplied['inputs'][path]
    c.write_new('contract-grid-result.json.gz',dict(cases=len(selected['cases']),loaded_sources=loaded,
        inputs_unchanged=stable,scope=selected['scope']))
    print('Public pre-change contract grid retained:',len(selected['cases']),'cases; actual loaded bytes and supplied inputs unchanged')


if __name__ == '__main__':
    main()
