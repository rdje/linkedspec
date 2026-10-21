"""Retain direct dependent suites, surface scanner and actual historical audit result."""
import re
import sys
import json
import common as c
import context

SUITES=['t/uniform_binding_contract.t','t/callable_codeblock_literal_contract.t',
    't/codeblock_push_composition_perl.t','t/codeblock_matches_perl.t','t/variadic_user_function_contract.t',
    't/generated_source_contract.t','t/actionir_receiver_scalar_copy.t',
    't/actionir_array_receiver_required_capture.t','t/actionir_scalar_receiver_required_capture.t',
    't/scalar_numeric_contract.t','t/drop_keys_generated.t','t/actionir_ast_parser.t',
    't/trace_actionir_method_lowering.t','t/trace_emit_context_bridge.t']
HISTORY='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'


def main():
    epoch=sys.argv[1] if len(sys.argv)>1 else "focused1"
    assert epoch in ("focused1","focused2")
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras+['tests/numeric-codeblocks/pipelines.json'])
    snapshot.update(suites=SUITES,new_inputs={path:c.read(path) for path in extras if not path.endswith('.gz')})
    c.write_new(epoch+'-inputs.json.gz',snapshot)
    history=c.run(['bash','tools/run_python_project_data.sh',HISTORY])
    print('Historical audit exit:',history['returncode'],flush=True)
    tests=c.run(['bash','tools/project_data_run.sh','prove','-q','-Iperl']+SUITES)
    scanner=c.run(['bash','tools/run_python_project_data.sh','tools/check_public_aggregate_selector_surface.py'])
    stable=c.unchanged(snapshot['inputs'])
    c.write_new(epoch+'-run.json.gz',dict(history=history,tests=tests,scanner=scanner,inputs_unchanged=stable))
    assert stable and tests['returncode']==scanner['returncode']==0
    stderr=c.decode(tests['stderr_base64'])
    prefix=b'# RECEIVER_COPY_OBSERVATIONS '
    assert stderr.startswith(prefix) and len(stderr.splitlines())==1 and stderr.endswith(b'\n')
    observed=json.loads(stderr[len(prefix):])
    assert observed['live_error'] is None and observed['live']==observed['standalone']
    assert observed['live_identity']==observed['standalone_identity']
    assert set(observed['live_identity'].values())=={1}
    sender='t/actionir_receiver_scalar_copy.t'
    assert b"diag('RECEIVER_COPY_OBSERVATIONS '" in (c.ROOT/sender).read_bytes()
    assert not c.decode(scanner['stderr_base64'])
    match=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(tests['stdout_base64']))
    assert match and int(match[1])==len(SUITES) and b'Result: PASS' in c.decode(tests['stdout_base64'])
    print('Direct aggregate dependents PASS:',len(SUITES),'suites;',match[2].decode(),'TAP; scanner PASS')
    if history['returncode']!=0:print('Actual historical RED retained for owned inverse repair before canonical admission')


if __name__=='__main__':main()
