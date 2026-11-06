"""Readonly finite typed-source RED/GREEN and actual input/module recovery."""
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
NORMAL = "t/key_count_block_source_composition.t"
FIXTURE = "tests/fixtures/key_count_block_source_cases.json"
ACTIVATION = "989580054c520830f32729a2eebccfd548bb429e"
RED = {"error_fluent_default", "error_direct", "error_receiver_source", "typed_hash_mutation"}


def digest(body): return hashlib.sha256(body).hexdigest()


def same(a, b): return json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True)


def raw(path):
    path = ROOT / path
    return path.read_bytes() if path.exists() else gzip.decompress(Path(str(path) + ".gz").read_bytes())


def recover(phase):
    records = json.loads((ROOT / BASE / phase / "input-identities.json").read_text())
    result = {}
    with tarfile.open(ROOT / BASE / phase / "inputs-before-first-run.tar.gz") as archive:
        for member in archive.getmembers():
            name = PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and ".." not in name.parts
            assert member.name not in result
            body = archive.extractfile(member).read(); item = records[member.name]
            assert digest(body) == item["sha256"] and len(body) == item["bytes"]
            assert member.mode & 0o777 == item["mode"]
            result[member.name] = body
    assert result.keys() == records.keys()
    assert (ROOT / BASE / phase / "activation.txt").read_text().strip() == ACTIVATION
    return result


def observations(phase):
    result = {}
    for line in raw(BASE / phase / "normal-stderr.log").decode().splitlines():
        line = line.lstrip()
        for prefix in ("# KEY_COUNT_BLOCK_ACTUAL ", "# KEY_COUNT_BLOCK_ERROR "):
            if line.startswith(prefix):
                identifier, body = line[len(prefix):].split(" ", 1)
                assert identifier not in result
                result[identifier] = json.loads(body)
    return result


def target(case, row):
    if not row["native_callable"] or row["build_error"] or not row["loaded"] or row["emission_error"] or row["load_error"] or row["warnings"] or row["descriptor_error"]:
        return False
    meta = row["metadata"]
    if not meta["language_agnostic_action_ir_ready"] or any(meta[k] for k in ("raw_perl_dependency_count", "canonical_action_ir_fallback_count", "unresolved_helper_count")):
        return False
    for route in ("native", "fresh"):
        error = row[route + "_error"]
        if "expected_error" in case:
            if not isinstance(error, dict) or case["expected_error"] not in error.get("detail", "") or error.get("stage") != case["expected_stages"][route] or row[route] is not None:
                return False
        elif error or not same(row[route], case["expected"]) or row[route + "_cursor"] != 0:
            return False
    return True


def validate(rows, cases, failing):
    assert list(rows) == [r["id"] for r in cases], "complete ordered observations"
    assert {r["id"] for r in cases if not target(r, rows[r["id"]])} == failing, "target values/kinds/execution-stage errors"


def expected_source(before):
    source = before.decode()
    replacements = [
        ("&& ($method eq 'contains' || $method eq 'index_of' || $method eq 'count')", "&& ($method eq 'contains' || $method eq 'index_of' || $method eq 'count' || $method eq 'count_keys')"),
        ("# A terminal Count on a value block uses the same typed argument owner as", "# A terminal Count or CountKeys on a value block uses the same typed owner as"),
        ("      && ($terminal_count_call->{method} // '') eq 'count'\n      && ($terminal_count_call->{source_method} // 'count') eq 'count'\n", "      && ($terminal_count_call->{method} // '') =~ /\\A(?:count|count_keys)\\z/o\n      && ($terminal_count_call->{source_method} // $terminal_count_call->{method}) eq $terminal_count_call->{method}\n"),
        ("    kind => 'call', name => 'count', source_method => 'count',\n", "    kind => 'call', name => $terminal_count_call->{method}, source_method => $terminal_count_call->{method},\n"),
    ]
    for old, new in replacements:
        assert source.count(old) == 1
        source = source.replace(old, new)
    return source.encode()


def check_modules(bodies, frames):
    assert list(frames) == [str(i) for i in range(1, 10)]
    assert list(bodies) == [str(i) for i in range(1, 10)]
    for identifier, body in bodies.items():
        assert body.decode() == frames[identifier]["emitted"], "actual persisted module before execution"


def main():
    for path, item in json.loads((ROOT / BASE / "raw-identities.json").read_text()).items():
        capsule = (ROOT / item["capsule"]).read_bytes(); body = gzip.decompress(capsule)
        assert digest(capsule) == item["capsule_sha256"] and digest(body) == item["sha256"] and len(body) == item["bytes"] and body == raw(path)
    inputs = {p: recover(p) for p in ("before", "after", "nearest")}
    before, after, nearest = (inputs[p] for p in ("before", "after", "nearest"))
    assert before.keys() == after.keys() == nearest.keys()
    assert [p for p in before if before[p] != after[p]] == [OWNER]
    assert after == nearest and after[OWNER] == expected_source(before[OWNER]), "only typed argument and canonical terminal delegation changes"
    assert before[OWNER] == subprocess.check_output(["git", "show", ACTIVATION + ":" + OWNER])
    for path in (NORMAL, FIXTURE):
        assert before[path] == after[path] == (ROOT / path).read_bytes(), "unchanged normal/oracles"
    cases = json.loads(before[FIXTURE]); rows = {p: observations(p) for p in inputs}
    for phase in inputs:
        validate(rows[phase], cases, RED if phase == "before" else set())
        assert (ROOT / BASE / phase / "normal-exit.txt").read_text() == ("1\n" if phase == "before" else "0\n")
    for case in cases:
        if case["id"] not in RED:
            assert same(rows["before"][case["id"]], rows["after"][case["id"]]), "healthy complete observation changed"
    modules, frames_by_phase = {}, {}
    for phase in inputs:
        frames = {}
        for line in raw(BASE / phase / "normal-stdout.log").decode().splitlines():
            line = line.lstrip()
            if line.startswith("KEY_COUNT_BLOCK_INPUT "):
                _, identifier, body = line.split(" ", 2); assert identifier not in frames
                frames[identifier] = json.loads(body)
        bodies = {}
        records = json.loads((ROOT / BASE / phase / "module-identities.json").read_text())
        for i, case in enumerate(cases, 1):
            path = BASE / phase / "modules" / ("module-" + str(i) + ".pm.gz")
            capsule = (ROOT / path).read_bytes(); body = gzip.decompress(capsule); item = records[str(path)]
            assert digest(capsule) == item["sha256"] and digest(body) == item["raw_sha256"] and len(body) == item["raw_bytes"]
            assert (ROOT / path).stat().st_mode & 0o777 == item["mode"]
            assert frames[str(i)]["source"] == case["source"]
            bodies[str(i)] = body
        assert len(records) == len(cases)
        check_modules(bodies, frames); modules[phase] = bodies; frames_by_phase[phase] = frames
    assert modules["after"] == modules["nearest"]
    assert {cases[int(i)-1]["id"] for i in modules["before"] if modules["before"][i] != modules["after"][i]} == RED
    assert (ROOT / BASE / "after/owner-syntax-exit.txt").read_text() == "0\n"
    assert b"syntax OK" in raw(BASE / "after/owner-syntax-stderr.log")
    assert "Files=3, Tests=28," in raw(BASE / "nearest/normal-stdout.log").decode()
    rejected = []
    for control in ("missing-row", "number-as-bool", "needed-error-stage", "changed-module", "outside-scope-source"):
        mutated = copy.deepcopy(rows["after"])
        try:
            if control == "missing-row": mutated.pop(next(iter(mutated)))
            elif control == "number-as-bool":
                mutated["pure_hash_block"]["native"] = mutated["pure_hash_block"]["fresh"] = True
            elif control == "needed-error-stage": mutated["error_direct"]["fresh_error"]["stage"] = "rule_handler_compile"
            elif control == "changed-module":
                bodies = dict(modules["after"]); bodies["1"] += b" changed"
                check_modules(bodies, frames_by_phase["after"])
            else: assert after[OWNER] + b" changed" == expected_source(before[OWNER]), "outside allowed source delta"
            validate(mutated, cases, set())
        except AssertionError: rejected.append(control)
        else: raise AssertionError("ineffective control " + control)
    print(json.dumps(dict(result="PASS", original="5PASS4RED", final="9PASS", unchanged_healthy=5, changed_emitted_modules=4, nearest_groups=28, rejected_controls=rejected, limits="Finite authored native/fresh typed-source controls and declared direct inputs/modules. Historical retained epochs, not latest-code freshness; full native/transitive closure, domains75.0.2, result guards75.1, peers and full admission remain separate."), sort_keys=True))


if __name__ == "__main__": main()
