"""Retain a complete public/direct contract execution at one fixed source epoch."""
import json
import sys
import common as c
import context


def observations(run):
    marker = "# LITERAL_KIND_OBSERVATION "
    rows = []
    for line in c.decode(run["stdout_base64"]).decode().splitlines():
        text = line.lstrip()
        if text.startswith(marker):
            rows.append(json.loads(text[len(marker):]))
    return rows


def value_same(left, right):
    return json.dumps(left, sort_keys=True) == json.dumps(right, sort_keys=True)


def summarize(run, population):
    rows = observations(run)
    assert len(rows) == population * 2 and len({row["id"] for row in rows}) == population
    assert len({(row["id"], row["route"]) for row in rows}) == population * 2
    instrument_errors = [row["id"] + "/" + row["route"] for row in rows
        if not row["completed"] or row["warnings"] or row["stdout"]
        or row["exception"] is not None or row["runtime_error"] is not None]
    mismatches = [row["id"] + "/" + row["route"] for row in rows
        if not value_same(row["flags"], row["expected_flags"])
        or not value_same(row["value"], row["expected"])]
    return dict(public_programs=population, public_routes=2, observations=len(rows),
        instrument_errors=instrument_errors, mismatches=mismatches)


def main():
    phase = sys.argv[1]
    assert len(sys.argv) == 2 and phase in ("before", "after", "verified-before", "verified-after")
    epoch = context.snapshot()
    c.write_new(phase + "-inputs.json.gz", dict(context=epoch, producer=c.read(c.PREFIX + "capture.py"),
        worker=c.read("t/callable_codeblock_literal_contract.t")))
    run = c.run(["bash", "tools/project_data_run.sh", "env", "PERL5LIB=",
        "LINKEDSPEC_LITERAL_KIND_OBSERVE=1", "prove", "-v", "-Iperl", "t/callable_codeblock_literal_contract.t"])
    unchanged = c.unchanged(epoch["inputs"])
    c.write_new(phase + "-runs.json.gz", dict(run=run, inputs_unchanged=unchanged))
    assert unchanged
    result = summarize(run, 37 if phase.startswith("verified-") else 35)
    print(json.dumps(dict(phase=phase, exit_code=run["returncode"], **result), sort_keys=True), flush=True)
    assert not result["instrument_errors"], result["instrument_errors"]
    if phase.endswith("before"):
        assert run["returncode"] != 0 and result["mismatches"], "Missing actual RED"
    else:
        assert run["returncode"] == 0 and not result["mismatches"], "Incomplete GREEN"


if __name__ == "__main__":
    main()
