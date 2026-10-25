"""Physical numeric faults with durable leases and exact source restoration."""
import json
import sys
import common as c

TARGETS={
    'core':('linkedspec-core','test','numeric_conversion_contract'),
    'runtime':('linkedspec-runtime','test','numeric_conversion_contract'),
    'bridge':('linkedspec-runtime','test','numeric_bridge_contract'),
    'library':('linkedspec-runtime','lib','linkedspec_runtime'),
}
FILES={
    'json-clamp':'rust/linkedspec-core/src/numeric.rs',
    'host-bound':'rust/linkedspec-core/src/numeric.rs',
    'roundtrip':'rust/Cargo.toml',
    'signed-zero':'rust/linkedspec-core/src/types.rs',
    'definition-field':'rust/linkedspec-runtime/src/spec_parser.rs',
}
SELECTED={
    'json-clamp':(['core','bridge'],['programs','functions']),
    'host-bound':(['runtime'],[]),
    'roundtrip':(['core'],['programs','functions']),
    'signed-zero':(['core'],[]),
    'definition-field':(['library'],[]),
}


def mutate(name,raw):
    if name=='json-clamp':
        start=raw.index(b'pub(crate) fn integral_json_number(')
        end=raw.index(b'pub(crate) fn number_text(',start)
        replacement=b'''pub(crate) fn integral_json_number(value: f64) -> Option<serde_json::Number> {
    if !value.is_finite() || value.fract() != 0.0 { return None; }
    Some(serde_json::Number::from(value as i64))
}

'''
        changed=raw[:start]+replacement+raw[end:]
    elif name=='host-bound':
        assert raw.count(b'value < upper_exclusive')==1
        changed=raw.replace(b'value < upper_exclusive',b'value <= upper_exclusive',1)
    elif name=='roundtrip':
        old=b'serde_json = { version = "1", features = ["float_roundtrip"] }'
        assert raw.count(old)==1
        changed=raw.replace(old,b'serde_json = "1"',1)
    elif name=='signed-zero':
        old=b'if *n == 0.0 && n.is_sign_negative()'
        assert raw.count(old)==1
        changed=raw.replace(old,b'if false && *n == 0.0 && n.is_sign_negative()',1)
    elif name=='definition-field':
        start=raw.index(b'return linkedspec_core::numeric::nonnegative_integer_to_usize(n).ok_or_else(')
        end=raw.index(b'});',start)+3
        changed=raw[:start]+b'return Ok(n as usize);'+raw[end:]
    else:raise AssertionError(name)
    assert changed!=raw
    return changed


def suite(stem,target,red):
    package,kind,name=TARGETS[target]
    run=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'run_suite.py',
        stem,package,kind,name])
    c.save(stem+'-producer-run.json.gz',run)
    assert run['returncode']==0,'capture/build failure is not product RED'
    actual=c.load(stem+'-run.json.gz')
    assert actual['run']['returncode']==(101 if red else 0)
    return stem


def emitted(stem,dataset):
    args=['bash','tools/run_python_project_data.sh',c.PREFIX+'execute_emitted.py',stem]
    if dataset=='functions':args.append('functions')
    run=c.run(args)
    c.save(stem+'-producer-run.json.gz',run)
    assert run['returncode']==1,'actual observer must reject a successfully executed wrong value'
    result=c.load('emitted-'+stem+'-result.json.gz')
    actual=c.load('emitted-'+stem+'-run.json.gz')
    assert actual['run']['returncode']==0 and result['failures']
    return 'emitted-'+stem


def main():
    assert len(sys.argv)>=2
    label=sys.argv[1];assert label.replace('-','').isalnum()
    names=sys.argv[2:] or list(SELECTED)
    assert len(set(names))==len(names) and all(name in SELECTED for name in names)
    lease=c.ROOT/'.linkedspec-data/verification/numeric55-source-fault-lease.json'
    assert not lease.exists(),'recover the existing exact-byte lease before another fault'
    for name in names:
        stem='fault-'+label+'-'+name
        path=FILES[name];before=c.read(path);raw=c.decode(before['base64'])
        changed=mutate(name,raw)
        c.save(stem+'-source.json.gz',dict(path=path,before=before,
            after=dict(base64=c.encode(changed),sha256=c.sha(changed),mode=before['mode']),
            producer=c.read(c.PREFIX+'source_faults.py'),
            scope='Actual temporary first-party source mutation. Build failures earn '
                'no product-RED credit; every observed test binary is captured before '
                'execution. Restore the exact original bytes/mode in finally.'))
        lease.write_text(json.dumps(dict(owner=c.OWNER,stem=stem,path=path,before=before,
            fault_sha256=c.sha(changed)),indent=2)+'\n')
        tests,children=SELECTED[name];records=[];error=None
        (c.ROOT/path).write_bytes(changed)
        try:
            for target in tests:records.append(suite(stem+'-'+target,target,True))
            for dataset in children:records.append(emitted(stem+'-'+dataset,dataset))
        except Exception as failure:
            error=repr(failure)
            raise
        finally:
            current=c.read(path)
            assert c.decode(current['base64'])==changed,'conflicting source edit; preserve lease'
            (c.ROOT/path).write_bytes(raw);(c.ROOT/path).chmod(before['mode'])
            assert c.read(path)==before
            c.save(stem+'-restoration.json.gz',dict(path=path,before=before,
                restored=c.read(path),records=records,producer_error=error))
            lease.unlink()
        restored=suite(stem+'-restored',tests[0],False)
        c.save(stem+'-result.json.gz',dict(name=name,records=records,restored=restored,
            exact_source_restored=True,
            limits='The private definition-field control establishes its private '
                'reader boundary, not a reachable huge source-language definition.'))
        print('Physical fault',name,'observed RED; exact restoration and fresh GREEN.',flush=True)


if __name__=='__main__':
    main()
