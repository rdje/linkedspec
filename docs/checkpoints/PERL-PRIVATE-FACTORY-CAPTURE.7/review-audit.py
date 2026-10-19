"""Readonly complete registration, correction-lineage and actual historical-audit review."""
import ast
import base64
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
RUNNER='tools/run_ci_local.sh'
AUDITOR='tests/language-readiness/verify_objectives.py'
LOG='docs/checkpoints/REPO-HYGIENE.19/canonical.log.gz'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
assert sys.argv[1:] in ([],['--capture'])
inputs=set()
def raw(p):inputs.add(p);return (ROOT/p).read_bytes()
def load(n):return json.loads(raw(PREFIX+n))
def old(p):return subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
registration=load('registration.json');inventory=load('inventory.json')
assert registration['result']=='PASS' and registration['base']==BASE
assert registration['producer_sha256']==sha(raw(PREFIX+'finish-registration.py'))
for p,identity in registration['inputs'].items():assert sha(raw(p))==identity
original=raw(PREFIX+'auditor-original.py');original_runner=raw(PREFIX+'runner-original.sh')
assert original==old(AUDITOR) and original_runner==old(RUNNER),'accepted original runner/auditor bytes'
assert registration['auditor_before_sha256']==sha(original) and registration['runner_before_sha256']==sha(original_runner)
constant_raw=raw(PREFIX+'auditor-constant.py');tree=ast.parse(constant_raw)
constants={}
for node in tree.body:
    assert isinstance(node,ast.Assign) and len(node.targets)==1 and isinstance(node.targets[0],ast.Name)
    constants[node.targets[0].id]=ast.literal_eval(node.value)
assert set(constants)=={'PRIVATE_FACTORY_FIXTURE_OWNER','PRIVATE_FACTORY_FIXTURE_PATHS','PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS'}
assert constants['PRIVATE_FACTORY_FIXTURE_OWNER']=='PERL-PRIVATE-FACTORY-CAPTURE.7'
paths=inventory['suites']+inventory['helpers']
assert constants['PRIVATE_FACTORY_FIXTURE_PATHS']==tuple(paths) and len(paths)==137
assert len(constants['PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS'])==1
anchor,block=constants['PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS'][0]
assert anchor==decode(registration['anchor_base64']) and block==raw(PREFIX+'registration-block.sh')
assert len(block.splitlines())==150 and sha(block)==registration['block_sha256']
assert original_runner.count(anchor)==1
runner=raw(RUNNER)
assert runner==original_runner.replace(anchor,anchor+block,1),'one exact runner insertion/outside bytes'
assert sha(runner)==registration['runner_after_sha256']
controls=raw(PREFIX+'auditor-controls.py')
first=original.replace(b'PERL_STORAGE_REPLACEMENTS = (\n',constant_raw+b'PERL_STORAGE_REPLACEMENTS = (\n',1)
first=first.replace(b'(KNOWLEDGE_HEADER_GATE_CI_INSERTIONS + SCALAR_RECEIVER_COPY_CI_INSERTIONS',
    b'(PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS + KNOWLEDGE_HEADER_GATE_CI_INSERTIONS + SCALAR_RECEIVER_COPY_CI_INSERTIONS',1)
metadata=b'            "scalar_receiver_copy_owner": SCALAR_RECEIVER_COPY_OWNER,\n            "knowledge_header_gate_owner": KNOWLEDGE_HEADER_GATE_OWNER,\n'
assert first.count(metadata)==1
first=first.replace(metadata,metadata+b'            "private_factory_fixture_owner": PRIVATE_FACTORY_FIXTURE_OWNER,\n',1)
assert first.count(b'            verify = verify_governance_evolution\n')==1
first=first.replace(b'            verify = verify_governance_evolution\n',controls+b'            verify = verify_governance_evolution\n',1)
assert first==raw(PREFIX+'auditor-first.py') and sha(first)==registration['auditor_after_sha256'],'complete first auditor reconstruction'
repair=load('registration-repair.json')
assert repair['producer_sha256']==sha(raw(PREFIX+'finish-registration.py')) and repair['original_source_sha256']==sha(raw(PREFIX+'register.py'))
assert repair['original_exit_observed']==1 and b'line 59' in decode(repair['original_combined_base64'])
assert original.count(b'            "knowledge_header_gate_owner": KNOWLEDGE_HEADER_GATE_OWNER,\n')==2
control_repair=load('controls-repair.json')
assert control_repair['producer_sha256']==sha(raw(PREFIX+'repair-controls.py'))
assert control_repair['original_auditor_sha256']==sha(first)
before,after=decode(control_repair['old_base64']),decode(control_repair['new_base64'])
assert first.count(before)==1
current=raw(AUDITOR)
assert current==first.replace(before,after,1) and sha(current)==control_repair['corrected_auditor_sha256'],'exact block-scoped control repair'
census={p:dict(whole_runner=runner.count((' '+p+'\n').encode()),owned_block=block.count((' '+p+'\n').encode())) for p in paths}
assert census==control_repair['path_census'] and all(v['owned_block']==1 for v in census.values())
assert control_repair['collisions']=={p:v for p,v in census.items() if v['whole_runner']!=1} and len(control_repair['collisions'])==6
first_channels_raw=raw(PREFIX+'audit-channels.json.gz')
assert sha(first_channels_raw)==control_repair['actual_failed_channels_sha256']
first_channels=json.loads(gzip.decompress(first_channels_raw))
assert first_channels['returncode']!=0 and not decode(first_channels['stdout_base64'])
assert b'private fixture path is not unique' in decode(first_channels['stderr_base64'])

text=gzip.decompress(raw(LOG)).decode();found=[]
for match in re.finditer(r'^\{',text,re.M):
    try:value,_=json.JSONDecoder().raw_decode(text,match.start())
    except json.JSONDecodeError:continue
    if isinstance(value,dict) and {'audit_report','audit_controls','healthy_audit_guard'}<=set(value):found.append(value)
assert len(found)==1
baseline=found[0]
assert baseline['tracked_inputs'][RUNNER]==sha(original_runner) and baseline['tracked_inputs'][AUDITOR]==sha(original)
historical=next(v for v in baseline['audit_report']['governance_updates'] if v['path']==RUNNER)['historical']
spec=importlib.util.spec_from_file_location('readonly_original_auditor',ROOT/(PREFIX+'auditor-original.py'))
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
module.verify_governance_evolution(RUNNER,original_runner,historical)
try:module.verify_governance_evolution(RUNNER,runner,historical)
except ValueError as error:assert str(error)=='unreviewed governance drift: '+RUNNER
else:raise AssertionError('unchanged original auditor must deny new insertion')
for name in ('audit-original-baseline.json','audit-original-red.json'):
    value=load(name)
    assert value==registration['baseline' if 'baseline' in name else 'original_audit_red']
assert registration['baseline']['returncode']==0 and registration['original_audit_red']['returncode']!=0

record=load('audit-final.json');channels_raw=raw(PREFIX+'audit-final-channels.json.gz')
assert record['result']=='PASS' and record['producer_sha256']==sha(raw(PREFIX+'finish-audit.py'))
assert record['command_capture_producer']==PREFIX+'capture-audit-final.py'
assert record['command_capture_producer_sha256']==sha(raw(PREFIX+'capture-audit-final.py'))
assert record['channels_sha256']==sha(channels_raw)
channels=json.loads(gzip.decompress(channels_raw))
assert channels['returncode']==record['returncode']==0 and channels['command']==record['command']
assert not decode(channels['stderr_base64'])
actual=json.loads(decode(channels['stdout_base64']))
manifest=json.loads(raw('tests/language-readiness/artifacts/objective-audit-inputs.json'))
expected_hashes={v['path']:v['sha256'] for v in manifest['entries']}
assert actual['restored_hashes']==baseline['restored_hashes']==expected_hashes
assert actual['restored_inputs']==record['restored_inputs']==len(expected_hashes)==134,'actual recovered membership'
assert actual['restored_bytes']==record['restored_bytes']==sum(v['bytes'] for v in manifest['entries'])==84613241
assert actual['controls']==baseline['controls'] and len(actual['controls'])==record['recovery_controls']==22
assert actual['healthy_audit_guard']==record['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
assert actual['isolated_deterministic_capture'] is True and actual['archive']==baseline['archive']
expected=dict(baseline['audit_controls']['governance_mutations_by_source'])
expected[RUNNER]+=2*len(paths)+6
assert actual['audit_controls']['governance_mutations_by_source']==expected,'all actual evolution source populations'
assert actual['audit_controls']['governance_mutations_rejected']==sum(expected.values())==368,'all actual evolution denials'
assert record['audit_controls']==actual['audit_controls']
expected_updates=[]
for row in baseline['audit_report']['governance_updates']:
    value=dict(row)
    if row['path']==RUNNER:value.update(current=sha(runner),private_factory_fixture_owner='PERL-PRIVATE-FACTORY-CAPTURE.7')
    expected_updates.append(value)
assert actual['audit_report']['governance_updates']==record['governance_updates']==expected_updates
failure=load('audit-metadata-failure.json')
assert failure['command_returncode']==0 and failure['outer_exit_observed']==1
assert failure['observed_recovered']==134 and failure['incorrect_expected_recovered']==192
assert b"assert actual['restored_inputs']==192" in decode(failure['outer_combined_base64'])
assert failure['actual_channels_sha256']==sha(channels_raw)
packed=raw(PREFIX+'audit-final-inputs.json.gz');assert record['capsule_sha256']==sha(packed)
capsule=json.loads(gzip.decompress(packed))
assert set(capsule)==set(record['inputs']) and set(actual['tracked_inputs'])<=set(capsule)
for p,row in capsule.items():
    value=raw(p)
    assert decode(row['bytes_base64'])==value and row['sha256']==sha(value),'complete actual audit input bytes'
    assert row['mode']==(ROOT/p).stat().st_mode&0o7777 and record['inputs'][p]==dict(sha256=sha(value),mode=row['mode'])
    if p in actual['tracked_inputs']:assert sha(value)==actual['tracked_inputs'][p]
raw(PREFIX+'review-audit.py')
report=dict(result='PASS',base=BASE,producer_sha256=sha(raw(PREFIX+'review-audit.py')),
    runner_inserted_lines=150,selected_paths=137,restored_inputs=134,restored_bytes=84613241,
    recovery_controls=22,evolution_denials=368,new_evolution_denials=280,audit_inputs=len(capsule),
    inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
    scope='Independent full accepted runner/auditor and exact registration/correction reconstruction; actual old-auditor baseline/RED; complete successful historical proof channels and manifest-derived recovered membership. All22 recovery and368 evolution denials match the accepted original population plus280 narrow new block mutations. Full194 captured input bytes/modes and separate successful command-capture/metadata actors remain gated. First control-scope and metadata-count failures stay exact; no native replay, original-log read, tracked write, copied-root, immutable host-toolchain or broader admission is inferred.')
target=ROOT/(PREFIX+'audit-review.json')
if sys.argv[1:]:
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:assert json.loads(target.read_bytes())==report
print('Historical audit review PASS:exact150-line insertion;134 recovered/22 recovery/368 evolution denials;194 full inputs;all original actors retained')
