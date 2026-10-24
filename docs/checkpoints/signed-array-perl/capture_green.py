"""One-shot corrected full population and direct-dependent compatibility proof."""
import json
import common as c
import context
import oracle

epoch = context.snapshot()
plan = json.loads(c.source("tests/numeric-codeblocks/signed-array-selectors.json").read_bytes())
c.write_new("green-inputs.json.gz", dict(context=epoch,
    sources={path: c.read(path) for path in c.SOURCES},
    plan=c.read("tests/numeric-codeblocks/signed-array-selectors.json")))
observations = {}
for route in ("descriptor", "native", "generated"):
    observations[route] = c.run(["bash", "tools/project_data_run.sh", "perl", "-Iperl",
        c.PREFIX + "perl_probe.pl", route], input=json.dumps(plan, ensure_ascii=False).encode())
observations["focused"] = c.run(["bash", "tools/project_data_run.sh", "prove", "-v", "-Iperl",
    "t/signed_array_selector_perl_contract.t", "t/write_vivification_perl_contract.t",
    "t/callable_codeblock_literal_contract.t", "t/uniform_binding_contract.t",
    "t/codeblock_push_composition_perl.t", "t/generated_source_contract.t",
    "t/variadic_user_function_contract.t", "t/actionir_ast_parser.t",
    "t/actionir_nested_block_source_spans.t"])
c.write_new("green-runs.json.gz", dict(observations=observations,
    inputs_unchanged=c.unchanged(epoch["inputs"])))
assert c.unchanged(epoch["inputs"])
for route in ("native", "generated"):
    failures = oracle.check(plan, route, observations[route])
    assert not failures, (route, failures)
    print(route, "PASS", len(plan["cases"]))
assert observations["focused"]["returncode"] == 0
print(c.decode(observations["focused"]["stdout_base64"]).decode().split("Test Summary Report")[-1][-700:])
