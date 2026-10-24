"""One-shot first implementation observation; keep failures as observed."""
import json
import common as c
import context
import oracle

epoch = context.snapshot()
plan = json.loads(c.source("tests/numeric-codeblocks/signed-array-selectors.json").read_bytes())
c.write_new("after-inputs.json.gz", dict(context=epoch,
    sources={path: c.read(path) for path in c.SOURCES},
    plan=c.read("tests/numeric-codeblocks/signed-array-selectors.json")))
observations = {}
for route in ("descriptor", "native", "generated"):
    observations[route] = c.run(["bash", "tools/project_data_run.sh", "perl", "-Iperl",
        c.PREFIX + "perl_probe.pl", route], input=json.dumps(plan, ensure_ascii=False).encode())
observations["permanent"] = c.run(["bash", "tools/project_data_run.sh", "prove", "-v", "-Iperl",
    "t/signed_array_selector_perl_contract.t"])
c.write_new("after-runs.json.gz", dict(observations=observations,
    inputs_unchanged=c.unchanged(epoch["inputs"])))
assert c.unchanged(epoch["inputs"])
for route in ("native", "generated"):
    failures = oracle.check(plan, route, observations[route])
    print(route, "failures", json.dumps(failures))
print("permanent", observations["permanent"]["returncode"])
