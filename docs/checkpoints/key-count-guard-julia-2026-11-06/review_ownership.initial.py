"""Recover the separate Count-owned-source RED/GREEN and final current Julia normal."""
import contextlib
import copy
import io
import json
from pathlib import Path
import runpy
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
r = runpy.run_path(str((ROOT / BASE / "review.py").resolve()))
OWNER, NORMAL = r["OWNER"], r["NORMAL"]
FIXTURE = "tests/fixtures/key_count_count_source_ownership_julia_cases.json"
PHASES = ("ownership-before", "ownership-after", "final-current")


def main():
    old_output = io.StringIO()
    with contextlib.redirect_stdout(old_output):
        r["main"]()
    assert json.loads(old_output.getvalue()) == json.loads((BASE / "review-result.json").read_text())
    sealed = json.loads((BASE / "extra-raw-identities.json").read_text())
    for path, item in sealed.items():
        capsule = (ROOT / item["capsule"]).read_bytes()
        body = r["gzip"].decompress(capsule)
        assert r["digest"](capsule) == item["capsule_sha256"]
        assert r["digest"](body) == item["sha256"] and len(body) == item["bytes"]
        assert body == r["raw"](Path(path))
    inputs, artifacts = {}, {}
    for phase in PHASES:
        folder = BASE / phase
        records = json.loads((folder / "input-identities.json").read_text())
        inputs[phase] = r["recover"](folder / "inputs-before-first-run.tar.gz", records)
        records = json.loads((folder / "artifact-identities.json").read_text())
        recovered = r["recover"](folder / "actual-emitted-parsed.tar.gz", records)
        artifacts[phase] = {Path(p).name: body for p, body in recovered.items()}
        assert len(artifacts[phase]) == (6 if phase.startswith("ownership-") else 50)
        assert (folder / "activation.txt").read_text().strip() == r["ACTIVATION"]
        assert (folder / "exit.txt").read_text() == "0\n"
        assert r["raw"](folder / "stderr.log") == b""
        for name in ("observer.jl", "ownership-cases.json"):
            assert inputs[phase].get(str(BASE / name), (BASE / name).read_bytes()) == (BASE / name).read_bytes()
    original_records = json.loads((BASE / "final/input-identities.json").read_text())
    original = r["recover"](BASE / "final/inputs-before-first-run.tar.gz", original_records)
    before, after, final = (inputs[p] for p in PHASES)
    assert before[OWNER] == original[OWNER], "actual first candidate source"
    line = b"        !_runtime_is_ordinary_count_result_chain(chain.receiver, ()) &&\n"
    assert after[OWNER].count(line) == 2 and before[OWNER].count(line) == 1
    assert after[OWNER].replace(line, b"", 1) == before[OWNER], "exact single Count-owner permission exclusion"
    git_before = subprocess.check_output(["git", "show", r["ACTIVATION"] + ":" + OWNER])
    assert r["apply_patch"](git_before, (BASE / "current-producer-change.patch").read_bytes()) == after[OWNER]
    assert final[OWNER] == after[OWNER]
    old_list = b'("key_count_result_guard_cases.json",)'
    new_list = b'("key_count_result_guard_cases.json", "key_count_count_source_ownership_julia_cases.json")'
    assert after[NORMAL].count(new_list) == 1
    assert after[NORMAL].replace(new_list, old_list) == before[NORMAL] == original[NORMAL]
    assert final[NORMAL] == after[NORMAL]
    assert final[FIXTURE] == (BASE / "ownership-cases.json").read_bytes() == (ROOT / FIXTURE).read_bytes()
    cases = json.loads(final[FIXTURE])
    domain, errors = (json.loads(final[r[k]]) for k in ("DOMAIN", "ERRORS"))
    before_rows = r["frames"]("ownership-before", "KEY_COUNT_JULIA")
    after_rows = r["frames"]("ownership-after", "KEY_COUNT_JULIA")
    r["validate"](before_rows, cases, domain, errors, False)
    r["validate"](after_rows, cases, domain, errors, True)
    assert {c["id"] for c in cases if not r["target"](c, before_rows[c["id"]]["native"], domain)} == {"count_to_keys", "count_to_keys_effects"}
    assert r["same"](before_rows["initial_keys_controls"], after_rows["initial_keys_controls"])
    assert artifacts["ownership-before"] == artifacts["ownership-after"], "actual ownership modules/parsed unchanged"
    all_cases = json.loads(final[r["FIXTURES"][0]]) + cases
    rows = r["frames"]("final-current", "KEY_COUNT_GUARD_JULIA")
    r["validate"](rows, all_cases, domain, errors, True)
    old_rows = r["frames"]("final", "KEY_COUNT_GUARD_JULIA")
    assert all(r["same"](rows[key], value) for key, value in old_rows.items()), "original22 exact at final current source"
    old_records = json.loads((BASE / "final/artifact-identities.json").read_text())
    old_artifacts = r["recover"](BASE / "final/actual-emitted-parsed.tar.gz", old_records)
    expected = {Path(p).name: body for p, body in old_artifacts.items()}
    assert not expected.keys() & artifacts["ownership-before"].keys()
    expected.update(artifacts["ownership-before"])
    assert artifacts["final-current"] == expected, "all25 actual module/parsed bodies unchanged"
    output = r["raw"](BASE / "final-current/stdout.log").decode()
    for summary in ("Julia CountKeys source and continuation guards |  126    126", "Julia Count source and prefix guards |   92     92", "Julia Length source and continuation guards |  122    122", "Count and length receiver continuations |    3      3", "Count array-only domain |    3      3"):
        assert summary in output
    rejected = []
    for control in ("Count-owner-zero-restored", "missing-new-case", "source-drift", "new-fixture-omission"):
        changed = copy.deepcopy(rows)
        try:
            if control == "Count-owner-zero-restored":
                changed["count_to_keys"]["native"]["value"][0] = 0
            elif control == "missing-new-case":
                changed.pop("count_to_keys_effects")
            elif control == "source-drift":
                assert (after[OWNER] + b"drift").replace(line, b"", 1) == before[OWNER]
            else:
                altered = dict(final); altered.pop(FIXTURE)
                assert altered[FIXTURE] == final[FIXTURE]
            r["validate"](changed, all_cases, domain, errors, True)
        except (AssertionError, KeyError):
            rejected.append(control)
        else:
            raise AssertionError("ineffective control " + control)
    print(json.dumps(dict(result="PASS", original22="historical proof preserved; current observations exact", ownership="1PASS2RED to3PASS/four routes", current_normal_assertions=126, final_focused_assertions=346, emitted_modules_and_parsed_unchanged=25, rejected_extra_controls=rejected, limits="Finite Julia controls; fresh Modules share runtime. Prior peers require independent75.7 assessment; full admission/custody/isolation remain separate."), sort_keys=True))


if __name__ == "__main__":
    main()
