"""One-shot finite public-source grid; expected valid positions use L + index."""
import json
import common as c


def main():
    rows = []
    def add(name,body,expected=None,*,invalid=False,control=False):
        row = dict(id=name,body=body,source='Top: /x/\n I { '+body+' }\n',input='x',
            policy='invalid position or selector' if invalid else 'valid position/value',control=control)
        if not invalid:
            row['requested_value'] = expected
        rows.append(row)
    # Each finite expected result is authored independently of the engine.
    add('read-last','items=[10,20,30]; return([items[-1],items])',[30,[10,20,30]])
    add('read-first','items=[10,20,30]; return(items[-3])',10)
    add('read-before-last','items=[10,20,30]; return(items[-2])',20)
    add('read-dynamic','items=[10,20,30]; chosen_index=-2; return(items[chosen_index])',20)
    add('read-underflow','items=[10,20,30]; return([items[-4],items])',invalid=True)
    add('read-empty','items=[]; return([items[-1],items])',invalid=True)
    add('read-mixed','tree={"rows":[{"v":1},{"v":2}]}; return(tree["rows"][-1]["v"])',2)
    add('read-quoted-key','tree={"-1":"key"}; return(tree["-1"])','key',control=True)
    add('read-positive','items=[10,20,30]; return(items[0])',10,control=True)
    add('read-negative-zero','items=[10,20,30]; return(items[-0])',10,control=True)
    add('write-last','items=[10,20,30]; items[-1]=99; return(items)',[10,20,99])
    add('write-first','items=[10,20,30]; items[-3]=99; return(items)',[99,20,30])
    add('write-dynamic','items=[10,20,30]; chosen_index=-2; items[chosen_index]=99; return(items)',[10,99,30])
    add('write-underflow','items=[10,20,30]; items[-4]=99; return(items)',invalid=True)
    add('write-empty','items=[]; items[-1]=99; return(items)',invalid=True)
    add('write-absent','items[-1]=99; return(items)',invalid=True)
    add('write-null','items=undef; items[-1]=99; return(items)',invalid=True)
    add('write-mixed','tree={"rows":[{"v":1},{"v":2}]}; tree["rows"][-1]["v"]=9; return(tree)',{'rows':[{'v':1},{'v':9}]})
    add('write-quoted-key','tree={"-1":"key"}; tree["-1"]="new"; return(tree)',{'-1':'new'},control=True)
    add('write-append','items=[10,20,30]; items[3]=99; return(items)',[10,20,30,99],control=True)
    add('callable-read','items=[10,20,30]; runner={||return(items[-1])}; return([runner(),items])',[30,[10,20,30]])
    add('callable-write','items=[10,20,30]; runner={||items[-1]=99; return(items)}; result=runner(); return([result,items])',[[10,20,99],[10,20,99]])
    add('callable-parameter-read','runner={|data_items|return(data_items[-1])}; return(runner([10,20,30]))',30)
    add('callable-positive-write','items=[10,20,30]; runner={||items[0]=99; return(items)}; return(runner())',[99,20,30],control=True)
    add('read-selector-effect','items=[10,20,30]; audit=""; choose={||audit=cat(audit,"key"); return(-1)}; selected=items[choose()]; return([selected,audit,items])',[30,'key',[10,20,30]])
    add('read-receiver-retention','items=[10,20,30]; choose={||items=[91,92]; return(-1)}; selected=items[choose()]; return([selected,items])',[30,[91,92]])
    add('read-positive-receiver-retention','items=[10,20,30]; choose={||items=[91,92]; return(0)}; selected=items[choose()]; return([selected,items])',[10,[91,92]],control=True)
    add('write-positive-effects','items=[10,20,30]; audit=""; choose={||audit=cat(audit,"key"); return(1)}; supply={||audit=cat(audit,"rhs"); return(99)}; items[choose()]=supply(); return([items,audit])',[[10,99,30],'keyrhs'],control=True)
    add('read-dynamic-quoted-key','tree={"-1":"key"}; chosen_index="-1"; return(tree[chosen_index])','key',control=True)
    add('callable-copied-parameter-write','items=[10,20,30]; runner={|data_items|data_items[-1]=99; return(data_items)}; return([runner(items),items])',[[10,20,99],[10,20,30]])
    add('write-fractional','items=[10,20,30]; items[1.5]=99; return(items)',invalid=True)
    add('write-string-negative-on-array','items=[10,20,30]; items["-1"]=99; return(items)',invalid=True)
    assert len(rows) == 32 and len({row['id'] for row in rows}) == 32
    c.write_new('cases.json',dict(cases=rows,scope='Finite native public-interface baseline and requested valid-position values; invalid-position observations retain actual diagnostics without preselecting a new error identity. Current receiver-retention semantics are an independent positive control, not a newly ratified cross-backend policy.'))
    print('Prepared',len(rows),'finite public sources; no runtime observation yet')


if __name__ == '__main__':
    main()
