"""One-shot original public probe capture; never recapture this epoch."""
import json
import common as c
import context

epoch = context.snapshot()
c.write_new("explore-inputs.json.gz", dict(context=epoch,
    sources={path: c.read(path) for path in (c.PREFIX + "explore.py", c.PREFIX + "context.py",
        c.PREFIX + "common.py", c.PREFIX + "perl_probe.pl")},
    plan=c.read(c.PREFIX + "explore.json"),
    scope="Descriptor/native/independently emitted populations execute in separate fresh Perl processes at unchanged accepted runtime sources. Each parser has fresh working slots. These are mechanism observations, not a newly adjudicated syntax/coercion contract."))
observations = {}
for route in ("descriptor", "native", "generated"):
    observations[route] = c.run(["bash", "tools/project_data_run.sh", "perl", "-Iperl",
        c.PREFIX + "perl_probe.pl", route], input=c.source(c.PREFIX + "explore.json").read_bytes())
c.write_new("explore-runs.json.gz", dict(observations=observations,
    inputs_unchanged=c.unchanged(epoch["inputs"])))
assert c.unchanged(epoch["inputs"])
for route, run in observations.items():
    assert run["returncode"] == 0, (route, c.decode(run["stderr_base64"]).decode())
    value = json.loads(c.decode(run["stdout_base64"]))
    print(route, json.dumps([{key: row[key] for key in
        ("id", "completed", "value", "runtime_detail", "exception")} for row in value["rows"]], sort_keys=True))
