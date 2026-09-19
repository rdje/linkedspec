"""Verify Dart source/AOT errors, diagnostics and a relocated native bundle.

Prepare packages and compile bin/parse_words.dart before running this verifier.
The verifier reuses the executable; it does not compile or resolve dependencies.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def assert_fields(actual, expected):
    for key, value in expected.items():
        assert key in actual, (key, actual)
        if isinstance(value, dict):
            assert_fields(actual[key], value)
        else:
            assert actual[key] == value, (key, actual[key], value)


def hashes(directory):
    return {
        path.relative_to(directory).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted(directory.rglob("*"))
        if path.is_file()
    }


def main():
    root = Path(__file__).resolve().parents[3]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument("--library-root", type=Path, default=root)
    parser.add_argument("--grammar", type=Path, default=root / "examples/integration/word.spec")
    parser.add_argument("--fixtures", type=Path, help="Directory containing diagnostics.spec and exit.spec")
    parser.add_argument("--executable", type=Path)
    parser.add_argument("--bash", help="Host Bash executable for the deployed launcher")
    args = parser.parse_args()
    package = args.package.resolve(strict=True)
    library = args.library_root.resolve(strict=True)
    grammar = args.grammar.resolve(strict=True)
    fixtures_root = (args.fixtures or package).resolve(strict=True)
    executable = (args.executable or package / "build/bin/parse_words").resolve(strict=True)
    assert os.access(executable, os.X_OK), executable
    config = package / ".dart_tool/package_config.json"
    assert config.is_file(), "Resolve the application packages first"
    scratch = Path(os.environ["TMPDIR"]).resolve(strict=True)
    for path in (package, library, grammar, fixtures_root, executable, scratch):
        assert path.stat().st_dev == root.stat().st_dev, path
    data = package / ".app-data/linkedspec"
    environment = dict(
        os.environ,
        LINKEDSPEC_PROJECT_DATA_ROOT=str(data),
        LINKEDSPEC_CACHE_ROOT=str(data / "cache"),
        LINKEDSPEC_SCRATCH_ROOT=str(data / "scratch"),
        PUB_CACHE=str(data / "cache/dart-pub"),
        LINKEDSPEC_DART_HOME=str(data / "cache/dart-home"),
    )
    source_command = [
        "bash", str(library / "tools/run_dart_project_data.sh"),
        "--packages=" + str(config), str(package / "bin/parse_words.dart"),
    ]
    checks = []

    def run(label, command, arguments, cwd, values, records=(), status=0, env=None):
        result = subprocess.run(
            command + [str(arg) for arg in arguments], cwd=cwd,
            env=environment if env is None else env, capture_output=True,
            timeout=120, check=False,
        )
        assert result.returncode == status, (label, result)
        stdout = result.stdout.decode("utf-8", errors="strict")
        stderr = result.stderr.decode("utf-8", errors="strict")
        assert [json.loads(line) for line in stdout.splitlines()] == values, (label, stdout)
        actual = [json.loads(line) for line in stderr.splitlines()]
        assert len(actual) == len(records), (label, actual, records)
        for record, expected in zip(actual, records):
            assert_fields(record, expected)
        checks.append(label)
        return actual

    with tempfile.TemporaryDirectory(prefix="dart-deployment-", dir=scratch) as name:
        work = Path(name)
        specs = work / "specs"
        specs.mkdir()
        support_bytes = (library / "specs/user_function_definition.spec").read_bytes()
        (specs / "user_function_definition.spec").write_bytes(support_bytes)
        diagnostic_spec = fixtures_root / "diagnostics.spec"
        exit_spec = fixtures_root / "exit.spec"
        fixtures = {
            "parse.spec": b"not a spec\n",
            "empty.spec": b"# no rules\n",
            "invalid.spec": b"\xff",
            "arity.spec": b'Top::\n -> Hit { say(); return("late") }\nHit:\n /x/\n',
            "null.spec": b'Top::\n -> Hit { return(undef) }\nHit:\n /x/\n',
            "--diagnostics": grammar.read_bytes(),
        }
        for filename, contents in fixtures.items():
            (work / filename).write_bytes(contents)
        events = [
            {"type": "diagnostic_output", "helper_name": "say", "rule_label": "Top", "message": "héllo 雪\n"},
            {"type": "diagnostic_output", "helper_name": "print", "rule_label": "Top", "message": "done"},
        ]
        before_exit = {"type": "diagnostic_output", "helper_name": "say", "rule_label": "Top", "message": "before\n"}
        typed_exit = {"type": "runtime_exit_now", "status": 7}
        pipeline = {"type": "spec_pipeline_error"}
        for mode, command in (("source", source_command), ("aot", [str(executable)])):
            run(mode + ": quiet diagnostic helpers", command, [diagnostic_spec, "x", "x"], work, ["ok", "ok"])
            run(mode + ": ordered Unicode events", command, ["--diagnostics", diagnostic_spec, "x"], work, ["ok"], events)
            run(mode + ": typed exit retains earlier output and stops input loop", command,
                ["--diagnostics", exit_spec, "x", "y", "x"], work, ["ok"], [before_exit, typed_exit], 1)
            run(mode + ": quiet typed exit", command, [exit_spec, "y"], work, [], [typed_exit], 1)
            run(mode + ": runtime arity with source identity", command, [work / "arity.spec", "x"], work, [],
                [{"type": "runtime_error", "diagnostic": {"stage": "helper_arity_mismatch", "rule_label": "Top", "spec_path": str(work / "arity.spec")}}], 1)
            run(mode + ": null is a successful value", command, [work / "null.spec", "x"], work, [None])
            run(mode + ": literal option-like grammar", command, ["--", "--diagnostics", "alpha"], work, [["alpha"]])
            for filename, stage, code in (
                ("absent.spec", "resolve_spec_path", "spec_path_not_found"),
                ("invalid.spec", "decode_spec_content", "invalid_utf8"),
                ("parse.spec", "parse_spec", "spec_parse_failed"),
                ("empty.spec", "validate_spec", "no_rules_defined"),
            ):
                run(mode + ": " + code, command, [work / filename, "x"], work, [],
                    [{**pipeline, "stage": stage, "code": code}], 1)
            run(mode + ": missing arguments", command, ["--diagnostics"], work, [], [{"type": "consumer_error"}], 1)
            sentinel = work / (mode + "-trace.log")
            sentinel.write_bytes(b"preserve trace sentinel\n")
            inherited = dict(environment, LINKEDSPEC_TRACE_LEVEL="500", LINKEDSPEC_TRACE_MODE="mirror",
                             LINKEDSPEC_TRACE_FILE=str(sentinel), LINKEDSPEC_TRACE_RESET="1")
            run(mode + ": inherited trace controls remain separate", command, [diagnostic_spec, "x"], work, ["ok"], env=inherited)
            assert sentinel.read_bytes() == b"preserve trace sentinel\n"

        bundle = work / "bundle"
        (bundle / "bin").mkdir(parents=True)
        (bundle / "specs").mkdir()
        shutil.copy2(executable, bundle / "bin/parse_words")
        shutil.copy2(package / "bin/parse-words", bundle / "bin/parse-words")
        for source, destination in (
            (grammar, "word.spec"), (diagnostic_spec, "diagnostics.spec"),
            (exit_spec, "exit.spec"), (library / "specs/user_function_definition.spec", "user_function_definition.spec"),
        ):
            shutil.copy2(source, bundle / "specs" / destination)
        baseline = hashes(bundle)
        assert set(baseline) == {
            "bin/parse_words", "bin/parse-words", "specs/word.spec", "specs/diagnostics.spec",
            "specs/exit.spec", "specs/user_function_definition.spec",
        }
        # Invoke the necessary host Bash directly; the empty PATH has no Dart SDK.
        bash = shutil.which(args.bash or "bash")
        assert bash is not None
        shell_version = subprocess.check_output([bash, "--version"], text=True).splitlines()[0]
        empty_path = work / "empty-path"
        empty_path.mkdir()
        native_env = dict(environment, PATH=str(empty_path))
        assert shutil.which("dart", path=native_env["PATH"]) is None
        caller = work / "caller é"
        (caller / "specs").mkdir(parents=True)
        (caller / "specs/user_function_definition.spec").write_text("not a spec\n", encoding="utf-8")
        (caller / "word é.spec").write_bytes(grammar.read_bytes())
        launcher = lambda: [bash, str(bundle / "bin/parse-words")]
        run("bundle: outside cwd selects owned support grammar", launcher(), [bundle / "specs/word.spec", "alpha"], caller, [["alpha"]], env=native_env)
        run("bundle: caller-relative Unicode grammar", launcher(), ["word é.spec", "alpha rest"], caller, [["alpha", "rest"]], env=native_env)
        (caller / "--diagnostics").write_bytes(diagnostic_spec.read_bytes())
        run("bundle: diagnostic flag and literal option-like grammar", launcher(),
            ["--diagnostics", "--", "--diagnostics", "x"], caller, ["ok"], events, env=native_env)
        retained_executable = work / "retained-executable"
        (bundle / "bin/parse_words").rename(retained_executable)
        try:
            run("bundle: missing executable is a deployment error", launcher(),
                [bundle / "specs/word.spec", "alpha"], caller, [],
                [{"type": "deployment_error", "detail": "Missing executable bin/parse_words"}], 1, native_env)
        finally:
            retained_executable.rename(bundle / "bin/parse_words")
        run("control: bare executable sees the bad caller support grammar", [str(bundle / "bin/parse_words")],
            [bundle / "specs/word.spec", "alpha"], caller, [], [{**pipeline, "stage": "parse_spec", "code": "spec_parse_failed"}], 1, native_env)
        asset = bundle / "specs/user_function_definition.spec"
        asset.write_text("not a spec\n", encoding="utf-8")
        try:
            run("bundle: bad owned asset is selected", launcher(), [bundle / "specs/word.spec", "alpha"], caller, [],
                [{**pipeline, "stage": "parse_spec", "code": "spec_parse_failed"}], 1, native_env)
        finally:
            asset.write_bytes(support_bytes)
        asset.unlink()
        try:
            run("bundle: missing owned asset cannot fall back to ancestors", launcher(), [bundle / "specs/word.spec", "alpha"], caller, [],
                [{"type": "deployment_error", "detail": "Missing packaged specs/user_function_definition.spec"}], 1, native_env)
        finally:
            asset.write_bytes(support_bytes)
        assert hashes(bundle) == baseline
        moved = work / "moved 雪" / "application"
        moved.parent.mkdir()
        bundle.rename(moved)
        bundle = moved
        for path in bundle.rglob("*"):
            if path.is_file():
                path.chmod(0o555 if path.parent.name == "bin" else 0o444)
        run("moved bundle: repeated direct values without SDK on PATH", launcher(),
            [bundle / "specs/word.spec", "alpha", "Beta", "123", "alpha"], caller,
            [["alpha"], ["Beta"], [], ["alpha"]], env=native_env)
        run("moved bundle: typed exit and Unicode path", launcher(),
            ["--diagnostics", bundle / "specs/exit.spec", "x", "y", "x"], work,
            ["ok"], [before_exit, typed_exit], 1, native_env)
        run("moved bundle: Unicode event bytes", launcher(),
            ["--diagnostics", bundle / "specs/diagnostics.spec", "x"], caller,
            ["ok"], events, env=native_env)
        assert hashes(bundle) == baseline
        assert all(path.stat().st_dev == root.stat().st_dev for path in work.rglob("*"))
    assert not work.exists()
    print(json.dumps({"status": "PASS", "checks": checks, "check_count": len(checks),
                      "bundle_files": sorted(baseline), "moved_bytes_unchanged": True,
                      "deployment_shell_version": shell_version,
                      "dart_absent_from_deployment_path": True, "fixture_cleanup": True}, ensure_ascii=False))


if __name__ == "__main__":
    main()
