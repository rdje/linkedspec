"""Read-only review of the retained failed candidate and exact historical CI inverse."""
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import types

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
digest = lambda raw: hashlib.sha256(raw).hexdigest()
packet = json.loads((HERE / 'attempt-02.json').read_bytes())
patch = gzip.decompress((HERE / 'attempt-02-candidate.patch.gz').read_bytes())
assert digest(patch) == packet['candidate_diff']['sha256']
assert len(patch) == packet['candidate_diff']['bytes']
assert packet['fingerprint_after_exit_before_changes'] == packet['base_head'] + ' ' + digest(patch)
stderr = base64.b64decode(packet['channels']['stderr.log']).decode()
assert packet['tool_reported_exit_code'] == 1
assert 'ALL 10 enforced doctrines PASS' in stderr
assert 'ValueError: governance registration mismatch: tools/run_ci_local.sh' in stderr
envelope = json.loads((HERE / 'after.json').read_bytes())
raw = gzip.decompress(base64.b64decode(envelope['data']))
assert len(raw) == envelope['bytes'] and digest(raw) == envelope['sha256']
observed = json.loads(raw)

def require(condition, message):
    if not condition:
        raise ValueError(message)

def verify(data):
    require(len(data['inputs']) == 192, 'supplied input population')
    for path, row in data['inputs'].items():
        p = Path(path)
        require(not p.is_absolute() and '..' not in p.parts, 'unsafe input path')
        body = base64.b64decode(row['data'])
        require(digest(body) == row['sha256'], 'retained input hash')
        require((ROOT / p).read_bytes() == body, 'current supplied input changed')
    execution = data['execution']
    require(execution['returncode'] == 0, 'actual historical proof exit')
    report = json.loads(base64.b64decode(execution['stdout_base64']))
    require(report['healthy_audit_guard'] == {'original_log_attempts': 0, 'tracked_write_attempts': 0},
            'healthy historical guards')
    require(report['restored_inputs'] == 134 and len(report['controls']) == 22,
            'historical recovery population')
    controls = report['audit_controls']
    require(controls['governance_mutations_by_source'] == {
        'tools/run_ci_local.sh': 37, 'tools/test_perl_project_data_storage.sh': 6,
        't/phase0_regression.t': 21, 'perl/LinkedSpec/ActionIR/Contracts.pm': 10},
        'actual evolution controls')
    require(controls['governance_mutations_rejected'] == 74, 'actual evolution total')
    require(all(data['inputs'][p]['sha256'] == h for p, h in report['tracked_inputs'].items()),
            'actual producer input identities')
    return report

report = verify(observed)
before = json.loads((HERE / 'before.json').read_bytes())
audit = types.ModuleType('retained_original_auditor')
audit.__file__ = str(ROOT / 'tests/language-readiness/verify_objectives.py')
exec(compile(base64.b64decode(packet['inputs']['tests/language-readiness/verify_objectives.py']),
             audit.__file__, 'exec'), audit.__dict__)
baseline = subprocess.check_output(['git', 'show', packet['base_head'] + ':tools/run_ci_local.sh'], cwd=ROOT)
assert audit.verify_governance_evolution('tools/run_ci_local.sh', baseline, before['historical_hash']) == before['baseline']
try:
    audit.verify_governance_evolution('tools/run_ci_local.sh',
        base64.b64decode(packet['inputs']['tools/run_ci_local.sh']), before['historical_hash'])
except ValueError as error:
    assert str(error) == before['native_rejection']
else:
    raise AssertionError('original CI rejection lost')
controls = (
    ('exit', lambda d: d['execution'].update(returncode=1), 'actual historical proof exit'),
    ('population', lambda d: d['inputs'].pop(next(iter(d['inputs']))), 'supplied input population'),
    ('hash', lambda d: d['inputs'][next(iter(d['inputs']))].update(sha256='0' * 64), 'retained input hash'),
)
for name, mutate, reason in controls:
    changed = copy.deepcopy(observed)
    mutate(changed)
    try:
        verify(changed)
    except ValueError as error:
        assert str(error) == reason, name
    else:
        raise AssertionError('evidence corruption accepted: ' + name)
assert verify(observed) == report
print('Historical CI compatibility review PASS: original RED; full192 inputs; actual22/74 controls; evidence3')
