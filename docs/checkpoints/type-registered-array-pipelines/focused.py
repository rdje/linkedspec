"""Run permanent changed-surface and direct-dependent tests on exact final sources."""
import re
import common as c

SUITES=['t/uniform_binding_contract.t','t/callable_codeblock_literal_contract.t',
 't/codeblock_push_composition_perl.t','t/codeblock_matches_perl.t','t/variadic_user_function_contract.t',
 't/generated_source_contract.t','t/actionir_receiver_scalar_copy.t',
 't/actionir_array_receiver_required_capture.t','t/actionir_scalar_receiver_required_capture.t',
 't/scalar_numeric_contract.t','t/drop_keys_generated.t','t/actionir_ast_parser.t',
 't/trace_actionir_method_lowering.t','t/trace_emit_context_bridge.t','t/actionir_method_kind_capture.t']

def main():
    c.write_new('focused-inputs.json.gz',c.epoch())
    run=c.run(['bash','tools/project_data_run.sh','prove','-q','-Iperl']+SUITES)
    c.write_new('focused-run.json.gz',dict(run=run,producer=c.read(c.PREFIX+'focused.py'),suites=SUITES))
    assert run['returncode']==0
    match=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(run['stdout_base64']))
    assert match and int(match[1])==len(SUITES)
    print('Direct dependents GREEN:',match[1].decode(),'suites /',match[2].decode(),'TAP')

if __name__=='__main__':main()
