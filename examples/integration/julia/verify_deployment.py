"""Verify Julia diagnostics and a relocated, offline source application.

Prepare the maintained application's depot first. Deployment copies its verified
package sources and registry, then lets Julia prepare a new local compiled cache.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import tomllib


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
        for path in sorted(directory.rglob("*")) if path.is_file()
    }


def environment_for(package):
    data = package / ".app-data/linkedspec"
    scratch = data / "scratch/tmp"
    return dict(os.environ, LINKEDSPEC_PROJECT_DATA_ROOT=str(data),
        LINKEDSPEC_CACHE_ROOT=str(data / "cache"), LINKEDSPEC_SCRATCH_ROOT=str(data / "scratch"),
        JULIA_DEPOT_PATH=str(data / "cache/julia-depot") + ":",
        LINKEDSPEC_JULIA_DEPOT_PATH=str(data / "cache/julia-depot") + ":",
        JULIA_LOAD_PATH="@:@stdlib", JULIA_PKG_OFFLINE="true",
        TMPDIR=str(scratch), TMP=str(scratch), TEMP=str(scratch))


def main():
    root = Path(__file__).resolve().parents[3]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument("--library-root", type=Path, default=root)
    parser.add_argument("--grammar", type=Path, default=root / "examples/integration/word.spec")
    parser.add_argument("--fixtures", type=Path, help="Directory containing diagnostics.spec and exit.spec")
    parser.add_argument("--bash", help="Host Bash executable for the deployed launcher")
    args = parser.parse_args()
    package = args.package.resolve(strict=True)
    library = args.library_root.resolve(strict=True)
    grammar = args.grammar.resolve(strict=True)
    fixtures = (args.fixtures or package).resolve(strict=True)
    scratch = Path(os.environ["TMPDIR"]).resolve(strict=True)
    bash = shutil.which(args.bash or "bash")
    assert bash is not None
    for path in (package, library, grammar, fixtures, scratch):
        assert path.stat().st_dev == root.stat().st_dev, path
    environment = environment_for(package)
    source_command = [bash, str(library / "tools/run_julia_project_data.sh"),
        "--project=" + str(package), str(package / "bin/parse_words.jl")]
    checks = []
    timings = {}
    preparations = {}

    def run(label, command, arguments, cwd, values, records=(), status=0, env=None):
        started = time.monotonic()
        result = subprocess.run(command + [str(arg) for arg in arguments], cwd=cwd,
            env=environment if env is None else env, capture_output=True, timeout=240, check=False)
        timings[label] = round(time.monotonic() - started, 3)
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

    def prepare(app, label):
        selected = app / "vendor/linkedspec"
        started = time.monotonic()
        result = subprocess.run([bash, str(selected / "tools/run_julia_project_data.sh"),
            "--project=" + str(app), "-e", '''using Pkg
Pkg.instantiate()
using LinkedSpecJulia, JSON3
println(JSON3.write(Dict("sdk" => string(VERSION), "project" => Base.active_project(),
    "library" => pathof(LinkedSpecJulia), "json3" => pathof(JSON3), "depots" => DEPOT_PATH)))
'''], cwd=app, env=environment_for(app), capture_output=True, timeout=600, check=False)
        assert result.returncode == 0, (label, result)
        provenance = json.loads(result.stdout)
        depot = app / ".app-data/linkedspec/cache/julia-depot"
        assert Path(provenance["project"]).resolve() == app / "Project.toml", provenance
        assert Path(provenance["library"]).resolve() == selected / "julia/src/LinkedSpecJulia.jl", provenance
        assert Path(provenance["json3"]).resolve().is_relative_to(depot / "packages"), provenance
        assert Path(provenance["depots"][0]).resolve() == depot, provenance
        manifest = tomllib.loads((app / "Manifest.toml").read_text())
        assert manifest["deps"]["LinkedSpecJulia"][0]["path"] == "vendor/linkedspec/julia"
        original = tomllib.loads((package / "Manifest.toml").read_text())
        registry_versions = lambda value: {name: (entries[0]["version"], entries[0]["git-tree-sha1"])
            for name, entries in value["deps"].items() if "git-tree-sha1" in entries[0]}
        assert registry_versions(manifest) == registry_versions(original)
        preparations[label] = {"seconds": round(time.monotonic() - started, 3),
            "sdk": provenance["sdk"], "stderr_bytes": len(result.stderr),
            "registry_versions": registry_versions(manifest)}
        checks.append(label)

    with tempfile.TemporaryDirectory(prefix="julia-deployment-", dir=scratch) as name:
        work = Path(name)
        diagnostic = fixtures / "diagnostics.spec"
        exiting = fixtures / "exit.spec"
        for filename, contents in {
            "parse.spec": b"not a spec\n", "empty.spec": b"# no rules\n", "invalid.spec": b"\xff",
            "arity.spec": b'Top::\n -> Hit { say(); return("late") }\nHit:\n /x/\n',
            "null.spec": b'Top::\n -> Hit { return(undef) }\nHit:\n /x/\n',
        }.items():
            (work / filename).write_bytes(contents)
        events = [
            {"type": "diagnostic_output", "helper_name": "say", "rule_label": "Top", "message": "héllo 雪\n"},
            {"type": "diagnostic_output", "helper_name": "print", "rule_label": "Top", "message": "done"},
        ]
        before_exit = {"type": "diagnostic_output", "helper_name": "say", "rule_label": "Top", "message": "before\n"}
        typed_exit = {"type": "runtime_exit_now", "status": 7}
        run("source: quiet helpers and independent calls", source_command, [diagnostic, "x", "x"], work, ["ok", "ok"])
        run("source: ordered Unicode events", source_command, ["--diagnostics", diagnostic, "x"], work, ["ok"], events)
        run("source: typed exit preserves prior output and stops input loop", source_command,
            ["--diagnostics", exiting, "x", "y", "x"], work, ["ok"], [before_exit, typed_exit], 1)
        run("source: quiet typed exit", source_command, [exiting, "y"], work, [], [typed_exit], 1)
        run("source: runtime arity and source identity", source_command, [work / "arity.spec", "x"], work, [],
            [{"type": "runtime_error", "diagnostic": {"stage": "helper_arity_mismatch", "rule_label": "Top",
                "spec_path": str(work / "arity.spec")}}], 1)
        run("source: successful null", source_command, [work / "null.spec", "x"], work, [None])
        for filename, stage, code in (
            ("absent.spec", "resolve_spec_path", "spec_path_not_found"),
            ("invalid.spec", "decode_spec_content", "invalid_utf8"),
            ("parse.spec", "parse_spec", "spec_parse_failed"),
            ("empty.spec", "validate_spec", "no_rules_defined"),
        ):
            run("source: " + code, source_command, [work / filename, "x"], work, [],
                [{"type": "spec_pipeline_error", "stage": stage, "code": code}], 1)
        run("source: missing arguments", source_command, ["--diagnostics"], work, [], [{"type": "consumer_error"}], 1)
        sentinel = work / "trace.log"
        sentinel.write_bytes(b"preserve trace sentinel\n")
        inherited = dict(environment, LINKEDSPEC_TRACE_LEVEL="500", LINKEDSPEC_TRACE_MODE="mirror",
            LINKEDSPEC_TRACE_FILE=str(sentinel), LINKEDSPEC_TRACE_RESET="1")
        run("source: inherited trace configuration remains separate", source_command,
            [diagnostic, "x"], work, ["ok"], env=inherited)
        assert sentinel.read_bytes() == b"preserve trace sentinel\n"

        bundle = work / "application"
        vendor = bundle / "vendor/linkedspec"
        # Use the documented Git archive route, pinned to this checkout's committed source.
        revision = subprocess.check_output(["git", "-C", str(library), "rev-parse", "HEAD"], text=True).strip()
        tracked = subprocess.check_output(["git", "-C", str(library), "ls-tree", "-r", "-z", revision])
        vendor.mkdir(parents=True)
        archive = work / "source.tar"
        with archive.open("wb") as output:
            subprocess.run(["git", "-C", str(library), "archive", "--format=tar", revision], stdout=output, check=True)
        subprocess.run(["tar", "-xf", str(archive), "-C", str(vendor)], check=True)
        archive.unlink()
        library_paths = []
        for record in tracked.split(b"\0"):
            if not record:
                continue
            metadata, encoded_path = record.split(b"\t", 1)
            mode = metadata.split()[0]
            if mode == b"160000":
                continue
            assert mode in (b"100644", b"100755"), record
            relative = Path(os.fsdecode(encoded_path))
            assert (vendor / relative).is_file(), relative
            library_paths.append(relative)
        for directory in ("bin", "specs"):
            (bundle / directory).mkdir()
        for filename in ("parse_words.jl", "parse-words"):
            shutil.copy2(package / "bin" / filename, bundle / "bin" / filename)
        for source, filename in ((grammar, "word.spec"), (diagnostic, "diagnostics.spec"), (exiting, "exit.spec")):
            shutil.copy2(source, bundle / "specs" / filename)
        (bundle / "--diagnostics").write_bytes(grammar.read_bytes())
        original_project = (package / "Project.toml").read_text()
        original_path = tomllib.loads(original_project)["sources"]["LinkedSpecJulia"]["path"]
        assert original_project.count('path = "' + original_path + '"') == 1
        (bundle / "Project.toml").write_text(original_project.replace(
            'path = "' + original_path + '"', 'path = "vendor/linkedspec/julia"'))
        # A separately assembled app already has the deployable relative source path.
        # The in-repository example needs Pkg to generate its bundle's local-path entry.
        manifest = tomllib.loads((package / "Manifest.toml").read_text())
        copied_manifest = manifest["deps"]["LinkedSpecJulia"][0]["path"] == "vendor/linkedspec/julia"
        if copied_manifest:
            shutil.copy2(package / "Manifest.toml", bundle / "Manifest.toml")
        original_depot = package / ".app-data/linkedspec/cache/julia-depot"
        depot = bundle / ".app-data/linkedspec/cache/julia-depot"
        source_hashes = {}
        for directory in ("packages", "registries"):
            shutil.copytree(original_depot / directory, depot / directory)
            source_hashes[directory] = hashes(original_depot / directory)
            assert hashes(depot / directory) == source_hashes[directory]
        assert not (depot / "compiled").exists()
        prepare(bundle, "bundle: offline preparation from retained source without copied compiled cache")
        if copied_manifest:
            assert (bundle / "Manifest.toml").read_bytes() == (package / "Manifest.toml").read_bytes()
        app_files = [Path(name) for name in ("Project.toml", "Manifest.toml", "bin/parse_words.jl", "bin/parse-words",
            "specs/word.spec", "specs/diagnostics.spec", "specs/exit.spec", "--diagnostics")]
        snapshot = lambda app: {str(path): hashlib.sha256((app / path).read_bytes()).hexdigest()
            for path in app_files + [Path("vendor/linkedspec") / path for path in library_paths]}
        baseline = snapshot(bundle)
        caller = work / "caller é"
        (caller / "specs").mkdir(parents=True)
        (caller / "specs/user_function_definition.spec").write_text("not a spec\n", encoding="utf-8")
        launcher = lambda: [bash, str(bundle / "bin/parse-words")]
        run("bundle: application-relative grammar from outside cwd", launcher(),
            ["specs/word.spec", "alpha", "Beta", "123"], caller, [["alpha"], ["Beta"], []])
        run("bundle: literal option-like grammar", launcher(), ["--", "--diagnostics", "alpha"], caller, [["alpha"]])
        asset = vendor / "specs/user_function_definition.spec"
        support_bytes = asset.read_bytes()
        asset.write_text("not a spec\n", encoding="utf-8")
        try:
            run("bundle: bad packaged support grammar is selected", launcher(), ["specs/word.spec", "alpha"], caller, [],
                [{"type": "spec_pipeline_error", "stage": "parse_spec", "code": "spec_parse_failed"}], 1)
        finally:
            asset.write_bytes(support_bytes)
        asset.unlink()
        try:
            run("bundle: missing packaged grammar fails before ancestor lookup", launcher(),
                ["specs/word.spec", "alpha"], caller, [],
                [{"type": "deployment_error", "detail": "Missing packaged specs/user_function_definition.spec"}], 1)
        finally:
            asset.write_bytes(support_bytes)
        assert snapshot(bundle) == baseline
        moved = work / "moved 雪" / "application"
        moved.parent.mkdir()
        bundle.rename(moved)
        bundle = moved
        prepare(bundle, "moved bundle: offline preparation preserves package versions")
        run("moved bundle: independent and repeated values", launcher(), ["specs/word.spec", "alpha", "Beta", "alpha"],
            caller, [["alpha"], ["Beta"], ["alpha"]])
        run("moved bundle: fresh process reuses prepared depot", launcher(), ["specs/word.spec", "alpha"], caller, [["alpha"]])
        run("moved bundle: exact Unicode diagnostic events", launcher(), ["--diagnostics", "specs/diagnostics.spec", "x"],
            caller, ["ok"], events)
        run("moved bundle: typed exit keeps prior output", launcher(), ["--diagnostics", "specs/exit.spec", "x", "y", "x"],
            caller, ["ok"], [before_exit, typed_exit], 1)
        run("moved bundle: absolute Unicode grammar", launcher(), [bundle / "specs/word.spec", "one two"], caller, [["one", "two"]])
        assert snapshot(bundle) == baseline
        for directory in source_hashes:
            assert hashes(bundle / ".app-data/linkedspec/cache/julia-depot" / directory) == source_hashes[directory]
        assert not any((bundle / "vendor/linkedspec/rgx").rglob("*"))
        assert all(path.stat().st_dev == root.stat().st_dev for path in work.rglob("*"))
        checks.append("source, manifest and package bytes survive relocation on the repository volume")
    assert not work.exists()
    print(json.dumps({"status": "PASS", "checks": checks, "check_count": len(checks),
        "copied_library_files": len(library_paths), "library_revision": revision,
        "copied_application_manifest": copied_manifest, "preparations": preparations,
        "elapsed_seconds": timings, "fixture_cleanup": True,
        "deployment_shell_version": subprocess.check_output([bash, "--version"], text=True).splitlines()[0]}, ensure_ascii=False))


if __name__ == "__main__":
    main()
