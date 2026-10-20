"""Run the original auditor from explicit restored inputs under calibrated denial guards."""
import gzip
import importlib.util
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-signature/'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
proposals = json.loads(gzip.decompress((ROOT / (P + 'proposals.json.gz')).read_bytes()))
previous = json.loads(gzip.decompress((ROOT / (P + 'historical-final-run.json.gz')).read_bytes()))
plan = json.loads((ROOT / (P + 'historical-final-inputs.json')).read_bytes())


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


proof = load('current_objective_recovery_proof', PROOF)
recovery = load('original_control_recovery', proof.DECODER)
recovered = recovery.validate(recovery.read_input(recovery.MANIFEST), recovery.read_input(recovery.ARCHIVE))
base = recovery.SCRATCH + 'type-values-original-' + str(os.getpid())
root = recovery.restore(base, recovered)
assert root.stat().st_dev == ROOT.stat().st_dev
restored = {path: dict(sha256=c.sha((root / path).read_bytes()),
                      mode=(root / path).stat().st_mode & 0o7777) for path in recovered}
assert all(restored[path]['sha256'] == c.sha(raw) for path, raw in recovered.items())
paths = set(plan['proof_inputs']) | {P + 'preservation.json.gz', P + 'proposals.json.gz',
    P + 'historical-final-inputs.json', P + 'historical-final-run.json.gz', P + 'baseline_isolated.py'}
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
c.write_new(P + 'baseline-isolated-inputs.json', dict(inputs=inputs, restored=restored,
    producer=c.read(P + 'baseline_isolated.py'), original_auditor=preserved['before'][AUDITOR],
    phase0_before=proposals['phase0_before_command'],
    scope='Premeasurement identities/modes for all declared current proof artifacts and every '
          'restored original log. Only real c053 Phase0 source is supplied to the original '
          'auditor; historical logs are supplied exclusively from the validated archive.'))
namespace = dict(__name__='original_isolated_signature_auditor', __file__=str(ROOT / AUDITOR))
exec(compile(c.decode(preserved['before'][AUDITOR]['base64']), AUDITOR, 'exec'), namespace)
original_reader = namespace['read_relative']
phase0_before = c.decode(proposals['phase0_before_command']['stdout_base64'])


def reader(path):
    if path == 't/phase0_regression.t':
        return phase0_before
    if path in recovered:
        return (root / path).read_bytes()
    recovery.require(not path.startswith('.linkedspec-data/'), 'unowned local input rejected')
    return original_reader(path)


namespace['read_relative'] = reader
original_paths = {(ROOT / path).resolve() for path in recovered}
with proof.read_write_guard(original_paths) as guard:
    for kind in ('read', 'write'):
        try:
            if kind == 'read':
                (ROOT / next(iter(recovered))).read_bytes()
            else:
                (ROOT / AUDITOR).open('wb')
        except ValueError as error:
            assert str(error) == ('original log read denied' if kind == 'read' else 'tracked write denied')
        else:
            raise AssertionError('Denial guard did not observe the actual calibration attempt')
    assert guard == dict(original_log_attempts=1, tracked_write_attempts=1)
    guard.update(original_log_attempts=0, tracked_write_attempts=0)
    report = namespace['audit_evidence'](reader)
    controls = namespace['falsify'](report)
    assert guard == dict(original_log_attempts=0, tracked_write_attempts=0)
    healthy_guard = dict(guard)
assert controls == previous['baseline_controls']
assert report == previous['baseline_report']
assert all(all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')) for path, item in inputs.items())
assert all((root / path).read_bytes() == recovered[path] and
           (root / path).stat().st_mode & 0o7777 == item['mode'] for path, item in restored.items())
c.write_new(P + 'baseline-isolated-run.json.gz', dict(result='PASS', report=report, controls=controls,
    healthy_guard=healthy_guard, calibration=True, producer=c.read(P + 'baseline_isolated.py'),
    restored_inputs=len(restored), restored_bytes=sum(map(len, recovered.values())),
    current_inputs_bytes_modes_unchanged=True, restored_inputs_bytes_modes_unchanged=True,
    scope='Complete current original-control baseline. The earlier outer baseline remains '
          'supplemental with its original-path limitation; no missing initial mode/denial '
          'observation is invented. This isolated baseline reproduces its exact report and '
          'all368 controls from declared source/archive inputs under actual denial guards.'), packed=True)
print('Original baseline isolated PASS:', controls['governance_mutations_rejected'],
      'controls;', len(restored), 'restored inputs; actual original-log/tracked-write attempts0')
