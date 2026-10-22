"""Retain the direct consumers and historical audit on the final runtime and tests."""
import json
import re
import common as c
import context

SUITES = ['t/uniform_binding_contract.t','t/callable_codeblock_literal_contract.t',
    't/codeblock_push_composition_perl.t','t/codeblock_matches_perl.t','t/variadic_user_function_contract.t',
    't/generated_source_contract.t','t/actionir_receiver_scalar_copy.t',
    't/actionir_array_receiver_required_capture.t','t/actionir_scalar_receiver_required_capture.t',
    't/scalar_numeric_contract.t','t/drop_keys_generated.t','t/actionir_ast_parser.t',
    't/trace_actionir_method_lowering.t','t/trace_emit_context_bridge.t']
HISTORY = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'


def validate(value):
    assert value['inputs_unchanged']
    for key in ('history','tests','scanner'):
        assert value[key]['returncode'] == 0,key
    history = json.loads(c.decode(value['history']['stdout_base64']))
    assert history['audit_controls']['governance_mutations_rejected'] == 650
    assert history['healthy_audit_guard'] == dict(original_log_attempts=0,tracked_write_attempts=0)
    stderr = c.decode(value['tests']['stderr_base64'])
    marker = b'# RECEIVER_COPY_OBSERVATIONS '
    assert stderr.startswith(marker) and len(stderr.splitlines()) == 1
    observed = json.loads(stderr[len(marker):])
    assert observed['live_error'] is None and observed['live'] == observed['standalone']
    assert observed['live_identity'] == observed['standalone_identity']
    assert set(observed['live_identity'].values()) == {1}
    assert not c.decode(value['scanner']['stderr_base64'])
    out = c.decode(value['tests']['stdout_base64'])
    match = re.search(rb'Files=(\d+), Tests=(\d+),',out)
    assert match and int(match[1]) == len(SUITES) and b'Result: PASS' in out
    return dict(suites=int(match[1]),tap=int(match[2]),historical_controls=650)


def main():
    supplied = context.snapshot()
    c.write_new('focused-inputs.json.gz',supplied)
    history = c.run(['bash','tools/run_python_project_data.sh',HISTORY])
    print('Historical audit exit:',history['returncode'],flush=True)
    tests = c.run(['bash','tools/project_data_run.sh','prove','-q','-Iperl']+SUITES)
    scanner = c.run(['bash','tools/run_python_project_data.sh','tools/check_public_aggregate_selector_surface.py'])
    value = dict(history=history,tests=tests,scanner=scanner,
        inputs_unchanged=c.unchanged(supplied['inputs']))
    c.write_new('focused-run.json.gz',value)
    print('Direct dependent proof:',json.dumps(validate(value),sort_keys=True))


if __name__ == '__main__':
    main()
