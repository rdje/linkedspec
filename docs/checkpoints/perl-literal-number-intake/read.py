"""Read-only preliminary issue review; repair/admission remains TYPE-REFERENCE-BOOK.1.2.22."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "docs/checkpoints/signed-array-perl"))
import common as c
import book as renderer

PREFIX = "docs/checkpoints/perl-literal-number-intake/"


def load(name):
    return json.loads(gzip.decompress((ROOT / PREFIX / name).read_bytes()))


def same(a, b):
    return json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True)


def check():
    candidate = load("candidate-before.json.gz")
    assert candidate["fingerprint"] == "34796a33f7ff0ed40fd75eb86c9bc87392189dca913bbab14b90ce6e580a0d50"
    assert candidate["ci_termination"]["observed_tool_exit_code"] == 143
    assert len(candidate["candidate"]) == 129
    for path, item in candidate["candidate"].items():
        if "base64" in item:
            raw = base64.b64decode(item["base64"])
            assert c.sha(raw) == item["sha256"]
            assert hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest() == item["git_oid"]
        else:
            assert c.identity(path)["sha256"] == item["sha256"]
    for path, item in candidate["sealed_publication"].items():
        assert c.read(path) == item
    inputs, runs = load("inputs.json.gz"), load("runs.json.gz")
    assert runs["inputs_unchanged"]
    for path, item in inputs["accepted_sources"].items():
        raw = subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=ROOT)
        assert base64.b64decode(item["base64"]) == raw
    assert set(runs["observations"]) == {"current/descriptor", "current/native", "current/generated",
        "accepted/native", "accepted/generated"}
    expected_order = [row["id"] for row in inputs["plan"]["cases"]]
    assert len(expected_order) == len(set(expected_order)) == 16
    for name, run in runs["observations"].items():
        assert run["returncode"] == 0 and not c.decode(run["stderr_base64"])
        observed = json.loads(c.decode(run["stdout_base64"]))
        assert [row["id"] for row in observed["rows"]] == expected_order
        rows = {row["id"]: row for row in observed["rows"]}
        if name.endswith("descriptor"):
            assert all(row["completed"] and row["value"]["canonical_action_ir_fallback_count"] == 0
                and row["value"]["raw_perl_dependency_count"] == 0 for row in rows.values())
            continue
        module = observed["inc"]["LinkedSpec/CodeblockRuntime.pm"]
        if name.startswith("accepted/"):
            shadow = run["command"][3].removeprefix("-I")
            assert module == shadow + "/LinkedSpec/CodeblockRuntime.pm"
        else:
            assert module.endswith("/perl/LinkedSpec/CodeblockRuntime.pm")
        assert rows["returned_float"]["value"] == -1
        flags = rows["returned_float"]["scalar_flags"]
        assert flags["integer_flag"] == 1 and flags["float_flag"] == flags["string_flag"] == 0
        assert same(rows["assigned_float"]["value"], [None if name.startswith("accepted/") else 30, -1])
        assert rows["assigned_float"]["scalar_flags"]["items"][1]["integer_flag"] == 1
        assert rows["literal_float"]["value"] is None
        assert same(rows["parameter_float"]["value"], [None, -1])
        assert rows["parameter_float"]["scalar_flags"]["items"][1]["float_flag"] == 1
        assert same(rows["literal_false"]["value"], 0) and same(rows["literal_true"]["value"], 1)
        assert same(rows["boolean_array"]["value"], [0, 1])
        assert rows["compiled_boolean"]["value"] is False
        assert rows["compiled_boolean"]["scalar_flags"] == {"kind": "boolean"}
        assert same(rows["assigned_boolean_write"]["value"], [99, 20, 30])
        assert same(rows["assigned_positive_float_write"]["value"], [10, 99, 30])
        for case, kind in (("literal_boolean_write", "boolean"), ("literal_positive_float_write", "number")):
            row = rows[case]
            error = row["runtime_detail"] if name.endswith("native") else row["generated_cause"]
            assert error["fields"]["code"] == "nested_write_segment_invalid"
            assert error["fields"]["actual_kind"] == kind
        assert rows["null_control"]["value"] is None
    book_inputs, book_runs = load("book-inputs.json.gz"), load("book-runs.json.gz")
    assert book_runs["inputs_unchanged"]
    renderer.validate(book_runs["run"], book_inputs["inputs"])
    page = c.decode(book_runs["run"]["page_base64"]).decode()
    assert "Current callable literal-kind limitation" in page and "pre-existing producer defect" in page
    for path, item in book_inputs["inputs"].items():
        assert c.sha(c.decode(item["base64"])) == item["sha256"]
    assert len(book_inputs["inputs"]) == 93
    return dict(cases=16, current_routes=3, accepted_byte_shadow_routes=2,
        finding="Pre-existing deferred whole-float and boolean literal kind erasure, reproduced before assignment as well as in typed selectors. Compiled argument twins retain kinds.",
        producer="CodeblockRuntime::_eval_expr number (0+serialized value) and boolean (native1/0) branches",
        repair_owner="TYPE-REFERENCE-BOOK.1.2.22", canonical1="deliberately superseded143; no success credit", disclosed_book_inputs=93,
        limits="Preliminary issue ownership, not producer repair or admission. Accepted runtime byte shadows use the same current SDK/environment and preloaded owned modules; this is not a reconstruction of every historical environment input. The sealed finite118-input signed publication is unchanged.")


if __name__ == "__main__":
    print(json.dumps(check(), sort_keys=True))
