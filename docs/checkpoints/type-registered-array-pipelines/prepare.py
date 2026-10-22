"""Declare fixed independent values and effects before product changes."""
import shutil
import common as c

def main():
    shutil.copy2(c.ROOT/'docs/checkpoints/type-array-count-first/probe.pl',c.ROOT/(c.PREFIX+'probe.pl'))
    shutil.copy2(c.ROOT/'docs/checkpoints/type-array-count-first/oracle.py',c.ROOT/(c.PREFIX+'oracle.py'))
    for name in ('pipeline11-intake','pipeline11-intake2'):
        shutil.copy2(c.ROOT/('.linkedspec-data/verification/'+name+'.json.gz'),c.ROOT/(c.PREFIX+name+'.json.gz'))
    c.write_new('live-claims.json.gz',__import__('json').loads((c.ROOT/'.linkedspec-data/verification/pipeline11-claims.json').read_text()))
    cases=[]
    def pair(name,body,expected,functions=''):
        for scope in ('ordinary','deferred'):
            cases.append(dict(id=scope+'/'+name,body=body if scope=='ordinary' else
                'cb = {|| '+body+' }; return(cb())',expected=expected,functions=functions))
    function='fn select_items(items) { return(items.sorted().take(2)) }\n'
    for name,value,expected in [('numbers','[2,10,1]',[1,10]),('strings','["2","10","1"]',['1','10']),
        ('empty','[]',[]),('scalar','7',[]),('harray','{"a":1}',[]),('null','undef',[])]:
        pair('function/'+name,'return(select_items('+value+'))',expected,function)
    pair('function/free-control','return(select_items([2,10,1]))',[1,10],
        'fn select_items(items) { return(take(sorted(items),2)) }\n')
    pair('function/local','return(select_items([2,10,1]))',[1,10],
        'fn select_items(values) { chosen = values; return(chosen.sorted().take(2)) }\n')
    pair('function/rest','return(select_items(2,10,1))',[1,10],
        'fn select_items(...items) { return(items.sorted().take(2)) }\n')
    pair('function/nested','return(select_items([2,10,1]))',[1,10],
        'fn select_base(items) { return(items.sorted()) }\nfn select_items(items) { return(select_base(items).take(2)) }\n')
    pair('function/copy','items = [2,10,1]; chosen = select_items(items); return([chosen,items])',[[1,10],[2,10,1]],function)
    pair('function/length','return(select_items([2,10,1]))',2,
        'fn select_items(items) { return(items.sorted().take(2).length()) }\n')
    pair('function/invalid-sort','return(select_items([2,10,1]))',None,
        'fn select_items(items) { return(items.sorted(2)) }\n')
    pair('function/invalid-take','return(select_items([2,10,1]))',None,
        'fn select_items(items) { return(items.take(1,2)) }\n')
    pair('function/terminal','return(select_items([2,10,1]))',None,
        'fn select_items(items) { return(items.sorted().length().abs()) }\n')
    for name,body,expected in [
        ('chain','items = [2,10,1]; return(items.sorted().take(2).length())',2),
        ('empty','items = []; return(items.sorted().take(2).length())',0),
        ('free','return(length(take(sorted([2,10,1]),2)))',2),
        ('array','items = [2,10,1]; return(items.length())',3),
        ('string','items = "abc"; return(items.length())',3),
        ('null','items = undef; return(items.length())',None),
        ('returned','source = {|| return([2,10,1]) }; return(source().sorted().take(2).length())',2),
        ('free-continuation','items = [2,10,1]; return(length(items).abs())',3),
    ]:
        pair('length/'+name,body,expected)
    setup='seen = ""; source = {|| seen = cat(seen,"s"); return([2,10,1]) }; limit = {|| seen = cat(seen,"n"); return(2) }; '
    pair('effect/length',setup+'out = source().sorted().take(limit()).length(); return([out,seen])',[2,'sn'])
    pair('effect/length-arity',setup+'out = source().sorted().take(limit()).length(limit()); return([out,seen])',[None,''])
    pair('effect/length-terminal',setup+'out = source().sorted().take(limit()).length().abs(); return([out,seen])',[None,''])
    pair('effect/direct-terminal',setup+'out = source().length().abs(); return([out,seen])',[None,''])
    pair('function/argument-effects',setup+'out = select_items(source()); return([out,seen])',[[1,10],'s'],function)
    plan=dict(cases=cases,scope='Fixed lexical order/kinds, empty/nonarray, parameter/local/rest/nested registration, source preservation, ordinary/deferred native/fresh values, length terminal/arity effects. Independent documented ordinary length and selection contracts; no complete inventory or other-backend admission.')
    c.write_new('cases.json',plan)
    before=c.epoch()
    run=c.observe(plan)
    c.write_new('baseline.json.gz',dict(context=before,run=run))
    import oracle
    failures=oracle.failures(run,plan)
    c.write_new('baseline-review.json',dict(cases=len(cases),failures=failures,
        limits='Original invalid codeblock() fixture remains an instrument failure; only corrected intake and this declared contract plan measure the product.'))
    print('Declared',len(cases),'cases;',len(failures),'baseline RED cases')

if __name__=='__main__':main()
