"""Capture the candidate and direct-consumer proof without changing baseline observations."""
import gzip
import json
import common as c

red = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'red-inputs.json.gz')).read_bytes()))
proposal = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'candidate-proposal.json.gz')).read_bytes()))
inputs = dict(red['inputs'])
assert c.read(proposal['path']) == proposal['after']
inputs[proposal['path']] = proposal['after']
for name in ('capture_green.py', 'apply_materialization.py', 'host_list.pl', 'host-list-inputs.json', 'host-list-run.json'):
    inputs[c.PREFIX + name] = c.read(c.PREFIX + name)
assert c.unchanged(inputs)
commands = [
    ['perl', '-c', '-Iperl', 'perl/LinkedSpec/ActionIR/MethodLowering.pm'],
    ['prove', '-v', '-Iperl', 't/callable_codeblock_literal_contract.t'],
    ['prove', '-v', '-Iperl', 't/generated_source_contract.t', 't/uniform_binding_contract.t',
     't/variadic_user_function_contract.t', 't/actionir_ast_parser.t',
     't/trace_actionir_method_lowering.t', 't/trace_emit_context_bridge.t'],
]
c.write_new(c.PREFIX + 'green-inputs.json.gz', dict(inputs=inputs, cases=red['cases'], commands=commands,
    scope='Actual candidate source and every direct source/test/fixture input precede commands. '
          'Original syntax-valid RED, initial impact and host actors remain unchanged. Existing '
          'generic/explicit flat and ordinary/copy nesting controls are in the direct-dependent suites.'), packed=True)
runs = [c.run(command) for command in commands]
public = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(red['cases']).encode())
c.write_new(c.PREFIX + 'green-run.json.gz', dict(runs=runs, public=public,
    inputs_unchanged=c.unchanged(inputs)), packed=True)
print('Candidate direct-proof exits:', [run['returncode'] for run in runs], 'public:', public['returncode'])
assert all(run['returncode'] == 0 for run in runs) and public['returncode'] == 0
assert c.unchanged(inputs)
