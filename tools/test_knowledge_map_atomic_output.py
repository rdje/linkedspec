"""Exercise public Knowledge generation with deterministic rendering barriers."""
import argparse
import base64
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--generator", type=Path,
                        default=Path("knowledge-map/scripts/gen_knowledge_map.sh"))
    parser.add_argument("--evidence", type=Path)
    args = parser.parse_args()
    for path in (args.generator, args.evidence):
        if path is not None and (path.is_absolute() or ".." in path.parts):
            parser.error("paths must be repository-relative")
    if args.evidence and (not args.evidence.parts or args.evidence.parts[0] != ".linkedspec-data"):
        parser.error("evidence must be beneath .linkedspec-data")
    real_awk = shutil.which("awk")
    assert real_awk
    results = []
    retained = []
    with tempfile.TemporaryDirectory(prefix="knowledge-atomic-", dir=os.environ["LINKEDSPEC_RUN_DIR"]) as name:
        scratch = Path(name)
        facts = scratch / "facts"
        facts.mkdir()
        fact = facts / "sample.md"
        fact.write_text('''---
id: atomic-sample
title: Atomic sample
answers:
  - first atomic question
  - second atomic question
date: 2026-11-01
status: current
evidence: sample-source.md
reverify:
  - printf first
  - printf second
---

Canonical body.
''')
        shim_dir = scratch / "bin"
        shim_dir.mkdir()
        shim = shim_dir / "awk"
        shim.write_text('''#!/usr/bin/env python3
import os, sys, time
from pathlib import Path
mode = os.environ.get('KM_ATOMIC_TEST_MODE', '')
if mode and any('### %s' in item for item in sys.argv[1:]):
    Path(os.environ['KM_ATOMIC_TEST_BARRIER']).touch()
    while not Path(os.environ['KM_ATOMIC_TEST_RELEASE']).exists():
        time.sleep(0.01)
    if mode == 'render_fail':
        sys.exit(17)
os.execv(os.environ['KM_ATOMIC_TEST_REAL_AWK'], ['awk', *sys.argv[1:]])
''')
        shim.chmod(0o755)
        env = dict(os.environ, KM_SCAN_DIRS=str(facts.relative_to(ROOT)),
                   KM_TITLE="Atomic fixture", KM_ATOMIC_TEST_REAL_AWK=real_awk,
                   PATH=str(shim_dir) + os.pathsep + os.environ["PATH"])
        old = b"ORIGINAL COMPLETE MAP\n"

        def invoke(output, child_env):
            return subprocess.run(["bash", str(args.generator)], cwd=ROOT,
                                  env=dict(child_env, KM_OUTPUT=str(output.relative_to(ROOT))),
                                  stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)

        golden = scratch / "golden.md"
        generated = invoke(golden, env)
        assert generated.returncode == 0, generated.stderr
        expected = golden.read_bytes()
        assert b'first atomic question' in expected and b'second atomic question' in expected

        def leftovers(output):
            return [p.name for p in output.parent.glob(output.name + ".*")]

        def observe(name, mode, fresh=False):
            directory = scratch / name
            directory.mkdir()
            output = directory / "map.md"
            if not fresh:
                output.write_bytes(old)
            barrier = directory / "entered"
            release = directory / "release"
            child_env = dict(env, KM_OUTPUT=str(output.relative_to(ROOT)),
                             KM_ATOMIC_TEST_MODE=mode, KM_ATOMIC_TEST_BARRIER=str(barrier),
                             KM_ATOMIC_TEST_RELEASE=str(release))
            process = subprocess.Popen(["bash", str(args.generator)], cwd=ROOT, env=child_env,
                                       stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                       start_new_session=True)
            try:
                deadline = time.monotonic() + 30
                while not barrier.exists():
                    if process.poll() is not None or time.monotonic() > deadline:
                        raise AssertionError((name, "renderer barrier was not reached"))
                    time.sleep(0.01)
                before = output.read_bytes() if output.exists() else None
                observed = {before}
                if mode == "interrupt":
                    os.killpg(process.pid, signal.SIGTERM)
                else:
                    release.touch()
                    while process.poll() is None:
                        observed.add(output.read_bytes() if output.exists() else None)
                        if time.monotonic() > deadline:
                            raise AssertionError((name, "renderer did not finish"))
                        time.sleep(0.001)
                stdout, stderr = process.communicate(timeout=10)
                after = output.read_bytes() if output.exists() else None
                observed.add(after)
                failed = mode in ("render_fail", "interrupt")
                original = None if fresh else old
                checks = {
                    "old_complete_or_absent_while_rendering": before == original,
                    "expected_exit": (process.returncode != 0) if failed else process.returncode == 0,
                    "failure_preserves_old_or_success_publishes_new": after == (original if failed else expected),
                    "reader_saw_only_complete_versions": observed <= {original, expected},
                    "no_staging_residue": not leftovers(output),
                }
                results.append({"case": name, "checks": checks})
                retained.append({"case": name, "exit": process.returncode,
                                 "stdout": stdout.decode(errors="replace"),
                                 "stderr": stderr.decode(errors="replace"),
                                 "observed_base64": [None if b is None else base64.b64encode(b).decode()
                                                     for b in observed]})
            finally:
                if process.poll() is None:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.communicate(timeout=10)

        observe("replace", "pause")
        observe("first_publication", "pause", fresh=True)
        observe("render_failure", "render_fail")
        observe("termination", "interrupt")

        validator = shim_dir / "validate-output"
        validator.write_text('''#!/usr/bin/env python3
import sys
from pathlib import Path
p = Path(sys.argv[1])
sys.exit(29 if p.is_file() and p.read_bytes().startswith(b'# Atomic fixture') else 0)
''')
        validator.chmod(0o755)
        output = scratch / "invalid-map.md"
        output.write_bytes(old)
        rejected = invoke(output, dict(env, KM_OUTPUT_VALIDATOR=str(validator)))
        results.append({"case": "completed_output_rejected", "checks": {
            "validation_failed": rejected.returncode != 0,
            "old_map_preserved": output.read_bytes() == old,
            "no_staging_residue": not leftovers(output),
        }})
        target = scratch / "symlink-target.md"
        target.write_bytes(old)
        linked = scratch / "symlink-map.md"
        linked.symlink_to(target.name)
        rejected_link = invoke(linked, env)
        results.append({"case": "symlink_rejected", "checks": {
            "validation_failed": rejected_link.returncode != 0,
            "target_preserved": target.read_bytes() == old,
        }})
        report = {"results": results, "observations": retained,
                  "fact_source": fact.read_text(), "awk_shim": shim.read_text(),
                  "validator": validator.read_text(), "source_path": str(fact.relative_to(ROOT)),
                  "expected_base64": base64.b64encode(expected).decode(),
                  "rejected_output_exit": rejected.returncode,
                  "rejected_output_stderr": rejected.stderr.decode(errors="replace"),
                  "symlink_exit": rejected_link.returncode,
                  "symlink_stderr": rejected_link.stderr.decode(errors="replace")}
        if args.evidence:
            (ROOT / args.evidence).write_text(json.dumps(report, sort_keys=True) + "\n")
        print(json.dumps({"results": results}, sort_keys=True))
        if not all(all(row["checks"].values()) for row in results):
            raise SystemExit(1)


if __name__ == "__main__":
    main()
