"""One-shot unchanged-runtime public and permanent regression observation."""
import json
import subprocess
import common as c
import context

for path in c.SOURCES:
    assert c.source(path).read_bytes() == subprocess.check_output(
        ["git", "show", c.BASE + ":" + path], cwd=c.ROOT), path
epoch = context.snapshot()
c.write_new("before-inputs.json.gz", dict(context=epoch,
    sources={path: c.read(path) for path in c.SOURCES},
    plan=c.read("tests/numeric-codeblocks/signed-array-selectors.json"),
    scope="Actual unchanged production sources, fixed independently authored public gold and permanent regression consumer before implementation."))
observations = {}
for route in ("descriptor", "native", "generated"):
    observations[route] = c.run(["bash", "tools/project_data_run.sh", "perl", "-Iperl",
        c.PREFIX + "perl_probe.pl", route],
        input=c.source("tests/numeric-codeblocks/signed-array-selectors.json").read_bytes())
observations["permanent"] = c.run(["bash", "tools/project_data_run.sh", "prove", "-v", "-Iperl",
    "t/signed_array_selector_perl_contract.t"])
c.write_new("before-runs.json.gz", dict(observations=observations,
    inputs_unchanged=c.unchanged(epoch["inputs"])))
assert c.unchanged(epoch["inputs"])
for route, run in observations.items():
    print(route, run["returncode"], len(c.decode(run["stdout_base64"])), len(c.decode(run["stderr_base64"])))
    if route != "permanent":
        value = json.loads(c.decode(run["stdout_base64"]))
        print("rows", len(value["rows"]))
