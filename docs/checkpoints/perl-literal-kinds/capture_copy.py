"""One-shot diagnosis of scalar-cache and aggregate-copy kind boundaries."""
import json
import common as c
import context

epoch = context.snapshot()
c.write_new("copy-inputs.json.gz", dict(context=epoch,
    producer=c.read(c.PREFIX + "capture_copy.py"), worker=c.read(c.PREFIX + "copy_probe.pl")))
run = c.run(["bash", "tools/project_data_run.sh", "env", "PERL5LIB=", "perl", "-Iperl", c.PREFIX + "copy_probe.pl"])
assert c.unchanged(epoch["inputs"])
c.write_new("copy-runs.json.gz", dict(run=run, inputs_unchanged=True))
assert run["returncode"] == 0 and not c.decode(run["stderr_base64"]), run
result = json.loads(c.decode(run["stdout_base64"]))
print(json.dumps({key: result[key] for key in ("source", "cached_conversion", "fresh_conversion", "copies")}, sort_keys=True))
for row in result["public"]:
    print(json.dumps({key: row[key] for key in ("body", "route", "result", "flags")}, sort_keys=True), flush=True)
