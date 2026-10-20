"""Bind the complete owned execution inputs before observing baseline or candidate."""
import json
import subprocess
import sys
import common as c

assert sys.argv[1:] in (['red'], ['red-channel'], ['green'])
epoch = sys.argv[1]
tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=c.ROOT).decode().split('\0')
paths = {path for path in tracked if path.startswith('perl/') and path.endswith(('.pm', '.pl'))}
paths.update(path for path in tracked if path.startswith('capability_conformance/') and path.endswith('.json'))
paths.update(('tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
              'tests/scoped-with/cases.json'))
paths.update(c.PREFIX + name for name in ('common.py', 'probe.pl', 'capture.py'))
inputs = {path: c.identity(path) for path in sorted(paths)}
plan = json.loads((c.ROOT / 'tests/scoped-with/cases.json').read_bytes())
assert len(plan['cases']) == len({case['id'] for case in plan['cases']})
c.write_new(epoch + '-inputs.json', dict(inputs=inputs, plan=plan,
    accepted_before=c.BASE, source=c.read(c.SOURCE),
    scope='All owned Perl sources and neutral JSON contracts precede descriptor/Get/fresh emitted execution. '
          'System Perl/core modules are external read-only prerequisites; no dependency implementation is read.'))
run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(plan).encode())
c.write_new(epoch + '-run.json.gz', dict(run=run, inputs_unchanged=c.unchanged(inputs)))
assert run['returncode'] == 0, c.decode(run['stderr_base64']).decode()
assert c.unchanged(inputs)
print(epoch, 'scoped execution captured:', len(plan['cases']), 'cases;', len(inputs), 'declared inputs')
