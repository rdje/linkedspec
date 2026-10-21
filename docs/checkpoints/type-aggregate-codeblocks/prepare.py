"""Fix aggregate fixtures and public instruments before accepted-baseline execution."""
import json
import common as c


def main():
    rows=[]
    families={'sum':12,'avg':4,'median':3,'range':7,'min':1,'max':8}
    def pair(name,expression,expected=None,*,prefix='',functions='',observe=False):
        for scope in ('ordinary','deferred'):
            body=prefix+('return('+expression+')' if scope=='ordinary' else
                'cb = {|| return('+expression+') }; return(cb())')
            row=dict(id=scope+'/'+name,body=body,functions=functions)
            row['observation_only' if observe else 'expected']=True if observe else expected
            rows.append(row)
    for name,value in families.items():
        for spelling,expression in (
            ('canonical','num_'+name+'([3,1,8])'),
            ('alias',name+'([3,1,8])'),
            ('receiver','items.'+name+'()')):
            pair(name+'/'+spelling,expression,value,prefix='items = [3,1,8]; ')
        pair(name+'/direct','num_'+name+'(document["items"])',value,
            prefix='document = {"items":[3,1,8]}; ')
        pair(name+'/function',name+'(supply())',value,
            functions='fn supply() { return([3,1,8]) }\n')
        pair(name+'/empty',name+'([])',observe=True)
        pair(name+'/wrong-kind',name+'(3)',observe=True)
        pair(name+'/mixed',name+'([3,"1","bad",undef,8])',observe=True)
        pair(name+'/strings',name+'(["3","1","8"])',observe=True)
        pair(name+'/receiver-arity','items.'+name+'(tick())',None,
            prefix='items = [3,1,8]; trace = ""; tick = {|| trace = cat(trace,"x"); return(1) }; ')
        pair(name+'/terminal','items.'+name+'().abs()',None,prefix='items = [3,1,8]; ')
        pair(name+'/once',name+'(tick())',observe=True,
            prefix='trace = ""; tick = {|| trace = cat(trace,"x"); return([3,1,8]) }; ')
    pair('chain','items.sorted().take(2).sum()',4,prefix='items = [3,1,8]; ')
    pair('parameter','summarize([3,1,8])',[12,4,3,7,1,8],functions=
        'fn summarize(items) { return([sum(items),avg(items),median(items),range(items),min(items),max(items)]) }\n')
    pair('scalar-min','min(3,1)',1)
    pair('scalar-max','max(3,8)',8)
    pair('scalar-chain','score.abs().ceil().add(2)',6,prefix='score = -3.2; ')
    pair('nested','add(sum([3,1,8]),max([3,1,8]))',20)
    for name in ('sum','avg','median','range','min','max'):
        pair(name+'/no-args',name+'()',observe=True)
        if name not in ('min','max'):
            pair(name+'/excess',name+'([3,1,8],[2])',observe=True)
    assert len(rows)==len({row['id'] for row in rows})
    c.write_new('cases.json',dict(cases=rows,scope='Accepted baseline first; fixed numeric values derive '
        'from [3,1,8]. Empty/kind/string/effect policy remains observation-only until reconciled with '
        'ordinary public behavior. Scalar ADR0029 does not define these aggregates.'))
    source=(c.ROOT/'docs/checkpoints/type-numeric-codeblocks/probe.pl').read_text()
    source=source.replace('numeric-codeblocks.spec','aggregate-codeblocks.spec').replace(
        'NumericCodeblockProbe','AggregateCodeblockProbe')
    source=source.replace('$emitted, $diagnostics);','$emitted, $diagnostics, $dump);')
    source=source.replace('my $parser = LinkedSpec::Get(\\$source, runtime_ctx_ref => \\%context);',
        'my $parser = LinkedSpec::Get(\\$source, runtime_ctx_ref => \\%context, parser_source_ref => \\$dump);')
    source=source.replace('defined($emitted) ? (source => $emitted) : (),',
        'defined($emitted) ? (source => $emitted) : (),\n            defined($dump) ? (dump => $dump) : (),')
    assert 'parser_source_ref => \\$dump' in source
    with (c.ROOT/(c.PREFIX+'probe.pl')).open('x') as output:output.write(source)
    context=(c.ROOT/'docs/checkpoints/type-drop-generated/context.py').read_bytes()
    with (c.ROOT/(c.PREFIX+'context.py')).open('xb') as output:output.write(context)
    print('Fixed aggregate plan:',len(rows),'cases; numeric oracle precedes baseline; observations explicit')


if __name__=='__main__':main()
