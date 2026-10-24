"""One-shot public-tool diagnosis of suspected serialized numeric payload loss."""
import json
import common as c
import context

epoch = context.snapshot()
c.write_new("precision-inputs.json.gz", dict(context=epoch,
    producer=c.read(c.PREFIX + "capture_precision.py"), worker=c.read(c.PREFIX + "precision_probe.pl")))
run = c.run(["bash", "tools/project_data_run.sh", "env", "PERL5LIB=", "perl", "-Iperl",
    c.PREFIX + "precision_probe.pl"])
assert c.unchanged(epoch["inputs"])
c.write_new("precision-runs.json.gz", dict(run=run, inputs_unchanged=True))
assert run["returncode"] == 0 and not c.decode(run["stderr_base64"]), run
for row in json.loads(c.decode(run["stdout_base64"]))["rows"]:
    print(json.dumps({key: row[key] for key in ("body", "route", "flags", "hexadecimal", "value")}, sort_keys=True), flush=True)
