"""Verify prepared Lua consumers, diagnostics and relocatable deployment without a native build."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    root = Path(__file__).resolve().parents[3]
    fixtures = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", choices=("puc", "luajit"), required=True)
    parser.add_argument("--package", type=Path, default=fixtures)
    parser.add_argument("--library-root", type=Path, default=root)
    parser.add_argument("--grammar", type=Path, default=root / "examples/integration/word.spec")
    args = parser.parse_args()
    package = args.package.resolve(strict=True)
    library = args.library_root.resolve(strict=True)
    grammar = args.grammar.resolve(strict=True)
    native = package / "build/native" / args.runtime
    interpreter = shutil.which("lua" if args.runtime == "puc" else "luajit")
    assert interpreter is not None
    data = package / ".app-data/linkedspec"
    scratch = data / "scratch/tmp"
    scratch.mkdir(parents=True, exist_ok=True)
    for path in (package, library, grammar, native, scratch):
        assert path.stat().st_dev == root.stat().st_dev and not path.is_symlink(), path

    def product_state():
        return {p.name: (hashlib.sha256(p.read_bytes()).hexdigest(), p.stat().st_mtime_ns)
                for p in native.iterdir() if p.is_file()}

    baseline = product_state()
    environment = dict(os.environ, LINKEDSPEC_PROJECT_DATA_ROOT=str(data),
        LINKEDSPEC_CACHE_ROOT=str(data / "cache"), LINKEDSPEC_SCRATCH_ROOT=str(data / "scratch"),
        LINKEDSPEC_LUA_NATIVE_ROOT=str(native), TMPDIR=str(scratch), TMP=str(scratch), TEMP=str(scratch))
    command = ["bash", str(library / "tools/project_data_run.sh"), interpreter, "-E",
               str(package / "bin/parse_words.lua")]
    checks = []

    def run(label, arguments, cwd, values, records=(), status=0, selected=None, env=None):
        result = subprocess.run((selected or command) + [str(a) for a in arguments], cwd=cwd,
            env=environment if env is None else env, capture_output=True, timeout=180, check=False)
        assert result.returncode == status, (label, result)
        try:
            actual_values = [json.loads(line) for line in result.stdout.splitlines()]
            observed = [json.loads(line) for line in result.stderr.splitlines()]
        except (json.JSONDecodeError, UnicodeDecodeError) as failure:
            raise AssertionError((label, result)) from failure
        assert actual_values == values, (label, result)
        assert len(observed) == len(records), (label, observed, records)
        for actual, expected in zip(observed, records):
            for key, value in expected.items():
                assert actual.get(key) == value, (label, actual, expected)
            if expected["type"] in ("diagnostic_output", "runtime_exit_now"):
                assert actual == expected, (label, actual, expected)
        checks.append(label)

    def event(helper, message):
        return {"type": "diagnostic_output", "helper_name": helper, "rule_label": "Top", "message": message}

    events = [event("say", "héllo 雪\n"), event("print", "done")]
    exit_records = [event("say", "before\n"), {"type": "runtime_exit_now", "status": 7}]
    with tempfile.TemporaryDirectory(prefix="lua-deployment-é-", dir=scratch) as directory:
        work = Path(directory)
        diagnostic = fixtures / "diagnostics.spec"
        exit_spec = fixtures / "exit.spec"
        run("quiet diagnostic helpers preserve value", [diagnostic, "x"], work, ["ok"])
        run("ordered Unicode events across independent inputs", ["--diagnostics", diagnostic, "x", "x"],
            work, ["ok", "ok"], events * 2)
        run("typed exit preserves prior value and stops later input", ["--diagnostics", exit_spec, "x", "y", "x"],
            work, ["ok"], exit_records, status=1)
        run("quiet typed exit", [exit_spec, "y"], work, [], [{"type": "runtime_exit_now", "status": 7}], status=1)
        arity = work / "arity.spec"
        arity.write_text('Top::\n -> Hit { print(); return("unreachable") }\nHit:\n /x/\n', encoding="utf-8")
        arity_message = "helper 'print' expects at least 1 positional argument, got 0"
        run("structured helper arity failure", ["--diagnostics", arity, "x"], work, [],
            [{"type": "runtime_error", "code": "helper_arity_mismatch", "helper_name": "print",
              "actual_arity": 0, "expected_arity": "at least 1 positional argument", "message": arity_message,
              "diagnostic": {"type": "runtime_parser", "stage": "runtime_execution", "owner_stage": "lua_runtime",
                  "summary": "Lua runtime interpreter failed", "detail": arity_message, "spec_path": str(arity),
                  "top_rule": "Top", "rule_label": "Top", "handler_source_label": "lua_runtime:rule:Top"}}], status=1)
        nested = work / "nested.spec"
        nested.write_text('Top::\n -> Hit { return({ "items" : [1, false, undef] }) }\nHit:\n /x/\n', encoding="utf-8")
        run("nested harray array false and null values", [nested, "x"], work, [{"items": [1, False, None]}])
        for literal, value in (("undef", None), ("false", False)):
            fixture = work / (literal + ".spec")
            fixture.write_text('Top::\n -> Hit { return(' + literal + ') }\nHit:\n /x/\n', encoding="utf-8")
            run("successful " + literal, [fixture, "x"], work, [value])
        invalid = work / "invalid.spec"
        invalid.write_bytes(b"\xff")
        run("strict UTF-8 failure", [invalid, "x"], work, [],
            [{"type": "spec_pipeline_error", "stage": "decode_spec_content", "code": "invalid_utf8"}], status=1)
        run("missing grammar", [work / "absent.spec", "x"], work, [],
            [{"type": "spec_pipeline_error", "stage": "resolve_spec_path", "code": "spec_path_not_found"}], status=1)
        run("missing option arguments", ["--diagnostics"], work, [], [{"type": "consumer_error"}], status=1)
        option_name = work / "--diagnostics"
        option_name.write_bytes(grammar.read_bytes())
        run("option-like grammar with delimiter", ["--", option_name.name, "alpha"], work, [["alpha"]])
        sentinel = work / "caller.trace"
        sentinel.write_bytes(b"caller trace must remain unchanged\n")
        inherited = dict(environment, LINKEDSPEC_TRACE_LEVEL="500", LINKEDSPEC_TRACE_FILE=str(sentinel),
            LINKEDSPEC_TRACE_MIRROR_STDOUT="1", LINKEDSPEC_TRACE_RESET_FILE="1")
        run("diagnostic events do not enable or reset ambient trace", ["--diagnostics", diagnostic, "x"],
            work, ["ok"], events, env=inherited)
        assert sentinel.read_bytes() == b"caller trace must remain unchanged\n"

        # Copy only the committed runtime/source-wrapper closure, never a working cache or a dependency.
        bundle = work / "bundle"
        vendored = bundle / "vendor/linkedspec"
        entries = subprocess.check_output(["git", "-C", str(root), "ls-tree", "-rz", "HEAD", "--",
                                           "lua/src", "specs", "tools"])
        source_count = source_bytes = 0
        for row in filter(None, entries.split(b"\0")):
            metadata, raw_name = row.split(b"\t", 1)
            mode, kind, oid = metadata.split()
            assert kind == b"blob" and mode in (b"100644", b"100755"), row
            relative = os.fsdecode(raw_name)
            content = (library / relative).read_bytes()
            assert hashlib.sha1(b"blob " + str(len(content)).encode() + b"\0" + content).hexdigest() == oid.decode(), relative
            target = vendored / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)
            target.chmod(0o755 if mode == b"100755" else 0o644)
            source_count += 1
            source_bytes += len(content)
        (bundle / "bin").mkdir()
        (bundle / "specs").mkdir()
        for name in ("parse_words.lua", "parse-words"):
            shutil.copy2(package / "bin" / name, bundle / "bin" / name)
        for source, name in ((grammar, "word.spec"), (diagnostic, "diagnostics.spec"), (exit_spec, "exit.spec")):
            shutil.copy2(source, bundle / "specs" / name)
        bundled_native = bundle / "build/native" / args.runtime
        bundled_native.mkdir(parents=True)
        for name in ("linkedspec_regex_pcre2.so", "linkedspec_filesystem_native.so"):
            shutil.copy2(native / name, bundled_native / name)
        assert not (bundled_native / "linkedspec_mcp_system.so").exists()
        hashes = {p.relative_to(bundle): hashlib.sha256(p.read_bytes()).hexdigest()
                  for p in bundle.rglob("*") if p.is_file()}

        def launcher(at):
            return ["/bin/bash", str(at / "bin/parse-words"), args.runtime]

        run("packaged source and two native modules", [bundle / "specs/word.spec", "alpha", "Beta"],
            work, [["alpha"], ["Beta"]], selected=launcher(bundle))
        moved = work / "moved 雪 bundle"
        bundle.rename(moved)
        for relative in hashes:
            path = moved / relative
            path.chmod(0o555 if path.stat().st_mode & 0o111 else 0o444)
        run("moved bundle outside cwd with read-only source files", [moved / "specs/word.spec", "one two"],
            work, [["one", "two"]], selected=launcher(moved))
        local = work / "caller 雪.spec"
        local.write_bytes(grammar.read_bytes())
        run("moved bundle caller-relative grammar", [local.name, "alpha"], work, [["alpha"]], selected=launcher(moved))
        run("packaged Unicode diagnostic events", ["--diagnostics", moved / "specs/diagnostics.spec", "x"],
            work, ["ok"], events, selected=launcher(moved))
        run("packaged typed exit and stop behavior", ["--diagnostics", moved / "specs/exit.spec", "x", "y", "x"],
            work, ["ok"], exit_records, status=1, selected=launcher(moved))
        (work / "specs").mkdir()
        (work / "specs/user_function_definition.spec").write_text("invalid caller grammar\n", encoding="utf-8")
        run("packaged supporting grammar ignores caller copy", [local, "alpha"], work, [["alpha"]], selected=launcher(moved))
        support = moved / "vendor/linkedspec/specs/user_function_definition.spec"
        saved = support.read_bytes()
        support.chmod(0o644)
        support.write_text("invalid packaged grammar\n", encoding="utf-8")
        try:
            run("invalid packaged supporting grammar is selected", [local, "alpha"], work, [],
                [{"type": "spec_pipeline_error"}], status=1, selected=launcher(moved))
        finally:
            support.write_bytes(saved)
            support.chmod(0o444)
        for relative, detail in (("vendor/linkedspec/specs/user_function_definition.spec", "Missing packaged specs/user_function_definition.spec"),
                                 ("build/native/" + args.runtime + "/linkedspec_regex_pcre2.so", "Missing selected native parsing modules")):
            target = moved / relative
            held = target.with_name(target.name + ".held")
            target.rename(held)
            try:
                run("missing packaged " + target.name, [local, "alpha"], work, [],
                    [{"type": "deployment_error", "detail": detail}], status=1, selected=launcher(moved))
            finally:
                held.rename(target)
        run("invalid ABI selector", [local, "alpha"], work, [], [{"type": "deployment_error"}], status=1,
            selected=["/bin/bash", str(moved / "bin/parse-words"), "unknown"])
        for relative, digest in hashes.items():
            assert hashlib.sha256((moved / relative).read_bytes()).hexdigest() == digest, relative
        assert all(p.stat().st_dev == root.stat().st_dev for p in moved.rglob("*"))
        checks.append("all packaged source and native bytes preserved after move and controls")
    assert not work.exists()
    assert product_state() == baseline
    print(json.dumps({"status": "PASS", "runtime": args.runtime, "checks": checks, "check_count": len(checks),
        "runtime_source_files": source_count, "runtime_source_bytes": source_bytes, "bundle_files": len(hashes),
        "native_products_unchanged": True, "native_builds": 0, "fixture_cleanup": True}, ensure_ascii=False))


if __name__ == "__main__":
    main()
