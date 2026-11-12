"""Retain own Lua parsed/payload projections and runtime traces before repair."""
import gzip
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import traceback

sys.dont_write_bytecode = True
ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
spec = importlib.util.spec_from_file_location('owned_transform_lua_trace_io', ROOT / BASE / 'proof_io.py')
proof = importlib.util.module_from_spec(spec)
spec.loader.exec_module(proof)
OUT = BASE / 'trace'
OUT.mkdir()
try:
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'fff959ef7e8896b5b97f311a276cabc4f5034551'
    cases = json.loads((BASE / 'trace-sources.json').read_bytes())
    assert len(cases) == 9
    (OUT / 'cases.json').write_bytes((BASE / 'trace-sources.json').read_bytes())
    paths = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'lua', 'tests/fixtures'], text=True).splitlines()]
    paths += [proof.FIXTURE, Path('lua/test/callable_array_transform_observation.lua'), OUT / 'cases.json']
    paths += [p for p in BASE.iterdir() if p.is_file() and p.suffix in ('.py', '.lua', '.json', '.gz')]
    paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh', 'run_lua_project_data.sh', 'build_lua_native.sh')]
    paths += [BASE / 'intake' / host / name for host in proof.HOSTS for name in ('native-identities.json', 'native-before-first-run.tar.gz')]
    inputs = proof.freeze(OUT, paths)
    for host in proof.HOSTS:
        target = OUT / host
        target.mkdir()
        runtime = os.environ.get('LINKEDSPEC_LUA_CMD' if host == 'puc' else 'LINKEDSPEC_LUAJIT_CMD', 'lua' if host == 'puc' else 'luajit')
        environment = {key: value for key, value in os.environ.items() if not key.startswith(('LUA_INIT', 'LUA_PATH_', 'LUA_CPATH_'))}
        environment.update(LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;',
            LUA_CPATH=str(target / 'native/?.so') + ';;', LINKEDSPEC_LUA_TEST_RUNTIME=runtime)
        memory = proof.execute(target, 'memory', ['bash', 'tools/project_data_run.sh', 'memory_pressure'], environment)
        free = re.search(rb'System-wide memory free percentage: (\d+)%', memory.stdout)
        assert memory.returncode == 0 and free and int(free[1]) >= 30
        native, products = proof.build_native(target, host, environment)
        result = proof.execute(target, 'trace', ['bash', 'tools/project_data_run.sh', runtime,
            str(BASE / 'trace.lua'), str(OUT / 'cases.json'), str(target)], environment)
        assert result.returncode == 0, 'Actual trace failure retained; do not replay'
        rows = proof.frames(result.stdout, 'CALLABLE_TRANSFORM_LUA_TRACE')
        assert list(rows) == [row['id'] for row in cases]
        files = list(target.glob('*.trace.log')) + list(target.glob('*.parsed.json')) + list(target.glob('*.compiled.json'))
        assert len(files) == 27
        proof.freeze(target, files, 'artifact', 'actual-trace-inputs.tar.gz')
        proof.verify(products)
        proof.verify(inputs)
        for name in products:
            Path(name).unlink()
        native.rmdir()
        print(host + ': nine public parsed/compiled-payload/runtime trace inputs and exact cold native images retained', flush=True)
    (OUT / 'complete.txt').write_text('Both installed host nine public trace epochs complete.\n')
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
