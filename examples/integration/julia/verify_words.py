"""Verify Julia application setup, source provenance and native parser values."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import tomllib


def main():
    root = Path(__file__).resolve().parents[3]
    options = argparse.ArgumentParser(description=__doc__)
    options.add_argument("--package", type=Path, default=Path(__file__).resolve().parent)
    options.add_argument("--library-root", type=Path, default=root)
    options.add_argument("--grammar", type=Path, default=root / "examples/integration/word.spec")
    args = options.parse_args()
    package = args.package.resolve(strict=True)
    library = args.library_root.resolve(strict=True)
    grammar = args.grammar.resolve(strict=True)
    data = package / ".app-data/linkedspec"
    scratch = data / "scratch/tmp"
    scratch.mkdir(parents=True, exist_ok=True)
    depot = data / "cache/julia-depot"
    environment = dict(os.environ, LINKEDSPEC_PROJECT_DATA_ROOT=str(data),
        LINKEDSPEC_CACHE_ROOT=str(data / "cache"), LINKEDSPEC_SCRATCH_ROOT=str(data / "scratch"),
        JULIA_DEPOT_PATH=str(depot) + ":", LINKEDSPEC_JULIA_DEPOT_PATH=str(depot) + ":",
        JULIA_LOAD_PATH="@:@stdlib", JULIA_PKG_OFFLINE="true",
        TMPDIR=str(scratch), TMP=str(scratch), TEMP=str(scratch))
    wrapper = ["bash", str(library / "tools/run_julia_project_data.sh"), "--project=" + str(package)]
    probe = '''using Pkg
Pkg.instantiate()
using LinkedSpecJulia, JSON3
println(JSON3.write(Dict(
    "sdk" => string(VERSION), "project" => Base.active_project(),
    "library" => pathof(LinkedSpecJulia), "json3" => pathof(JSON3),
    "depots" => DEPOT_PATH, "load_path" => LOAD_PATH,
    "support" => LinkedSpecJulia._user_function_definition_spec_path(),
)))
'''
    setup = subprocess.run(wrapper + ["-e", probe], cwd=package, env=environment,
        capture_output=True, timeout=300, check=False)
    assert setup.returncode == 0, setup
    provenance = json.loads(setup.stdout)
    assert Path(provenance["project"]).resolve() == package / "Project.toml", provenance
    assert Path(provenance["library"]).resolve() == library / "julia/src/LinkedSpecJulia.jl", provenance
    assert Path(provenance["json3"]).resolve().is_relative_to(depot / "packages/JSON3"), provenance
    assert Path(provenance["depots"][0]).resolve() == depot, provenance
    assert provenance["load_path"] == ["@", "@stdlib"], provenance
    assert Path(provenance["support"]).resolve() == library / "specs/user_function_definition.spec", provenance
    manifest = tomllib.loads((package / "Manifest.toml").read_text())
    source_path = Path(manifest["deps"]["LinkedSpecJulia"][0]["path"])
    assert not source_path.is_absolute() and (package / source_path).resolve() == library / "julia"
    versions = {name: entries[0]["version"] for name, entries in manifest["deps"].items()
                if "git-tree-sha1" in entries[0]}
    checked = ["offline preparation, explicit project and application-local package provenance"]
    command = wrapper + [str(package / "bin/parse_words.jl")]
    timings = {}

    def run(label, arguments, cwd, expected=None, error=None):
        started = time.monotonic()
        result = subprocess.run(command + [str(arg) for arg in arguments], cwd=cwd,
            env=environment, capture_output=True, timeout=180, check=False)
        timings[label] = round(time.monotonic() - started, 3)
        if error is None:
            assert result.returncode == 0 and result.stderr == b"", (label, result)
            assert [json.loads(line) for line in result.stdout.splitlines()] == expected, (label, result.stdout)
        else:
            assert result.returncode == 1 and result.stdout == b"", (label, result)
            record = json.loads(result.stderr)
            for key, value in error.items():
                assert record[key] == value, (label, record)
        checked.append(label)

    with tempfile.TemporaryDirectory(prefix="julia-integration-é-", dir=scratch) as directory:
        work = Path(directory)
        # Package-source ancestors take priority over this deliberately bad cwd asset.
        specs = work / "specs"
        specs.mkdir()
        (specs / "user_function_definition.spec").write_text("not a spec\n", encoding="utf-8")
        selection = subprocess.run(wrapper + ["-e", '''using LinkedSpecJulia, JSON3
cd(ARGS[1])
loaded = load_and_compile_spec(path_spec_request(ARGS[2]), SpecLoadOptions(; cwd = pwd()))
println(JSON3.write(Dict("support" => LinkedSpecJulia._user_function_definition_spec_path(),
    "value" => runtime_execute(create_engine(loaded), "alpha"; top_rule = "Top").value)))
''', str(work), str(grammar)], cwd=work, env=environment, capture_output=True,
            timeout=180, check=False)
        assert selection.returncode == 0 and selection.stderr == b"", selection
        selected = json.loads(selection.stdout)
        assert Path(selected["support"]).resolve() == library / "specs/user_function_definition.spec", selected
        assert selected["value"] == ["alpha"], selected
        checked.append("package-owned support grammar takes priority over controlled bad cwd asset")
        run("independent values and repeated input", [grammar, "alpha", "Beta", "123",
            "123 alpha rest", "", "alpha", "café"], work,
            expected=[["alpha"], ["Beta"], [], ["alpha", "rest"], [], ["alpha"], ["caf"]])
        relative_grammar = Path(os.path.relpath(grammar, package))
        run("application-relative grammar from outside cwd", [relative_grammar, "one two"], work,
            expected=[["one", "two"]])
        local = work / "grammar é.spec"
        local.write_bytes(grammar.read_bytes())
        run("absolute Unicode grammar path", [local, "one two"], work, expected=[["one", "two"]])
        run("missing grammar", [work / "absent.spec", "x"], work,
            error={"type": "spec_pipeline_error", "stage": "resolve_spec_path", "code": "spec_path_not_found"})
        invalid = work / "invalid.spec"
        invalid.write_bytes(b"\xff")
        run("strict UTF-8 grammar", [invalid, "x"], work,
            error={"type": "spec_pipeline_error", "stage": "decode_spec_content", "code": "invalid_utf8"})
        run("missing arguments", [], work, error={"type": "consumer_error"})
        run("missing input", [grammar], work, error={"type": "consumer_error"})
        null = work / "null.spec"
        null.write_text('Top::\n /x/\n E { return(undef) }\n', encoding="utf-8")
        run("successful null result", [null, "x"], work, expected=[None])
        run("fresh process reuses prepared package depot", [grammar, "alpha", "Beta"], work,
            expected=[["alpha"], ["Beta"]])
    assert not work.exists()
    assert all(path.stat().st_dev == root.stat().st_dev for path in data.rglob("*"))
    print(json.dumps({"status": "PASS", "checks": checked, "fixture_cleanup": True,
        "sdk": provenance["sdk"], "external_package_versions": versions, "elapsed_seconds": timings}))


if __name__ == "__main__":
    main()
