"""Retain the scanner's exact three-occurrence repair and distinguishing producer faults."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-selector/'
saved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
proposal = json.loads(gzip.decompress((ROOT / (P + 'proposals.json.gz')).read_bytes()))
assert c.unchanged(proposal['after'])
paths = set(saved['inputs']) | set(proposal['after']) | set(proposal['fixtures'])
paths.update(str(path.relative_to(ROOT)) for path in (ROOT / P).iterdir() if path.is_file())
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
c.write_new(P + 'scanner-inputs.json', dict(inputs=inputs, producer=c.read(P + 'capture.py'),
    scope='The full old837 closure, actual new scanner, three fixture files and all '
          'instruments precede every observation; old native observations remain exact.'))
runs = [dict(name=name, run=c.run(['bash', 'tools/run_python_project_data.sh', P + 'probe.py', name]))
        for name in ('healthy', 'drop-current', 'drop-prior', 'drop-owner', 'healthy')]
commands = [
    ['bash', 'tools/run_python_project_data.sh', 'tools/check_executable_aggregate_selector_sources.py'],
    ['bash', 'tools/run_python_project_data.sh', 'tools/check_executable_aggregate_selector_sources.py', '--concurrency-self-test'],
    ['bash', 'tools/run_python_project_data.sh', 'tools/check_public_aggregate_selector_surface.py'],
]
public = [c.run(command) for command in commands]
unchanged = all(all(c.read(path)[key] == item[key] for key in ('sha256', 'mode'))
                for path, item in inputs.items())
c.write_new(P + 'scanner-run.json.gz', dict(runs=runs, public=public,
    producer=c.read(P + 'capture.py'), inputs_bytes_modes_unchanged=unchanged), packed=True)
for index in (0, 4):
    run = runs[index]['run']
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    result = json.loads(c.decode(run['stdout_base64']))
    assert result['healthy_controls'] == 6 and result['rejection_controls'] == 28
    assert not result['unexpected']
for row, count in zip(runs[1:4], (9, 6, 3)):
    assert row['run']['returncode'] == 1 and not c.decode(row['run']['stderr_base64'])
    result = json.loads(c.decode(row['run']['stdout_base64']))
    assert len(result['unexpected']) == count, result
assert all(run['returncode'] == 0 for run in public)
assert unchanged
c.write_new(P + 'scanner-review.json', dict(result='PASS', fixtures=3, healthy_controls=6,
    rejected_controls=28, producer_fault_unexpected_acceptances=[9, 6, 3],
    full_scan=True, concurrent_scans=3, composed_public_admission=True,
    inputs_bytes_modes_unchanged=True,
    scope='Original and current exact fixture bytes admit; edited, copied, appended, '
          'foreign-owner and wrong/missing hash registrations reject. Actual current/prior/'
          'owner producer-check removal is RED and exact restoration is GREEN. Selector '
          'regex, generic classifications and original historical registrations are unchanged.'))
print('Selector admissions PASS:3 fixtures,28 denials, actual producer faults9/6/3 and restoration')
