"""Historical one-shot Julia Count acquisition; never overwrite retained phases."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
phase = sys.argv[1]
assert phase in ("before", "after", "direct")
out = HERE / phase
out.mkdir()  # Exclusive creation protects historical evidence.
emitted = out / "emitted"
emitted.mkdir()
paths = sorted(set(
    list((ROOT / "julia/src").rglob("*.jl")) +
    list((ROOT / "julia/test").glob("*count*jl")) +
    [ROOT / name for name in (
        "julia/test/copied_null_index_composition_test.jl", "julia/test/runtests.jl",
        "julia/Project.toml", "julia/Manifest.toml",
        "tests/fixtures/count_boolean_source_cases.json",
        "tests/fixtures/copied_null_index_cases.json",
        "tools/run_julia_project_data.sh", "tools/project_data_env.sh",
        "tools/project_data_run.sh",
    )] + [Path(__file__).resolve()]
))
identities = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
(out / "inputs.json").write_text(json.dumps(identities, indent=2) + "\n")
with tarfile.open(out / "before-first-run.tar.gz", "x:gz") as archive:
    for path in paths:
        archive.add(path, arcname=str(path.relative_to(ROOT)), recursive=False)
env = dict(os.environ, JULIA_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1",
           LINKEDSPEC_COUNT_SOURCE_CAPTURE=str(emitted.relative_to(ROOT)))
if phase == "direct":
    args = ["-e", "using LinkedSpecJulia,JSON3,Test;include(ARGS[1]);include(ARGS[2])",
            "julia/test/count_length_receivers_test.jl", "julia/test/copied_null_index_composition_test.jl"]
else:
    args = ["julia/test/count_source_fallback_test.jl"]
command = ["bash", "tools/run_julia_project_data.sh", "--project=julia", "--depwarn=error", *args]
pressure = subprocess.run(["memory_pressure"], capture_output=True, check=True).stdout
with gzip.open(out / "memory-before.log.gz", "wb") as channel:
    channel.write(pressure)
free = int(pressure.split(b"System-wide memory free percentage: ")[1].split(b"%")[0])
assert free > 20, "Julia job needs host headroom"
process = subprocess.Popen(command, cwd=ROOT, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = process.communicate()
for name, data in (("stdout.log.gz", stdout), ("stderr.log.gz", stderr)):
    with gzip.open(out / name, "wb") as channel:
        channel.write(data)
assert identities == {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
(out / "result.json").write_text(json.dumps({"command": command, "exit": process.returncode}, indent=2) + "\n")
print(phase, "exit", process.returncode)
print(stdout.decode(errors="replace")[-3500:])
print(stderr.decode(errors="replace")[-1000:])
