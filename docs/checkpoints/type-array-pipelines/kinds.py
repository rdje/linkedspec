"""Investigate the observed kind discrepancy through public values and independent B flags."""
import json
import common as c

def main():
    cases=[]
    for scope in ('ordinary','deferred'):
        for name,body,path in (
            ('sort','return(sorted([2,10,1]))',[]),
            ('sort-outer','out = sorted([2,10,1]); return([out])',[0]),
            ('control','return([1,10,2])',[]),
            ('index','out = sorted([2,10,1]); return(out[0])',[])):
            statement=body if scope=='ordinary' else 'cb = {|| '+body+' }; return(cb())'
            if name=='index':
                statement='index = sorted([2,10,1])[0];' if scope=='ordinary' else 'cb = {|| '+body+' }; index = cb();'
                if scope=='ordinary':statement='out = sorted([2,10,1]); index = out[0];'
                statement+=' target = ["zero","one","two"]; target[index] = "changed"; return(target)'
            cases.append(dict(id=scope+'/'+name,body=statement,path=path))
    inputs={p:c.read(p) for p in [c.PREFIX+'kinds.py',c.PREFIX+'kinds.pl',c.SOURCE,'perl/LinkedSpec/BindingRuntime.pm']}
    run=c.run(['perl','-Iperl',c.PREFIX+'kinds.pl'],input=json.dumps(dict(cases=cases)).encode())
    c.write_new('kind-investigation2.json.gz',dict(plan=dict(cases=cases),inputs=inputs,run=run))
    assert run['returncode']==0
    rows=json.loads(c.decode(run['stdout_base64']))['rows']
    for row in rows:print(json.dumps(row,sort_keys=True))

if __name__=='__main__':main()
