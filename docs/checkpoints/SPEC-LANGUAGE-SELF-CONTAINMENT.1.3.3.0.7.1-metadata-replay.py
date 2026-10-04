"""Execute both collectors on all800 retained exact source/event unit inputs."""
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
INPUT = PREFIX + "pre-compat-census-after.json"
OWNERS = {"RawDependencies": "perl/LinkedSpec/ActionIR/RawDependencies.pm",
          "Parser": "perl/LinkedSpec/ActionIR/AST/Parser.pm",
          "RuleIR": "perl/LinkedSpec/RuleIR.pm",
          "EmitContext": "perl/LinkedSpec/RuleIR/EmitContext.pm",
          "Diagnostics": "perl/LinkedSpec/ActionIR/Diagnostics.pm"}


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def main():
    paths = {INPUT, PREFIX + "metadata-replay.pl", PREFIX + "metadata-replay.py"}
    paths.update(OWNERS.values())
    paths.update(PREFIX + "before-compat-" + name + ".pm" for name in OWNERS)
    initial = {path: digest(path) for path in sorted(paths)}
    for name, path in OWNERS.items():
        if name != "RawDependencies":
            assert (ROOT / path).read_bytes() == (ROOT / (PREFIX + "before-compat-" + name + ".pm")).read_bytes(), path
    capture = json.loads((ROOT / INPUT).read_bytes())
    requests = []
    for row in capture["rows"]:
        observation = row["observation"]
        assert row["exit"] == 0 and json.loads(row["stdout"]) == observation
        for index, unit in enumerate(observation["units"]):
            requests.append({"id": observation["id"], "unit": index,
                             "source": unit["source"],
                             "events": unit["diagnostics"]["canonical_action_ir_events"]})
    assert len(capture["rows"]) == 55 and len(requests) == 800
    rows = []
    differences = []
    for seed in ("0", "1", "2"):
        command = ["perl", "-Iperl", PREFIX + "metadata-replay.pl"]
        run = subprocess.run(command, cwd=ROOT, input=json.dumps(requests), text=True,
                             capture_output=True, env=dict(os.environ, PERL5LIB="",
                             PERL_HASH_SEED=seed, PERL_PERTURB_KEYS="2"))
        assert run.returncode == 0 and run.stderr == "", run.stderr
        result = json.loads(run.stdout)
        assert len(result) == len(requests)
        for request, observation in zip(requests, result):
            assert {key: observation[key] for key in request} == request
            if observation["before"] != observation["after"]:
                differences.append({"seed": seed, **observation})
        rows.append({"seed": seed, "command": command, "exit": run.returncode,
                     "stdout": run.stdout, "stderr": run.stderr, "observation": result})
    assert initial == {path: digest(path) for path in sorted(paths)}, "inputs changed during replay"
    print(json.dumps({"owner": OWNER, "result": "DIAGNOSTIC", "differences": differences, "sources": 55, "units": 800,
                      "seeds": ["0", "1", "2"], "perturbation": "2", "rows": rows,
                      "tracked_inputs": initial,
                      "limits": "Diagnostic unmasked full-rewrite-input comparison only. These inputs include generated prefixes absent from the actual collection source units; differences are preserved and cannot establish unchanged live metadata. Complete fresh primary/census captures provide final current proof."}, indent=2))


if __name__ == "__main__":
    main()
