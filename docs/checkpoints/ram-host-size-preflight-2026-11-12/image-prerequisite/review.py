"""Recover exact retained source-admission evidence without rerunning producers."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE=Path(__file__).resolve().parent
OWNER='TYPE-REFERENCE-BOOK.1.2.23.4.14'
REVISION='b370de8d31e3f38da6abf8ed4702a523aa3d6d97'
OLD='docs/checkpoints/knowledge-map-capacity-2026-11-10/objective-current-recovery.stdout.log.gz'
AUDIT='tests/language-readiness/verify_objectives.py'


def canonical(value):
    return json.dumps(value,sort_keys=True,separators=(',',':'))


def archived(directory,stem):
    rows=json.loads((BASE/directory/(stem.replace('.tar.gz','.json'))).read_bytes())
    result={}
    with tarfile.open(BASE/directory/stem) as archive:
        assert len(archive.getnames())==len(rows) and set(archive.getnames())==rows.keys()
        for member in archive:
            raw=archive.extractfile(member).read();row=rows[member.name]
            assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']
            assert member.mode&0o777==row['mode']
            result[member.name]=raw
    return result,rows


def block(raw,start,end):
    assert raw.count(start)==1
    at=raw.index(start)
    return raw[at:raw.index(end,at)]


def validate(model):
    current=model['current'];old=model['old'];inputs=model['inputs'];identities=model['identities']
    for key in ('restored_inputs','restored_bytes','restored_hashes','archive','controls','healthy_audit_guard'):
        assert canonical(current[key])==canonical(old[key]),'original recovery boundary'
    assert current['isolated_deterministic_capture'] and current['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0),'actual isolated guard'
    assert canonical(current['audit_report']['latest_source_inputs'])==canonical(old['audit_report']['latest_source_inputs']),'historical source population'
    for key,value in old['audit_controls'].items():
        assert canonical(current['audit_controls'][key])==canonical(value),'prior control field'
    assert set(current['audit_controls'])-set(old['audit_controls'])=={'phase0_value_fixture_mutations_rejected','ram_preflight_ci_mutations_rejected'},'new control field population'
    assert len(current['audit_controls']['phase0_value_fixture_mutations_rejected'])==12 and len(current['audit_controls']['ram_preflight_ci_mutations_rejected'])==9,'new control fields'
    declared=current['tracked_inputs'];observed=current['observed_artifact_inputs']
    assert set(observed)<=set(declared)<=set(identities),'actual producer/input closure'
    assert all(declared[name]==identities[name]['sha256'] for name in declared),'declared input identity'
    assert all(declared[name]==value for name,value in observed.items()),'observed input identity'
    for name,row in identities.items():
        assert hashlib.sha256(inputs[name]).hexdigest()==row['sha256'],'retained input identity'
    later=json.loads(gzip.decompress(inputs['tests/language-readiness/current-source-successors-2026-11-12.json.gz']))
    assert later['owner']==OWNER and later['activation_commit']==REVISION and len(later['images'])==4,'later table boundary'
    actual={row['path']:row for row in current['audit_report']['source_image_evolutions']}
    previous={row['path']:row for row in old['audit_report']['source_image_evolutions']}
    assert actual.keys()==previous.keys(),'image membership'
    selected={row['path']:row for row in later['images']}
    for name,row in actual.items():
        if name not in selected:
            assert canonical(row)==canonical(previous[name]),'unchanged image report'
            continue
        entry=selected[name]
        assert row['current_sha256']==entry['current_sha256'] and row['activation_commit']==REVISION and row['owner']==OWNER,'later image binding'
        nested=row['successor_admission']
        assert nested['previous_current_sha256']==entry['prior_sha256'] and nested['previous_activation_commit']==entry['prior_revision'],'intermediate image lineage'
        assert entry['historical_sha256']==previous[name]['historical_sha256'],'original image boundary'
        assert hashlib.sha256(inputs[name]).hexdigest()==entry['current_sha256'],'accepted runtime bytes'
    before_audit=model['before_audit'];after_audit=inputs[AUDIT]
    old_governance=block(before_audit,b'def verify_governance_evolution(',b'\n\nSELECTOR_LITERAL_PATTERN_UPDATES')
    new_governance=block(after_audit,b'def verify_governance_precursor(',b'\n\nSELECTOR_LITERAL_PATTERN_UPDATES')
    assert new_governance.replace(b'def verify_governance_precursor(',b'def verify_governance_evolution(',1)==old_governance,'original governance predicate'
    phase_start=b'def falsify_phase0_value_fixture('
    assert block(before_audit,phase_start,b'\n\ndef audit_evidence(')==block(after_audit,phase_start,b'\n\ndef audit_evidence('),'protected Phase0 value predicate'
    ram=json.loads(gzip.decompress(inputs['tests/language-readiness/ram-preflight-ci-evolution.json.gz']))
    assert ram['owner']==OWNER and ram['activation_commit']==REVISION and 'precursor only' in ram['current_stage'],'owned candidate boundary'
    ci=inputs['tools/run_ci_local.sh']
    assert hashlib.sha256(ci).hexdigest()==ram['after_sha256'],'RAM CI candidate identity'
    restored=ci
    for hunk in reversed(ram['hunks']):
        assert restored.count(hunk['after'].encode())==1,'RAM CI exact hunk'
        restored=restored.replace(hunk['after'].encode(),hunk['before'].encode(),1)
    assert hashlib.sha256(restored).hexdigest()==ram['before_sha256'],'RAM CI precursor identity'
    for row in ram['support']:
        assert hashlib.sha256(inputs[row['path']]).hexdigest()==row['sha256'],'RAM CI support identity'


sealed=json.loads((BASE/'sealed-identities.json').read_bytes())
for name,row in sealed.items():
    path=BASE/name;raw=path.read_bytes()
    assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256'] and path.stat().st_mode&0o777==row['mode']
# Input metadata uses the existing producer's explicit filename, not archive stem.
def captured(directory,archive_name,metadata_name):
    rows=json.loads((BASE/directory/metadata_name).read_bytes());result={}
    with tarfile.open(BASE/directory/archive_name) as archive:
        assert len(archive.getnames())==len(rows) and set(archive.getnames())==rows.keys()
        for member in archive:
            raw=archive.extractfile(member).read();row=rows[member.name]
            assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256'] and member.mode&0o777==row['mode']
            result[member.name]=raw
    return result,rows

inputs,identities=captured('isolated-recovery','inputs-before-use.tar.gz','input-identities.json')
before,_=captured('intake','inputs-before-use.tar.gz','input-identities.json')
assert (BASE/'isolated-recovery/exit.txt').read_text().strip()=='0'
assert gzip.decompress((BASE/'isolated-recovery/stderr.gz').read_bytes())==b''
assert (BASE/'proofs/nested-report-red/exit.txt').read_text().strip()=='1'
assert b'AssertionError: nested successor current image' in gzip.decompress((BASE/'proofs/nested-report-red/stderr.gz').read_bytes())
for tag in ('nested-report-green','image-and-ci-unit','focused-evolution'):
    assert (BASE/'proofs'/tag/'exit.txt').read_text().strip()=='0'
    assert gzip.decompress((BASE/'proofs'/tag/'stderr.gz').read_bytes())==b''
model=dict(current=json.loads(gzip.decompress((BASE/'isolated-recovery/stdout.gz').read_bytes())),
           old=json.loads(gzip.decompress(inputs[OLD])),inputs=inputs,identities=identities,before_audit=before[AUDIT])
validate(model)
controls=[
    ('changed-original-recovery','original recovery boundary',lambda m:m['current'].update(restored_bytes=m['current']['restored_bytes']+1)),
    ('erased-prior-control','prior control field',lambda m:m['current']['audit_controls'].update(governance_mutations_rejected=713)),
    ('omitted-declared-input','actual producer/input closure',lambda m:m['current']['tracked_inputs'].pop(next(iter(m['current']['observed_artifact_inputs'])))),
    ('altered-observed-input','observed input identity',lambda m:m['current']['observed_artifact_inputs'].update({next(iter(m['current']['observed_artifact_inputs'])):'0'*64})),
    ('wrong-latest-image','later image binding',lambda m:next(row for row in m['current']['audit_report']['source_image_evolutions'] if row['path']=='dart/lib/src/runtime/interpreter.dart').update(current_sha256='0'*64)),
    ('wrong-intermediate-image','intermediate image lineage',lambda m:next(row for row in m['current']['audit_report']['source_image_evolutions'] if row['path']=='dart/lib/src/runtime/interpreter.dart')['successor_admission'].update(previous_activation_commit='0'*40)),
]
rejected=[]
for name,reason,change in controls:
    altered=copy.deepcopy(model);change(altered)
    try:validate(altered)
    except AssertionError as error:
        assert str(error)==reason
        rejected.append(name)
    else:raise AssertionError('ineffective recovery control: '+name)
print(json.dumps(dict(result='PASS',original_recovery_preserved=True,all_prior_control_fields_preserved=True,
    declared_inputs=len(model['current']['tracked_inputs']),observed_inputs=len(model['current']['observed_artifact_inputs']),
    captured_inputs=len(identities),rejected_controls=rejected,
    scope='Historical direct-source/evidence recovery only; no fresh runtime execution, canonical completion or native/toolchain/OS closure.')))
