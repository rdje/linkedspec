"""Exercise the actual path checkers with bounded, NUL-delimited Git input."""
import argparse
import base64
import errno
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parent.parent
CHECKERS = (
    "scripts/check_repo_root_path_portability.sh",
    "scripts/check_project_data_storage_locality.sh",
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--evidence", type=Path)
    args = parser.parse_args()
    if args.evidence and (args.evidence.is_absolute() or ".." in args.evidence.parts
                          or not args.evidence.parts or args.evidence.parts[0] != ".linkedspec-data"):
        parser.error("evidence must be beneath repository-relative .linkedspec-data")
    real_git = shutil.which("git")
    assert real_git
    # The fixture must be inside a governed source directory for both policies.
    # TemporaryDirectory removes only this newly created, uniquely owned subtree.
    with tempfile.TemporaryDirectory(prefix=".path-stream-", dir=ROOT / "tools") as directory:
        fixture = Path(directory)
        shim_dir = fixture / "bin"
        shim_dir.mkdir()
        shim = shim_dir / "git"
        shim.write_text("""#!/usr/bin/env python3
import os, pathlib, sys
if sys.argv[1:] == ['ls-files', '-z', '--', '.', ':(exclude)rgx']:
    sys.stdout.buffer.write(pathlib.Path(os.environ['PATH_STREAM_MANIFEST']).read_bytes())
    sys.exit(int(os.environ.get('PATH_STREAM_GIT_STATUS', '0')))
os.execv(os.environ['PATH_STREAM_REAL_GIT'], ['git', *sys.argv[1:]])
""")
        shim.chmod(0o755)
        manifest = fixture / "paths.nul"
        safe = fixture / "space and\nnewline.txt"
        safe.write_text("specs/Lispish.spec\n")
        binary = fixture / "binary.dat"
        binary.write_bytes(b"\0binary\0")
        linked = fixture / "linked.txt"
        linked.symlink_to(safe.name)
        bad = fixture / "bad.sh"
        bad.write_text("TMPDIR=" + str(ROOT) + "/forbidden\n")
        paths = [str(p.relative_to(ROOT)) for p in (safe, binary, linked)]
        nul = b"\0".join(os.fsencode(p) for p in paths) + b"\0"
        env = dict(os.environ, PATH=str(shim_dir) + os.pathsep + os.environ["PATH"],
                   PATH_STREAM_MANIFEST=str(manifest), PATH_STREAM_REAL_GIT=real_git)

        observations = []

        def run(checker, data, success, marker=None, git_status=0):
            manifest.write_bytes(data)
            child_env = dict(env, PATH_STREAM_GIT_STATUS=str(git_status))
            result = subprocess.run(["bash", checker], cwd=ROOT, env=child_env,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output = (result.stdout + result.stderr).decode(errors="replace")
            assert (result.returncode == 0) == success, (checker, result.returncode, output)
            if marker:
                assert marker in output, (checker, output)
            observations.append({"checker": checker, "git_status": git_status,
                                 "paths_nul_base64": base64.b64encode(data).decode(),
                                 "exit": result.returncode,
                                 "stdout": result.stdout.decode(errors="replace"),
                                 "stderr": result.stderr.decode(errors="replace")})
            return result.returncode

        repeated = os.fsencode(paths[0]) + b"\0"
        copies = os.sysconf("SC_ARG_MAX") // len(repeated) + 1
        oversized = repeated * copies
        try:
            subprocess.run(["perl", "-e", "exit 0", *([paths[0]] * copies)],
                           check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except OSError as error:
            assert error.errno == errno.E2BIG, error
        else:
            raise AssertionError("oversized argv RED control unexpectedly launched")

        results = {}
        for checker in CHECKERS:
            results[checker] = {
                "small": run(checker, nul, True),
                "large": run(checker, oversized, True),
                "truncated": run(checker, repeated[:-1], False, "not NUL-terminated"),
                "git_failure": run(checker, nul, False, git_status=23),
                "policy_violation": run(checker, os.fsencode(str(bad.relative_to(ROOT))) + b"\0",
                                        False, "not repository-filesystem rooted"
                                        if "storage" in checker else "not relocation-safe"),
            }
        if args.evidence:
            retained = {"observations": observations, "checks": results,
                        "oversized_argv_errno": errno.E2BIG,
                        "fixtures": {str(p.relative_to(ROOT)): base64.b64encode(p.read_bytes()).decode()
                                     for p in (safe, binary, bad, shim)},
                        "symlink": {"path": str(linked.relative_to(ROOT)), "target": safe.name}}
            (ROOT / args.evidence).write_text(json.dumps(retained, sort_keys=True) + "\n")
        print(json.dumps({"oversized_argv": "E2BIG", "checks": results}, sort_keys=True))


if __name__ == "__main__":
    main()
