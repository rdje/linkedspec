"""Measure actual historical recovery plus the retained original auditor's controls."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-signature/'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
TABLE = 'tests/language-readiness/evaluated-value-regression-evolution.json'
SEED = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2-historical-actual.json'
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
proposals = json.loads(gzip.decompress((ROOT / (P + 'proposals.json.gz')).read_bytes()))
assert all(c.read(path) == item for path, item in proposals['after'].items())
seed = json.loads((ROOT / SEED).read_bytes())
block = seed['stdout']
assert block['encoding'] == 'gzip-base64'
raw = gzip.decompress(c.decode(block['data']))
assert len(raw) == block['bytes'] and c.sha(raw) == block['sha256']
original = json.loads(raw)
proof_inputs = set(original['tracked_inputs']) | {TABLE}
paths = proof_inputs | {SEED, P + 'preservation.json.gz', P + 'baseline.json',
    P + 'proposals.json.gz', P + 'apply.py', P + 'preserve.py', P + 'capture.py'}
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
c.write_new(P + 'historical-inputs.json', dict(inputs=inputs, proof_inputs=sorted(proof_inputs),
    instrument=c.read(P + 'capture.py'), original_auditor=preserved['before'][AUDITOR],
    current_auditor=c.read(AUDITOR), current_proof=c.read(PROOF),
    scope='Actual input identities/modes precede execution. The dated retained report supplies '
          'the old explicit input membership; the new table is added explicitly. Actual reported '
          'membership must equal this independent preselection. Baseline original auditor uses '
          'the real c053 Phase0 bytes with all other current inputs unchanged; it is an archival '
          'source-integrity baseline, not a new historical/runtime execution.'))
namespace = dict(__name__='original_signature_auditor', __file__=str(ROOT / AUDITOR))
exec(compile(c.decode(preserved['before'][AUDITOR]['base64']), AUDITOR, 'exec'), namespace)
read_original = namespace['read_relative']
phase0_before = c.decode(proposals['phase0_before_command']['stdout_base64'])


def baseline_reader(path):
    return phase0_before if path == 't/phase0_regression.t' else read_original(path)


namespace['read_relative'] = baseline_reader
baseline_report = namespace['audit_evidence'](baseline_reader)
baseline_controls = namespace['falsify'](baseline_report)
run = c.run(['bash', 'tools/run_python_project_data.sh', PROOF])
# Retain complete channels before interpreting any candidate postcondition.
c.write_new(P + 'historical-run.json.gz', dict(run=run, producer=c.read(P + 'capture.py'),
    baseline_report=baseline_report, baseline_controls=baseline_controls,
    input_identities=inputs), packed=True)
assert run['returncode'] == 0 and c.decode(run['stderr_base64']) == b''
actual = json.loads(c.decode(run['stdout_base64']))
assert set(actual['tracked_inputs']) == proof_inputs
assert all(actual['tracked_inputs'][path] == inputs[path]['sha256'] for path in proof_inputs)
assert actual['isolated_deterministic_capture']
assert actual['healthy_audit_guard'] == dict(original_log_attempts=0, tracked_write_attempts=0)
assert actual['restored_inputs'] == original['restored_inputs']
assert actual['restored_bytes'] == original['restored_bytes']
assert actual['controls'] == original['controls']
candidate_controls = actual['audit_controls']
addition = 3 * proposals['hunks']
assert candidate_controls['governance_mutations_rejected'] == baseline_controls['governance_mutations_rejected'] + addition
for path, count in baseline_controls['governance_mutations_by_source'].items():
    assert candidate_controls['governance_mutations_by_source'][path] == count + (addition if path == 't/phase0_regression.t' else 0)
assert set(candidate_controls['governance_mutations_by_source']) == set(baseline_controls['governance_mutations_by_source'])
current_namespace = dict(__name__='current_signature_auditor', __file__=str(ROOT / AUDITOR))
exec(compile(c.decode(proposals['after'][AUDITOR]['base64']), AUDITOR, 'exec'), current_namespace)
reader = current_namespace['read_relative']
table_raw = (ROOT / TABLE).read_bytes()
assert table_raw.endswith(b'\n')
changed_table = table_raw[:-1] + b' '
assert json.loads(changed_table) == json.loads(table_raw) and changed_table != table_raw
current_namespace['read_relative'] = lambda path: changed_table if path == TABLE else reader(path)
observed = None
try:
    current_namespace['verify_signature_regression_evolution'](
        't/phase0_regression.t', c.decode(proposals['phase0_after']['base64']),
        proposals['historical_source']['sha256'])
except ValueError as error:
    observed = str(error)
finally:
    current_namespace['read_relative'] = reader
restored = current_namespace['verify_signature_regression_evolution'](
    't/phase0_regression.t', c.decode(proposals['phase0_after']['base64']),
    proposals['historical_source']['sha256'])
c.write_new(P + 'table-control.json', dict(producer=c.read(P + 'capture.py'),
    changed_base64=c.encode(changed_table), semantic_json_unchanged=True,
    observed_red=observed, restored=restored,
    scope='Actual maintained auditor reads the altered table bytes through its reader. '
          'Only trailing whitespace changes, so JSON parsing/content remain valid; '
          'the exact identity guard must distinguish it. The original reader restores.'))
assert observed == 'evaluated-value inverse table identity mismatch: t/phase0_regression.t'
assert all(all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')) for path, item in inputs.items())
c.write_new(P + 'historical-review.json', dict(result='PASS',
    original_verifier_red=proposals['original_verifier_red'],
    fragments=proposals['hunks'], added_source_denials=addition,
    original_controls=baseline_controls, current_controls=candidate_controls,
    restored_inputs=actual['restored_inputs'], restored_bytes=actual['restored_bytes'],
    recovery_controls=len(actual['controls']), healthy_audit_guard=actual['healthy_audit_guard'],
    proof_inputs=len(proof_inputs), input_bytes_modes_unchanged=True,
    table_identity_red=observed,
    scope='Complete original historical bytes/hash recover after the exact owned inverse. '
          'Every original auditor control remains effective; three new actual source denials '
          'per fragment are additional. Archive membership, original log denial and tracked '
          'write denial retain their original population and outcomes. No old claim/hash/log '
          'or runtime result is refreshed.'))
print('Historical inverse PASS:', proposals['hunks'], 'fragments;', addition,
      'additional denials;', actual['restored_inputs'], 'restored inputs;', len(actual['controls']), 'recovery controls')
