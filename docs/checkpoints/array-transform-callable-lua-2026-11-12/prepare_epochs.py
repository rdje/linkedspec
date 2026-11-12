"""Prepare unused Lua normal/inverse/direct and bounded writer instruments."""
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
OLD = ROOT / 'docs/checkpoints/array-pipeline-callable-lua-2026-11-11'

def adapt(text):
    return (text.replace('array-pipeline-callable-lua-2026-11-11', BASE.name)
        .replace('9a6b229ce3f944ef3822e71935b1c40c109f74b9', 'fff959ef7e8896b5b97f311a276cabc4f5034551')
        .replace('pipeline', 'transform').replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform'))

source = adapt((OLD / 'capture.py').read_text())
source = source.replace("assert phase in ('intake', 'before', 'after', 'direct', 'inverse', 'restored')", "assert phase in ('before', 'after', 'direct', 'inverse', 'restored')\nassert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'fff959ef7e8896b5b97f311a276cabc4f5034551'")
start = source.index("    paths = list(source_paths) + [BASE / name for name in (")
end = source.index("    if phase != 'intake':", start)
source = source[:start] + "    paths = list(source_paths) + [p for p in BASE.iterdir() if p.is_file() and p.suffix in ('.py', '.lua', '.json', '.gz')]\n" + source[end:]
anchor = "    source_paths += [FIXTURE, GRAMMAR, Path('lua/test/callable_array_transform_observation.lua'), Path('tests/fixtures/array_transform_callable_result_guard_cases.json')]"
assert source.count(anchor) == 1
source = source.replace(anchor, anchor + "\n    source_paths += [Path('specs/spec.spec'), Path('specs/pplugin.spec')]")
source = source.replace("tests += ['lua/test/array_transform_result_guard_composition_test.lua', 'lua/test/key_count_callable_result_guard_composition_test.lua']", "tests += ['lua/test/array_transform_result_guard_composition_test.lua', 'lua/test/array_pipeline_callable_result_guard_composition_test.lua']")
old_env = "clean_environment = {key: value for key, value in os.environ.items() if not key.startswith(('LUA_INIT', 'LUA_PATH_', 'LUA_CPATH_'))}"
new_env = """clean_environment = {key: value for key, value in os.environ.items()
            if not key.startswith(('LUA_INIT', 'LUA_PATH_', 'LUA_CPATH_')) and key not in (
                'LINKEDSPEC_ARRAY_TRANSFORM_CAPTURE', 'LINKEDSPEC_ARRAY_TRANSFORM_INPUT_ROOT',
                'LINKEDSPEC_CALLABLE_PIPELINE_CAPTURE', 'LINKEDSPEC_CALLABLE_PIPELINE_INPUT_ROOT')}
        # Unchanged older direct normals execute semantically without writing
        # an older packet. Their transient strings gain no new custody credit."""
assert source.count(old_env) == 1
source = source.replace(old_env, new_env)
marker = '        native, native_rows = build_native(target, host, environment)'
preflight = """        memory = execute(target, 'memory', ['bash', 'tools/project_data_run.sh', 'memory_pressure'], environment)
        free = re.search(rb'System-wide memory free percentage: (\\d+)%', memory.stdout)
        assert memory.returncode == 0 and free and int(free[1]) >= 30
"""
assert source.count(marker) == 1
source = source.replace(marker, preflight + marker)
marker = "        verify(records)\n        verify(native_rows)"
check = """        summary = re.search(rb'CALLABLE_TRANSFORM_LUA_SUMMARY ([0-9]+) checks ([0-9]+) failures', result.stdout)
        red = phase in ('before', 'inverse')
        assert summary and summary.groups() == (b'1872', b'124' if red else b'0')
        assert result.returncode == (1 if red else 0)
        if phase == 'direct':
            assert b'ARRAY_TRANSFORM_LUA_SUMMARY 903 checks 0 failures' in result.stdout
            assert b'CALLABLE_PIPELINE_LUA_SUMMARY 1164 checks 0 failures' in result.stdout
"""
assert source.count(marker) == 1
source = source.replace(marker, check + marker)
(BASE / 'capture_epochs.py').write_text(source)

repair = adapt((OLD / 'repair.py').read_text()).replace("'traceq/complete.txt'", "'trace/complete.txt'")
repair = repair.replace('Both installed host public trace epochs complete.', 'Both installed host nine public trace epochs complete.')
old = 'typed_source.receiver_mutation.is_ordinary_array_transform_arguments(expr.name, expr.args, false)'
assert repair.count(old) == 2
repair = repair.replace(old, 'typed_source.receiver_mutation.is_ordinary_array_transform_arguments(expr.args)')
old = """            assert not target.exists()
            target.write_bytes(gzip.compress(body, mtime=0))
            assert gzip.decompress(target.read_bytes()) == body"""
new = """            if phase == 'before':
                assert gzip.decompress(target.read_bytes()) == body
            else:
                assert not target.exists()
                target.write_bytes(gzip.compress(body, mtime=0))
                assert gzip.decompress(target.read_bytes()) == body"""
assert repair.count(old) == 1
repair = repair.replace(old, new)
(BASE / 'repair.py').write_text(repair)
(BASE / 'run_repair.py').write_text((OLD / 'run_repair.py').read_text().replace("'traceq/complete.txt'", "'trace/complete.txt'"))
print('Prepared Lua per-host1872-check normals/inverses and semantic direct3939, plus classifier/runner writer; production unchanged')
