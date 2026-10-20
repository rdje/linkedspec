"""Retain the direct hash/capture/binding/numeric consumers and surface scanner."""
import re
import common as c
import context

SUITES=['t/uniform_binding_contract.t','t/actionir_uniform_target.t',
        't/actionir_hash_receiver_required_capture.t','t/actionir_method_ast_hash_key_capture.t',
        't/actionir_method_ast_hash_key_capture_cold.t','t/actionir_receiver_scalar_copy.t',
        't/scalar_numeric_contract.t','t/compact_hash_keys_book.t','t/drop_keys_generated.t']


def main():
    extras=[c.PREFIX+path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    extras+=['tests/drop-generated/cases.json','tests/drop-generated/book-cases.json','t/drop_keys_generated.t',
             'tests/language-readiness/drop-generated-regression-evolution.json.gz']
    snapshot=context.snapshot(extras)
    snapshot.update(suites=SUITES)
    c.write_new('focused-inputs.json.gz',snapshot)
    tests=c.run(['bash','tools/project_data_run.sh','prove','-q','-Iperl']+SUITES)
    scanner=c.run(['bash','tools/run_python_project_data.sh','tools/check_public_aggregate_selector_surface.py'])
    value=dict(tests=tests,scanner=scanner,inputs_unchanged=c.unchanged(snapshot['inputs']))
    c.write_new('focused-run.json.gz',value)
    assert tests['returncode']==scanner['returncode']==0 and not c.decode(tests['stderr_base64'])
    match=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(tests['stdout_base64']))
    assert match and int(match[1])==len(SUITES) and b'Result: PASS' in c.decode(tests['stdout_base64'])
    assert value['inputs_unchanged']
    print('Direct consumers PASS:',match[1].decode(),'suites;',match[2].decode(),'assertions; selector surface PASS')


if __name__=='__main__':main()
