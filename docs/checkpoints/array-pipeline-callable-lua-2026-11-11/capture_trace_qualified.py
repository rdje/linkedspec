"""Capture bounded public AST/runtime traces with exact cold native products."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
spec = importlib.util.spec_from_file_location('owned_trace_io', ROOT / BASE / 'proof_io.py')
proof = importlib.util.module_from_spec(spec)
spec.loader.exec_module(proof)
OUT = BASE / 'traceq'
OUT.mkdir()
keys = ['trim_each_free_hash_guard', 'trim_each_receiver_hash_guard', 'trim_later_with',
    'own_signature_variadic_multi_composed', 'own_pattern_literal_composed',
    'own_pattern_block_composed', 'own_signature_fixed_missing_composed', 'lower_logical_later_with']
cases = {row['id']: row for row in json.loads((BASE / 'cases.json').read_bytes())}
source = OUT / 'cases.json'
source.write_text(json.dumps([cases[key] for key in keys], indent=2) + '\n')
paths = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'lua', 'tests/fixtures'], text=True).splitlines()]
paths += [Path('lua/test/callable_array_pipeline_observation.lua'), proof.NORMAL, proof.FIXTURE, proof.PROFILE,
    proof.GRAMMAR, BASE / 'proof_io.py', BASE / 'trace_qualified.lua', BASE / 'capture_trace_qualified.py', source]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'build_lua_native.sh')]
paths += [BASE / 'intake' / host / name for host in proof.HOSTS for name in ('native-identities.json', 'native-before-first-run.tar.gz')]
inputs = proof.freeze(OUT, paths)
for host in proof.HOSTS:
    target = OUT / host
    target.mkdir()
    runtime = os.environ.get('LINKEDSPEC_LUA_CMD' if host == 'puc' else 'LINKEDSPEC_LUAJIT_CMD', 'lua' if host == 'puc' else 'luajit')
    environment = {key: value for key, value in os.environ.items() if not key.startswith(('LUA_INIT', 'LUA_PATH_', 'LUA_CPATH_'))}
    environment.update(LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;', LUA_CPATH=str(target / 'native/?.so') + ';;',
        LINKEDSPEC_LUA_TEST_RUNTIME=runtime)
    native, products = proof.build_native(target, host, environment)
    result = proof.execute(target, 'trace', ['bash', 'tools/project_data_run.sh', runtime, str(BASE / 'trace_qualified.lua'), str(source), str(target)], environment)
    assert result.returncode == 0 and result.stderr == b''
    rows = proof.frames(result.stdout, 'CALLABLE_PIPELINE_LUA_TRACE')
    assert list(rows) == keys
    files = list(target.glob('*.trace.log')) + list(target.glob('*.parsed.json')) + list(target.glob('*.compiled.json'))
    assert len(files) == 3 * len(keys)
    proof.freeze(target, files, 'artifact', 'actual-trace-inputs.tar.gz')
    proof.verify(products)
    for name in products:
        Path(name).unlink()
    native.rmdir()
    print(host, 'eight public parse/compiled AST/runtime traces retained', flush=True)
proof.verify(inputs)
(OUT / 'complete.txt').write_text('Both installed host public trace epochs complete.\n')
