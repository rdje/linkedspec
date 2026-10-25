"""Read-only original stream recovery and retained source-admission controls."""
import io
import json
import types
import zipfile
import common as c

AUDIT='tests/language-readiness/verify_objectives.py'


def module(packet):
    result=types.ModuleType('retained_numeric_auditor')
    result.__file__=str(c.ROOT/AUDIT)
    exec(compile(c.decode(packet['base64']),result.__file__,'exec'),result.__dict__)
    return result


def check():
    result=c.load('history-final-result.json.gz')
    run=c.load('history-final-run.json.gz')
    assert run['returncode']==0 and run['producer_inputs_unchanged']
    assert not c.decode(run['stderr_base64'])
    assert json.loads(c.decode(run['stdout_base64']))==result
    assert result['restored_inputs']==134 and result['restored_bytes']==84613241
    assert len(result['controls'])==22 and result['isolated_deterministic_capture']
    assert result['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    supplied=c.load('history-final-read-inputs.json.gz')
    report=result['audit_report'];logs=report['retained_log_hashes']
    assert result['restored_hashes']==logs
    raw=c.decode(supplied['files'][result['archive']['path']]['base64'])
    assert c.sha(raw)==result['archive']['sha256'] and len(raw)==result['archive']['bytes']
    with zipfile.ZipFile(io.BytesIO(raw)) as archive:
        decoded={row.filename:archive.read(row) for row in archive.infolist()}
    assert len(decoded)==len(logs)==134
    assert sorted((c.sha(raw),len(raw)) for raw in decoded.values())==sorted(
        (row['sha256'],row['bytes']) for row in supplied['isolated_reads'].values())
    assert sorted(c.sha(raw) for raw in decoded.values())==sorted(logs.values())
    assert sum(map(len,decoded.values()))==84613241
    for path,expected in result['tracked_inputs'].items():assert supplied['files'][path]['sha256']==expected
    audit=module(supplied['loaded_sources'][AUDIT])
    def read(path):return c.decode(supplied['files'][path]['base64'])
    updates=report['runtime_source_updates']
    assert {row['path'] for row in updates}==set(audit.RUST_NUMERIC_IMAGES)
    assert len(audit.RUST_NUMERIC_SUPPORT)==5
    for row in updates:
        assert audit.verify_rust_numeric_evolution(row['path'],read(row['path']),row['historical'],read=read)==row
        assert row['support_sources']==audit.RUST_NUMERIC_SUPPORT
    assert result['audit_controls']['runtime_source_mutations_rejected']==6
    assert set(result['audit_controls']['numeric_support_mutations_rejected'])==set(audit.RUST_NUMERIC_SUPPORT)
    gap=c.load('support-admission-gap.json.gz');denial=c.load('support-admission-denial.json.gz')
    assert gap['actual_helper']==denial['actual_helper'] and gap['lease']==denial['lease']
    assert gap['actual_helper']['sha256']!=gap['lease']['before']['sha256']
    assert denial['reason']=='unreviewed Rust numeric support drift: '+gap['lease']['path']
    controls=c.load('auditor-direct-controls.json.gz')['controls'];assert len(controls)==9
    for name in ['rollback','primary-bypass','support-bypass']:
        record=c.load('auditor-'+name+'.json.gz');assert record['run']['returncode']!=0
        error=c.decode(record['run']['stderr_base64'])
        if name=='rollback':assert b'current executable evidence drift: rust/Cargo.toml' in error
        elif name=='primary-bypass':
            assert record['admitted'] and b'runtime corruption control did not reject' in error
            faulty=module(record['source'])
            row=next(row for row in updates if row['path']==audit.RUST_SIGNED_SOURCE)
            assert faulty.verify_rust_numeric_evolution(row['path'],read(row['path'])+b'\n// unreviewed\n',row['historical'],read=read)==record['admitted']
        else:
            assert record['admitted'] and b'numeric support corruption control did not reject' in error
            faulty=module(record['source']);support=next(iter(audit.RUST_NUMERIC_SUPPORT))
            row=next(row for row in updates if row['path']==audit.RUST_SIGNED_SOURCE)
            changed=read(support)+b'\n// unreviewed support\n'
            assert faulty.verify_rust_numeric_evolution(row['path'],read(row['path']),row['historical'],
                read=lambda path:changed if path==support else read(path))==record['admitted']
    restored=c.load('auditor-restored.json.gz')
    assert restored['run']['returncode']==0 and not c.decode(restored['run']['stderr_base64'])
    assert json.loads(c.decode(restored['run']['stdout_base64']))==result
    assert restored['source']==supplied['loaded_sources'][AUDIT]
    return dict(streams=134,bytes=84613241,original_controls=22,primary_denials=6,
        support_denials=5,direct_denials=9,physical_auditor_faults=3)


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
