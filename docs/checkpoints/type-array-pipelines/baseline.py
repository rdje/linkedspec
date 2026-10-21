"""Fix public probes before changing either execution owner."""
import json
import common as c

def main():
    rows=[]
    expressions={
      'sorted/free':'sorted(items)', 'sorted/receiver':'items.sorted()',
      'sorted/empty':'sorted([])', 'sorted/scalar':'sorted(3)',
      'sorted/missing':'sorted()', 'sorted/excess':'sorted(items,1)',
      'sorted/receiver-extra':'items.sorted(1)',
      'take/free':'take(items,2)', 'take/receiver':'items.take(2)',
      'take/default':'take(items)', 'take/receiver-default':'items.take()',
      'take/empty':'take([],2)', 'take/scalar':'take(3,2)',
      'take/zero':'take(items,0)', 'take/negative':'take(items,-1)',
      'take/fraction':'take(items,1.9)', 'take/large':'take(items,99)',
      'take/null':'take(items,undef)', 'take/text':'take(items,"bad")',
      'take/string-count':'take(items,"2")', 'take/missing':'take()',
      'take/excess':'take(items,2,9)', 'take/receiver-extra':'items.take(2,9)',
      'chain/reducer':'items.sorted().take(2).sum()',
      'chain/nested':'sum(take(sorted(items),2))',
      'chain/count':'items.sorted().take(2).count()',
      'chain/first':'items.sorted().take(2).first()',
      'chain/terminal':'items.sorted().take(2).sum().abs()',
    }
    for name,expr in expressions.items():
        for scope in ('ordinary','deferred'):
            inner='return('+expr+')'
            body='items = [2,10,1]; '+(inner if scope=='ordinary' else 'cb = {|| '+inner+' }; return(cb())')
            rows.append(dict(id=scope+'/'+name,body=body))
    plan=dict(cases=rows,scope='Public diagnostic observations; lexical expected sorted order [1,10,2], first two sum11. No new count policy inferred before ordinary source inspection.')
    c.write_new('baseline-plan.json',plan)
    run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    c.write_new('baseline-run.json.gz',dict(run=run,producer=c.read(c.PREFIX+'baseline.py'),probe=c.read(c.PREFIX+'probe.pl'),plan=c.read(c.PREFIX+'baseline-plan.json'),source={p:c.read(p) for p in (c.SOURCE,'perl/LinkedSpec/ActionIR/MethodLowering.pm')}))
    assert run['returncode']==0
    data=json.loads(c.decode(run['stdout_base64']))
    for row in data['rows']:
        print(row['id'],json.dumps(row['native']['value']),json.dumps(row['native']['runtime_detail']), 'warnings',row['native']['warnings'])
    selected={row['id']:row['generated']['source'] for row in data['rows'] if row['id'] in ('ordinary/sorted/free','ordinary/take/free','ordinary/take/receiver-extra','deferred/chain/reducer')}
    c.write_new('public-lowering.json.gz',selected)
    for name,source in selected.items():
        print('PUBLIC SOURCE',name)
        for line in source.splitlines():
            if any(key in line for key in ('__ls_take','__ls_sorted','sub Execute','unknown_helper','$items =','invalid_fluent')):
                print(line[:8000])

if __name__=='__main__':main()
