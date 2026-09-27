#!/usr/bin/env python3
"""Check a bounded readiness grammar through a documented public text consumer.

Prepare the chosen integration example using the public integration guide, then
run through tools/run_python_project_data.sh. The default is nested-tree;
--fixture context-names selects the scoped closing-name trial. This is native
readiness evidence, not emitted or same-engine rejection-recovery proof.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess


def canonical(value):
    """Compare JSON kinds as well as values, independently of object field order."""
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(",", ":"))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", required=True,
                        choices=("perl", "rust", "dart", "julia", "puc", "luajit"))
    parser.add_argument("--fixture", default="nested-tree",
                        choices=("nested-tree", "context-names"))
    arguments = parser.parse_args()
    runtime = arguments.runtime
    root = Path(__file__).resolve().parents[3]
    fixture = root / "tests/language-readiness" / arguments.fixture
    grammar = fixture / "grammar.spec"
    authority = fixture / "cases.json"
    cases = json.loads(authority.read_text(encoding="utf-8"))
    accepted, rejected = cases["accept"], cases["reject"]
    expected_counts = {"nested-tree": (6, 7), "context-names": (11, 17)}
    assert (len(accepted), len(rejected)) == expected_counts[arguments.fixture]
    assert len({case["id"] for case in accepted + rejected}) == sum(
        expected_counts[arguments.fixture])
    environment = dict(os.environ, PERL5LIB="", PERL5OPT="", PERL_UNICODE="0")
    protected = [grammar, authority]
    integration = root / "examples/integration"

    if runtime == "rust":
        binary = root / "rust/target/debug/linkedspec-integration-example"
        protected.extend([binary, integration / "rust/src/main.rs"])
        command = [str(binary)]
    elif runtime == "perl":
        adapter = integration / "perl/parse_words.pl"
        protected.append(adapter)
        command = ["perl", "-I" + str(root / "perl"), str(adapter)]
    elif runtime == "dart":
        adapter = integration / "dart/bin/parse_words.dart"
        config = integration / "dart/.dart_tool/package_config.json"
        protected.extend([adapter, config])
        command = ["bash", str(root / "tools/run_dart_project_data.sh"),
                   "--packages=" + str(config), str(adapter)]
    elif runtime == "julia":
        package = integration / "julia"
        adapter = package / "bin/parse_words.jl"
        data = package / ".app-data/linkedspec"
        depot = data / "cache/julia-depot"
        assert depot.is_dir() and depot.stat().st_dev == root.stat().st_dev
        protected.extend([adapter, package / "Project.toml", package / "Manifest.toml"])
        environment.update(
            LINKEDSPEC_PROJECT_DATA_ROOT=str(data),
            LINKEDSPEC_CACHE_ROOT=str(data / "cache"),
            LINKEDSPEC_SCRATCH_ROOT=str(data / "scratch"),
            JULIA_DEPOT_PATH=str(depot) + ":",
            LINKEDSPEC_JULIA_DEPOT_PATH=str(depot) + ":",
            JULIA_LOAD_PATH="@:@stdlib", JULIA_PKG_OFFLINE="true",
            TMPDIR=str(data / "scratch/tmp"), TMP=str(data / "scratch/tmp"),
            TEMP=str(data / "scratch/tmp"),
        )
        command = ["bash", str(root / "tools/run_julia_project_data.sh"),
                   "--project=" + str(package), "--startup-file=no",
                   "--history-file=no", str(adapter)]
    else:
        adapter = integration / "lua/bin/parse_words.lua"
        native = integration / "lua/build/native" / runtime
        protected.extend([adapter, native / "linkedspec_regex_pcre2.so",
                          native / "linkedspec_filesystem_native.so"])
        environment["LINKEDSPEC_LUA_NATIVE_ROOT"] = str(native)
        interpreter = shutil.which("lua" if runtime == "puc" else "luajit")
        assert interpreter is not None, runtime
        command = [interpreter, "-E", str(adapter)]

    for path in protected:
        assert path.is_file() and path.stat().st_dev == root.stat().st_dev, path
    hashes = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in protected}

    def run(selected):
        return subprocess.run(command + [str(grammar), *selected], cwd=root,
                              env=environment, capture_output=True, timeout=600,
                              check=False)

    repeated = accepted + list(reversed(accepted))
    result = run([case["input"] for case in repeated])
    assert result.returncode == 0 and not result.stderr, (runtime, "accepted batch", result)
    observed = [json.loads(line) for line in result.stdout.splitlines()]
    assert len(observed) == len(repeated), (runtime, "result count", observed)
    for case, value in zip(repeated, observed):
        assert canonical(value) == canonical(case["expected"]), (runtime, case["id"], value)

    for case in rejected:
        result = run([case["input"]])
        assert result.returncode == 1 and not result.stdout, (runtime, case["id"], result)
        expected_status = case.get("status", 1)
        if runtime == "rust":
            # This published adapter prints Display. Typed recovery is a later probe.
            expected_error = f"consumer: exit_now({expected_status})\n".encode("utf-8")
            assert result.stderr == expected_error, (case["id"], result.stderr)
        else:
            error = json.loads(result.stderr)
            assert error.get("type") == "runtime_exit_now" and error.get("status") == expected_status, (
                runtime, case["id"], error)

    for path, original in hashes.items():
        assert hashlib.sha256(path.read_bytes()).hexdigest() == original, path
    print(json.dumps({
        "status": "PASS", "runtime": runtime, "fixture": arguments.fixture,
        "accepted": len(accepted),
        "rejected": len(rejected), "same_engine_accepted_executions": len(repeated),
        "rejection_projection": "Display" if runtime == "rust" else "typed JSON",
        "protected_sha256": {str(path.relative_to(root)): digest for path, digest in hashes.items()},
        "limits": "Native text consumer only; no carrier or same-engine rejection-recovery claim",
    }, sort_keys=True))


if __name__ == "__main__":
    main()
