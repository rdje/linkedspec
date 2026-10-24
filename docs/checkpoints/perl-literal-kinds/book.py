"""Current complete book, exact executable sources and effective rendered denials."""
import copy
import json
import re
import common as c
import context
import booklib as b

OBSERVER = "docs/checkpoints/signed-array-perl/perl_probe.pl"
EXAMPLES = {
    "examples/deferred-literal-kinds-perl.spec": [False, True, None, -1],
    "examples/deferred-literal-precision-perl.spec": 0.5,
    "examples/negative-array-current-perl.spec": [30, [10,20,30]],
    "examples/negative-array-current-callable-perl.spec": [30, [10,20,30]],
    "examples/negative-array-write-perl.spec": [30, [10,99,30]],
    "examples/negative-array-write-callable-perl.spec": {"rows": [[1],[99,3]]},
}


def validate(run, packets):
    text = b.page(run)
    assert 'id="current-callable-literal-kind-limitation"' in text, "old anchor"
    parser = b.Page()
    parser.feed(text)
    plain = re.sub(r"\s+", " ", "".join(parser.text))
    assert "Literal kinds inside Perl codeblocks" in plain, "new heading"
    assert "Boolean literals retain typed booleans" in plain, "boolean kind teaching"
    assert "Floating literals retain their numeric value" in plain, "numeric value teaching"
    for path in EXAMPLES:
        source = c.decode(packets[path]["base64"]).decode().rstrip("\n")
        assert parser.blocks.count(source) == 1, "exact executable source: " + path


def execute(plan, route):
    run = c.run(["bash", "tools/project_data_run.sh", "env", "PERL5LIB=", "perl", "-Iperl", OBSERVER, route],
        input=json.dumps(plan).encode())
    assert run["returncode"] == 0 and not c.decode(run["stderr_base64"])
    rows = json.loads(c.decode(run["stdout_base64"]))["rows"]
    assert [row["id"] for row in rows] == [row["id"] for row in plan["cases"]]
    failed = []
    for row, expected in zip(rows, plan["cases"]):
        assert row["completed"] and not row["warnings"] and not row["stdout"]
        assert row["exception"] is None and row["last_error"] is None
        if json.dumps(row["value"], sort_keys=True) != json.dumps(expected["expected"], sort_keys=True):
            failed.append(row["id"])
    return run, failed


def main():
    packets = b.inputs()
    epoch = context.snapshot()
    plan = dict(cases=[dict(id=path, source=c.decode(packets[path]["base64"]).decode(), input="x", expected=expected)
        for path, expected in EXAMPLES.items()])
    c.write_new("book-inputs.json.gz", dict(context=epoch, producer=c.read(c.PREFIX + "book.py"),
        observer=c.read(OBSERVER), renderer=c.read(b.RENDERER), inputs=packets, plan=plan))
    healthy = b.render(packets)
    c.write_new("book-original-output.json.gz", healthy)
    validate(healthy, packets)
    executions = {}
    for route in ("native", "generated"):
        run, failed = execute(plan, route)
        executions[route] = run
        assert not failed, failed
    variants = {}
    for name, path, old, new in (
        ("heading", b.FLOW, b"#### Literal kinds inside Perl codeblocks", b"#### Changed literal heading"),
        ("boolean-teaching", b.FLOW, b"Boolean literals retain typed booleans", b"Boolean literals become integers"),
        ("example", "examples/deferred-literal-kinds-perl.spec", b"index=-1.0", b"index=-1"),
    ):
        changed = copy.deepcopy(packets)
        raw = c.decode(changed[path]["base64"])
        assert raw.count(old) == 1
        raw = raw.replace(old, new, 1)
        changed[path].update(base64=c.encode(raw), sha256=c.sha(raw))
        variants[name] = changed
    c.write_new("book-fault-inputs.json.gz", dict(overrides={name: {path: item for path, item in value.items()
        if item != packets[path]} for name, value in variants.items()}))
    faults = {}
    for name, changed in variants.items():
        run = b.render(changed)
        try:
            validate(run, packets)
        except AssertionError as error:
            reason = str(error)
        else:
            raise AssertionError("Rendered mutation admitted: " + name)
        faults[name] = dict(run={k: v for k, v in run.items() if k != "files"},
            manifest=b.manifest(run), page=run["files"][b.HTML], rejected=True, reason=reason)
    wrong_plan = dict(cases=[dict(id="examples/deferred-literal-kinds-perl.spec",
        source=c.decode(variants["example"]["examples/deferred-literal-kinds-perl.spec"]["base64"]).decode(),
        input="x", expected=EXAMPLES["examples/deferred-literal-kinds-perl.spec"])])
    wrong_runs = {}
    for route in ("native", "generated"):
        run, failed = execute(wrong_plan, route)
        assert failed == ["examples/deferred-literal-kinds-perl.spec"]
        wrong_runs[route] = run
    pressure = c.run(["bash", "scripts/check_readme_stability.sh"])
    unchanged = c.unchanged(epoch["inputs"])
    c.write_new("book-runs.json.gz", dict(executions=executions, faults=faults, wrong_plan=wrong_plan,
        wrong_runs=wrong_runs, pressure=pressure, inputs_unchanged=unchanged))
    assert unchanged and pressure["returncode"] == 0, pressure["returncode"]
    print("Book:", len(packets), "whole inputs; six native/emitted examples; three rendered denials; executed selector denial; pressure PASS.", flush=True)


if __name__ == "__main__":
    main()
