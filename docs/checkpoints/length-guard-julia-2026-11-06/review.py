"""Read-only recovery of finite Julia Length guard evidence; no runtime replay."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import tarfile

ROOT = Path.cwd()
BASE = Path(__file__).parent.relative_to(ROOT)
OWNER = "julia/src/runtime/Interpreter.jl"
NORMAL = "julia/test/length_result_guard_composition_test.jl"
DOMAIN = "tests/fixtures/length_result_guard_julia_domain.json"
ERRORS = "tests/fixtures/length_result_guard_julia_errors.json"
FIXTURES = ("tests/fixtures/length_result_guard_cases.json", "tests/fixtures/length_count_source_ownership_cases.json")
PHASES = ("probe-before", "normal-before", "normal-after", "probe-after", "final")
RED = {"length_free_guard", "length_receiver_guard", "function_guard", "copy_guard", "logical_guard", "seeded_hash", "count_contrast", "free_length_count", "receiver_length_count", "length_count_with", "length_count_copy_logical", "produced_null_zero_count"}
ROUTES = {"native", "restored", "plan", "fresh"}


def digest(body):
    return hashlib.sha256(body).hexdigest()


def same(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return a == b
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def raw(path):
    path = ROOT / path
    return path.read_bytes() if path.exists() else gzip.decompress(Path(str(path) + ".gz").read_bytes())


def recover(archive_path, records):
    found = {}
    with tarfile.open(ROOT / archive_path) as archive:
        for member in archive.getmembers():
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and ".." not in path.parts
            assert member.name not in found
            body = archive.extractfile(member).read()
            item = records[member.name]
            assert digest(body) == item["sha256"] and len(body) == item["bytes"]
            assert member.mode & 0o777 == item["mode"]
            found[member.name] = body
    assert found.keys() == records.keys(), "complete declared inputs"
    return found


def frames(phase, prefix):
    rows = {}
    for line in raw(BASE / phase / "stdout.log").decode().splitlines():
        if line.startswith(prefix + " "):
            _, identifier, body = line.split(" ", 2)
            assert identifier not in rows
            rows[identifier] = json.loads(body)
    return rows


def target(row, value, domain):
    if "expected_error" in row:
        return isinstance(value.get("error"), str) and row["expected_error"] in value["error"]
    return set(value) == {"value"} and same(value["value"], row.get("expected", domain["expected"]))


def validate(rows, cases, domain, errors, required):
    assert list(rows) == [r["id"] for r in cases], "complete ordered observations"
    for row in cases:
        routes = rows[row["id"]]
        assert set(routes) == ROUTES
        if "expected_error" in row:
            assert same(routes, errors[row["id"]]), "frozen per-route error profiles"
        else:
            assert all(same(routes["native"], v) for v in routes.values()), "route value/kind agreement"
        if required:
            assert all(target(row, value, domain) for value in routes.values()), "target value/kind/effects"


def main():
    sealed = json.loads((ROOT / BASE / "raw-identities.json").read_text())
    for path, item in sealed.items():
        capsule = (ROOT / item["capsule"]).read_bytes()
        body = gzip.decompress(capsule)
        assert digest(capsule) == item["capsule_sha256"]
        assert digest(body) == item["sha256"] and len(body) == item["bytes"] and body == raw(Path(path))
    inputs = {}
    artifacts = {}
    for phase in PHASES:
        records = json.loads((ROOT / BASE / phase / "input-identities.json").read_text())
        inputs[phase] = recover(BASE / phase / "inputs-before-first-run.tar.gz", records)
        artifact_records = json.loads((ROOT / BASE / phase / "artifact-identities.json").read_text())
        artifacts[phase] = recover(BASE / phase / "actual-emitted-parsed.tar.gz", artifact_records)
        assert (ROOT / BASE / phase / "exit.txt").read_text() == ("1\n" if phase == "normal-before" else "0\n")
    before, after, final = (inputs[p] for p in ("normal-before", "normal-after", "final"))
    assert before.keys() == after.keys() == final.keys()
    assert [p for p in before if before[p] != after[p]] == [OWNER], "only runtime owner changes"
    assert after == final
    assert after[OWNER] == (ROOT / OWNER).read_bytes()
    for path in (NORMAL, DOMAIN, ERRORS, *FIXTURES):
        assert before[path] == after[path] == (ROOT / path).read_bytes(), "unchanged normal and oracles"
    source = after[OWNER].decode()
    start = source.index("# Length results retain ownership before initial Count fallback.")
    end = source.index("# Canonical index sources", start)
    retained = source[:start] + source[end:]
    line = "        _runtime_is_ordinary_length_result_chain(chain.receiver, chain.calls) ||\n"
    assert retained.count(line) == 1
    assert retained.replace(line, "").encode() == before[OWNER], "outside-helper/admission bytes exact"
    cases = []
    for path in FIXTURES:
        cases.extend(json.loads(before[path]))
    domain = json.loads(before[DOMAIN])
    errors = json.loads(before[ERRORS])
    observations = {}
    modules = {}
    parsed_inputs = {}
    for phase in PHASES:
        rows = frames(phase, "LENGTH_JULIA" if phase.startswith("probe-") else "LENGTH_GUARD_JULIA")
        validate(rows, cases, domain, errors, phase not in ("probe-before", "normal-before"))
        observations[phase] = rows
        mismatch = {r["id"] for r in cases if not target(r, rows[r["id"]]["native"], domain)}
        assert mismatch == (RED if phase in ("probe-before", "normal-before") else set())
        prefix = str(BASE / phase / ("emitted" if phase.startswith("probe-") else "normal-artifacts/emitted")) + "/"
        modules[phase] = {p[len(prefix):]: body for p, body in artifacts[phase].items() if p.startswith(prefix)}
        assert set(modules[phase]) == {r["id"] + ".jl" for r in cases}
        parsed_prefix = prefix.replace("/emitted/", "/parsed/")
        parsed_inputs[phase] = {p[len(parsed_prefix):]: json.loads(body) for p, body in artifacts[phase].items() if p.startswith(parsed_prefix)}
        assert set(parsed_inputs[phase]) == {r["id"] + ".json" for r in cases}
        if phase.startswith("probe-"):
            persisted = frames(phase, "LENGTH_JULIA_INPUT")
            assert list(persisted) == [r["id"] for r in cases]
            assert all(same(persisted[r["id"]], parsed_inputs[phase][r["id"] + ".json"]) for r in cases)
    assert all(m == modules["probe-before"] for m in modules.values()), "actual emitted bodies identical"
    assert all(same(p, parsed_inputs["probe-before"]) for p in parsed_inputs.values()), "actual parsed inputs identical"
    assert same(observations["probe-before"][domain["id"]]["native"], {"value": domain["expected"]})
    for row in cases:
        if row["id"] not in RED:
            assert same(observations["probe-before"][row["id"]], observations["probe-after"][row["id"]]), "healthy observation changed"
    assert b"122    122" in raw(BASE / "normal-after/stdout.log"), "new normal assertions"
    final_output = raw(BASE / "final/stdout.log").decode()
    assert "Julia Length source and continuation guards |  122    122" in final_output
    assert "Count and length receiver continuations |    3      3" in final_output
    assert "Count array-only domain |    3      3" in final_output
    assert "Julia Count source and prefix guards |   92     92" in final_output
    assert raw(BASE / "final/stderr.log") == b""
    rejected = []
    for control in ("missing-row", "false-as-number", "error-class-drift", "missing-domain-input", "changed-module"):
        rows = copy.deepcopy(observations["probe-after"])
        try:
            if control == "missing-row":
                rows.pop(next(iter(rows)))
            elif control == "false-as-number":
                rows["logical_valid_null_zero"]["native"]["value"][0] = 0
            elif control == "error-class-drift":
                rows["needed_source_error"]["plan"]["class"] = "wrong"
            elif control == "missing-domain-input":
                broken = dict(final); broken.pop(DOMAIN)
                assert DOMAIN in broken, "direct domain omission"
            else:
                module = next(iter(modules["probe-after"].values()))
                assert digest(module + b"changed") == digest(module), "actual module mutation"
            validate(rows, cases, domain, errors, True)
        except AssertionError:
            rejected.append(control)
        else:
            raise AssertionError("ineffective control " + control)
    print(json.dumps(dict(result="PASS", original="12PASS12RED", final="24PASS", unchanged_healthy=12, normal_assertions=122, final_focused_assertions=220, emitted_modules_identical=24, rejected_controls=rejected, limits="Finite authored four-route controls; fresh Modules share process/runtime. Actual declared Julia source/manifest/fixture/wrapper/module/parsed inputs retained; complete native/transitive closure, general isolation, canonical discovery and full admission remain separate."), sort_keys=True))


if __name__ == "__main__":
    main()
