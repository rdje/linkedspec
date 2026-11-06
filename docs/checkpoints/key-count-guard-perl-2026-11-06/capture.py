"""One-shot focused CountKeys source/result guard runs with actual declared first inputs."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile
ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
phase = sys.argv[1]
assert phase in ("before", "after", "nearest")
OUT = BASE / phase
OUT.mkdir(); (OUT / "modules").mkdir()
paths = [Path(p) for p in subprocess.check_output(["git", "ls-files", "perl", "specs", "tests/fixtures", "tools/project_data_env.sh", "tools/project_data_run.sh", "tools/run_python_project_data.sh", "t/key_count_source_domain.t", "t/key_count_block_source_composition.t", "t/length_count_source_ownership.t", "t/count_length_receiver_contract.t"], text=True).splitlines()]
paths += [Path(p) for p in ("t/key_count_result_guard_composition.t", "tests/fixtures/key_count_perl_source_owner_cases.json", "tests/fixtures/key_count_perl_source_profiles.json")]
paths.append(BASE / "capture.py")
records = {}
with tarfile.open(OUT / "inputs-before-first-run.tar.gz", "x:gz") as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and ".." not in path.parts and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / "input-identities.json").write_text(json.dumps(records, indent=2, sort_keys=True) + "\n")
(OUT / "activation.txt").write_bytes(subprocess.check_output(["git", "rev-parse", "HEAD"]))
tests = ["t/key_count_result_guard_composition.t"]
if phase == "nearest": tests += ["t/key_count_source_domain.t", "t/key_count_block_source_composition.t", "t/length_count_source_ownership.t", "t/count_length_receiver_contract.t"]
commands = {"normal": ["prove", "-v", "-Iperl", *tests]}
if phase == "after": commands["owner-syntax"] = ["perl", "-Iperl", "-c", "perl/LinkedSpec/ActionIR/MethodLowering.pm"]
for tag, arguments in commands.items():
    command = ["bash", "tools/project_data_run.sh", "env", "PERL5LIB=", "LINKEDSPEC_KEY_COUNT_GUARD_DIR=" + str(OUT / "modules"), *arguments]
    (OUT / (tag + "-command.json")).write_text(json.dumps(command, indent=2) + "\n")
    with (OUT / (tag + "-stdout.log")).open("wb") as stdout, (OUT / (tag + "-stderr.log")).open("wb") as stderr:
        result = subprocess.run(command, cwd=ROOT, stdout=stdout, stderr=stderr)
    (OUT / (tag + "-exit.txt")).write_text(str(result.returncode) + "\n")
    assert result.returncode in ((0,1) if phase == "before" and tag == "normal" else (0,)), "inspect retained complete channels"
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == r["sha256"] for p, r in records.items())
print(phase + ": complete focused commands retained with declared actual first inputs; inspect observations before grading")
