"""One-shot validity/cache diagnosis, accepted runtime shadows, and scope census."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import common as c
import context

records = {}
for path in subprocess.check_output(["git", "ls-files", "docs/claims"], cwd=c.ROOT).decode().splitlines():
    record = json.loads(c.source(path).read_bytes())
    live = [claim for claim in record["claims"] if claim["durability"].get("status") == "checked"
        and claim["durability"].get("mode") == "live"]
    if live:
        names = {item["path"] for claim in live for item in claim["durability"]["inputs"]}
        assert "perl/LinkedSpec/BindingRuntime.pm" not in names, path
        records[path] = dict(packet=c.read(path), inputs=sorted(names))
sources = {path: subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
    for path in ("perl/LinkedSpec/CodeblockRuntime.pm", "perl/LinkedSpec/BindingRuntime.pm")}
epoch = context.snapshot()
c.write_new("validity-inputs.json.gz", dict(context=epoch, producer=c.read(c.PREFIX + "capture_validity.py"),
    worker=c.read(c.PREFIX + "validity_probe.pl"), live_records=records,
    added_owned_path="perl/LinkedSpec/BindingRuntime.pm", planned_intersections=0,
    accepted_sources={path: dict(base64=c.encode(raw), sha256=c.sha(raw)) for path, raw in sources.items()}))
command = ["bash", "tools/project_data_run.sh", "env", "PERL5LIB=", "perl", "-Iperl", c.PREFIX + "validity_probe.pl"]
runs = {"current": c.run(command)}
with tempfile.TemporaryDirectory(prefix="literal-validity-accepted-", dir=os.environ["TMPDIR"]) as folder:
    shadow = Path(folder)
    assert shadow.stat().st_dev == c.ROOT.stat().st_dev
    for path, raw in sources.items():
        target = shadow / Path(path).relative_to("perl")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    runs["accepted_runtime_shadow"] = c.run(["bash", "tools/project_data_run.sh", "env", "PERL5LIB=",
        "perl", "-I" + str(shadow), "-Iperl", "-MLinkedSpec::CodeblockRuntime", c.PREFIX + "validity_probe.pl"])
assert c.unchanged(epoch["inputs"])
c.write_new("validity-runs.json.gz", dict(runs=runs, inputs_unchanged=True,
    scope="Two accepted owned runtime-byte shadows share the same current unchanged compiler/SDK environment; this is not a historical environment reconstruction."))
for name, run in runs.items():
    assert run["returncode"] == 0 and not c.decode(run["stderr_base64"]), (name, run)
    value = json.loads(c.decode(run["stdout_base64"]))
    print(name, json.dumps({key: value[key] for key in
        ("perl_version", "parsed_source", "evaluated", "fresh", "copies", "delegated_kinds", "chosen", "receiver", "rhs_effects", "error")}, sort_keys=True), flush=True)
    for row in value["public"]:
        print(name, json.dumps({key: row[key] for key in ("body", "route", "value", "index_flags")}, sort_keys=True), flush=True)
