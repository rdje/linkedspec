"""One-shot direct-dependent compatibility proof at the repaired source epoch."""
import common as c
import context

TESTS = [
    "t/signed_array_selector_perl_contract.t", "t/write_vivification_perl_contract.t",
    "t/uniform_binding_contract.t", "t/codeblock_push_composition_perl.t",
    "t/generated_source_contract.t", "t/variadic_user_function_contract.t",
    "t/actionir_ast_parser.t", "t/actionir_nested_block_source_spans.t",
    "t/map_leaves_mutation_perl_contract.t", "t/scalar_numeric_contract.t",
    "t/logical_helper_perl_contract.t",
]

epoch = context.snapshot()
c.write_new("focused-inputs.json.gz", dict(context=epoch, tests=TESTS,
    producer=c.read(c.PREFIX + "focused.py")))
run = c.run(["bash", "tools/project_data_run.sh", "env", "PERL5LIB=", "prove", "-v", "-Iperl", *TESTS])
unchanged = c.unchanged(epoch["inputs"])
c.write_new("focused-runs.json.gz", dict(run=run, inputs_unchanged=unchanged))
assert unchanged and run["returncode"] == 0, run["returncode"]
print(c.decode(run["stdout_base64"]).decode()[-800:], flush=True)
