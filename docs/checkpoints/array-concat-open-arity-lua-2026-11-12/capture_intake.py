"""Acquire each actual installed Lua host with native bodies before first SDK load."""
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
ACTIVATION = 'fb613736f68f7d1f90df5ade3c0e73c98160ca3f'
spec = importlib.util.spec_from_file_location('owned_transform_lua_proof_io', ROOT / BASE / 'proof_io.py')
proof = importlib.util.module_from_spec(spec)
spec.loader.exec_module(proof)
OUT = BASE / 'intake'
OUT.mkdir()
try:
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    (OUT / 'activation.txt').write_text(ACTIVATION + '\n')
    (OUT / 'cases.json').write_bytes(proof.FIXTURE.read_bytes())
    cases = json.loads(proof.FIXTURE.read_bytes())
    assert len(cases) == 508
    paths = [Path(p) for p in json.loads((BASE / 'selected-inputs.json').read_bytes())]
    paths += [proof.FIXTURE, OUT / 'cases.json']
    paths += [p for p in BASE.iterdir() if p.is_file() and p.suffix in ('.py', '.lua', '.json', '.gz')]
    records = proof.freeze(OUT, paths)
    for host in proof.HOSTS:
        target = OUT / host
        target.mkdir()
        for name in ('emitted', 'parsed'):
            (target / name).mkdir()
        runtime = os.environ.get('LINKEDSPEC_LUA_CMD' if host == 'puc' else 'LINKEDSPEC_LUAJIT_CMD', 'lua' if host == 'puc' else 'luajit')
        environment = {key: value for key, value in os.environ.items() if not key.startswith(('LUA_INIT', 'LUA_PATH_', 'LUA_CPATH_'))}
        environment.update(LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;',
            LUA_CPATH=str(target / 'native/?.so') + ';;', LINKEDSPEC_LUA_TEST_RUNTIME=runtime,
            LINKEDSPEC_ARRAY_CONCAT_CAPTURE=str(target), LINKEDSPEC_ARRAY_CONCAT_INPUT_ROOT='')
        memory = proof.execute(target, 'memory', ['bash', 'tools/project_data_run.sh', 'memory_pressure'], environment)
        assert memory.returncode == 0
        free = re.search(rb'System-wide memory free percentage: (\d+)%', memory.stdout)
        assert free and int(free[1]) >= 45, 'Defer native/SDK job: conservative4GiB peak plus headroom unavailable'
        version = proof.execute(target, 'version', ['bash', 'tools/project_data_run.sh', runtime, '-v'], environment)
        assert version.returncode == 0
        headers = proof.execute(target, 'headers', ['bash', 'tools/project_data_run.sh', 'pkg-config', '--modversion', 'lua' if host == 'puc' else 'luajit', 'libpcre2-8'], environment)
        assert headers.returncode == 0
        banner = version.stdout + version.stderr
        identity = re.search(rb'Lua ([0-9]+\.[0-9]+\.[0-9]+)' if host == 'puc' else rb'LuaJIT ([0-9]+\.[0-9]+\.[0-9]+)', banner)
        assert identity and identity[1].decode() == headers.stdout.decode().splitlines()[0], 'Actual interpreter/header identities differ; retain and review before loading'
        native, native_rows = proof.build_native(target, host, environment)
        result = proof.execute(target, 'normal', ['bash', 'tools/project_data_run.sh', runtime,
            str(BASE / 'observer.lua'), str(OUT / 'cases.json'), str(target)], environment)
        assert result.returncode == 0, 'Actual native acquisition failure retained; do not replay'
        rows = proof.frames(result.stdout, 'ARRAY_CONCAT_LUA')
        assert list(rows) == [row['id'] for row in cases]
        assert all(set(row) == {'native', 'restored', 'plan', 'fresh'} for row in rows.values())
        assert b'ARRAY_CONCAT_LUA_OWNER @lua/src/linkedspec/interpreter.lua\n' in result.stdout
        proof.verify(records)
        proof.verify(native_rows)
        proof.artifacts(target)
        metadata = json.loads((target / 'artifact-identities.json').read_bytes())
        assert len(metadata) == 1016
        for name in native_rows:
            Path(name).unlink()
        native.rmdir()
        print(json.dumps(dict(host=host, programs=508, routes=4, actual_pairs=508,
            interpreter_header=identity[1].decode(), memory_free_before_percent=int(free[1]),
            native_stderr_bytes=len(result.stderr))), flush=True)
    proof.verify(records)
    assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'lua/src', 'lua/test/run.lua']) == b''
    (OUT / 'complete.txt').write_text('Both installed host original508 four-route epochs complete with actual native bodies retained before loading.\n')
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
