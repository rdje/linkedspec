"""Capture the actual complete historical recovery/read-denied audit once."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
sha=lambda v:hashlib.sha256(v).hexdigest()
target=ROOT/(PREFIX+'audit.json');assert not target.exists()
sources=[PROOF,'tools/run_ci_local.sh','tests/language-readiness/verify_objectives.py',
    'tests/language-readiness/recover_objective_audit_inputs.py',
    'tools/run_python_project_data.sh','tools/project_data_env.sh','tools/project_data_run.sh',
    PREFIX+'capture-audit.py']
before={p:sha((ROOT/p).read_bytes()) for p in sources}
command=['bash','tools/run_python_project_data.sh',PROOF]
run=subprocess.run(command,cwd=ROOT,capture_output=True)
channels=dict(command=command,returncode=run.returncode,stdout_base64=base64.b64encode(run.stdout).decode(),stderr_base64=base64.b64encode(run.stderr).decode())
with (ROOT/(PREFIX+'audit-channels.json.gz')).open('xb') as output:output.write(gzip.compress(json.dumps(channels,sort_keys=True).encode(),mtime=0))
assert run.returncode==0,run.stderr
actual=json.loads(run.stdout)
assert actual['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
assert actual['restored_inputs']==192 and actual['isolated_deterministic_capture'] is True
assert before=={p:sha((ROOT/p).read_bytes()) for p in sources}
paths=set(sources)|set(actual['tracked_inputs'])
capsule={}
for p in sorted(paths):
    source=ROOT/p;value=source.read_bytes()
    if p in actual['tracked_inputs']:assert sha(value)==actual['tracked_inputs'][p]
    capsule[p]=dict(sha256=sha(value),mode=source.stat().st_mode&0o7777,bytes_base64=base64.b64encode(value).decode())
capsule_raw=gzip.compress(json.dumps(capsule,sort_keys=True).encode(),mtime=0)
with (ROOT/(PREFIX+'audit-inputs.json.gz')).open('xb') as output:output.write(capsule_raw)
report=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),command=command,
    returncode=run.returncode,channels_sha256=sha((ROOT/(PREFIX+'audit-channels.json.gz')).read_bytes()),
    capsule_sha256=sha(capsule_raw),inputs={p:dict(sha256=v['sha256'],mode=v['mode']) for p,v in capsule.items()},
    restored_inputs=actual['restored_inputs'],restored_bytes=actual['restored_bytes'],
    recovery_controls=len(actual['controls']),audit_controls=actual['audit_controls'],
    governance_updates=actual['audit_report']['governance_updates'],healthy_audit_guard=actual['healthy_audit_guard'],
    scope='Complete actual unchanged historical recovery/read-denied proof with current narrowly extended auditor. Every emitted artifact/source input byte and actual mode is supplied in a bound capsule; full actual command/channels remain retained. Real Git historical object reads stay in the original project; no copied-root, full immutable host-toolchain, new runtime execution or broader objective admission claim.')
with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
print('Complete historical audit PASS:',report['restored_inputs'],'recovered inputs;',report['recovery_controls'],'recovery controls;',report['audit_controls']['governance_mutations_rejected'],'evolution denials')
