"""Acquire the narrow native-error projection boundary without changing SDK code."""
import gzip
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
spec = importlib.util.spec_from_file_location('owned_lua_field_probe_io', ROOT / BASE / 'proof_io.py')
proof = importlib.util.module_from_spec(spec)
spec.loader.exec_module(proof)
OUT = BASE / 'fieldprobe'
OUT.mkdir()
keys = {'own_signature_fixed_missing_composed', 'own_needed_source_take_receiver'}
cases = [row for row in json.loads((BASE / 'cases.json').read_bytes()) if row['id'] in keys]
assert len(cases) == 2
(OUT / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
paths = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'lua', 'tests/fixtures'], text=True).splitlines()]
paths += [OUT / 'cases.json', BASE / 'field_probe.lua', BASE / 'capture_field_probe.py', BASE / 'proof_io.py']
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'build_lua_native.sh')]
paths += [BASE / 'intake' / host / name for host in proof.HOSTS for name in ('native-identities.json', 'native-before-first-run.tar.gz')]
inputs = proof.freeze(OUT, paths)
for host in proof.HOSTS:
    target = OUT / host
    target.mkdir()
    runtime = os.environ.get('LINKEDSPEC_LUA_CMD' if host == 'puc' else 'LINKEDSPEC_LUAJIT_CMD', 'lua' if host == 'puc' else 'luajit')
    environment = {key: value for key, value in os.environ.items() if not key.startswith(('LUA_INIT', 'LUA_PATH_', 'LUA_CPATH_'))}
    environment.update(LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;', LUA_CPATH=str(target / 'native/?.so') + ';;', LINKEDSPEC_LUA_TEST_RUNTIME=runtime)
    native, products = proof.build_native(target, host, environment)
    result = proof.execute(target, 'probe', ['bash', 'tools/project_data_run.sh', runtime,
        str(BASE / 'field_probe.lua'), str(OUT / 'cases.json'), str(target)], environment)
    assert result.returncode == 0 and result.stderr == b'', 'Actual probe failure retained'
    rows = proof.frames(result.stdout, 'LUA_FIELD_PROBE')
    assert set(rows) == keys
    proof.freeze(target, list(target.glob('*.parsed.json')), 'artifact', 'actual-parsed-inputs.tar.gz')
    proof.verify(inputs)
    proof.verify(products)
    for name in products:
        Path(name).unlink()
    native.rmdir()
    print(host + ': published JSON/native outer-field boundary and distinguishing mutations retained', flush=True)
(OUT / 'complete.txt').write_text('Both installed host two-case native error field probes complete; no SDK change.\n')
