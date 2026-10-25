"""Actual auditor rollback, two guard bypasses and exact restored recovery."""
import json
import types
import common as c

AUDIT='tests/language-readiness/verify_objectives.py'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'


def module():
    result=types.ModuleType('numeric_actual_auditor')
    result.__file__=str(c.ROOT/AUDIT)
    exec(compile(c.source(AUDIT).read_bytes(),result.__file__,'exec'),result.__dict__)
    return result


def main():
    assert not (c.ROOT/'.linkedspec-data/verification/numeric55-source-fault-lease.json').exists()
    before=c.read(AUDIT)
    old=c.load('historical-source-images.json.gz')['auditor_before']
    inputs=c.load('history-final-read-inputs.json.gz')['files']
    assert inputs[AUDIT]==before
    assert all(c.read(path)==packet for path,packet in inputs.items())
    c.save('auditor-control-inputs.json.gz',dict(current=before,prior=old,
        producer=c.read(c.PREFIX+'auditor_controls.py'),
        input_reference=c.PREFIX+'history-final-read-inputs.json.gz',
        scope='Actual unchanged recovery driver and supplied inputs; only the auditor '
            'is temporarily replaced. Direct controls cover the exact source/support '
            'boundary; actual guard bypasses must admit drift and fail its own controls.'))
    lease=c.ROOT/'.linkedspec-data/verification/numeric55-auditor-lease.json'
    assert not lease.exists()
    current=c.decode(before['base64'])
    variants={
        'rollback':c.decode(old['base64']),
        'primary-bypass':current.replace(b'require(digest(contents) == accepted,',b'require(True,',1),
        'support-bypass':current.replace(b'require(digest(read(support)) == expected,',b'require(True,',1),
    }
    assert all(raw!=current for raw in variants.values())
    audit=module();engine=audit.RUST_SIGNED_SOURCE;data=c.source(engine).read_bytes()
    controls=[]
    for name,path,raw,historical in [
        ('wrong-source',engine+'.other',data,audit.RUST_SIGNED_BEFORE),
        ('wrong-history',engine,data,'0'*64),
        ('unreviewed-primary',engine,data+b'\n// unreviewed\n',audit.RUST_SIGNED_BEFORE),
        ('old-primary',engine,audit.git('show',c.BASE+':'+engine),audit.RUST_SIGNED_BEFORE),
    ]:
        try:audit.verify_rust_numeric_evolution(path,raw,historical)
        except ValueError as error:reason=str(error)
        else:raise AssertionError('direct source control admitted: '+name)
        controls.append(dict(name=name,path=path,source_base64=c.encode(raw),historical=historical,reason=reason))
    for support in audit.RUST_NUMERIC_SUPPORT:
        changed=c.source(support).read_bytes()+b'\n// unreviewed support\n'
        def reader(path):return changed if path==support else audit.read_relative(path)
        try:audit.verify_rust_numeric_evolution(engine,data,audit.RUST_SIGNED_BEFORE,read=reader)
        except ValueError as error:reason=str(error)
        else:raise AssertionError('direct support control admitted: '+support)
        assert reason=='unreviewed Rust numeric support drift: '+support
        controls.append(dict(name='support',path=support,source_base64=c.encode(changed),reason=reason))
    c.save('auditor-direct-controls.json.gz',dict(controls=controls))
    results={}
    for name,raw in variants.items():
        lease.write_text(json.dumps(dict(owner=c.OWNER,path=AUDIT,before=before,
            variant=name,fault_sha256=c.sha(raw)),indent=2)+'\n')
        (c.ROOT/AUDIT).write_bytes(raw)
        try:
            faulty=module();admitted=None
            if name=='primary-bypass':
                admitted=faulty.verify_rust_numeric_evolution(engine,data+b'\n// unreviewed\n',faulty.RUST_SIGNED_BEFORE)
            elif name=='support-bypass':
                support=next(iter(faulty.RUST_NUMERIC_SUPPORT))
                changed=c.source(support).read_bytes()+b'\n// unreviewed support\n'
                admitted=faulty.verify_rust_numeric_evolution(engine,data,faulty.RUST_SIGNED_BEFORE,
                    read=lambda path:changed if path==support else faulty.read_relative(path))
            assert all(path==AUDIT or c.read(path)==packet for path,packet in inputs.items())
            run=c.run(['bash','tools/run_python_project_data.sh',PROOF])
            assert all(path==AUDIT or c.read(path)==packet for path,packet in inputs.items())
            c.save('auditor-'+name+'.json.gz',dict(source=c.read(AUDIT),run=run,admitted=admitted))
            assert run['returncode']!=0
            error=c.decode(run['stderr_base64'])
            if name=='rollback':assert b'current executable evidence drift: rust/Cargo.toml' in error
            elif name=='primary-bypass':assert b'runtime corruption control did not reject' in error
            else:assert b'numeric support corruption control did not reject' in error
            results[name]=run['returncode']
        finally:
            assert c.source(AUDIT).read_bytes()==raw,'conflicting auditor edit; preserve lease'
            (c.ROOT/AUDIT).write_bytes(current);(c.ROOT/AUDIT).chmod(before['mode'])
            assert c.read(AUDIT)==before
            lease.unlink()
    restored=c.run(['bash','tools/run_python_project_data.sh',PROOF])
    c.save('auditor-restored.json.gz',dict(source=c.read(AUDIT),run=restored))
    assert restored['returncode']==0 and not c.decode(restored['stderr_base64'])
    assert json.loads(c.decode(restored['stdout_base64']))==c.load('history-final-result.json.gz')
    assert c.read(AUDIT)==before
    c.save('auditor-control-result.json.gz',dict(controls=len(controls),variants=results,
        actual_bypasses_admit_drift=True,exact_restoration=True,restored_report_identical=True))
    print('Auditor9 direct denials, rollback/two actual bypass REDs and exact restored recovery PASS.')


if __name__=='__main__':main()
