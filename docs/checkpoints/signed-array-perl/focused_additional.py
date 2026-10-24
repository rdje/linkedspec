"""Retain the existing map-mutation direct-dependent contract at restored sources."""
import common as c
import context

assert c.load("green-inputs.json.gz")["sources"] == {path: c.read(path) for path in c.SOURCES}
epoch = context.snapshot()
c.write_new("focused-additional-inputs.json.gz", dict(context=epoch,
    sources={path: c.read(path) for path in c.SOURCES}))
run = c.run(["bash", "tools/project_data_run.sh", "prove", "-v", "-Iperl", "t/map_leaves_mutation_perl_contract.t"])
c.write_new("focused-additional-runs.json.gz", dict(run=run, inputs_unchanged=c.unchanged(epoch["inputs"])))
assert c.unchanged(epoch["inputs"]) and run["returncode"] == 0
print(c.decode(run["stdout_base64"]).decode()[-400:])
