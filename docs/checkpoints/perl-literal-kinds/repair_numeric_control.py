"""Retain and update exactly the live control for the now-repaired boolean issue."""
import json
import subprocess
import common as c
import context

PATH = "tests/numeric-codeblocks/cases.json"
ID = "control/boolean-literal-owned-startup35"


def main():
    records = {}
    for path in subprocess.check_output(["git", "ls-files", "docs/claims"], cwd=c.ROOT).decode().splitlines():
        value = json.loads(c.source(path).read_bytes())
        live = [claim for claim in value["claims"] if claim["durability"].get("status") == "checked"
            and claim["durability"].get("mode") == "live"]
        if live:
            names = {item["path"] for claim in live for item in claim["durability"]["inputs"]}
            assert not {PATH, "t/scalar_numeric_contract.t"} & names, path
            records[path] = dict(packet=c.read(path), inputs=sorted(names))
    before = c.read(PATH)
    raw = c.decode(before["base64"])
    assert raw == subprocess.check_output(["git", "show", c.BASE + ":" + PATH], cwd=c.ROOT)
    original = json.loads(raw)
    row, = [item for item in original["cases"] if item["id"] == ID]
    assert row == dict(id=ID, body="cb = {|| return(true) }; return(cb())", expected=1)
    assert type(row["expected"]) is int
    replacement = dict(row, expected=True)
    old = json.dumps(row, sort_keys=True, separators=(",", ":")).encode()
    new = json.dumps(replacement, sort_keys=True, separators=(",", ":")).encode()
    assert raw.count(old) == 1
    updated = raw.replace(old, new, 1)
    epoch = context.snapshot()
    c.write_new("numeric-control-inputs.json.gz", dict(context=epoch,
        producer=c.read(c.PREFIX + "repair_numeric_control.py"), live_records=records, before=before,
        historical_producer=c.read("docs/checkpoints/type-numeric-codeblocks/build_cases.py"),
        original_row=row, replacement_row=replacement,
        qualification="Only the live known-gap expectation changes. The historical producer and every original observation remain unchanged and must not be rerun as a live fixture writer."))
    c.source(PATH).write_bytes(updated)
    after = c.read(PATH)
    changed = json.loads(updated)
    assert len(changed["cases"]) == len(original["cases"]) == 431
    differences = [a["id"] for a, b in zip(original["cases"], changed["cases"])
        if not (a == b and type(a.get("expected")) is type(b.get("expected")))]
    assert differences == [ID]
    run_epoch = context.snapshot()
    c.write_new("numeric-control-after-inputs.json.gz", dict(context=run_epoch, after=after))
    run = c.run(["bash", "tools/project_data_run.sh", "env", "PERL5LIB=", "prove", "-v", "-Iperl",
        "t/scalar_numeric_contract.t"])
    unchanged = c.unchanged(run_epoch["inputs"])
    c.write_new("numeric-control-runs.json.gz", dict(run=run, inputs_unchanged=unchanged,
        changed_case_ids=differences, after=after))
    assert unchanged and run["returncode"] == 0, run["returncode"]
    print("One exact live expected value repaired: integer1 -> JSON true; all431 case sources/ids retained.", flush=True)
    print(c.decode(run["stdout_base64"]).decode()[-500:], flush=True)


if __name__ == "__main__":
    main()
