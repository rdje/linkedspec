"""One-shot installed-host Lua observations with declared inputs before execution."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
phase = sys.argv[1]
assert phase in ("probe-before", "normal-before", "normal-after", "probe-after", "final")
OUT = BASE / phase
OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(["git", "ls-files", "lua", "tests/fixtures"], text=True).splitlines()]
paths += [BASE / "capture.py", BASE / "observer.lua"]
paths += [Path(p) for p in ("tools/run_lua_project_data.sh", "tools/build_lua_native.sh", "tools/project_data_env.sh", "tools/run_python_project_data.sh", "tools/project_data_run.sh")]
for name in ("lua/test/length_result_guard_composition_test.lua", "tests/fixtures/length_result_guard_lua_domain.json", "tests/fixtures/length_result_guard_lua_errors.json"):
    if Path(name).is_file(): paths.append(Path(name))
if phase.startswith("probe-"):
    cases = []
    for name in ("tests/fixtures/length_result_guard_cases.json", "tests/fixtures/length_count_source_ownership_cases.json"):
        cases.extend(json.loads(Path(name).read_text()))
    assert len({r["id"] for r in cases}) == len(cases)
    (OUT / "cases.json").write_text(json.dumps(cases, indent=2) + "\n")
    paths.append(OUT / "cases.json")
records = {}
with tarfile.open(OUT / "inputs-before-first-run.tar.gz", "x:gz") as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and ".." not in path.parts and not path.is_symlink()
        assert path.is_file() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / "input-identities.json").write_text(json.dumps(records, indent=2, sort_keys=True) + "\n")
(OUT / "activation.txt").write_bytes(subprocess.check_output(["git", "rev-parse", "HEAD"]))
for host in ("puc", "luajit"):
    target = OUT / host
    target.mkdir()
    for name in ("emitted", "parsed"): (target / name).mkdir()
    if phase.startswith("probe-"):
        args = [str(BASE / "observer.lua"), str(OUT / "cases.json"), str(target)]
    elif phase == "final":
        args = ["-e", 'dofile("lua/test/length_result_guard_composition_test.lua"); dofile("lua/test/count_length_receivers_test.lua"); dofile("lua/test/count_result_guard_composition_test.lua")']
    else:
        args = ["lua/test/length_result_guard_composition_test.lua"]
    for tag, arguments in (("version", ["-v"]), ("normal", args)):
        command = ["bash", "tools/run_lua_project_data.sh", host, *arguments]
        env = dict(os.environ, LINKEDSPEC_LENGTH_CAPTURE=str(target))
        (target / (tag + "-command.json")).write_text(json.dumps(dict(argv=command, environment=dict(LINKEDSPEC_LENGTH_CAPTURE=str(target))), indent=2) + "\n")
        with (target / (tag + "-stdout.log")).open("wb") as stdout, (target / (tag + "-stderr.log")).open("wb") as stderr:
            result = subprocess.run(command, cwd=ROOT, env=env, stdout=stdout, stderr=stderr)
        (target / (tag + "-exit.txt")).write_text(str(result.returncode) + "\n")
        print(phase, host, tag, "exit", result.returncode, flush=True)
        allowed = (0, 1) if phase == "normal-before" and tag == "normal" else (0,)
        assert result.returncode in allowed, "inspect complete retained channels"
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == r["sha256"] for p, r in records.items())
print(phase + ": declared source inputs unchanged through both host observations")
