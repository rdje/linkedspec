"""Install actual owned runtime variants, capture RED, restore exact bytes/mode."""
import json
import re
import common as c
import epoch
import review_after as a

ENGINE='rust/linkedspec-runtime/src/engine.rs'
TEST='rust/linkedspec-runtime/tests/signed_array_selector_contract.rs'
FIXTURE='tests/signed-array-rust/cases.json'


def once(text,old,new):
    assert text.count(old)==1,old
    return text.replace(old,new,1)


def main():
    original=c.read(ENGINE);raw=c.decode(original['base64']);text=raw.decode()
    accepted=c.load('before-inputs.json.gz')['context']['sources'][ENGINE]
    variants={'accepted-runtime-inverse':c.decode(accepted['base64'])}
    start=text.index('            EvaluatedAccessSegment::NegativeIndex(_) => Err(NestedWriteError {')
    end=text.index('\n        }\n    }\n',start)
    variants['invent-missing-negative']=(text[:start]+'            EvaluatedAccessSegment::NegativeIndex(_) => Ok(RuntimeValue::Array(Vec::new())),\n'+text[end:]).encode()
    old='''                path.push(segment.clone());
                let result = Self::assign_nested_runtime_value(
                    base,
                    &mut items[index],'''
    new=old.replace('path.push(segment.clone())','path.push(EvaluatedAccessSegment::Index(index))')
    variants['normalized-authored-prefix']=once(text,old,new).encode()
    variants['rounded-underflow-arithmetic']=once(text,
        'resolved_index: items.len() as i128 + index,',
        'resolved_index: (items.len() as f64 + *index as f64) as i128,').encode()
    needle='''    fn assert_receiver_write_expr(&self, expr: &Expr, ctx: &RuntimeContext) -> Result<(), String> {
'''
    variants['receiver-guard-bypass']=once(text,needle,needle+'        return Ok(()); // deliberate physical fault\n').encode()
    assert all(value!=raw for value in variants.values())
    supplied=epoch.snapshot([TEST,FIXTURE])
    c.write_new('runtime-fault-inputs.json.gz',dict(context=supplied,producer=c.read(c.PREFIX+'faults.py'),
        pristine=original,variants={name:dict(base64=c.encode(value),sha256=c.sha(value),mode=original['mode']) for name,value in variants.items()},
        scope='Five actual runtime variants. The accepted inverse is the exact pre-leaf engine source. Each variant runs the complete current four-route consumer without emitted compilation; each source restores exact bytes/mode, followed by one complete six-route restored epoch.'))
    reports={}
    for name,value in variants.items():
        c.source(ENGINE).write_bytes(value)
        try:
            run=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'run_test.py','fault-'+name,'--skip-emitted'])
            c.write_new('runtime-fault-'+name+'-driver.json.gz',run)
            assert run['returncode']==0,'capture itself failed: '+name
            reports[name]=a.check('fault-'+name,a.FOUR,False)
            assert reports[name]['failures'],name
        finally:
            # An unexpected concurrent edit is preserved, never overwritten.
            assert c.source(ENGINE).read_bytes()==value,'concurrent owned-engine change; inspect before restoration'
            c.source(ENGINE).write_bytes(raw);c.source(ENGINE).chmod(original['mode'])
            assert c.read(ENGINE)==original
        c.write_new('runtime-fault-'+name+'-review.json.gz',dict(report=reports[name],restored=c.identity(ENGINE)))
        print('Actual runtime RED/restored:',name,len(reports[name]['failures']),'mismatches',flush=True)
    assert c.unchanged(supplied['inputs'])
    c.write_new('runtime-faults.json.gz',dict(reports=reports,inputs_restored=True))
    print('All five runtime variants rejected; exact source restored. Full restored six-route run remains required.',flush=True)


if __name__=='__main__':main()
