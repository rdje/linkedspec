"""Read-only review of finite installed-host Count source controls."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
ROUTES = {"native", "restored", "plan", "fresh"}
RED = {"receiver_source_domains", "initial_boolean_count_continuations",
       "boolean_count_source_once", "function_boolean_count_scope"}


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


inputs, observations = {}, {}
for phase in ("before", "after", "direct"):
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
    inputs[phase] = bodies
    rows = json.loads(bodies["tests/fixtures/count_boolean_source_cases.json"])
    assert len(rows) == 25 and len({r["id"] for r in rows}) == 25
    for host in ("puc", "luajit"):
        target = out / host
        assert json.loads((target / "version-result.json").read_text())["exit"] == 0
        expected_exit = 1 if phase == "before" else 0
        assert json.loads((target / "normal-result.json").read_text())["exit"] == expected_exit
        raw = gzip.decompress((target / "normal-stdout.log.gz").read_bytes()).decode()
        if phase == "direct":
            assert "count/length receiver checks passed" in raw
            assert "COPIED_NULL_SUMMARY 70 checks 0 failures" in raw
            assert not gzip.decompress((target / "normal-stderr.log.gz").read_bytes())
            continue
        values = {}
        for line in raw.splitlines():
            if line.startswith("COUNT_SOURCE_LUA "):
                label, value = line[len("COUNT_SOURCE_LUA "):].split(" ", 1)
                assert label not in values
                values[label] = json.loads(value)
        assert values.keys() == {r["id"] for r in rows}
        with tarfile.open(target / "emitted.tar.gz") as archive:
            modules = {m.name: archive.extractfile(m).read() for m in archive.getmembers() if m.isfile()}
        assert modules.keys() == {r["id"] + suffix for r in rows for suffix in (".lua", ".ast.json")}
        red = {route: set() for route in ROUTES}
        for row in rows:
            label = row["id"]
            assert values[label].keys() == ROUTES
            json.loads(modules[label + ".ast.json"])
            assert modules[label + ".lua"]
            for route, value in values[label].items():
                good = row["expected_error"] in value.get("error", "") if "expected_error" in row else (
                    value.keys() == {"value"} and same(value["value"], row.get("expected_nonperl", row["expected"]))
                )
                if not good:
                    red[route].add(label)
        assert all(labels == (RED if phase == "before" else set()) for labels in red.values()), red
        assert "COUNT_SOURCE_LUA_SUMMARY 125 checks " + ("16 failures" if phase == "before" else "0 failures") in raw
        if phase == "after":
            assert not gzip.decompress((target / "normal-stderr.log.gz").read_bytes())
        observations[phase, host] = values
        print(phase, host, "PASS:25 groups/four routes; expected RED groups", len(RED) if phase == "before" else 0)
for host in ("puc", "luajit"):
    assert observations["before", host]["count_copy_needed_source_error"] == observations["after", host]["count_copy_needed_source_error"]
for name in inputs["after"]:
    assert inputs["after"][name] == (ROOT / name).read_bytes(), name
for name in inputs["before"]:
    if name not in ("lua/src/linkedspec/interpreter.lua", "lua/test/run.lua"):
        assert inputs["before"][name] == inputs["after"][name], name
assert inputs["after"] == inputs["direct"]
assert not same(False, 0) and not same("0", 0)
print("PASS: unchanged controls, strict kinds/errors, direct consumers and actual archived input bodies")
