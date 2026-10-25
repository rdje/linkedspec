"""Retain the actual public1 observer failure before corrected acceptance."""
import common as c

result=c.load('public1-result.json.gz')
runs=c.load('public1-runs.json.gz')
assert result['programs']==113 and result['observations']==452
assert result['failure_count']==4 and runs['tests']['returncode']==0
assert all(row['route']=='generated_wrapper' and row['actual']['injected_identity'] is True
    and row['actual']['native_error']['diagnostic']['code']=='fixture_evaluation_failed'
    for row in result['failures'])
c.save('public1-qualification.json.gz',dict(producer=c.read(c.PREFIX+'qualify_public.py'),
    inputs=c.read(c.PREFIX+'public1-inputs.json.gz'),
    result=c.read(c.PREFIX+'public1-result.json.gz'),runs=c.read(c.PREFIX+'public1-runs.json.gz'),
    interface=c.read('dart/lib/src/source_emitter.dart'),
    qualification='All113 programs compiled and452 observations completed; permanent114 tests passed. '
        'The independent Python observer wrongly required generic generated metadata for four '
        'caller-sink failures. The existing _GeneratedDiagnosticOutputSinkFailure catch preserves '
        'the caller exception and stack identity. The complete failed oracle/input epoch is retained; '
        'public2 corrects that expectation only and strengthens the permanent exception-carrier test. '
        'No runtime defect, source change or product-RED credit from this observer failure.'))
print('public1 caller-exception observer qualification retained')
