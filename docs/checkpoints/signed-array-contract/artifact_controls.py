"""One-shot actual isolated input-validator bypass/restoration controls."""
import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile
import common as c
import publish

RUNNER = """import json,sys
from pathlib import Path
sys.path.insert(0, 'docs/checkpoints/signed-array-contract')
namespace = {'__name__':'artifact_control_subject', '__file__':sys.argv[1]}
exec(compile(Path(sys.argv[1]).read_bytes(), sys.argv[1], 'exec'), namespace)
value = json.loads(Path(sys.argv[2]).read_bytes())
try:
 if sys.argv[3] == 'identity':
  namespace['validate_inputs'](value['declared'], value['actual'])
 else:
  namespace['validate_scope'](value['actual'], controls_ready=False)
except AssertionError as error:
 print(json.dumps({'admitted':False,'reason':str(error)},sort_keys=True))
 sys.exit(1)
print(json.dumps({'admitted':True},sort_keys=True))
"""


def main():
    publisher = c.read(c.PREFIX + "publish.py")
    raw = c.decode(publisher["base64"])
    target = "capability_conformance/signed_array_selector_contract.json"
    actual = {target: c.identity(target)}
    wrong_bytes = copy.deepcopy(actual)
    wrong_bytes[target]["sha256"] = "0" * 64
    wrong_mode = copy.deepcopy(actual)
    wrong_mode[target]["mode"] ^= 0o100
    cases = {
        "identity": {
            "missing": dict(bad=dict(declared={}, actual=actual), good=dict(declared=actual, actual=actual), reason="input population"),
            "bytes": dict(bad=dict(declared=wrong_bytes, actual=actual), good=dict(declared=actual, actual=actual), reason="input bytes: " + target),
            "mode": dict(bad=dict(declared=wrong_mode, actual=actual), good=dict(declared=actual, actual=actual), reason="input mode: " + target),
        },
        "scope": {},
    }
    population = {path: c.identity(path) for path in publish.input_paths()}
    publish.validate_scope(population, controls_ready=False)
    for name, omitted in (
        ("model_producer", "tools/check_signed_array_selector_contract.py"),
        ("neutral_observations", c.PREFIX + "neutral-runs.json.gz"),
    ):
        bad = copy.deepcopy(population)
        del bad[omitted]
        cases["scope"][name] = dict(bad=dict(actual=bad), good=dict(actual=population),
            omitted=omitted, reason="required input: " + omitted)
    results = {"identity": {}, "scope": {}}
    with tempfile.TemporaryDirectory(prefix="signed-input-controls-", dir=os.environ["TMPDIR"]) as directory:
        root = Path(directory)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        runner = root / "runner.py"
        runner.write_text(RUNNER)
        subject = root / "publisher.py"
        payload = root / "inputs.json"
        for category, controls in cases.items():
            marker = b"def validate_inputs(declared, actual):\n" if category == "identity" else b"def validate_scope(actual, controls_ready=True):\n"
            assert raw.count(marker) == 1
            bypass = raw.replace(marker, marker + b"    return\n", 1)
            for name, case in controls.items():
                phases = {}
                for phase in ("healthy", "bypass", "validator_restored", "restored"):
                    source = bypass if phase == "bypass" else raw
                    subject.write_bytes(source)
                    subject.chmod(publisher["mode"])
                    value = case["good"] if phase == "restored" else case["bad"]
                    payload.write_text(json.dumps(value, sort_keys=True))
                    command = ["python3", "-B", runner.relative_to(c.ROOT).as_posix(),
                        subject.relative_to(c.ROOT).as_posix(), payload.relative_to(c.ROOT).as_posix(), category]
                    result = subprocess.run(command, cwd=c.ROOT, capture_output=True)
                    run = dict(command=command, returncode=result.returncode,
                        stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
                    assert not result.stderr
                    observed = json.loads(result.stdout)
                    if phase in ("healthy", "validator_restored"):
                        assert result.returncode == 1 and observed == dict(admitted=False, reason=case["reason"])
                    else:
                        assert result.returncode == 0 and observed == dict(admitted=True)
                    phases[phase] = dict(source_base64=c.encode(source), source_sha256=c.sha(source),
                        mode=subject.stat().st_mode & 0o7777, payload=value, run=run)
                results[category][name] = phases
    assert c.read(c.PREFIX + "publish.py") == publisher
    c.write_new("artifact-controls-inputs.json.gz", dict(publisher=publisher,
        actor=c.read(c.PREFIX + "artifact_controls.py"), runner_base64=c.encode(RUNNER.encode()), cases=cases,
        scope="Actual pure validators consume these complete retained payloads/harness and isolated source copies. Bootstrap scope excludes its own not-yet-written outputs; no real input or publisher is altered."))
    c.write_new("artifact-controls.json.gz", results)
    print("Artifact controls PASS: input3/scope2 RED, actual bypass admits, restored validator RED and restored inputs GREEN")


if __name__ == "__main__":
    main()
