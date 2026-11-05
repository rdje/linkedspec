"""One-shot direct Lua Count acquisition; existing phases are never overwritten."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
phase = sys.argv[1]
assert phase in ("before", "after", "direct")
out = HERE / phase
out.mkdir()
paths = sorted(set(
    [p for p in (ROOT / "lua/src").rglob("*") if p.is_file()] +
    [p for p in (ROOT / "lua/native").rglob("*") if p.is_file()] +
    [ROOT / name for name in (
        "lua/test/run.lua", "lua/test/count_source_fallback_test.lua",
        "lua/test/count_length_receivers_test.lua", "lua/test/copied_null_index_composition_test.lua",
        "tests/fixtures/count_boolean_source_cases.json", "tests/fixtures/copied_null_index_cases.json",
        "tools/run_lua_project_data.sh", "tools/build_lua_native.sh",
        "tools/project_data_env.sh", "tools/project_data_run.sh",
    )] + [Path(__file__).resolve()]
))
identities = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
(out / "inputs.json").write_text(json.dumps(identities, indent=2) + "\n")
with tarfile.open(out / "before-first-run.tar.gz", "x:gz") as archive:
    for path in paths:
        archive.add(path, arcname=str(path.relative_to(ROOT)), recursive=False)
for host in ("puc", "luajit"):
    target = out / host
    target.mkdir()
    emitted = target / "emitted"
    emitted.mkdir()
    commands = {"version": ["-v"], "normal": (
        ["-e", 'dofile("lua/test/count_length_receivers_test.lua"); dofile("lua/test/copied_null_index_composition_test.lua")']
        if phase == "direct" else ["lua/test/count_source_fallback_test.lua"]
    )}
    for label, args in commands.items():
        command = ["bash", "tools/run_lua_project_data.sh", host, *args]
        env = dict(os.environ, LINKEDSPEC_COUNT_SOURCE_CAPTURE=str(emitted.relative_to(ROOT)))
        result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True)
        for channel in ("stdout", "stderr"):
            with gzip.open(target / (label + "-" + channel + ".log.gz"), "xb") as stream:
                stream.write(getattr(result, channel))
        (target / (label + "-result.json")).write_text(json.dumps({"command": command, "exit": result.returncode}, indent=2) + "\n")
        print(phase, host, label, "exit", result.returncode, flush=True)
        if label == "normal":
            print(result.stdout.decode(errors="replace")[-600:], flush=True)
            print(result.stderr.decode(errors="replace")[-600:], flush=True)
    # Preserve captured pre-load bodies, then remove only these redundant files.
    with tarfile.open(target / "emitted.tar.gz", "x:gz") as archive:
        for path in sorted(emitted.iterdir()):
            archive.add(path, arcname=path.name, recursive=False)
    for path in emitted.iterdir():
        path.unlink()
    emitted.rmdir()
assert identities == {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
