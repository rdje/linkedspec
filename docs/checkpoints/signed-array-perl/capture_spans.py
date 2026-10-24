"""One-shot existing positive-gap diagnostic source-unit calibration."""
import json
import common as c
import context

epoch = context.snapshot()
c.write_new("span-inputs.json.gz", dict(context=epoch,
    sources={path: c.read(path) for path in (c.PREFIX + "capture_spans.py", c.PREFIX + "context.py",
        c.PREFIX + "common.py", c.PREFIX + "perl_probe.pl")},
    plan=c.read(c.PREFIX + "span.json"),
    scope="Unchanged positive write failures calibrate the public authored span unit before new diagnostic expectations are written. Runtime source bytes remain accepted ed658fb83."))
observations = {}
for route in ("native", "generated"):
    observations[route] = c.run(["bash", "tools/project_data_run.sh", "perl", "-Iperl",
        c.PREFIX + "perl_probe.pl", route], input=c.source(c.PREFIX + "span.json").read_bytes())
c.write_new("span-runs.json.gz", dict(observations=observations,
    inputs_unchanged=c.unchanged(epoch["inputs"])))
assert c.unchanged(epoch["inputs"])
for route, run in observations.items():
    assert run["returncode"] == 0
    value = json.loads(c.decode(run["stdout_base64"]))
    for row in value["rows"]:
        print(route, row["id"], json.dumps(row["runtime_detail"] if route == "native"
            else row["generated_cause"], sort_keys=True, ensure_ascii=False))
