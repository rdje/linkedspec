"""Capture all owned test/runtime/data inputs before direct-consumer proof."""
import subprocess
import common as c

selected = [
    't/callable_codeblock_literal_contract.t',
    't/variadic_user_function_contract.t',
    't/generated_source_contract.t',
    't/uniform_binding_contract.t',
    't/codeblock_matches_perl.t',
    't/codeblock_null_return_perl.t',
    't/codeblock_while_perl.t',
    't/codeblock_push_composition_perl.t',
    't/codeblock_attached_if_perl.t',
    't/codeblock_value_if_perl.t',
    't/codeblock_marker_if_perl.t',
    't/actionir_scalar_receiver_required_capture.t',
    't/actionir_array_receiver_required_capture.t',
    't/actionir_hash_receiver_required_capture.t',
]
tracked = subprocess.check_output(['git', 'ls-files', '-z', '--',
    'perl', 't', 'tests', 'capability_conformance', 'bin', 'tools'], cwd=c.ROOT).decode().split('\0')
paths = {path for path in tracked if path and (c.ROOT / path).is_file()}
paths.update(('tests/scoped-with/cases.json', c.PREFIX + 'common.py', c.PREFIX + 'focused.py'))
inputs = {path: c.identity(path) for path in sorted(paths)}
assert all(path in inputs for path in selected)
commands = [
    ['perl', '-c', '-Iperl', c.SOURCE],
    ['perl', '-c', '-Iperl', 't/callable_codeblock_literal_contract.t'],
    ['prove', '-q', '-Iperl'] + selected,
    ['python3', '-B', 'tools/check_callable_codeblock_contract.py'],
]
c.write_new('focused-inputs.json', dict(inputs=inputs, selected=selected, commands=commands,
    scope='Complete owned Perl/t/tests/neutral/bin/tools tracked input population, plus new fixture and actors. '
          'System Perl/Python/core libraries are read-only prerequisites. No backend or private-parent admission.'))
runs = []
for command in commands:
    run = c.run(command)
    runs.append(run)
    if run['returncode']:
        break
c.write_new('focused-run.json.gz', dict(runs=runs, inputs_unchanged=c.unchanged(inputs)))
assert all(run['returncode'] == 0 for run in runs), [(r['command'], r['returncode']) for r in runs]
assert len(runs) == len(commands) and c.unchanged(inputs)
print('Focused scoped-with proof PASS:', len(selected), 'suites;', len(inputs), 'inputs')
