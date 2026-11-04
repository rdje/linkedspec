#!/usr/bin/env python3
"""Exercise the real TASK-ACCEPTANCE gate with isolated repository-local indexes."""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
GATE = "scripts/check_diagnosis_evidence.sh"
TASK = "docs/tasks/TASK-ACCEPTANCE-CONTROL.md"
LABELS = (
    "REPRODUCE / ISSUE", "ROOT CAUSE (WHY + WHERE)", "FIX",
    "ADDRESSED (verified)", "NO REGRESSION", "LOCKSTEP",
)
CHECKLIST = ("## Acceptance Checklist\n" + "\n".join(
    f"- [x] **{label}** — controlled staged set; "
    "bash scripts/check_diagnosis_evidence.sh exit 0\n" for label in LABELS
)).encode()
# Select actual tracked files by their public parent-repository path, without
# reading dependency implementations. Every prefix is checked independently.
NEW = ("dart/lib/", "dart/test/", "julia/src/", "julia/test/",
       "lua/src/", "lua/native/", "lua/test/", "tests/")
EXISTING = ("perl/", "rust/", "specs/", "t/", "tools/", "scripts/",
            "bin/", ".githooks/", ".github/workflows/")
INPUTS = (GATE, "tools/test_diagnosis_evidence.py", "tools/project_data_env.sh",
          "tools/project_data_run.sh", "tools/run_python_project_data.sh")


def git(*args, env=None, raw=None):
    return subprocess.run(["git", "-C", str(ROOT), *args], env=env, input=raw,
                          check=True, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE).stdout


def put(env, name, raw):
    blob = git("hash-object", "-w", "--stdin", env=env, raw=raw).decode().strip()
    git("update-index", "--add", "--cacheinfo", f"100644,{blob},{name}", env=env)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--legacy", action="store_true",
                        help="capture the pre-repair omitted-path behavior")
    parser.add_argument("--record", help="write full source/input/output evidence below the repository")
    args = parser.parse_args()
    run = Path(os.environ.get("LINKEDSPEC_RUN_DIR", ""))
    if (os.environ.get("LINKEDSPEC_RUN_ACTIVE") != "1" or not run.is_absolute()
            or not run.is_dir() or run.stat().st_dev != ROOT.stat().st_dev
            or not run.resolve().is_relative_to(ROOT)):
        parser.error("run through tools/run_python_project_data.sh in managed repository storage")
    index = Path(git("rev-parse", "--git-path", "index").decode().strip())
    if not index.is_absolute():
        index = ROOT / index
    before = index.read_bytes()
    head = git("rev-parse", "HEAD").decode().strip()
    paths = git("ls-tree", "-r", "--name-only", "-z", head).decode().split("\0")[:-1]
    inventory = {prefix: [p for p in paths if p.startswith(prefix)]
                 for prefix in NEW + EXISTING}
    if not all(inventory.values()):
        raise RuntimeError("a required owned path population is empty")
    rows = []
    with tempfile.TemporaryDirectory(prefix="task-acceptance-", dir=run) as directory:
        env = dict(os.environ, GIT_INDEX_FILE=str(Path(directory) / "index"))

        def check(path, evidence, success, signature, operation="modify"):
            git("read-tree", head, env=env)
            if operation == "delete":
                git("update-index", "--force-remove", path, env=env)
            else:
                put(env, path, b"controlled staged path delta\n")
            if evidence != "missing":
                task = CHECKLIST if evidence == "complete" else CHECKLIST.replace(b"[x]", b"[ ]", 1)
                put(env, TASK, task)
            result = subprocess.run(["bash", GATE], cwd=ROOT, env=env,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            channels = (result.stdout + result.stderr).decode()
            rows.append(dict(path=path, evidence=evidence, operation=operation,
                             exit=result.returncode, stdout=result.stdout.decode(),
                             stderr=result.stderr.decode()))
            if (result.returncode == 0) != success or signature not in channels:
                raise RuntimeError(f"{path}/{evidence}/{operation}: exit {result.returncode}: {channels}")

        for prefix in NEW + EXISTING:
            path = inventory[prefix][0]
            governed = prefix in EXISTING or not args.legacy
            check(path, "missing", not governed,
                  "require an owning" if governed else "no staged governed")
            check(path, "complete", True,
                  "complete tool-evidence checklist" if governed else "no staged governed")
            check(path, "incomplete", not governed,
                  "need one staged" if governed else "no staged governed")
            check(path, "missing", not governed,
                  "require an owning" if governed else "no staged governed", "delete")
            print(f"task-acceptance-controls: checked {prefix}", flush=True)
        for path in ("README.md", "docs/acceptance-control.md"):
            check(path, "missing", True, "no staged governed")
    if index.read_bytes() != before:
        raise RuntimeError("the real index changed during isolated controls")
    report = dict(base=head, mode="legacy" if args.legacy else "repaired",
                  inventory=inventory, checklist=CHECKLIST.decode(), rows=rows,
                  index_unchanged=True, inputs={})
    for name in INPUTS:
        raw = (ROOT / name).read_bytes()
        report["inputs"][name] = dict(sha256=hashlib.sha256(raw).hexdigest(),
                                    base64=base64.b64encode(raw).decode())
    if args.record:
        target = ROOT / args.record
        if Path(args.record).is_absolute() or not target.resolve().is_relative_to(ROOT):
            parser.error("record must stay below the repository")
        target.parent.mkdir(parents=True, exist_ok=True)
        with target.open("x") as stream:
            json.dump(report, stream, indent=2)
            stream.write("\n")
    print(f"task-acceptance-controls: PASS {len(rows)} actual gate calls ({report['mode']}); real index unchanged")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"task-acceptance-controls: FAIL {error}", file=sys.stderr)
        sys.exit(1)
