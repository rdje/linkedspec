"""Read-only historical key-count selection recovery; no runtime replay."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile
ROOT = Path.cwd()
BASE = Path(__file__).parent.relative_to(ROOT)
OWNER = "perl/LinkedSpec/ActionIR/MethodLowering.pm"
FIXTURE = "tests/fixtures/key_count_result_guard_cases.json"
ACTIVATION = "f5e2350ba41b67584640ca80b662ec0708ed484a"
RED = {"key_count_free_guard", "key_count_receiver_guard", "function_guard", "copy_guard", "logical_guard", "seeded_hash", "count_contrast", "free_keys_count", "receiver_keys_count", "keys_count_with", "keys_count_copy_logical", "produced_zero_keys"}
REF_ERRORS = {"free_false", "receiver_false", "free_array", "receiver_array", "free_true", "free_nonempty_array"}


def same(a, b):
    return json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True)


def digest(body):
    return hashlib.sha256(body).hexdigest()


def raw(path):
    path = ROOT / path
    return path.read_bytes() if path.exists() else gzip.decompress(Path(str(path) + ".gz").read_bytes())


def frames(body):
    found = []
    for line in body.splitlines():
        try:
            data = json.loads(line)
        except (ValueError, UnicodeDecodeError):
            continue
        if isinstance(data, list) and data and all(isinstance(r, dict) and "id" in r and "metadata" in r for r in data):
            found.append(data)
    assert len(found) == 1, "one complete identity-checked frame"
    return found[0]


def recover(phase):
    records = json.loads((ROOT / BASE / phase / "input-identities.json").read_text())
    found = {}
    with tarfile.open(ROOT / BASE / phase / "inputs-before-first-run.tar.gz") as archive:
        for member in archive.getmembers():
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and ".." not in path.parts
            assert member.name not in found
            body = archive.extractfile(member).read(); item = records[member.name]
            assert digest(body) == item["sha256"] and len(body) == item["bytes"]
            assert member.mode & 0o777 == item["mode"]
            found[member.name] = body
    assert found.keys() == records.keys(), "complete declared archive"
    assert (ROOT / BASE / phase / "activation.txt").read_text().strip() == ACTIVATION
    assert (ROOT / BASE / phase / "exit.txt").read_text() == "0\n"
    assert raw(BASE / phase / "stderr.log") == b""
    return found


def validate(rows, cases, modules):
    assert [r["id"] for r in rows] == [r["id"] for r in cases], "complete ordered cases"
    for row, case in zip(rows, cases):
        assert row["source"] == case["source"] and row["body"] == case["body"]
        assert row["metadata"] == dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0, canonical_action_ir_fallback_count=0, unresolved_helper_count=0)
        assert row["native_callable"] == 1
        assert not row["descriptor_error"] and not row["native_build_error"] and not row["emission_error"]
        path = PurePosixPath(row["module_retained_before_load"])
        assert not path.is_absolute() and ".." not in path.parts
        assert modules[row["id"]].decode() == row["emitted_before_load"], "actual pre-load module"
        if row["id"] != "needed_source_error":
            assert row["loaded"] == 1 and not row["load_error"] and not row["warnings"]
        if not row["native_error"] and not row["fresh_error"]:
            assert same(row["native"], row["fresh"]), "native/fresh actual value and kind"
            assert row["native_cursor"] == row["fresh_cursor"] == 0


def validate_seeds(seed, namespace):
    assert seed["namespace"] == namespace
    assert [(r["route"], r["seed"]) for r in seed["rows"]] == [(route, mode) for route in ("public", "module") for mode in ("empty", "outer", "main")]
    for row in seed["rows"]:
        expected = {"k": 1, "main": "MAIN"} if row["seed"] == "main" else {"k": 1}
        assert same(row["value"], expected), "distinguishing main namespace read"
        assert not row["error"] and not row["warnings"]
        assert same(row["host_before"], row["host_after"]), "unchanged localized host data"


def validate_boundary(inputs, git_owner):
    assert all(records[OWNER] == git_owner for records in inputs.values()), "historical source boundary; no latest-code freshness claim"


def validate_guard_targets(rows, cases):
    wrong = {r["id"] for r, case in zip(rows, cases) if "expected" in case and not same(r["native"], case["expected"])}
    assert wrong == RED, "exact original target gaps and healthy value kinds"


def main():
    for path, item in json.loads((ROOT / BASE / "raw-identities.json").read_text()).items():
        capsule = (ROOT / item["capsule"]).read_bytes(); body = gzip.decompress(capsule)
        assert digest(capsule) == item["capsule_sha256"] and digest(body) == item["sha256"]
        assert len(body) == item["bytes"] and body == raw(path)
    phases = ("initial", "diagnostics", "preservation", "seeds", "producer-seeds")
    inputs = {p: recover(p) for p in phases}
    original_owner = subprocess.check_output(["git", "show", ACTIVATION + ":" + OWNER])
    validate_boundary(inputs, original_owner)
    assert b"&& ($method eq 'contains' || $method eq 'index_of' || $method eq 'count')" in original_owner
    assert b"defined($__ls_count_keys) ? scalar(keys %{$__ls_count_keys}) : 0" in original_owner
    observations, modules, cases = {}, {}, {}
    for phase, filename in (("initial", "cases.json"), ("diagnostics", "domain-cases.json"), ("preservation", "continuation-cases.json")):
        cases[phase] = json.loads(inputs[phase][str(BASE / filename)])
        assert inputs[phase][str(BASE / filename)] == (ROOT / BASE / filename).read_bytes()
        rows = frames(raw(BASE / phase / "stdout.log"))
        modules[phase] = {r["id"]: gzip.decompress((ROOT / r["module_retained_before_load"]).read_bytes()) for r in rows}
        validate(rows, cases[phase], modules[phase]); observations[phase] = rows
    initial = {r["id"]: r for r in observations["initial"]}
    prior_path = "docs/checkpoints/length-selection-2026-11-05/stdout.json.gz"
    prior = frames(gzip.decompress(inputs["initial"][prior_path]))
    originals = [r for r in prior if r["id"].startswith("key_count_")]
    assert len(originals) == 3
    for old in originals:
        current = initial[old["id"]]
        assert old["source"] == current["source"]
        assert same(old["native"], current["native"]) and same(old["fresh"], current["fresh"])
    validate_guard_targets(observations["initial"], cases["initial"])
    needed = initial["needed_source_error"]
    assert needed["loaded"] == 0 and needed["native_error"]["stage"] == "rule_handler_compile"
    assert "Can't modify constant" in needed["load_error"] and needed["warnings"]
    assert '{items="text";' in needed["lowered"], "raw block assignment emitted into Perl"
    domain = initial["source_domain"]
    assert "Not a HASH reference" in domain["native_error"]["detail"] and "Not a HASH reference" in domain["fresh_error"]["detail"]
    diagnostic = {r["id"]: r for r in observations["diagnostics"]}
    for row, case in zip(observations["diagnostics"], cases["diagnostics"]):
        if row["id"] in REF_ERRORS:
            assert all("Not a HASH reference" in row[route + "_error"]["detail"] for route in ("native", "fresh"))
        elif "expected_error" in case:
            assert all(case["expected_error"] in row[route + "_error"]["detail"] for route in ("native", "fresh"))
        else:
            expected = case.get("expected", 2 if row["id"] == "receiver_hash" else 0)
            assert all(not row[route + "_error"] and same(row[route], expected) for route in ("native", "fresh"))
    preservation = observations["preservation"][0]
    assert preservation["id"] == "initial_source_fallback" and same(preservation["native"], [1, 1, 1, 1])
    selected = cases["initial"] + cases["preservation"]
    frozen = [{**{k: v for k, v in row.items() if k != "body"}, "input": "x", "rule": "Value"} for row in selected]
    assert json.loads((ROOT / FIXTURE).read_text()) == frozen and len(frozen) == 22
    seed_input = json.loads(inputs["seeds"][str(BASE / "seed-input.json")])
    namespace = str(diagnostic["free_hash"]["native"])
    assert seed_input["namespace"] == namespace and namespace == "2"
    assert seed_input["lowered"] == initial["seeded_hash"]["lowered"]
    assert gzip.decompress(inputs["seeds"][seed_input["module"]]) == modules["initial"]["seeded_hash"]
    carrier = gzip.decompress((ROOT / BASE / "seeds/public-carrier.pl.gz").read_bytes()).decode()
    assert carrier == "package LinkedSpec::KeyCountSeedPublic; no strict; sub Run { " + seed_input["lowered"] + " }"
    seeds = json.loads(raw(BASE / "seeds/stdout.log")); validate_seeds(seeds, namespace)
    producer_input = json.loads(inputs["producer-seeds"][str(BASE / "producer-seed-input.json")])
    producer_row = diagnostic["free_number"]
    assert producer_input["source"] == producer_row["source"]
    assert producer_input["lowered"] == producer_row["lowered"] == "return scalar(keys %4)"
    assert producer_input["namespace"] == "4"
    assert gzip.decompress(inputs["producer-seeds"][producer_input["module"]]) == modules["diagnostics"]["free_number"]
    producer_carrier = gzip.decompress((ROOT / BASE / "producer-seeds/public-carrier.pl.gz").read_bytes()).decode()
    assert producer_carrier == "package LinkedSpec::KeyCountProducerSeedPublic; no strict; sub Run { " + producer_input["lowered"] + " }"
    producer_seeds = json.loads(raw(BASE / "producer-seeds/stdout.log"))
    assert producer_seeds["namespace"] == "4"
    assert [(r["route"], r["seed"]) for r in producer_seeds["rows"]] == [(route, mode) for route in ("public", "module") for mode in ("empty", "outer", "main")]
    for row in producer_seeds["rows"]:
        assert row["value"] == (1 if row["seed"] == "main" else 0), "numeric input is misread as main host Hash4"
        assert not row["error"] and not row["warnings"] and same(row["host_before"], row["host_after"])
    rejected = []
    for control in ("missing-row", "not-ready", "false-as-number", "changed-module", "false-source-boundary", "host-scope-drift"):
        rows = copy.deepcopy(observations["initial"]); bodies = dict(modules["initial"])
        try:
            if control == "missing-row": rows.pop()
            elif control == "not-ready": rows[0]["metadata"]["raw_perl_dependency_count"] = 1
            elif control == "false-as-number":
                changed = next(r for r in rows if r["id"] == "logical_valid_zero")
                changed["native"][0] = changed["fresh"][0] = 0
            elif control == "changed-module": bodies[rows[0]["id"]] += b" changed"
            elif control == "false-source-boundary":
                changed_inputs = copy.deepcopy(inputs)
                changed_body = original_owner + b"changed"
                changed_inputs["initial"][OWNER] = changed_body
                forged = dict(sha256=digest(changed_body), bytes=len(changed_body))
                assert forged["sha256"] == digest(changed_body) and forged["bytes"] == len(changed_body)
                validate_boundary(changed_inputs, original_owner)

            else:
                changed = copy.deepcopy(seeds); changed["namespace"] = "4"
                validate_seeds(changed, namespace)
            validate(rows, cases["initial"], bodies)
            validate_guard_targets(rows, cases["initial"])
        except AssertionError:
            rejected.append(control)
        else: raise AssertionError("ineffective control " + control)
    print(json.dumps(dict(result="PASS", frozen_programs=22, initial_runtime_clean=19, original_healthy=7, guard_target_gaps=12, extra_initial_preservation=1, producer_prerequisites=2, independent_source_controls=20, reference_errors=6, localized_result_seed_controls=6, localized_producer_seed_controls=6, rejected_controls=rejected, limits="Historical authored primary observations at the named Git boundary, not repaired behavior/current runtime freshness. Native/transitive closure and general host/process/package isolation remain separate; peers unassessed."), sort_keys=True))


if __name__ == "__main__": main()
