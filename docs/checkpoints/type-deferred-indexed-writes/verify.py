"""Capture focused direct-dependent proof against a complete regular-file epoch."""
import re,sys
import common as c
SUITES=['t/callable_codeblock_literal_contract.t','t/write_vivification_perl_contract.t','t/map_leaves_mutation_perl_contract.t','t/uniform_binding_contract.t','t/codeblock_push_composition_perl.t','t/codeblock_matches_perl.t','t/variadic_user_function_contract.t','t/generated_source_contract.t','t/scalar_numeric_contract.t','t/actionir_ast_parser.t','t/trace_actionir_method_lowering.t','t/trace_emit_context_bridge.t','t/actionir_receiver_scalar_copy.t','t/actionir_array_receiver_required_capture.t','t/actionir_scalar_receiver_required_capture.t','t/actionir_method_kind_capture.t','t/drop_keys_generated.t','t/actionir_emit_context_capture.t','t/actionir_emit_context_capture_cold.t','t/trace_ruleir_planning.t']
def main():
 name=sys.argv[1]
 context=c.epoch()
 run=c.run(['bash','tools/project_data_run.sh','prove','-q','-Iperl']+SUITES)
 c.save(name,dict(context=context,run=run,suites=SUITES,producer=c.read(c.PREFIX+'verify.py')))
 print(c.decode(run['stdout_base64']).decode()[-2500:])
 print(c.decode(run['stderr_base64']).decode()[-2500:])
 assert run['returncode']==0
if __name__=='__main__':main()
