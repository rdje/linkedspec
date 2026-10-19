"""Finalize the successful actual audit without replaying its command or source."""
import base64
import gzip
import hashlib
import json
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
MANIFEST='tests/language-readiness/artifacts/objective-audit-inputs.json'
LOG='docs/checkpoints/REPO-HYGIENE.19/canonical.log.gz'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
decode=lambda v:base64.b64decode(v,validate=True)
target=ROOT/(PREFIX+'audit-final.json');assert not target.exists()
channels_raw=(ROOT/(PREFIX+'audit-final-channels.json.gz')).read_bytes()
channels=json.loads(gzip.decompress(channels_raw))
assert channels['command']==['bash','tools/run_python_project_data.sh',PROOF] and channels['returncode']==0
assert not decode(channels['stderr_base64'])
actual=json.loads(decode(channels['stdout_base64']))
manifest=json.loads((ROOT/MANIFEST).read_bytes())
assert actual['restored_inputs']==len(manifest['entries'])==len(actual['restored_hashes'])==134
assert actual['restored_bytes']==sum(v['bytes'] for v in manifest['entries'])==84613241
assert actual['restored_hashes']=={v['path']:v['sha256'] for v in manifest['entries']}
assert actual['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
assert actual['isolated_deterministic_capture'] is True
text=gzip.decompress((ROOT/LOG).read_bytes()).decode();found=[]
for match in re.finditer(r'^\{',text,re.M):
    try:value,_=json.JSONDecoder().raw_decode(text,match.start())
    except json.JSONDecodeError:continue
    if isinstance(value,dict) and {'audit_report','audit_controls','healthy_audit_guard'}<=set(value):found.append(value)
assert len(found)==1
baseline=found[0]
assert baseline['restored_hashes']==actual['restored_hashes'] and baseline['archive']==actual['archive']
assert baseline['restored_inputs']==134 and baseline['restored_bytes']==84613241
assert len(actual['controls'])==len(baseline['controls'])==22
old=baseline['audit_controls'];new=actual['audit_controls']
expected=dict(old['governance_mutations_by_source']);expected['tools/run_ci_local.sh']+=280
assert new['governance_mutations_by_source']==expected and new['governance_mutations_rejected']==old['governance_mutations_rejected']+280==368
combined=(ROOT/'.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.7-audit-final.log').read_bytes()
assert b"assert actual['restored_inputs']==192" in combined and combined.rstrip().endswith(b'AssertionError')
capture=(ROOT/(PREFIX+'capture-audit-final.py')).read_bytes()
failure=dict(result='RETAINED',command_returncode=0,outer_exit_observed=1,outer_combined_base64=encode(combined),
    command_capture_producer=PREFIX+'capture-audit-final.py',command_capture_producer_sha256=sha(capture),
    actual_channels_sha256=sha(channels_raw),observed_recovered=134,incorrect_expected_recovered=192,
    scope='Complete actual historical proof succeeded and remains unchanged. Only the outer metadata guard confused the old supplied-closure count with recovered archive membership. Manifest and accepted canonical observation both derive134 recovered files. A distinct metadata producer finalizes closure without a native replay or producer relabeling.')
with (ROOT/(PREFIX+'audit-metadata-failure.json')).open('x') as output:output.write(json.dumps(failure,indent=2)+'\n')
paths=set(actual['tracked_inputs'])|{PROOF,MANIFEST,LOG,'tools/run_ci_local.sh','tests/language-readiness/verify_objectives.py',
    'tests/language-readiness/recover_objective_audit_inputs.py','tools/run_python_project_data.sh',
    'tools/project_data_env.sh','tools/project_data_run.sh'}
paths.update(PREFIX+n for n in ('capture-audit.py','capture-audit-final.py','finish-audit.py',
    'audit-channels.json.gz','audit-final-channels.json.gz','audit-metadata-failure.json',
    'auditor-first.py','controls-repair.json','repair-controls.py'))
capsule={}
for p in sorted(paths):
    source=ROOT/p;value=source.read_bytes()
    if p in actual['tracked_inputs']:assert sha(value)==actual['tracked_inputs'][p],'actual complete proof input custody'
    capsule[p]=dict(sha256=sha(value),mode=source.stat().st_mode&0o7777,bytes_base64=encode(value))
capsule_raw=gzip.compress(json.dumps(capsule,sort_keys=True).encode(),mtime=0)
with (ROOT/(PREFIX+'audit-final-inputs.json.gz')).open('xb') as output:output.write(capsule_raw)
report=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),
    command_capture_producer=PREFIX+'capture-audit-final.py',command_capture_producer_sha256=sha(capture),
    command=channels['command'],returncode=0,channels_sha256=sha(channels_raw),capsule_sha256=sha(capsule_raw),
    inputs={p:dict(sha256=v['sha256'],mode=v['mode']) for p,v in capsule.items()},
    restored_inputs=actual['restored_inputs'],restored_bytes=actual['restored_bytes'],recovery_controls=len(actual['controls']),
    audit_controls=new,governance_updates=actual['audit_report']['governance_updates'],healthy_audit_guard=actual['healthy_audit_guard'],
    scope='Successful original actual complete recovery/read-denied command/channels keep their original capture identity; only metadata/closure are finalized by this distinct producer. Manifest membership derives134 files/84613241 bytes;22 recovery controls/368 evolution REDs include280 new exact block controls, and healthy original-log reads/tracked writes are zero. All actual emitted artifact/source inputs plus explicit capture context retain full bytes/modes. Original-project Git object reads remain required; no new native run, copied-root, immutable host-toolchain or broader objective admission follows.')
with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
print('Audit metadata finalized:actual134 recovered/84613241 bytes;22 recovery/368 evolution denials;zero original-log reads/tracked writes;no replay')
