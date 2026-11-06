"""Read-only recovery of finite installed-host Lua Length guard evidence; no runtime replay."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import tarfile

ROOT = Path.cwd()
BASE = Path(__file__).parent.relative_to(ROOT)
OWNER = "lua/src/linkedspec/interpreter.lua"
NORMAL = "lua/test/length_result_guard_composition_test.lua"
DOMAIN = "tests/fixtures/length_result_guard_lua_domain.json"
ERRORS = "tests/fixtures/length_result_guard_lua_errors.json"
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


def frames(phase, host, prefix):
    rows = {}
    for line in raw(BASE / phase / host / "normal-stdout.log").decode().splitlines():
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
        for host in ("puc", "luajit"):
            folder = BASE / phase / host
            records = json.loads((ROOT / folder / "artifact-identities.json").read_text())
            artifacts[phase, host] = recover(folder / "actual-emitted-parsed.tar.gz", records)
            assert (ROOT / folder / "version-exit.txt").read_text() == "0\n"
            assert (ROOT / folder / "normal-exit.txt").read_text() == ("1\n" if phase == "normal-before" else "0\n")
    before, after, final = (inputs[p] for p in ("normal-before", "normal-after", "final"))
    assert before.keys() == after.keys() == final.keys()
    assert [p for p in before if before[p] != after[p]] == [OWNER], "only runtime owner changes"
    assert after == final
    assert after[OWNER] == (ROOT / OWNER).read_bytes()
    for path in (NORMAL, DOMAIN, ERRORS, *FIXTURES):
        assert before[path] == after[path] == (ROOT / path).read_bytes(), "unchanged normal/oracles"
    source = after[OWNER].decode()
    start = source.index("-- Length results retain ownership before initial Count fallback.")
    end = source.index("-- Canonical index sources", start)
    retained = source[:start] + source[end:]
    line = "    typed_source.receiver_mutation.is_ordinary_length_result_chain(target_receiver, calls) or\n"
    assert retained.count(line) == 1
    assert retained.replace(line, "").encode() == before[OWNER], "outside-member/admission bytes exact"
    cases = []
    for path in FIXTURES:
        cases.extend(json.loads(before[path]))
    domain, errors = (json.loads(before[p]) for p in (DOMAIN, ERRORS))
    observations, modules, parsed_inputs = {}, {}, {}
    for host in ("puc", "luajit"):
        versions = []
        for phase in PHASES:
            folder = BASE / phase / host
            version = (raw(folder / "version-stdout.log") + raw(folder / "version-stderr.log")).decode().strip()
            assert version
            versions.append(version)
            rows = frames(phase, host, "LENGTH_LUA" if phase.startswith("probe-") else "LENGTH_GUARD_LUA")
            validate(rows, cases, domain, errors, phase not in ("probe-before", "normal-before"))
            observations[phase, host] = rows
            mismatch = {r["id"] for r in cases if not target(r, rows[r["id"]]["native"], domain)}
            assert mismatch == (RED if phase in ("probe-before", "normal-before") else set())
            prefix = str(folder / "emitted") + "/"
            modules[phase, host] = {p[len(prefix):]: body for p, body in artifacts[phase, host].items() if p.startswith(prefix)}
            assert set(modules[phase, host]) == {r["id"] + ".lua" for r in cases}
            prefix = str(folder / "parsed") + "/"
            parsed_inputs[phase, host] = {p[len(prefix):]: json.loads(body) for p, body in artifacts[phase, host].items() if p.startswith(prefix)}
            assert set(parsed_inputs[phase, host]) == {r["id"] + ".json" for r in cases}
            persisted = frames(phase, host, "LENGTH_LUA_INPUT")
            assert list(persisted) == [r["id"] for r in cases]
            assert all(same(persisted[r["id"]], parsed_inputs[phase, host][r["id"] + ".json"]) for r in cases)
            if phase != "normal-before":
                assert raw(folder / "normal-stderr.log") == b""
            if not phase.startswith("probe-"):
                summary = "LENGTH_GUARD_LUA_SUMMARY 122 checks " + ("48" if phase == "normal-before" else "0") + " failures"
                assert summary in raw(folder / "normal-stdout.log").decode()
        assert all(v == versions[0] for v in versions), "installed host identity unchanged"
        assert ("Lua 5.5.1" if host == "puc" else "LuaJIT 2.1.1788460057") in versions[0]
        assert all(modules[p, host] == modules["probe-before", host] for p in PHASES), "actual modules unchanged"
        assert all(same(parsed_inputs[p, host], parsed_inputs["probe-before", host]) for p in PHASES), "actual parsed inputs unchanged"
        baseline, current = (observations[p, host] for p in ("probe-before", "probe-after"))
        assert same(baseline[domain["id"]]["native"], {"value": domain["expected"]})
        for row in cases:
            if row["id"] not in RED:
                assert same(baseline[row["id"]], current[row["id"]]), "healthy observation changed"
        final_output = raw(BASE / "final" / host / "normal-stdout.log").decode()
        assert "count/length receiver checks passed" in final_output
        assert "COUNT_GUARD_LUA_SUMMARY 92 checks 0 failures" in final_output
    assert same(observations["probe-before", "puc"], observations["probe-before", "luajit"]), "independently observed common profiles"
    rejected = []
    for control in ("missing-row", "false-as-number", "error-profile-drift", "missing-domain-input", "changed-module"):
        rows = copy.deepcopy(observations["probe-after", "puc"])
        try:
            if control == "missing-row":
                rows.pop(next(iter(rows)))
            elif control == "false-as-number":
                rows["logical_valid_null_zero"]["native"]["value"][0] = 0
            elif control == "error-profile-drift":
                rows["needed_source_error"]["plan"]["generated"] = False
            elif control == "missing-domain-input":
                broken = dict(final); broken.pop(DOMAIN)
                assert DOMAIN in broken, "direct domain omission"
            else:
                module = next(iter(modules["probe-after", "puc"].values()))
                assert digest(module + b"changed") == digest(module), "actual module mutation"
            validate(rows, cases, domain, errors, True)
        except AssertionError:
            rejected.append(control)
        else:
            raise AssertionError("ineffective control " + control)
    print(json.dumps(dict(result="PASS", hosts=["PUC5.5.1", "LuaJIT2.1.1788460057"], original_per_host="12PASS12RED", final_per_host="24PASS", unchanged_healthy_per_host=12, normal_checks_per_host=122, emitted_modules_identical_per_host=24, rejected_controls=rejected, limits="Finite authored installed-host four-route controls; emitted modules share process/runtime. Actual declared direct Lua/native source/fixtures/wrappers/modules/parsed inputs retained. Complete native/transitive closure, general isolation, declared5.4, canonical discovery and full admission remain separate."), sort_keys=True))


if __name__ == "__main__":
    main()
