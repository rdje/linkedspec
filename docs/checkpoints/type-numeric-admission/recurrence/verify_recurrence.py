"""Readonly validation of the exact second source image and historical successor."""
import gzip
import json
import subprocess
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[2]/'type-numeric-codeblocks'))
import common as c
PREFIX='docs/checkpoints/type-numeric-admission/recurrence/'
AUDIT='tests/language-readiness/verify_objectives.py'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
TABLE='tests/language-readiness/scalar-numeric-regression-evolution.json.gz'


def load(name):
    return json.loads(gzip.decompress((c.ROOT/(PREFIX+name)).read_bytes()))


def recovered(path,identity):
    wanted={key:identity[key] for key in ('sha256','mode')}
    if c.identity(path)==wanted:
        return (c.ROOT/path).read_bytes()
    saved=load('canonical2.json.gz')
    implementation=load('implementation.json.gz')
    for population in (saved['before'],implementation['before']):
        packet=population.get(path)
        if packet and {key:packet[key] for key in ('sha256','mode')}==wanted:
            raw=c.decode(packet['base64'])
            assert c.sha(raw)==wanted['sha256']
            return raw
    raise AssertionError('second source image not recoverable: '+path)


def verify():
    saved=load('canonical2.json.gz')
    assert saved['base']==c.BASE and saved['producer']==c.read(PREFIX+'preserve2.py')
    assert saved['primitives']==c.read(c.PREFIX+'common.py')
    assert c.decode(saved['baseline']['status']['base64']).strip()==b'0'
    assert b'10162 closed inputs;318 GREEN;169 accepted RED;13 faults' in c.decode(saved['baseline']['log']['base64'])
    assert c.decode(saved['canonical']['status']['base64']).strip()==b'1'
    assert b'evaluated-value regression registration mismatch: t/phase0_regression.t' in c.decode(saved['canonical']['log']['base64'])
    for name,packet in saved['original'].items():
        assert c.read(c.PREFIX+name)==packet
    manifest=json.loads(c.decode(saved['original']['publication-final-inputs.json']['base64']))
    publication=json.loads(c.decode(saved['original']['publication-final.json']['base64']))
    assert publication['record_base64']==saved['claim']['base64']
    assert manifest['inputs']==saved['inputs'] and len(saved['inputs'])==10162
    for path,identity in saved['inputs'].items():
        recovered(path,identity)
    rows=[]
    for row in c.decode(saved['index_base64']).split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1)
        mode,oid,stage=metadata.decode().split()
        assert stage=='0'
        path=name.decode()
        if mode in ('100644','100755'):
            item=saved['images'][path]
            assert item['git_mode']==mode and item['oid']==oid
            raw=recovered(path,item)
            if c.identity(path)!={key:item[key] for key in ('sha256','mode')}:
                actual=subprocess.check_output(['git','hash-object','--stdin'],cwd=c.ROOT,input=raw).decode().strip()
                assert actual==oid
            rows.append((path,oid))
    assert len(rows)==len(saved['images'])==10175
    git=saved['git_hash_verification']
    assert git['returncode']==0 and not c.decode(git['stderr_base64'])
    assert c.decode(git['stdout_base64']).decode().splitlines()==[oid for path,oid in rows]
    implementation=load('implementation.json.gz')
    correction=load('key-correction.json.gz')
    assert implementation['producer']==c.read(PREFIX+'apply_numeric.py')
    assert c.decode(implementation['after'][AUDIT])==c.decode(correction['before']['base64'])
    assert (c.ROOT/AUDIT).read_bytes()==c.decode(correction['after'])
    assert (c.ROOT/PROOF).read_bytes()==c.decode(implementation['after'][PROOF])
    assert (c.ROOT/TABLE).read_bytes()==c.decode(implementation['table']['base64'])
    assert c.identity(TABLE)['sha256']==implementation['table']['sha256']
    for path,packet in implementation['before'].items():
        assert {key:packet[key] for key in ('sha256','mode')}=={key:saved['images'][path][key] for key in ('sha256','mode')}
    failed=load('historical-run.json.gz')
    assert failed['run']['returncode']!=0 and b"KeyError: 'historical'" in c.decode(failed['run']['stderr_base64'])
    assert correction['producer']==c.read(PREFIX+'correct_key.py')
    inputs=load('historical-final-inputs.json.gz')
    healthy=load('historical-final-run.json.gz')
    actual=json.loads(c.decode(healthy['run']['stdout_base64']))
    assert healthy['run']['returncode']==0 and not c.decode(healthy['run']['stderr_base64'])
    assert healthy['inputs_unchanged']
    assert c.unchanged(inputs['inputs'])
    assert set(actual['tracked_inputs'])==set(inputs['proof_inputs'])
    assert len(inputs['proof_inputs'])==185
    assert all(actual['tracked_inputs'][path]==inputs['inputs'][path]['sha256'] for path in inputs['proof_inputs'])
    baseline=load('baseline-run.json.gz')
    assert baseline['calibration'] and baseline['healthy_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    assert baseline['controls']['governance_mutations_rejected']==578
    assert actual['audit_controls']['governance_mutations_rejected']==644
    assert actual['restored_inputs']==134 and actual['restored_bytes']==84613241 and len(actual['controls'])==22
    assert actual['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    for path,count in baseline['controls']['governance_mutations_by_source'].items():
        assert actual['audit_controls']['governance_mutations_by_source'][path]==count+(66 if path=='t/phase0_regression.t' else 0)
    table=load('table-final-control.json.gz')
    assert table['semantic_json_unchanged'] and table['observed_red']=='numeric inverse table identity mismatch: t/phase0_regression.t'
    assert json.loads(gzip.decompress(c.decode(table['changed_base64'])))==json.loads(gzip.decompress((c.ROOT/TABLE).read_bytes()))
    faults=load('source-fault-inputs.json.gz')
    assert faults['source']==c.read(AUDIT) and c.unchanged(faults['inputs'])
    source=c.decode(faults['source']['base64'])
    for task in faults['tasks']:
        name=task['name']
        before,after=c.decode(task['before']),c.decode(task['after'])
        assert source.count(before)==1
        observed=load('source-fault-'+name+'-observed.json.gz')
        result=load('source-fault-'+name+'.json.gz')
        assert observed['mutant']==dict(sha256=c.sha(source.replace(before,after,1)),mode=faults['source']['mode'])
        assert result['run']==observed['run'] and result['run']['returncode']!=0
        assert c.decode(task['reason']) in c.decode(result['run']['stderr_base64'])
        assert result['restored']['returncode']==0 and not c.decode(result['restored']['stderr_base64'])
        assert result['source_restored'] and result['inputs_restored']
    review=load('source-fault-review.json.gz')
    assert review['result']=='PASS' and len(review['faults'])==2 and review['source_restored']
    return dict(second_inputs=10162,staged_source_images=len(rows),original_controls=578,current_controls=644,
        numeric_fragments=22,additional_denials=66,archive_inputs=134,archive_bytes=84613241,recovery_controls=22,
        historical_proof_inputs=185,auditor_source_faults=2,source_restored=True,
        scope='Whole second draft and actual readonly0 remain recoverable through exact primary/before source images; '
              'no draft Git revision is invented. The historical successor preserves all old controls/hash/archive/read-write '
              'boundaries and adds22 reviewed numeric fragments/66 controls plus two actual auditor faults. The first KeyError '
              'is retained as preparation failure; no runtime or historical observation is refreshed.')
