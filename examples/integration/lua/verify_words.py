"""Verify a prepared PUC Lua or LuaJIT consumer without rebuilding native modules."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time


PROBE = r'''
local root = assert(os.getenv("LINKEDSPEC_REPO_ROOT"))
local native = assert(os.getenv("LINKEDSPEC_LUA_NATIVE_ROOT"))
package.path = root .. "/lua/src/?.lua;" .. root .. "/lua/src/?/init.lua"
package.cpath = native .. "/?.so"
local l = require("linkedspec")
local fs = require("linkedspec_filesystem_native")
local j = l.json
local loaded = l.load_and_compile_spec(l.path_spec_request(arg[1]),
  l.spec_load_options({ cwd = fs.current_directory(), search_roots = {} }))
local engine = loaded:create_engine()
local values = j.array({l.runtime_parse(engine, "alpha").value, l.runtime_parse(engine, "Beta").value})
local first = l.user_function_definition_parser_metadata()
l.load_and_compile_spec(l.path_spec_request(arg[1]),
  l.spec_load_options({ cwd = fs.current_directory(), search_roots = {} }))
local second = l.user_function_definition_parser_metadata()
local native_modules = j.array()
for name in pairs(package.loaded) do
  if name:match("^linkedspec_") then native_modules[#native_modules + 1] = name end
end
table.sort(native_modules)
local mcp = require("linkedspec_mcp_system")
io.stdout:write(j.encode(j.harray({
  lua_version = _VERSION, jit_version = jit and jit.version or j.null,
  pcre2_version = l.runtime_regex_engine_version(),
  module_source = debug.getinfo(l.backend_name, "S").source,
  interpreter_source = debug.getinfo(l.runtime_parse, "S").source,
  json_source = debug.getinfo(j.encode, "S").source,
  module_path = package.path, native_path = package.cpath,
  ordinary_native_modules = native_modules, mcp_module_loads = type(mcp) == "table",
  loaded_type = l.spec_loader.node_type(loaded), support = second,
  first_support_build_count = first.build_count, values = values,
})), "\n")
'''


def main():
    root = Path(__file__).resolve().parents[3]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", choices=("puc", "luajit"), required=True)
    parser.add_argument("--package", type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument("--library-root", type=Path, default=root)
    parser.add_argument("--grammar", type=Path, default=root / "examples/integration/word.spec")
    args = parser.parse_args()
    package = args.package.resolve(strict=True)
    library = args.library_root.resolve(strict=True)
    grammar = args.grammar.resolve(strict=True)
    native = package / "build/native" / args.runtime
    names = ("linkedspec_regex_pcre2.so", "linkedspec_filesystem_native.so", "linkedspec_mcp_system.so")
    assert sorted(path.name for path in native.iterdir()) == sorted(names), native
    for name in names:
        path = native / name
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == root.stat().st_dev, path
    products = lambda: {name: {"bytes": (native / name).stat().st_size,
        "mtime_ns": (native / name).stat().st_mtime_ns,
        "sha256": hashlib.sha256((native / name).read_bytes()).hexdigest()} for name in names}
    baseline = products()
    data = package / ".app-data/linkedspec"
    scratch = data / "scratch/tmp"
    scratch.mkdir(parents=True, exist_ok=True)
    for path in (package, library, grammar, native, scratch):
        assert path.stat().st_dev == root.stat().st_dev and not path.is_symlink(), path
    environment = dict(os.environ, LINKEDSPEC_PROJECT_DATA_ROOT=str(data),
        LINKEDSPEC_CACHE_ROOT=str(data / "cache"), LINKEDSPEC_SCRATCH_ROOT=str(data / "scratch"),
        LINKEDSPEC_LUA_NATIVE_ROOT=str(native), TMPDIR=str(scratch), TMP=str(scratch), TEMP=str(scratch))
    interpreter = shutil.which("lua" if args.runtime == "puc" else "luajit")
    assert interpreter is not None
    runtime_banner = subprocess.check_output([interpreter, "-E", "-v"], stderr=subprocess.STDOUT, text=True).strip()
    wrapper = ["bash", str(library / "tools/project_data_run.sh"), interpreter, "-E"]
    command = wrapper + [str(package / "bin/parse_words.lua")]
    checks = []
    timings = {}

    def run(label, arguments, cwd, expected=None, error=None, env=None):
        started = time.monotonic()
        result = subprocess.run(command + [str(arg) for arg in arguments], cwd=cwd,
            env=environment if env is None else env, capture_output=True, timeout=180, check=False)
        timings[label] = round(time.monotonic() - started, 3)
        if error is None:
            assert result.returncode == 0 and result.stderr == b"", (label, result)
            assert [json.loads(line) for line in result.stdout.splitlines()] == expected, (label, result)
        else:
            assert result.returncode == 1 and result.stdout == b"", (label, result)
            record = json.loads(result.stderr)
            for key, value in error.items():
                assert record[key] == value, (label, record)
        checks.append(label)

    with tempfile.TemporaryDirectory(prefix="lua-integration-é-", dir=scratch) as directory:
        work = Path(directory)
        (work / "specs").mkdir()
        (work / "specs/user_function_definition.spec").write_text("not a spec\n", encoding="utf-8")
        probe = work / "provenance.lua"
        probe.write_text(PROBE, encoding="utf-8")
        result = subprocess.run(wrapper + [str(probe), str(grammar)], cwd=work,
            env=environment, capture_output=True, timeout=180, check=False)
        assert result.returncode == 0 and result.stderr == b"", result
        provenance = json.loads(result.stdout)
        assert provenance["values"] == [["alpha"], ["Beta"]], provenance
        assert provenance["loaded_type"] == "LoadedCompiledSpec"
        for key, relative in (("module_source", "init.lua"), ("interpreter_source", "interpreter.lua"),
                              ("json_source", "json.lua")):
            assert Path(provenance[key].removeprefix("@")).resolve() == library / "lua/src/linkedspec" / relative
        assert provenance["module_path"] == str(library / "lua/src/?.lua") + ";" + str(library / "lua/src/?/init.lua")
        assert provenance["native_path"] == str(native / "?.so")
        ordinary_modules = set(provenance["ordinary_native_modules"])
        assert {"linkedspec_regex_pcre2", "linkedspec_filesystem_native"}.issubset(ordinary_modules)
        assert ordinary_modules.issubset({Path(name).stem for name in names})
        assert provenance["mcp_module_loads"]
        assert Path(provenance["support"]["spec_path"]).resolve() == library / "specs/user_function_definition.spec"
        assert provenance["first_support_build_count"] == provenance["support"]["build_count"] == 1
        package_name = "lua" if args.runtime == "puc" else "luajit"
        abi_version = subprocess.check_output(["pkg-config", "--modversion", package_name], text=True).strip()
        pcre2_version = subprocess.check_output(["pkg-config", "--modversion", "libpcre2-8"], text=True).strip()
        if args.runtime == "puc":
            assert runtime_banner.startswith("Lua " + abi_version + " "), runtime_banner
            assert provenance["lua_version"] == "Lua " + ".".join(abi_version.split(".")[:2])
            assert provenance["jit_version"] is None
        else:
            assert runtime_banner.startswith("LuaJIT " + abi_version + " "), runtime_banner
            assert provenance["jit_version"] == "LuaJIT " + abi_version
        assert provenance["pcre2_version"].startswith(pcre2_version), provenance
        checks.append("runtime/header identity, exact module paths, native trio and cached module-owned grammar")
        run("independent and repeated values from outside cwd", [grammar, "alpha", "Beta", "123", "123 alpha rest", "", "alpha", "café"],
            work, expected=[["alpha"], ["Beta"], [], ["alpha", "rest"], [], ["alpha"], ["caf"]])
        local = work / "grammar 雪.spec"
        local.write_bytes(grammar.read_bytes())
        run("caller-relative Unicode grammar", [local.name, "one two"], work, expected=[["one", "two"]])
        run("absolute Unicode grammar", [local, "one two"], work, expected=[["one", "two"]])
        run("missing grammar", [work / "absent.spec", "x"], work,
            error={"type": "spec_pipeline_error", "stage": "resolve_spec_path", "code": "spec_path_not_found"})
        invalid = work / "invalid.spec"
        invalid.write_bytes(b"\xff")
        run("strict UTF-8 grammar", [invalid, "x"], work,
            error={"type": "spec_pipeline_error", "stage": "decode_spec_content", "code": "invalid_utf8"})
        run("missing arguments", [], work, error={"type": "consumer_error"})
        run("missing input", [grammar], work, error={"type": "consumer_error"})
        for literal, value in (("undef", None), ("false", False)):
            fixture = work / (literal + ".spec")
            fixture.write_text('Top::\n -> Hit { return(' + literal + ') }\nHit:\n /x/\n', encoding="utf-8")
            run("successful " + literal + " value", [fixture, "x"], work, expected=[value])
        inherited = dict(environment, LUA_INIT='error("ambient init must be ignored")',
            LUA_INIT_5_5='error("versioned init must be ignored")', LUA_PATH="missing/?.lua", LUA_CPATH="missing/?.so",
            LUA_PATH_5_5="missing/?.lua", LUA_CPATH_5_5="missing/?.so")
        run("explicit paths and -E ignore ambient Lua initialization", [grammar, "alpha"], work,
            expected=[["alpha"]], env=inherited)
        absent_native = work / "no-native"
        absent_native.mkdir()
        missing = subprocess.run(command + [str(grammar), "alpha"], cwd=work,
            env=dict(environment, LINKEDSPEC_LUA_NATIVE_ROOT=str(absent_native)), capture_output=True, timeout=180, check=False)
        assert missing.returncode != 0 and missing.stdout == b"" and b"module 'linkedspec_" in missing.stderr, missing
        checks.append("missing selected native products fail without an ambient fallback")
        run("fresh process reuses retained native products", [grammar, "alpha", "Beta"], work, expected=[["alpha"], ["Beta"]])
    assert not work.exists()
    assert products() == baseline
    assert all(path.stat().st_dev == root.stat().st_dev for path in data.rglob("*"))
    print(json.dumps({"status": "PASS", "runtime": args.runtime, "checks": checks, "check_count": len(checks),
        "runtime_banner": runtime_banner, "lua_version": provenance["lua_version"], "jit_version": provenance["jit_version"],
        "header_package_version": abi_version, "pcre2_version": provenance["pcre2_version"],
        "ordinary_native_modules": provenance["ordinary_native_modules"], "products_unchanged": True,
        "native_products": baseline, "elapsed_seconds": timings, "fixture_cleanup": True}, ensure_ascii=False))


if __name__ == "__main__":
    main()
