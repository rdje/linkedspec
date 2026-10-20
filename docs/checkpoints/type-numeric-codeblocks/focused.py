"""Capture exact current numeric/direct-consumer and neutral-contract proof."""
import json
import re
import common as c
import context

SELECTED = [
    't/scalar_numeric_contract.t', 't/callable_codeblock_literal_contract.t',
    't/variadic_user_function_contract.t', 't/generated_source_contract.t',
    't/uniform_binding_contract.t', 't/codeblock_matches_perl.t',
    't/codeblock_null_return_perl.t', 't/codeblock_while_perl.t',
    't/codeblock_push_composition_perl.t', 't/codeblock_attached_if_perl.t',
    't/codeblock_value_if_perl.t', 't/codeblock_marker_if_perl.t',
    't/actionir_scalar_receiver_required_capture.t',
    't/actionir_array_receiver_required_capture.t',
    't/actionir_hash_receiver_required_capture.t',
    't/actionir_ast_parser.t', 't/trace_actionir_method_lowering.t',
]


def main():
    extras = [c.PREFIX + name for name in ('common.py', 'context.py', 'focused.py', 'phase0-before-inputs.json')]
    extras.extend('tests/numeric-codeblocks/' + name + '.json'
                  for name in ('cases', 'effects', 'stability', 'receiver-invalid', 'terminals'))
    plan = context.snapshot(extras)
    phase0 = c.load('phase0-before-inputs.json')['plan']
    commands = [
        ['perl', '-c', '-Iperl', path] for path in
        ('perl/LinkedSpec/Numeric.pm', c.SOURCE, 'perl/LinkedSpec/ActionIR/MethodLowering.pm',
         't/scalar_numeric_contract.t', 't/actionir_ast_parser.t', 't/phase0_regression.t')
    ]
    commands.extend([
        ['prove', '-q', '-Iperl'] + SELECTED,
        ['python3', '-B', 'tools/check_scalar_numeric_contract.py'],
        ['python3', '-B', 'tools/check_callable_codeblock_contract.py'],
        ['perl', '-Iperl', 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-focused.pl'],
    ])
    plan.update(selected=SELECTED, commands=commands, phase0=phase0,
        limits='17 direct suites plus three selected ordinary Phase0 roots. SKIP roots do not establish '
               'full Phase0; canonical admission separately executes its complete ordinary population.')
    c.write_new('focused-inputs.json.gz', plan)
    runs = []
    for index, command in enumerate(commands):
        run = c.run(command, **({'input': json.dumps(phase0).encode()} if index == len(commands) - 1 else {}))
        runs.append(run)
        if run['returncode']:
            break
    c.write_new('focused-run.json.gz', dict(runs=runs, inputs_unchanged=c.unchanged(plan['inputs'])))
    assert len(runs) == len(commands) and all(run['returncode'] == 0 for run in runs)
    assert c.unchanged(plan['inputs'])
    prove = runs[6]
    assert not c.decode(prove['stderr_base64'])
    count = re.search(rb'Files=(\d+), Tests=(\d+),', c.decode(prove['stdout_base64']))
    assert count and int(count[1]) == len(SELECTED)
    marker = b'# FOCUSED_PHASE0_JSON '
    result = json.loads(c.decode(runs[-1]['stdout_base64']).split(marker)[1].splitlines()[0])
    assert result['complete_selection'] and result['passing'] and result['selected'] == result['wanted'] == 3
    assert result['root_tests'] == 1035
    print('Focused current numeric PASS:', len(SELECTED), 'suites;', int(count[2]), 'TAP;',
          len(plan['inputs']), 'regular input identities; neutral55/18; selected Phase0 three roots')


if __name__ == '__main__':
    main()
