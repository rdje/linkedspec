"""Read-only retained-epoch review; normal hooks/canonical CI own landing."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'tools'))
sys.path.insert(0,str(Path(__file__).parent))
from test_task_narrative import retained_migration_preservation
from projection_replay import review as projection_review
from punctuation_review import review as punctuation_review
from selector_review import review as selector_review
from signed_result_review import review as signed_result_review
from cycle_evidence import review as cycle_review
from numeric_calibration import review as numeric_review
from ast_calibration import review as ast_review
from factory_evidence import review as factory_review
from factory_reviewer_calibration import review as factory_reviewer_review
from storage_inventory import review as storage_review
from execution_evidence import review as execution_review
from phase0_evidence import review as phase0_review
from book_count import review as book_count_review


def decode(row):
    raw=base64.b64decode(row['base64'],validate=True)
    assert hashlib.sha256(raw).hexdigest()==row['sha256'],'component packet identity'
    return raw


def verify_objective_epoch(epoch,snapshot):
    report=json.loads(decode(epoch['report']))
    assert set(epoch['inputs'])==set(report['tracked_inputs']),'objective epoch input population'
    observed=report.get('observed_artifact_inputs',{})
    assert set(observed)<=set(report['tracked_inputs']),'observed artifact input omitted'
    for name,expected in report['tracked_inputs'].items():
        row=epoch['inputs'][name]
        if 'revision' in row:
            assert set(row)=={'revision','sha256'} and row['revision']=='0db5e9e87b7c1cfaf09936b9629974787038f5e3'
            raw=snapshot.read(name,row['revision'])
            assert hashlib.sha256(raw).hexdigest()==row['sha256']
        else:raw=decode(row)
        assert hashlib.sha256(raw).hexdigest()==expected,'objective input epoch drift: '+name
        if name in observed:assert observed[name]==expected,'observed/declared identity split'
    decode(epoch['capture_producer'])
    assert report['restored_inputs']==134 and report['isolated_deterministic_capture']
    assert report['healthy_audit_guard']=={'original_log_attempts':0,'tracked_write_attempts':0}
    assert len(report['audit_controls']['current_image_mutations_rejected'])==18
    assert len(report['audit_report']['source_image_evolutions'])==18
    return report


def review(control=None):
    record=json.loads(gzip.decompress((Path(__file__).parent/'component-evidence.json.gz').read_bytes()))
    if control=='input':
        first=next(iter(record['inputs'].values()));first['sha256']='0'*64
    for name,row in record['inputs'].items():
        path=Path(name);assert not path.is_absolute() and '..' not in path.parts
        decode(row)
    channels={name:decode(row) for name,row in record['channels'].items()}
    index=decode(record['index']);index_sha=hashlib.sha256(index).hexdigest()
    results=[json.loads(channels[name]) for name in ('claim-before-result.json','claim-after-result.json')]
    if control=='snapshot':results[1]['index_sha256']='0'*64
    assert all(row['passed'] and row['index_unchanged'] and row['index_sha256']==index_sha for row in results),'claim snapshot mismatch'
    for pair in record['histories'].values():
        before,after=decode(pair['before']),decode(pair['after'])
        if control=='history':after+=b'lost history\n'
        assert before==after,'ordered history changed'
    cleanup=json.loads(gzip.decompress((Path(__file__).parent/'cleanup-intake.json.gz').read_bytes()))
    for row in cleanup['removed']:
        raw=row['text'].encode();assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']
    bytecode=json.loads((Path(__file__).parent/'bytecode-cleanup.json').read_bytes())
    assert bytecode['owner']=='TYPE-REFERENCE-BOOK.1.2.20.1.10'
    assert bytecode['full_bytecode_payload_retained'] is False
    assert bytecode['identity_recorded_before_removal'] is True
    assert bytecode['original_identity']['path']=='tools/__pycache__/test_knowledge_map_projection.cpython-314.pyc'
    assert bytecode['original_identity']['bytes']==9395
    assert bytecode['original_identity']['sha256']=='d80647555bd844ba2011ebc9d2572a53c52834cc85f934a8a7e647ba187e7efa'
    decode(bytecode['source_observed_at_correction'])
    correction=json.loads((Path(__file__).parent/'cleanup-record-correction.json').read_bytes())
    decode(correction['before']);decode(correction['after'])
    assert correction['obsolete_canonical_exit']==143
    custody=json.loads((Path(__file__).parent/'custody-owner-correction.json').read_bytes())
    assert custody['current_custody_owner']=='TYPE-REFERENCE-BOOK.1.2.23.4.2'
    assert custody['incorrect_owner']=='TYPE-REFERENCE-BOOK.1.2.23.4.3'
    original=(ROOT/custody['original_artifact']).read_bytes()
    assert hashlib.sha256(original).hexdigest()==custody['original_artifact_sha256']
    decode(custody['producer_before']);decode(custody['producer_after'])
    catalog=json.loads(gzip.decompress((Path(__file__).parent/'catalog-metadata-repair.json.gz').read_bytes()))
    for key in ('before','after','consumer','red','green'):decode(catalog[key])
    assert b'Failed 4/45 subtests' in decode(catalog['red']) and b'Result: FAIL' in decode(catalog['red'])
    assert b'Tests=45' in decode(catalog['green']) and b'Result: PASS' in decode(catalog['green'])
    from check_claim_verification import InputSnapshot,index_files
    files=index_files();snapshot=InputSnapshot(files)
    epochs=[]
    for name in ('objective-recovery-first-green.json.gz','objective-recovery-owner-checked.json.gz','objective-recovery-input-closed.json.gz','objective-recovery-selector-literals.json.gz','objective-recovery-storage-inventory.json.gz','objective-recovery-execution-preflight.json.gz','objective-recovery-phase0-stable-inputs.json.gz','objective-recovery-cli-count.json.gz'):
        epoch=json.loads(gzip.decompress((Path(__file__).parent/name).read_bytes()))
        epochs.append(verify_objective_epoch(epoch,snapshot))
    previous,latest=[epoch['audit_controls'] for epoch in epochs[4:6]]
    expected=dict(previous['governance_mutations_by_source'])
    expected['tools/run_ci_local.sh']+=3
    assert latest['governance_mutations_by_source']==expected,'prior governance controls lost at execution preflight'
    assert latest['governance_mutations_rejected']==previous['governance_mutations_rejected']+3==703
    for key in previous:
        if key not in ('governance_mutations_by_source','governance_mutations_rejected'):
            assert latest[key]==previous[key],'prior recovery controls changed: '+key
    phase0_controls=epochs[6]['audit_controls']
    assert len(phase0_controls['phase0_fixture_mutations_rejected'])==11
    assert {k:v for k,v in phase0_controls.items() if k!='phase0_fixture_mutations_rejected'}==latest,'old controls changed at Phase0 fixture stage'
    assert epochs[7]['audit_controls']==phase0_controls, 'prior controls changed at CLI book correction'
    assert index_files()==files,'index changed during objective epoch review'
    # Independent input closure controls distinguish a missing declared input and
    # an omitted observation, even if an artifact's summaries still look healthy.
    import copy
    missing=copy.deepcopy(epoch);missing['inputs'].pop(next(iter(missing['inputs'])))
    try:verify_objective_epoch(missing,snapshot)
    except AssertionError:pass
    else:raise AssertionError('objective input loss admitted')
    report=json.loads(decode(epoch['report']));target=next(iter(report['observed_artifact_inputs']))
    report['tracked_inputs'].pop(target);omitted=copy.deepcopy(epoch);omitted['inputs'].pop(target)
    raw=json.dumps(report,sort_keys=True).encode();omitted['report']={'base64':base64.b64encode(raw).decode(),'sha256':hashlib.sha256(raw).hexdigest()}
    try:verify_objective_epoch(omitted,snapshot)
    except AssertionError:pass
    else:raise AssertionError('observed objective input omission admitted')
    retained_migration_preservation()
    projection=projection_review()
    punctuation=punctuation_review()
    selector=selector_review()
    signed_result=signed_result_review()
    cycles=cycle_review()
    numeric=numeric_review()
    ast=ast_review()
    factory=factory_review()
    factory_reviewer=factory_reviewer_review()
    storage_review()
    execution=execution_review()
    phase0=phase0_review()
    book_count=book_count_review()
    return dict(ordered_history_identity=True,task_contract_preservation=True,
                projection=projection,punctuation_required_needle=punctuation,selector_classification=selector,
                signed_callable_count=signed_result,
                callback_cycle_labels=cycles,
                scalar_numeric_calibration=numeric,
                ast_behavior_calibration=ast,
                factory_current_consumer_calibration=factory,
                factory_reviewer_source_calibration=factory_reviewer,
                storage_inventory='exact populations and distinguishing count/membership controls PASS',
                canonical_execution_prerequisite=execution,
                phase0_behavior_calibration=phase0,
                current_cli_book_count=book_count,
                claim_original_and_repaired_snapshot='same retained index; both PASS',
                limits=record['limits'])

if __name__=='__main__':
    result=review()
    for mutation in ('input','snapshot','history'):
        try:review(mutation)
        except AssertionError:continue
        raise AssertionError('retained evidence corruption accepted: '+mutation)
    print(json.dumps(dict(result=result,evidence_corruption_controls='input/snapshot/history RED'),sort_keys=True))
