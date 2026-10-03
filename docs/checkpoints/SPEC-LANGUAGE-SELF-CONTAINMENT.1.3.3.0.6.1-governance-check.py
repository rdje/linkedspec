"""Replay the exact Phase0 evolution and isolated historical audit on stdout."""
import base64
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
AUDITOR = "tests/language-readiness/verify_objectives.py"
PHASE0 = "t/phase0_regression.t"
PROOF = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py"
FAILURE_LOG = ".linkedspec-data/scratch/residual-event-order-repair/canonical.log"
FAILURE_REASON = "unreviewed signature-regression drift: t/phase0_regression.t"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def decode_failure(record):
    require(record["command"] == ["bash", "tools/run_ci_local.sh"] and record["exit"] == 1,
            "historical failure command/exit")
    envelope = record["log_envelope"]
    require(set(envelope) == {"original_path", "bytes", "sha256", "base64"} and
            envelope["original_path"] == FAILURE_LOG, "historical failure envelope fields")
    try:
        raw = base64.b64decode(envelope["base64"], validate=True)
    except ValueError as error:
        raise ValueError("historical failure base64") from error
    require(len(raw) == envelope["bytes"] and
            hashlib.sha256(raw).hexdigest() == envelope["sha256"],
            "historical failure byte identity")
    require(raw.endswith(("ValueError: " + FAILURE_REASON + "\n").encode()) and
            record["result"] == FAILURE_REASON, "historical failure boundary")
    return raw


def capture_failure():
    raw = (ROOT / FAILURE_LOG).read_bytes()
    record = {"command": ["bash", "tools/run_ci_local.sh"],
              "activation": "5bbceb962cc5aa5fb071b86efa479178e0e25d32", "exit": 1,
              "stage": "isolated historical artifact recovery and read-denied audit",
              "stderr_in_combined_log": True, "result": FAILURE_REASON,
              "log_envelope": {"original_path": FAILURE_LOG, "bytes": len(raw),
                               "sha256": hashlib.sha256(raw).hexdigest(),
                               "base64": base64.b64encode(raw).decode("ascii")}}
    require(decode_failure(record) == raw, "historical failure round trip")
    print(json.dumps(record, indent=2))


def main():
    failure = json.loads((ROOT / (PREFIX + "canonical-before.json")).read_bytes())
    raw_failure = decode_failure(failure)
    failure_controls = []
    for field, value in (("base64", "!"), ("sha256", "0" * 64),
                         ("bytes", len(raw_failure) + 1)):
        altered = copy.deepcopy(failure)
        altered["log_envelope"][field] = value
        try:
            decode_failure(altered)
        except ValueError as error:
            require(str(error) in ("historical failure base64", "historical failure byte identity"),
                    "unrelated failure envelope rejection")
            failure_controls.append(field)
        else:
            raise ValueError("historical failure envelope corruption accepted: " + field)
    prior = load("occurrence_audit_before", PREFIX + "governance-before.py")
    current = load("occurrence_audit_current", AUDITOR)
    before_bytes = (ROOT / (PREFIX + "governance-before.py")).read_bytes()
    require(before_bytes == subprocess.check_output(
        ["git", "show", "5bbceb962cc5aa5fb071b86efa479178e0e25d32:" + AUDITOR], cwd=ROOT),
        "historical audit snapshot differs from activation")
    contents = (ROOT / PHASE0).read_bytes()
    historical = prior.git("show", prior.SIGNATURE_BEFORE + ":" + PHASE0)
    historical_hash = prior.digest(historical)
    try:
        prior.verify_signature_regression_evolution(PHASE0, contents, historical_hash)
    except ValueError as error:
        require(str(error) == "unreviewed signature-regression drift: " + PHASE0,
                "unrelated baseline audit rejection")
        red = str(error)
    else:
        raise ValueError("unchanged audit unexpectedly accepts the new recurrence")
    green = current.verify_signature_regression_evolution(PHASE0, contents, historical_hash)
    normalized = contents.replace(current.OCCURRENCE_INSERTION + current.OCCURRENCE_ANCHOR,
                                  current.OCCURRENCE_ANCHOR, 1)
    require(normalized == current.git("show", current.SIGNATURE_AFTER + ":" + PHASE0),
            "new recurrence removal does not recover committed prior bytes")
    run = subprocess.run(["bash", "tools/run_python_project_data.sh", PROOF],
                         cwd=ROOT, text=True, capture_output=True)
    require(run.returncode == 0, "isolated historical replay failed: " + run.stderr)
    proof = json.loads(run.stdout)
    require(proof["healthy_audit_guard"] ==
            {"original_log_attempts": 0, "tracked_write_attempts": 0},
            "historical audit escaped isolated recovery")
    require(proof["isolated_deterministic_capture"], "archive replay differs")
    require(proof["audit_controls"]["governance_mutations_by_source"][PHASE0] == 6,
            "expected six actual Phase0 evolution corruptions")
    paths = set(proof["tracked_inputs"])
    paths.update((AUDITOR, PHASE0, PREFIX + "governance-before.py",
                  PREFIX + "governance-check.py", PREFIX + "canonical-before.json"))
    inputs = {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
              for path in sorted(paths)}
    print(json.dumps({"owner": OWNER, "result": "PASS", "red": red,
                      "failure_log_sha256": hashlib.sha256(raw_failure).hexdigest(),
                      "failure_log_bytes": len(raw_failure),
                      "failure_envelope_controls": failure_controls,
                      "green": green, "prior_phase0_bytes_recovered": True,
                      "command": run.args, "exit": run.returncode,
                      "stdout": run.stdout, "stderr": run.stderr,
                      "controls": proof["audit_controls"],
                      "isolated_controls": proof["controls"],
                      "restored_inputs": proof["restored_inputs"],
                      "restored_bytes": proof["restored_bytes"],
                      "tracked_inputs": inputs,
                      "limits": "Exact recurrence insertion and historical evidence integrity; no fresh objective execution or additional Phase0 drift permission."}, indent=2))


if __name__ == "__main__":
    if sys.argv[1:] == ["--capture-failure"]:
        capture_failure()
    elif not sys.argv[1:]:
        main()
    else:
        raise ValueError("expected --capture-failure or no arguments")
