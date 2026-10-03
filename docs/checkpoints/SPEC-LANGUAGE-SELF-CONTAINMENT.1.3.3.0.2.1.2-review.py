"""Read-only bridge reconciliation; stdout is the complete retained observation.

Historical producer bodies are validated, never executed. Current proofs use the
public Perl APIs and unchanged tracked tests. Only managed scratch logs are written.
"""
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3."
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2"
SUITES = (
    "t/codeblock_push_composition_perl.t",
    "t/callable_codeblock_literal_contract.t",
    "t/variadic_user_function_contract.t",
    "t/uniform_binding_contract.t",
    "t/map_leaves_mutation_perl_contract.t",
    "t/actionir_ast_parser.t",
    "t/trace_actionir_method_lowering.t",
    "t/composed_normalization_perl.t",
)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return (ROOT / path).read_bytes()


def git_blob(revision, path):
    return subprocess.check_output(["git", "show", revision + ":" + path], cwd=ROOT)


def main():
    bridge = json.loads(read(PREFIX + "0.2.1.1-verification.json"))
    recovery = json.loads(read(PREFIX + "0.2.1.4.0-recovery.json"))
    normalization = json.loads(read(PREFIX + "0.4.1-verification.json"))
    preserved = {}
    # Compare immutable original captures with the recovery's independently retained identities.
    for row in recovery["original_checkpoints"]:
        require(digest(read(row["path"])) == row["sha256"], "original checkpoint changed")
        preserved[row["path"]] = row["sha256"]
    recovered = {}
    for row in recovery["recoverable_inputs"]:
        data = "".join(row["source_lines"]).encode() if row["storage"] == "source_lines" else \
            git_blob(row["commit"], row["git_path"])
        require(digest(data) == row["sha256"], "historical producer recovery changed")
        recovered[row["path"]] = row["sha256"]
    for row in bridge["producer_sources"]:
        require(digest("".join(row["source_lines"]).encode()) == row["sha256"],
                "bridge producer recovery changed")
        recovered[row["path"]] = row["sha256"]
    # These production/test/authority bytes are the bridge capture's exact boundary.
    # Book, selection provenance, the composed source correction and CI evolved
    # in owned prerequisite leaves. The exact authorized loop is checked below;
    # neutral governance independently verifies its unchanged sixteen oracles.
    for path, expected in bridge["source_inputs_sha256"].items():
        if path.startswith(("perl/", "t/", "capability_conformance/", "tests/")) and \
                path != "capability_conformance/composed_objective_contract.json":
            require(digest(read(path)) == expected, "bridge source changed: " + path)
            preserved[path] = expected
    old = read("tests/language-readiness/composed/normalization.spec")
    successor = read("tests/language-readiness/composed/normalization-calls.spec")
    old_loop = b'while(i < count(pieces)) { visited = visited + 1; i = i + 1 }'
    new_loop = b'while(num_lt(i,count(pieces))) { visited = num_add(visited,1); i = num_add(i,1) }'
    require(old.count(old_loop) == 1 and old.replace(old_loop, new_loop) == successor,
            "normalization correction exceeds authorized loop")

    scratch = ROOT / ".linkedspec-data/scratch/bridge-reconciliation"
    scratch.mkdir(parents=True, exist_ok=True)
    require(scratch.resolve().is_relative_to(ROOT / ".linkedspec-data/scratch") and
            scratch.stat().st_dev == ROOT.stat().st_dev, "scratch escapes repository volume")
    env = dict(os.environ, PERL5LIB="")
    logs = []

    def run(name, command):
        process = subprocess.run(command, cwd=ROOT, env=env, capture_output=True)
        output = process.stdout + process.stderr
        path = scratch / name
        path.write_bytes(output)
        require(process.returncode == 0, "proof failed: " + name)
        logs.append({"path": path.relative_to(ROOT).as_posix(), "sha256": digest(output),
                     "command": command, "stdout": process.stdout.decode(),
                     "stderr": process.stderr.decode(), "exit": process.returncode})
        return process.stdout.decode()

    controls = json.loads(run("controls.json", ["perl", "-Iperl", PREFIX + "0.2.1.2-probe.pl"]))
    expected_values = [["x"], ["x"], "!x", "!x", ["!x", "before:x"], "AB", "!AB"]

    def check_controls(rows):
        require(len(rows) == len(expected_values), "control population changed")
        for row, historical, expected in zip(rows, bridge["original_controls"], expected_values):
            require(row["id"] == historical["id"] and
                    row["source_sha256"] == historical["source_sha256"], "control source changed")
            require(row["metadata"] == historical["metadata"], "control metadata changed")
            require(row["dumped_bytes"] > 0 and row["emitted_sha256"] == historical["emitted_sha256"],
                    "control generated bytes changed")
            for route in ("native", "fresh"):
                observed = row[route]
                require(observed["value"] == expected and observed["error"] is None and
                        observed["output"] == "" and observed["stderr"] == "", "control oracle mismatch")
            require(row["fresh"]["emitted_sha256"] == row["emitted_sha256"], "fresh source changed")

    check_controls(controls)
    tests = []
    normalization_observation = None
    for path in SUITES:
        output = run(Path(path).name + ".log", ["prove", "-v", "-Iperl", path])
        match = re.search(r"Files=1, Tests=(\d+),", output)
        require(match is not None and "Result: PASS" in output, "incomplete TAP proof")
        tests.append({"path": path, "tests": int(match.group(1))})
        if path == "t/composed_normalization_perl.t":
            lines = [line for line in output.splitlines() if line.startswith("# NORMALIZATION_OBSERVATIONS ")]
            require(len(lines) == 1, "normalization observation absent")
            normalization_observation = json.loads(lines[0].split(" ", 2)[2])

    def check_normalization(observation):
        require(observation == normalization["observations"], "normalization historical oracle mismatch")

    check_normalization(normalization_observation)
    falsifiers = []

    def rejected(name, checker, value):
        try:
            checker(value)
        except ValueError as error:
            falsifiers.append({"name": name, "reason": str(error)})
        else:
            raise ValueError("corruption accepted: " + name)

    for index, row in enumerate(controls):
        bad = copy.deepcopy(controls)
        bad[index]["fresh"]["value"] = "wrong-control-result"
        rejected(row["id"] + "-actual-result", check_controls, bad)
    bad = copy.deepcopy(controls)
    bad[0]["source_sha256"] = "0" * 64
    rejected("control-source-identity", check_controls, bad)
    for name in ("value", "event-order", "quiet", "typed-rejection"):
        bad = copy.deepcopy(normalization_observation)
        if name == "value":
            bad["fresh"][0]["value"]["visits"] = 99
        elif name == "event-order":
            bad["fresh"][0]["events"].reverse()
        elif name == "quiet":
            bad["native"][3]["events"] = bad["native"][0]["events"]
        else:
            bad["fresh"][4]["exit_status"] = None
        rejected("normalization-" + name, check_normalization, bad)

    paths = set(subprocess.check_output(["git", "ls-files", "perl"], cwd=ROOT).decode().splitlines())
    paths.update(SUITES)
    paths.update(preserved)
    paths.update((PREFIX + name for name in (
        "0.2.1.1-verification.json", "0.2.1.4.0-recovery.json", "0.4.1-verification.json",
        "0.2.1.2-probe.pl", "0.2.1.2-fresh.pl", "0.2.1.2-review.py", "0.4.1-fresh.pl")))
    paths.update(("tests/language-readiness/composed/normalization-calls.spec",
                  "capability_conformance/composed_objective_contract.json",
                  "docs/language-readiness/composed-objective-selection.md",
                  "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1-selection.json",
                  "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2-verification.json",
                  "tools/project_data_run.sh", "tools/run_python_project_data.sh",
                  "tools/project_data_env.sh"))
    print(json.dumps({"version": 1, "owner": OWNER, "original_controls": controls,
        "normalization": normalization_observation, "tests": tests,
        "preserved_bridge_inputs": preserved, "recovered_producers": recovered,
        "falsifiers": falsifiers, "logs": logs,
        "tracked_inputs": {path: digest(read(path)) for path in sorted(paths)},
        "limits": "Current selected native/fresh bridge and normalization proof only. Historical captures/producers are preserved, not replayed. The original infix failure is not admitted. Dispatcher, complete16 runtime/mutants, other backends, control/order/readiness and startup19/32/35/87 remain separately owned."},
        indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
