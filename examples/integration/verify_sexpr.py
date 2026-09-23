#!/usr/bin/env python3
"""Replay the documented document-grammar adaptations through public loaders.

Prepare the selected integration example first, then run this program through
tools/run_python_project_data.sh. Only the entry-rule literal is adapted in
temporary copies; the historical word examples and authored values stay intact.
This verifies text-argument consumers. Rust's verify_sexpr.py owns file input.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", required=True,
                        choices=("perl", "rust", "dart", "julia", "puc", "luajit"))
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    scratch = Path(os.environ["LINKEDSPEC_SCRATCH_ROOT"])
    assert scratch.stat().st_dev == root.stat().st_dev
    grammar = root / "specs/SExprDocumentV1.spec"
    authority = root / "tests/sexpr-document-v1/contract.json"
    cases = json.loads(authority.read_text(encoding="utf-8"))["cases"]
    accepted = [case for case in cases if case["outcome"] == "accept"]
    rejected = [case for case in cases if case["outcome"] == "reject"]
    assert (len(cases), len(accepted), len(rejected)) == (37, 21, 16)
    environment = dict(os.environ, PERL5LIB="", PERL5OPT="", PERL_UNICODE="0")
    protected = [grammar, authority]
    checks = []

    with tempfile.TemporaryDirectory(prefix="sexpr-public-", dir=scratch) as temporary:
        work = Path(temporary)
        outside = work / "caller é"
        outside.mkdir()
        specs = work / "specs"
        specs.mkdir()
        # Dart's staged frontend discovers this public support asset via cwd.
        shutil.copy2(root / "specs/user_function_definition.spec", specs)
        binary = root / "rust/target/debug/linkedspec-integration-example"
        sources = {
            "perl": ("perl/parse_words.pl", "top_rule => 'Top'", "top_rule => 'Document'"),
            "dart": ("dart/bin/parse_words.dart", "topRule: 'Top'", "topRule: 'Document'"),
            "julia": ("julia/bin/parse_words.jl", 'top_rule = "Top"', 'top_rule = "Document"'),
            "puc": ("lua/bin/parse_words.lua", 'top_rule = "Top"', 'top_rule = "Document"'),
            "luajit": ("lua/bin/parse_words.lua", 'top_rule = "Top"', 'top_rule = "Document"'),
        }
        if args.runtime == "rust":
            protected.extend([binary, root / "examples/integration/rust/src/main.rs"])
            command = [str(binary)]
        else:
            relative, old, new = sources[args.runtime]
            source = root / "examples/integration" / relative
            protected.append(source)
            text = source.read_text(encoding="utf-8")
            assert text.count(old) == 1, (source, "entry adaptation must have one exact owner")
            executable = work / "bin" / source.name
            executable.parent.mkdir()
            executable.write_text(text.replace(old, new), encoding="utf-8")
            if args.runtime == "perl":
                command = ["perl", "-I" + str(root / "perl"), str(executable)]
            elif args.runtime == "dart":
                config = root / "examples/integration/dart/.dart_tool/package_config.json"
                protected.append(config)
                command = ["bash", str(root / "tools/run_dart_project_data.sh"),
                           "--packages=" + str(config), str(executable)]
            elif args.runtime == "julia":
                package = root / "examples/integration/julia"
                data = package / ".app-data/linkedspec"
                depot = data / "cache/julia-depot"
                assert depot.is_dir() and depot.stat().st_dev == root.stat().st_dev, depot
                protected.extend([package / "Project.toml", package / "Manifest.toml"])
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
                           "--history-file=no", str(executable)]
            else:
                native = root / "examples/integration/lua/build/native" / args.runtime
                protected.extend(native / name for name in
                                 ("linkedspec_regex_pcre2.so", "linkedspec_filesystem_native.so"))
                environment["LINKEDSPEC_LUA_NATIVE_ROOT"] = str(native)
                interpreter = shutil.which("lua" if args.runtime == "puc" else "luajit")
                assert interpreter is not None, args.runtime
                command = [interpreter, "-E", str(executable)]

        for path in protected:
            assert path.is_file() and path.stat().st_dev == root.stat().st_dev, path
        hashes = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in protected}

        def run(label, selected, inputs, *, expected=(), failure=None):
            result = subprocess.run(command + [str(selected), *inputs], cwd=outside,
                                    env=environment, capture_output=True, timeout=600, check=False)
            assert result.returncode == (0 if failure is None else 1), (label, result)
            assert [json.loads(line) for line in result.stdout.splitlines()] == list(expected), (label, result)
            if failure is None:
                assert not result.stderr, (label, result.stderr)
            elif args.runtime == "rust":
                # The generic Rust text adapter deliberately prints Display;
                # the native file verifier independently checks typed JSON.
                message = ("exit_now(1)" if failure == "document" else {
                    "invalid_utf8": "Spec file is not valid UTF-8",
                    "spec_path_not_found": "Spec path not found",
                }[failure["code"]])
                assert result.stderr == f"consumer: {message}\n".encode(), (label, result.stderr)
            else:
                record = json.loads(result.stderr)
                expected_error = ({"type": "runtime_exit_now", "status": 1}
                                  if failure == "document" else failure)
                assert all(record.get(key) == value for key, value in expected_error.items()), (label, record)
            checks.append(label)

        run("all 21 authored values through one public-loaded engine", grammar,
            [case["input"] for case in accepted], expected=[case["expected"] for case in accepted])
        for case in rejected:
            run(case["id"], grammar, [case["input"]], failure="document")
        good = next(case for case in accepted if case["id"] == "reuse_after_rejection")
        run("prior successful output retained / no rejected or later value", grammar,
            [good["input"], rejected[0]["input"], good["input"]],
            expected=[good["expected"]], failure="document")
        relative = Path("document 雪.spec")
        # Julia documents application-root-relative paths; other adapters use cwd.
        (work if args.runtime == "julia" else outside).joinpath(relative).write_bytes(grammar.read_bytes())
        run("documented relative Unicode grammar path", relative,
            [good["input"]], expected=[good["expected"]])
        invalid = work / "invalid-utf8.spec"
        invalid.write_bytes(b"\xff")
        run("strict UTF-8 grammar", invalid, [good["input"]], failure={
            "type": "spec_pipeline_error", "stage": "decode_spec_content", "code": "invalid_utf8"})
        run("missing grammar", work / "absent.spec", [good["input"]], failure={
            "type": "spec_pipeline_error", "stage": "resolve_spec_path", "code": "spec_path_not_found"})
        for path, original in hashes.items():
            assert hashlib.sha256(path.read_bytes()).hexdigest() == original, path

    assert not work.exists(), "owned temporary adapters and fixtures must be removed"
    print(json.dumps({"status": "PASS", "runtime": args.runtime, "authored_cases": len(cases),
                      "accepted": len(accepted), "rejected": len(rejected), "checks": checks}))


if __name__ == "__main__":
    main()
