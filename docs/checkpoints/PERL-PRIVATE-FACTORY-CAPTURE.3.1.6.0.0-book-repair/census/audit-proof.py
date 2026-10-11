"""Retain/review the actual isolated historical proof and every supplied input."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
PRODUCER = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
target = HERE / 'audit-proof.json.gz'
if sys.argv[1:]:
    assert not target.exists(), 'one-shot current historical proof'
    command = ['bash', 'tools/run_python_project_data.sh', PRODUCER]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert result.returncode == 0, result.stderr.decode()
    observed = json.loads(result.stdout)
    inputs = {p: {'sha256': digest((ROOT / p).read_bytes()),
                  'data': base64.b64encode((ROOT / p).read_bytes()).decode()}
              for p in observed['tracked_inputs']}
    packet = {'producer_sha256': digest(Path(__file__).read_bytes()), 'inputs': inputs,
              'execution': {'command': command, 'returncode': result.returncode,
                            'stdout_base64': base64.b64encode(result.stdout).decode(),
                            'stderr_base64': base64.b64encode(result.stderr).decode()}}
    target.write_bytes(gzip.compress((json.dumps(packet,indent=2)+'\n').encode(),mtime=0))
else:
    packet = json.loads(gzip.decompress(target.read_bytes()))
assert packet['producer_sha256'] == digest(Path(__file__).read_bytes())
for path,row in packet['inputs'].items():
    raw = base64.b64decode(row['data'], validate=True)
    assert digest(raw) == row['sha256'] and (ROOT / path).read_bytes() == raw, 'current historical supplied input drift: ' + path
execution = packet['execution']
assert execution['returncode'] == 0 and execution['command'] == ['bash','tools/run_python_project_data.sh',PRODUCER]
observed = json.loads(base64.b64decode(execution['stdout_base64'], validate=True))
base64.b64decode(execution['stderr_base64'], validate=True)
assert len(packet['inputs']) == 192
assert observed['tracked_inputs'] == {p:r['sha256'] for p,r in packet['inputs'].items()}
assert observed['restored_inputs'] == 134 and len(observed['controls']) == 22
assert observed['healthy_audit_guard'] == {'original_log_attempts': 0, 'tracked_write_attempts': 0}
assert observed['audit_controls']['governance_mutations_by_source'] == {
 'tools/run_ci_local.sh':37, 'tools/test_perl_project_data_storage.sh':6,
 't/phase0_regression.t':21, 'perl/LinkedSpec/ActionIR/Contracts.pm':10,
 'tools/check_public_aggregate_selector_surface.py':6,
 'tools/check_executable_aggregate_selector_sources.py':55,
}
assert observed['audit_controls']['governance_mutations_rejected'] == 135
print('Current isolated historical proof PASS: full192 inputs;134 restored;22 recovery/135 evolution denials; zero healthy original-log reads/tracked writes')
