"""Review exact raw-readiness CI registration; optionally replay isolated history."""
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
BASE = "c9673d7eff39836fdc94d59b8d47639db5e937d4"
AUDITOR = "tests/language-readiness/verify_objectives.py"
CI = "tools/run_ci_local.sh"
PROOF = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def strip(contents, insertions):
    for anchor, insertion in insertions:
        require(contents.count(anchor + insertion) == 1, "exact registration anchor")
        contents = contents.replace(anchor + insertion, anchor, 1)
    return contents


def main(replay):
    prior = load("raw_readiness_audit_before", PREFIX + "governance-before.py")
    current = load("raw_readiness_audit_current", AUDITOR)
    require((ROOT / (PREFIX + "governance-before.py")).read_bytes() ==
            prior.git("show", BASE + ":" + AUDITOR), "before auditor byte identity")
    before = prior.git("show", BASE + ":" + CI)
    original = strip(before, prior.ARTIFACT_CI_INSERTIONS +
                     prior.NORMALIZATION_CI_INSERTIONS + prior.PUSH_CI_INSERTIONS +
                     prior.COMPOSED_CI_INSERTIONS + prior.CI_INSERTIONS)
    historical_hash = hashlib.sha256(original).hexdigest()
    prior.verify_governance_evolution(CI, before, historical_hash)
    contents = (ROOT / CI).read_bytes()
    require(strip(contents, current.RAW_READINESS_CI_INSERTIONS) == before,
            "new registration removal must recover exact activation CI")
    try:
        prior.verify_governance_evolution(CI, contents, historical_hash)
    except ValueError as error:
        require(str(error) == "governance registration mismatch: " + CI,
                "unrelated before-auditor rejection")
        red = str(error)
    else:
        raise ValueError("before auditor accepted unreviewed raw-readiness registration")
    green = current.verify_governance_evolution(CI, contents, historical_hash)
    blocks = current.RAW_READINESS_CI_INSERTIONS
    mutants = [("missing_" + name, contents.replace(blocks[index][1], b"", 1))
               for index, name in enumerate(("tracked", "syntax", "runtime"))]
    mutants += [
        ("duplicate_runtime", contents.replace(blocks[2][1], blocks[2][1] * 2, 1)),
        ("disabled_runtime", contents.replace(blocks[2][1],
         blocks[2][1].replace(b"PERL5LIB= prove", b"PERL5LIB= true"), 1)),
        ("wrong_tracked_test", contents.replace(blocks[0][1],
         blocks[0][1].replace(b"metadata.t", b"missing.t"), 1)),
    ]
    mutants += [("missing_span_" + name, contents.replace(line, b" t/actionir_raw_dependency_compatibility.t\n" if index == 2 else b"", 1))
                for index, (name, line) in enumerate((("tracked", b"require_tracked_file t/actionir_nested_block_source_spans.t\n"),
                    ("syntax", b"perl -c -Iperl t/actionir_nested_block_source_spans.t\n"),
                    ("runtime", b" t/actionir_nested_block_source_spans.t t/actionir_raw_dependency_compatibility.t\n")))]
    mutants += [("missing_compatibility_" + name, contents.replace(line, b"\n" if index == 2 else b"", 1))
                for index, (name, line) in enumerate((("tracked", b"require_tracked_file t/actionir_raw_dependency_compatibility.t\n"),
                    ("syntax", b"perl -c -Iperl t/actionir_raw_dependency_compatibility.t\n"),
                    ("runtime", b" t/actionir_raw_dependency_compatibility.t\n")))]
    controls = []
    for name, altered in mutants:
        require(altered != contents, "mutation did not change actual CI: " + name)
        try:
            current.verify_governance_evolution(CI, altered, historical_hash)
        except ValueError as error:
            expected = ("unreviewed governance drift: " if name == "duplicate_runtime"
                        else "governance registration mismatch: ") + CI
            require(str(error) == expected,
                    "unrelated CI corruption rejection")
            controls.append({"name": name, "reason": str(error)})
        else:
            raise ValueError("CI corruption accepted: " + name)
    result = {"owner": OWNER, "result": "PASS", "red": red, "green": green,
              "activation_ci_bytes_recovered": True, "new_controls": controls,
              "isolated_history_replayed": replay}
    paths = {AUDITOR, CI, PREFIX + "governance-before.py", PREFIX + "governance-check.py", PREFIX + "compatibility-oracles.json"}
    if replay:
        run = subprocess.run(["bash", "tools/run_python_project_data.sh", PROOF],
                             cwd=ROOT, text=True, capture_output=True)
        require(run.returncode == 0, "isolated historical replay failed: " + run.stderr)
        proof = json.loads(run.stdout)
        require(proof["healthy_audit_guard"] ==
                {"original_log_attempts": 0, "tracked_write_attempts": 0},
                "historical audit escaped isolated recovery")
        require(proof["isolated_deterministic_capture"], "archive replay differs")
        require(proof["audit_controls"]["governance_mutations_by_source"] ==
                {CI: 27, "tools/test_perl_project_data_storage.sh": 6,
                 "t/phase0_regression.t": 11}, "actual historical governance control population")
        require(proof["restored_inputs"] == 134 and proof["restored_bytes"] == 84613241,
                "historical archive recovery population")
        result.update({"command": run.args, "exit": run.returncode, "stdout": run.stdout,
                       "stderr": run.stderr, "controls": proof["audit_controls"],
                       "isolated_controls": proof["controls"],
                       "restored_inputs": proof["restored_inputs"],
                       "restored_bytes": proof["restored_bytes"]})
        paths.update(proof["tracked_inputs"])
    result["tracked_inputs"] = {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
                               for path in sorted(paths)}
    result["limits"] = "Exact CI additions and fourteen measured Phase0 metadata assertion replacements; original executable audit inputs remain byte-bound."
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    require(sys.argv[1:] in ([], ["--registration-only"]), "unexpected arguments")
    main(not sys.argv[1:])
