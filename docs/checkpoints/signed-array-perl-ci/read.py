"""Read-only replay of the retained exact CI-registration verifier epochs."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "docs/checkpoints/signed-array-perl"))
import common as c
import book as book_validator

AUDITOR = "tests/language-readiness/verify_objectives.py"


def load(name):
    return json.loads(gzip.decompress((HERE / name).read_bytes()))


def packet(item):
    raw = c.decode(item["base64"])
    assert c.sha(raw) == item["sha256"]
    return raw


def verifier(raw):
    namespace = {"__file__": str(ROOT / AUDITOR), "__name__": "signed_ci_retained_audit"}
    exec(compile(raw, str(ROOT / AUDITOR), "exec"), namespace)
    return namespace["verify_governance_evolution"]


def replay(source, plan):
    verify = verifier(source)
    rows = []
    for case in plan["cases"]:
        try:
            result = verify("tools/run_ci_local.sh", c.decode(case["ci_base64"]), plan["historical_hash"])
        except ValueError as error:
            rows.append(dict(id=case["id"], accepted=False, error=str(error)))
        else:
            rows.append(dict(id=case["id"], accepted=True, result=result))
    return rows


def recover(epoch, path):
    item = epoch["inputs"][path]
    if path in epoch["overrides"]:
        raw = packet(epoch["overrides"][path])
    elif path.endswith((".gz", ".part")):
        raw = c.source(path).read_bytes()
        assert c.identity(path) == item
    else:
        raw = subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=ROOT)
    assert c.sha(raw) == item["sha256"]
    return raw


def containment():
    before, original, runs = load("contain-before.json.gz"), load("contain-original-output.json.gz"), load("contain-runs.json.gz")
    assert before["actual_ci_exit"] == 143 and len(before["candidate"]["files"]) == 161
    assert before["candidate"]["fingerprint"] == "d2056c827e241b58cfecba06a2f39db7b2b0f9bae8b8aaabf5861a57ef870cb4"
    assert packet(before["registry"]) == subprocess.check_output(["git", "show", c.BASE + ":doctrine/readme_stability/routes.jsonl"], cwd=ROOT)
    page = "docs/linkedspec-book/src/development/local-ci-and-regression.md"
    raw = packet(before["inputs"][page])
    lines = raw.splitlines(keepends=True)
    removed = set(before["removed_zero_based_lines"])
    assert len(removed) == 12 and all(lines[index] == b"\n" and lines[index + 1].startswith(b"#") for index in removed)
    changed = packet(before["changed_page"])
    assert changed == b"".join(line for index, line in enumerate(lines) if index not in removed)
    assert len(raw.splitlines()) == 2057 and len(changed.splitlines()) == 2045
    assert runs["inputs_unchanged"] and runs["full_bytes_and_modes_identical"] and runs["heading_control_rejected"]
    assert original["returncode"] == runs["after"]["returncode"] == runs["fault"]["returncode"] == 0
    original_manifest = {}
    for path, item in original["files"].items():
        assert len(packet(item)) == item["bytes"]
        original_manifest[path] = {key: item[key] for key in ("sha256", "bytes", "mode")}
    assert original_manifest == runs["after_manifest"]
    assert len(original_manifest) == runs["counts"]["output_files"] == 90
    assert sum(item["bytes"] for item in original_manifest.values()) == runs["counts"]["output_bytes"]
    assert runs["counts"]["page_after"] == 2045 and runs["counts"]["public_after"] == 49994
    assert runs["fault_manifest"] != original_manifest
    ci_html = "development/local-ci-and-regression.html"
    assert c.sha(packet(runs["fault_ci_html"])) == runs["fault_manifest"][ci_html]["sha256"]
    assert runs["fault_manifest"][ci_html] != original_manifest[ci_html]
    return dict(removed_empty_lines=12, chapter_lines=2045, public_reference_lines=49994,
        rendered_files=90, rendered_bytes=runs["counts"]["output_bytes"], all_bytes_modes_identical=True,
        changed_heading_rejected=True, original_candidate_files=161, canonical3="superseded143 after actual budget rejection")


def check():
    before, inputs, after = load("before.json.gz"), load("after-inputs.json.gz"), load("after-runs.json.gz")
    assert before["actual_ci_exit"] == 1 and len(before["candidate"]["files"]) == 143
    assert before["candidate"]["fingerprint"] == "179d413b1d6c2fa2c24aa7059821630cb5124cb24f851a878b19ad8985711bfa"
    for path, item in before["candidate"]["files"].items():
        if "base64" in item:
            raw = packet(item)
            assert hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest() == item["git_oid"]
        else:
            assert c.identity(path)["sha256"] == item["sha256"]
    milestone = json.loads(packet(before["milestone"]))
    assert packet(before["auditor"]) == subprocess.check_output(["git", "show", c.BASE + ":" + AUDITOR], cwd=ROOT)
    assert packet(before["milestone"]) == subprocess.check_output(["git", "show", c.BASE + ":docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5-verification.json"], cwd=ROOT)
    assert c.decode(before["accepted_ci_base64"]) == subprocess.check_output(["git", "show", c.BASE + ":tools/run_ci_local.sh"], cwd=ROOT)
    gold = milestone["audit"]["current_source_hashes"]["tools/run_ci_local.sh"]
    assert gold == before["historical_hash"] == inputs["plan"]["historical_hash"]
    old_verify = verifier(packet(before["auditor"]))
    assert old_verify("tools/run_ci_local.sh", c.decode(before["accepted_ci_base64"]), gold) == before["accepted_baseline"]
    try:
        old_verify("tools/run_ci_local.sh", packet(before["ci"]), gold)
    except ValueError as error:
        assert str(error) == before["actual_rejection"] == "governance registration mismatch: tools/run_ci_local.sh"
    else:
        raise AssertionError("original mismatch no longer reproduced")
    assert after["inputs_unchanged"]
    assert set(after["runs"]) == {"healthy", "inverse", "bypass", "restored", "historical"}
    plan = inputs["plan"]
    assert len(plan["cases"]) == 14 and sum(case["expected_accepted"] for case in plan["cases"]) == 1
    source = packet(inputs["auditor"])
    assert source == recover(inputs["context"], AUDITOR)
    assert packet(inputs["ci"]) == recover(inputs["context"], "tools/run_ci_local.sh")
    assert packet(inputs["observer"]) == recover(inputs["context"], "docs/checkpoints/signed-array-perl-ci/observe.py")
    for name in ("healthy", "inverse", "bypass", "restored"):
        actual_source = source if name in ("healthy", "restored") else c.decode(inputs["physical_sources"][name])
        run = after["runs"][name]
        assert run["returncode"] == 0 and not c.decode(run["stderr_base64"])
        observed = json.loads(c.decode(run["stdout_base64"]))
        assert observed["auditor_sha256"] == c.sha(actual_source)
        assert replay(actual_source, plan) == observed["rows"]
        if name in ("healthy", "restored"):
            assert all(row["accepted"] == case["expected_accepted"] for row, case in zip(observed["rows"], plan["cases"]))
        elif name == "inverse":
            assert not observed["rows"][0]["accepted"]
        else:
            assert all(row["accepted"] for row in observed["rows"])
    historical = after["runs"]["historical"]
    assert historical["returncode"] == 0 and not c.decode(historical["stderr_base64"])
    record = json.loads(c.decode(historical["stdout_base64"]))
    assert (record["restored_inputs"], record["restored_bytes"], len(record["controls"])) == (134, 84613241, 22)
    assert record["audit_controls"]["governance_mutations_rejected"] == 690
    assert record["healthy_audit_guard"] == {"original_log_attempts": 0, "tracked_write_attempts": 0}
    for path, expected in record["tracked_inputs"].items():
        assert c.sha(recover(inputs["context"], path)) == expected, path
    book_inputs, book_runs = load("book-inputs.json.gz"), load("book-runs.json.gz")
    assert book_runs["inputs_unchanged"] and len(book_inputs["inputs"]) == 93
    for item in book_inputs["inputs"].values():
        packet(item)
    book_validator.validate(book_runs["healthy"], book_inputs["inputs"])
    page = c.decode(book_runs["healthy"]["ci_page_base64"]).decode()
    assert "Perl signed-array selector regression" in page
    assert "prove -Iperl t/signed_array_selector_perl_contract.t" in page
    assert book_runs["fault"]["returncode"] == 0
    assert "Perl signed-array selector regression" not in c.decode(book_runs["fault"]["ci_page_base64"]).decode()
    return dict(original_ci_exit=1, preserved_candidate_files=143, exact_historical_ci_hash=gold,
        ci_inputs=14, registration_denials=13, actual_verifier_faults=2, restored=True,
        recovery_inputs=134, recovered_bytes=84613241, recovery_controls=22, evolution_denials=690,
        current_book_inputs=93, book_ci_heading_denial=True, containment=containment(),
        limits="Bounded exact CI registration only; original archive/milestones/runtime observations and sealed118-input signed proof remain unchanged. Two physical verifier copies exercise supplied-byte scope; SDK/OS are read-only prerequisites. Canonical receipt and normal hooks remain required; literal-kind22 and portable admission stay separate.")


if __name__ == "__main__":
    print(json.dumps(check(), sort_keys=True))
