"""Read-only review of finite Julia source fallback observations and input bodies."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def same(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if type(a) in (int, float) and type(b) in (int, float):
        return a == b
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def archive_inputs(phase):
    out = HERE / phase
    identities = json.loads((out / "inputs.json").read_text())
    bodies = {}
    with tarfile.open(out / "before-first-run.tar.gz") as archive:
        for member in archive.getmembers():
            assert member.isfile() and member.name in identities and member.name not in bodies
            body = archive.extractfile(member).read()
            assert hashlib.sha256(body).hexdigest() == identities[member.name]
            bodies[member.name] = body
    assert bodies.keys() == identities.keys()
    return bodies


observed = {}
for phase in ("before", "after"):
    bodies = archive_inputs(phase)
    rows = json.loads(bodies["tests/fixtures/count_boolean_source_cases.json"])
    assert len(rows) == 25 and len({r["id"] for r in rows}) == 25
    values = {}
    raw = gzip.decompress((HERE / phase / "stdout.log.gz").read_bytes()).decode()
    for line in raw.splitlines():
        if line.startswith("COUNT_SOURCE_JULIA "):
            label, value = line[len("COUNT_SOURCE_JULIA "):].split(" ", 1)
            assert label not in values
            values[label] = json.loads(value)
    assert values.keys() == {r["id"] for r in rows}
    red = {route: set() for route in ("native", "restored", "plan", "fresh")}
    for row in rows:
        label = row["id"]
        assert values[label].keys() == red.keys()
        assert (HERE / phase / "emitted" / (label + ".jl")).is_file()
        json.loads((HERE / phase / "emitted" / (label + ".ast.json")).read_text())
        for route, value in values[label].items():
            good = (row["expected_error"] in value.get("error", "")) if "expected_error" in row else (
                value.keys() == {"ok"} and same(value["ok"], row.get("expected_nonperl", row["expected"]))
            )
            if not good:
                red[route].add(label)
    expected = {"receiver_source_domains", "initial_boolean_count_continuations",
                "boolean_count_source_once", "function_boolean_count_scope"} if phase == "before" else set()
    assert all(labels == expected for labels in red.values()), red
    assert json.loads((HERE / phase / "result.json").read_text())["exit"] == (1 if expected else 0)
    observed[phase] = (bodies, values)
    print(phase, "PASS:25 groups/four routes; expected failing groups", sorted(expected))
before, after = observed["before"], observed["after"]
for name in ("julia/test/count_source_fallback_test.jl", "tests/fixtures/count_boolean_source_cases.json"):
    assert before[0][name] == after[0][name] == (ROOT / name).read_bytes()
assert before[1]["count_copy_needed_source_error"] == after[1]["count_copy_needed_source_error"]
assert not same(False, 0) and not same("0", 0)
archive_inputs("direct")
assert json.loads((HERE / "direct/result.json").read_text())["exit"] == 0
print("PASS: identical authored controls, strict scalar kinds, observed error message/class, direct checks and actual input archive bodies")
