"""Fix final policy/effect controls before runtime writes; preserve discovery epochs."""
import json
import common as c


def main():
    rows=[]
    values={'sum':12,'avg':4,'median':3,'range':7,'min':1,'max':8}
    for source in c.load('cases.json')['cases']:
        row=dict(source)
        name=row['id'].split('/')[1]
        suffix=row['id'].split('/')[-1]
        row.pop('observation_only',None)
        if 'expected' not in row:
            row['expected']=(0 if name=='sum' else None) if suffix=='empty' else (
                values[name] if suffix in ('strings','once') else None)
        if suffix=='strings' and row['id'].startswith('deferred/') and name in ('min','max','median'):
            # Selected original string terms remain owned by result-kind repair95.
            row['expected']=str(values[name])
        if suffix in ('once','receiver-arity'):
            expression=(name+'(tick())') if suffix=='once' else ('items.'+name+'(tick())')
            prefix='items = [3,1,8]; trace = ""; tick = {|| trace = cat(trace,"x"); return([3,1,8]) }; '
            row['body']=prefix+('out = '+expression+'; ' if row['id'].startswith('ordinary/') else
                'cb = {|| return('+expression+') }; out = cb(); ')+'return([out,trace])'
            row['expected']=[values[name],'x'] if suffix=='once' else [None,'']
        if row['id']=='deferred/chain':
            row.pop('expected')
            row['error']=dict(code='unknown_helper',name='sorted')
            row['repair_owner']='TYPE-REFERENCE-BOOK.1.2.9'
        rows.append(row)
    for name,value in values.items():
        for scope in ('ordinary','deferred'):
            expression=name+'(items)'
            evaluation='return('+expression+')' if scope=='ordinary' else (
                'cb = {|items| return('+expression+') }; return(cb(items))')
            rows.append(dict(id=scope+'/'+name+'/captures',pattern='/([0-9]+),([0-9]+),([0-9]+)/',
                input='3,1,8',body='items = [entry_group(0),entry_group(1),entry_group(2)]; '+evaluation,
                expected=str(value) if name in ('min','max','median') else value))
            rows.append(dict(id=scope+'/'+name+'/typed-boolean',body=
                'items = [and(1,1),3]; '+evaluation,expected=dict(sum=4,avg=2,median=2,range=2,min=True,max=3)[name]))
        for mode,expression,expected in (
            ('invalid-arity',name+'(tick(),tick())' if name not in ('min','max') else name+'()', [None,'']),
            ('terminal-effect','read().'+name+'().cat(tick())',[None,''])):
            rows.append(dict(id='deferred/'+name+'/'+mode,body='trace = ""; '
                'read = {|| trace = cat(trace,"r"); return([3,1,8]) }; '
                'tick = {|| trace = cat(trace,"x"); return([3,1,8]) }; '
                'cb = {|| return('+expression+') }; out = cb(); return([out,trace])',expected=expected))
    rows.append(dict(id='deferred/registered-name',functions='fn sum(items) { return(99) }\n',
        body='cb = {|| return(sum([3,1,8])) }; return(cb())',expected=99))
    rows.append(dict(id='deferred/binding-precedence',body='sum = {|| return(99) }; '
        'cb = {|| return(sum([3,1,8])) }; return(cb())',expected=12))
    assert len(rows)==len({row['id'] for row in rows})
    c.write_new('final-cases.json',dict(cases=rows,scope='Fixed before production writes. '
        'Legacy aggregate decimal validation and selected result kinds stay distinct from scalar ADR0029. '
        'Capture/string kind defect95 and missing sorted pipeline9 have explicit owners.'))
    path=c.PREFIX+'probe.pl'
    before=c.read(path)
    raw=c.decode(before['base64']).decode()
    old='my $source = ($case->{functions} // \'\') . "Top: /x/\\n I { $case->{body} }\\n";'
    new='my $source = ($case->{functions} // \'\') . "Top: " . ($case->{pattern} // \'/x/\') . "\\n I { $case->{body} }\\n";'
    assert raw.count(old)==1
    after=raw.replace(old,new).replace("my $input = 'x';","my $input = $case->{input} // 'x';")
    c.write_new('final-preparation.json.gz',dict(probe_before=before,probe_after_base64=c.encode(after.encode()),
        cases_before=c.read(c.PREFIX+'cases.json'),
        scope='Original176 raw/value oracle remain intact. Add documented dump flag, pattern/input controls '
              'and explicit side effects; final fixture does not rewrite any accepted observation.'))
    (c.ROOT/path).write_text(after)
    print('Final fixed plan:',len(rows),'cases; 95 and new pipeline9 qualified')


if __name__=='__main__':main()
