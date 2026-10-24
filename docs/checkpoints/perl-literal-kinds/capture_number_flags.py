"""One-shot numeric construction diagnostics before choosing the repair."""
import json
import common as c
import context

epoch = context.snapshot()
c.write_new("number-flags-inputs.json.gz", dict(context=epoch,
    producer=c.read(c.PREFIX + "capture_number_flags.py"), worker=c.read(c.PREFIX + "number_flags.pl")))
run = c.run(["bash", "tools/project_data_run.sh", "perl", c.PREFIX + "number_flags.pl"])
assert run["returncode"] == 0 and not c.decode(run["stderr_base64"]), run
assert c.unchanged(epoch["inputs"])
c.write_new("number-flags-runs.json.gz", dict(run=run, inputs_unchanged=True))
for row in json.loads(c.decode(run["stdout_base64"]))["rows"]:
    print(row["id"], json.dumps(dict(native=row["native_flags"], variants={
        name: item["flags"] for name, item in row["variants"].items()}), sort_keys=True), flush=True)
