"""Declare independent fixed values and effect traces before repair execution."""
import json
import shutil
import common as c

def main():
    values=[ [1,10,2],[1,10,2],[],[],None,None,None,
        [2,10],[2,10],[2],[2],[],[],[],[],[],[2,10,1],[],[],[2,10],None,None,None,
        11,11,2,1,None ]
    original=c.load('baseline-plan.json')['cases']
    assert len(values)*2==len(original)
    cases=[]
    for index,value in enumerate(values):
        for case in original[index*2:index*2+2]:
            if case['id'].endswith(('chain/count','chain/first')):continue
            cases.append(dict(**case,expected=value))
    def pair(name,body,expected,functions=''):
        for scope in ('ordinary','deferred'):
            cases.append(dict(id=scope+'/'+name,body=body if scope=='ordinary' else
                'cb = {|| '+body+' }; return(cb())',expected=expected,functions=functions))
    pair('sorted/null-terms','return(sorted(["b",undef,"a"]))',[None,'a','b'])
    pair('sorted/strings','return(sorted(["2","10","1"]))',['1','10','2'])
    pair('sorted/copy','items = [2,10,1]; out = sorted(items); push(out,9); return([items,out])',[[2,10,1],[1,10,2,9]])
    pair('take/copy','items = [2,10,1]; out = take(items,2); push(out,9); return([items,out])',[[2,10,1],[2,10,9]])
    pair('take/nested','return(take([[1],[2]],1))',[[1]])
    pair('chain/repeat','items = [3,1,8]; return(items.sorted().take(2).sorted().take().sum())',1)
    pair('chain/length','items = [2,10,1]; return(items.sorted().take(2).length())',2)
    pair('chain/empty','items = []; return(items.sorted().take(2).sum())',0)
    pair('function/parameter','return(select_items([2,10,1]))',[1,10],
        'fn select_items(items) { return(items.sorted().take(2)) }\n')
    # The prefix receiver/count effects are sequenced and count is lazy for non-arrays.
    setup='trace = ""; source = {|| trace = cat(trace,"s"); return([2,10,1]) }; limit = {|| trace = cat(trace,"n"); return(2) }; '
    pair('effect/free',setup+'out = take(source(),limit()); return([out,trace])',[[2,10],'sn'])
    pair('effect/receiver',setup+'out = source().sorted().take(limit()); return([out,trace])',[[1,10],'sn'])
    setup='trace = ""; source = {|| trace = cat(trace,"s"); return(3) }; limit = {|| trace = cat(trace,"n"); return(2) }; '
    pair('effect/nonarray-free',setup+'out = take(source(),limit()); return([out,trace])',[[],'s'])
    pair('effect/nonarray-receiver',setup+'out = source().take(limit()); return([out,trace])',[[],'s'])
    setup='trace = ""; source = {|| trace = cat(trace,"s"); return([2,10,1]) }; limit = {|| trace = cat(trace,"n"); return(2) }; '
    pair('effect/sorted-arity',setup+'out = sorted(source(),limit()); return([out,trace])',[None,''])
    pair('effect/take-arity',setup+'out = take(source(),limit(),limit()); return([out,trace])',[None,''])
    pair('effect/sorted-receiver-arity',setup+'out = source().sorted(limit()); return([out,trace])',[None,''])
    pair('effect/take-receiver-arity',setup+'out = source().take(limit(),limit()); return([out,trace])',[None,''])
    pair('effect/terminal',setup+'out = source().sorted().take(limit()).sum().abs(); return([out,trace])',[None,''])
    plan=dict(cases=cases,scope='Fixed values/ordered effects at individual case granularity. Ordinary accepted public behavior is the independent policy oracle; three legacy reducer string-kind failures remain owned95. Count/first receiver helpers remain separately owned10.')
    c.write_new('cases.json',plan)
    shutil.copy2(c.ROOT/'docs/checkpoints/type-aggregate-codeblocks/oracle.py',c.ROOT/(c.PREFIX+'oracle.py'))
    shutil.copy2(c.ROOT/'docs/checkpoints/type-aggregate-codeblocks/context.py',c.ROOT/(c.PREFIX+'context.py'))
    c.write_new('preparation.json.gz',dict(producer=c.read(c.PREFIX+'prepare.py'),plan=c.read(c.PREFIX+'cases.json'),
        before_permanent=c.read('t/scalar_numeric_contract.t'),scope='Plan and actual preparer retained before execution. Baseline ordinary values agree with authored lexical/integer count controls; effect predictions are independently checked, not copied from runtime.'))
    print('Fixed plan',len(cases),'cases')

if __name__=='__main__':main()
