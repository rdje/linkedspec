"""Capture once: actual neutral consumers and isolated physical source faults."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import common as c

SOURCE = "tools/check_signed_array_selector_contract.py"
CONTRACT = "capability_conformance/signed_array_selector_contract.json"
INPUTS = [
    SOURCE, CONTRACT, "tools/check_write_vivification_contract.py",
    "tools/check_map_leaves_mutation_contract.py",
    "capability_conformance/write_vivification_contract.json",
    "capability_conformance/map_leaves_mutation_contract.json",
    "capability_conformance/write_map_leaves_composition_contract.json",
    "tools/project_data_env.sh", "tools/project_data_run.sh", "tools/run_python_project_data.sh",
    c.PREFIX + "capture.py", c.PREFIX + "common.py",
]
packets = {path: c.read(path) for path in INPUTS}
assert not (c.ROOT / c.PREFIX / "neutral-runs.json.gz").exists()
native = c.run(["bash", "tools/run_python_project_data.sh", SOURCE, "--json"])
assert native["returncode"] == 0 and not c.decode(native["stderr_base64"])
summary = json.loads(c.decode(native["stdout_base64"]))
compatibility = [
    c.run(["bash", "tools/run_python_project_data.sh", path])
    for path in ["tools/check_write_vivification_contract.py", "tools/check_map_leaves_mutation_contract.py"]
]
assert all(run["returncode"] == 0 and not c.decode(run["stderr_base64"]) for run in compatibility)
raw = c.decode(packets[SOURCE]["base64"])
changes = {
    "reject_all_negative": (
        b'return "array", value, None',
        b'return v1.selector(observation)',
        b"read fixture outside signed integer/quoted-key scope",
    ),
    "clamp_underflow": (
        b"return length + index if index < 0 else index",
        b"return max(0, length + index) if index < 0 else index",
        b"arithmetic: underflow",
    ),
    "pre_expression_snapshot": (
        b'work = copy.deepcopy(state["value"])',
        b'work = copy.deepcopy(case["initial_binding"]["value"])',
        b"write: selector_resize",
    ),
    "bypass_identity_guard": (
        b'if guard["active_identity"] == guard["target_identity"]:',
        b"if False:",
        b"write: guard_precedes_evaluation",
    ),
    "alias_committed_result": (
        b'return {"present": True, "value": copy.deepcopy(work)}, copy.deepcopy(work), None, effects',
        b'return {"present": True, "value": work}, work, None, effects',
        b"detachment",
    ),
}
sources = {"healthy": (raw, None)}
for name, (before, after, marker) in changes.items():
    assert raw.count(before) == 1, name
    sources[name] = (raw.replace(before, after, 1), marker)
sources["restored"] = (raw, None)
runs = {}
with tempfile.TemporaryDirectory(prefix="signed-model-controls-", dir=os.environ["TMPDIR"]) as directory:
    root = Path(directory)
    assert root.stat().st_dev == c.ROOT.stat().st_dev
    # Only these explicit files are consumed by the isolated model process.
    copied = [path for path in INPUTS if path.startswith(("tools/check_", "capability_conformance/"))]
    for path in copied:
        packet = packets[path]
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(c.decode(packet["base64"]))
        target.chmod(packet["mode"])
    for name, (source, marker) in sources.items():
        target = root / SOURCE
        target.write_bytes(source)
        command = ["python3", "-B", SOURCE, "--json"]
        result = subprocess.run(command, cwd=root, capture_output=True)
        row = dict(source_base64=c.encode(source), source_sha256=c.sha(source),
            command=command, returncode=result.returncode,
            stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
        if marker is None:
            assert result.returncode == 0 and not result.stderr, name
            assert json.loads(result.stdout) == summary
        else:
            assert result.returncode == 1 and not result.stdout, name
            assert result.stderr.rstrip().endswith(marker), (name, result.stderr[-500:])
        runs[name] = row
assert all(c.read(path) == packet for path, packet in packets.items())
c.write_new("neutral-inputs.json.gz", dict(base=c.BASE, packets=packets,
    scope="Exact model, finite authored authority, frozen inherited authorities/checkers and project wrappers. No DSL/backend/runtime source or whole-project I/O claim. Python standard library and installed interpreter are read-only prerequisites."))
c.write_new("neutral-runs.json.gz", dict(native=native, compatibility=compatibility, isolated_sources=runs,
    summary=summary, copied_inputs=copied, tool=c.run(["python3", "--version"]),
    scope="Actual model subprocesses. Five altered physical source copies fail named independent fixture targets; healthy/restored copies pass. No production source is changed and no backend support is admitted."))
print("Neutral capture PASS; five physical source controls RED and exact healthy/restored copies GREEN")
