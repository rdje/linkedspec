"""Retain six actual syntax-valid whole-source trim counterfactuals once."""
import base64
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '354c15530fd1445ebfa8c6c0683e7b8d066caced'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_dropped_trim_probe.pl'
COLD = 't/actionir_dropped_trim_cold_probe.pl'
TEST = 't/actionir_dropped_trim_capture.t'
NATIVE = PREFIX + 'native.json'
TARGET = ROOT / (PREFIX + 'inverses.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
b64 = lambda raw: base64.b64encode(raw).decode()
assert not TARGET.exists(), 'one-shot semantic fault capture'
seed = json.loads(subprocess.check_output(['git', 'show', BASE + ':docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-consumers-final.json'], cwd=ROOT))
files = {p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT) for p in seed['inputs']}
current = (ROOT / MODULE).read_bytes()
files[MODULE] = current
for p in (PROBE, COLD, TEST, NATIVE):
    assert p not in files
    files[p] = (ROOT / p).read_bytes()
assert len(files) == 215
start = current.index(b'sub _lower_dropped_value_statement {')
end = current.index(b'\nsub _lower_ast_call_statement {', start)
owner = current[start:end]
call = b'_bind_emission_dependency($trim_action_ir_value)->($expr)'
assert owner.count(call) == 1
guard = (b' die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback \'trim_action_ir_value\'"\n'
         b"  unless ref($trim_action_ir_value) eq 'CODE';")
cases = [
    ('raw-call', call, b'$trim_action_ir_value->($expr)', 'dropped trim known0 child cannot donate parent packet'),
    ('wrapper-identity', call, b'_bind_emission_dependency(sub { $trim_action_ir_value->(@_) })->($expr)', 'dropped trim known1 actual callback controls eligibility'),
    ('coerced-argument', call, b"_bind_emission_dependency($trim_action_ir_value)->(''.$expr)", 'dropped trim reference-input complete native observation'),
    ('removed-code-validation', guard, b'\n', 'dropped trim deps-missing keeps its required diagnostic'),
    ('removed-input-guard', b' return undef unless defined $expr;', b'', 'dropped trim undefined-tied stops before dependency lookup'),
    ('caller-equality', b'return undef if $lowered eq $trimmed;', b'return undef if $lowered eq $expr;', 'dropped trim method-mutated-original authored result'),
]
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)


def run(command, directory):
    result = subprocess.run(command, cwd=directory, env=environment, capture_output=True)
    return {'command': command, 'returncode': result.returncode,
            'stdout_base64': b64(result.stdout), 'stderr_base64': b64(result.stderr)}


rows = []
for name, old, new, reason in cases:
    assert owner.count(old) == 1, ('exact fault site', name)
    modified_owner = owner.replace(old, new, 1)
    mutated = current[:start] + modified_owner + current[end:]
    selected = dict(files)
    selected[MODULE] = mutated
    inputs = {p: sha(raw) for p, raw in sorted(selected.items())}
    with tempfile.TemporaryDirectory(prefix='dropped-trim-fault-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for p, raw in selected.items():
            target = supplied / p
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        syntax = run(['perl', '-Iperl', '-c', MODULE], supplied)
        probe = run(['perl', '-Iperl', './' + PROBE, 'observe'], supplied)
        fixture = run(['perl', '-Iperl', TEST], supplied)
        unchanged = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()} == inputs
    stdout = base64.b64decode(fixture['stdout_base64'])
    plans = re.findall(rb'^1\.\.(\d+)$', stdout, re.M)
    assertions = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', stdout, re.M)
    failed = [label.decode() for flag, _, label in assertions if flag]
    artifact = PREFIX + 'inverse-' + name + '.json'
    record = {'name': name, 'module_base64': b64(mutated), 'inputs': inputs,
        'replacement': {'old_base64': b64(old), 'new_base64': b64(new)},
        'syntax': syntax, 'probe': probe, 'fixture': fixture, 'unchanged': unchanged,
        'failures': failed, 'required_reason': reason,
        'producer_sha256': sha(Path(__file__).read_bytes())}
    assert not (ROOT / artifact).exists()
    (ROOT / artifact).write_text(json.dumps(record, indent=2) + '\n')
    # Retain the full variant and all actual channels before interpretation.
    rows.append({'name': name, 'artifact': artifact, 'artifact_sha256': sha((ROOT / artifact).read_bytes()),
                 'failure_count': len(failed), 'required_reason': reason})
    TARGET.write_text(json.dumps({'result': 'pending', 'rows': rows}, indent=2) + '\n')
    assert syntax['returncode'] == 0 and b'syntax OK' in base64.b64decode(syntax['stderr_base64'])
    assert probe['returncode'] == 0 and not base64.b64decode(probe['stderr_base64'])
    assert unchanged and len(plans) == 1 and int(plans[0]) == 298
    assert [int(number) for _, number, _ in assertions] == list(range(1, 299))
    assert fixture['returncode'] != 0 and reason in failed, ('distinguishing semantic RED', name, failed)
report = {'result': 'PASS', 'rows': rows, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'module_sha256': sha(current), 'scope': 'Six exact whole-source syntax-valid variants supplied with215 exact inputs each. Actual original probe and identical298-assertion fixture retain complete channels and distinguishing semantic reasons. No current/native artifact or old observation is refreshed.'}
TARGET.write_text(json.dumps(report, indent=2) + '\n')
print('Dropped trim source faults PASS:', [(row['name'], row['failure_count']) for row in rows])
