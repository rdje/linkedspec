"""Correct fixtures from exact lowering; retain the rejected first epoch whole."""
import common as c

def main():
    plan=c.load('cases.json');before=c.read(c.PREFIX+'cases.json')
    result=[]
    for case in plan['cases']:
        name=case['id']
        if '/function/parameter' in name or name=='ordinary/chain/length':continue
        if name.endswith('sorted/copy'):
            case['body']=case['body'].replace('[2,10,1]','["b","a","c"]').replace('push(out,9)','out[0] = "z"')
            case['expected']=[['b','a','c'],['z','b','c']]
        elif name.endswith('take/copy'):
            case['body']=case['body'].replace('[2,10,1]','["b","a","c"]').replace('push(out,9)','out[0] = "z"')
            case['expected']=[['b','a','c'],['z','a']]
        elif name.endswith(('effect/free','effect/receiver')):
            case['body']=case['body'].replace('[2,10,1]','["b","a","c"]')
            case['expected']=[['b','a'] if name.endswith('effect/free') else ['a','b'],'sn']
        result.append(case)
    final=dict(cases=result,scope='Bounded sorted/take free/receiver execution only. Fixed lexical strings isolate copy/effects from owned95 scalar-flag behavior. Whole rejected88 epoch retains actual child-push syntax misuse, kind observations, registered-function and ordinary length gaps. Deferred count/first10 and registered sorted/ordinary length11 are scheduled before enumeration. No flags/registered-function/length-family repair admitted.')
    c.write_new('cases2.json',final)
    c.write_new('refinement.json.gz',dict(producer=c.read(c.PREFIX+'refine.py'),before=before,after=c.read(c.PREFIX+'cases2.json'),
        explanation='Public source shows push(out,9) means child rule push outside, not append; use typed index assignment in copy controls. Scalar sort plus container dclone needs separate kind95 audit. Registered sorted is unresolved and ordinary length chain stays raw;11 owns both,10 count/first. No original expected/run data overwritten.'))
    print('Corrected fixed plan',len(result),'cases; rejected88 remains exact')

if __name__=='__main__':main()
