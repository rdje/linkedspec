"""One finite installed-Lua epoch through documented native/project-data interfaces."""
import gzip
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import traceback

sys.dont_write_bytecode = True
ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
module_spec = importlib.util.spec_from_file_location('owned_lua_callable_proof_io', ROOT / BASE / 'proof_io.py')
proof = importlib.util.module_from_spec(module_spec)
module_spec.loader.exec_module(proof)
OWNER, NORMAL, FIXTURE, PROFILE, GRAMMAR, HOSTS = proof.OWNER, proof.NORMAL, proof.FIXTURE, proof.PROFILE, proof.GRAMMAR, proof.HOSTS
freeze, verify, execute, build_native, artifacts, frames = proof.freeze, proof.verify, proof.execute, proof.build_native, proof.artifacts, proof.frames

phase, = sys.argv[1:]
assert phase in ('intake', 'before', 'after', 'direct', 'inverse', 'restored')
out = BASE / phase
out.mkdir()
private = BASE / 'control-owner'
is_private = phase in ('inverse', 'restored')
try:
    source_paths = [Path(p) for p in subprocess.check_output(
        ['git', 'ls-files', 'lua', 'tests/fixtures'], text=True).splitlines()]
    source_paths += [FIXTURE, GRAMMAR, Path('lua/test/callable_array_pipeline_observation.lua'), Path('tests/fixtures/array_pipeline_callable_result_guard_cases.json')]
    if NORMAL.exists():
        source_paths.append(NORMAL)
    if PROFILE.exists():
        source_paths.append(PROFILE)
    prefix = ''
    if is_private:
        if phase == 'inverse':
            assert not private.exists()
            private.mkdir()
        else:
            assert private.is_dir() and not private.is_symlink()
        activation = (BASE / 'intake/activation.txt').read_text().strip()
        for path in sorted(set(source_paths)):
            target = private / path
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
            if phase == 'inverse' and path == OWNER:
                target.write_bytes(subprocess.check_output(['git', 'show', activation + ':' + str(path)]))
        prefix = str(private) + '/'
    else:
        activation = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
    paths = list(source_paths) + [BASE / name for name in ('prepare.py', 'own_questions.py', 'proof_io.py', 'capture.py', 'freeze_profiles.py', 'observer.lua', 'profile-sources.json', 'signature-sources.json', 'pattern-sources.json', 'cases.json', 'template-identities.json') if (BASE / name).exists()]
    paths += list(BASE.glob('ordinary-*.gz')) + list(BASE.glob('source-only-*.gz'))
    paths += [Path(name) for name in json.loads((BASE / 'template-identities.json').read_bytes())]
    if phase != 'intake':
        paths += [BASE / 'intake' / host / name for host in HOSTS for name in ('native-before-first-run.tar.gz', 'native-identities.json')]
    paths += [Path('tools') / name for name in ('build_lua_native.sh', 'run_lua_project_data.sh',
                                              'project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
    if phase == 'intake':
        (out / 'cases.json').write_bytes(FIXTURE.read_bytes())
        paths.append(out / 'cases.json')
    if is_private:
        paths += [private / path for path in sorted(set(source_paths))]
        golden_phase = 'before' if phase == 'inverse' else 'after'
        paths += [BASE / golden_phase / host / 'normal-stdout.log.gz' for host in HOSTS]
    records = freeze(out, paths)
    (out / 'activation.txt').write_text(activation + '\n')
    for host in HOSTS:
        target = out / host
        target.mkdir()
        (target / 'emitted').mkdir()
        (target / 'parsed').mkdir()
        runtime = os.environ.get('LINKEDSPEC_LUA_CMD' if host == 'puc' else 'LINKEDSPEC_LUAJIT_CMD', 'lua' if host == 'puc' else 'luajit')
        clean_environment = {key: value for key, value in os.environ.items() if not key.startswith(('LUA_INIT', 'LUA_PATH_', 'LUA_CPATH_'))}
        environment = dict(clean_environment, LUA_PATH=prefix + 'lua/src/?.lua;' + prefix + 'lua/src/?/init.lua;;',
            LUA_CPATH=str(target / 'native/?.so') + ';;', LINKEDSPEC_LUA_TEST_RUNTIME=runtime,
            LINKEDSPEC_CALLABLE_PIPELINE_CAPTURE=str(target), LINKEDSPEC_CALLABLE_PIPELINE_INPUT_ROOT=prefix)
        native, native_rows = build_native(target, host, environment)
        assert execute(target, 'version', ['bash', 'tools/project_data_run.sh', runtime, '-v'], environment).returncode == 0
        if phase == 'intake':
            args = [str(BASE / 'observer.lua'), str(out / 'cases.json'), str(target)]
        else:
            tests = [prefix + str(NORMAL)]
            if phase == 'direct':
                tests += ['lua/test/array_pipeline_result_guard_composition_test.lua', 'lua/test/key_count_callable_result_guard_composition_test.lua']
            args = ['-e', '; '.join('dofile(' + json.dumps(path) + ')' for path in tests)]
        result = execute(target, 'normal', ['bash', 'tools/project_data_run.sh', runtime, *args], environment)
        verify(records)
        verify(native_rows)
        artifacts(target)
        rows = frames(result.stdout, 'CALLABLE_PIPELINE_LUA' if phase == 'intake' else 'CALLABLE_PIPELINE_LUA_NORMAL')
        assert list(rows) == [row['id'] for row in json.loads(FIXTURE.read_bytes())]
        assert all(set(row) == {'native', 'restored', 'plan', 'fresh'} for row in rows.values())
        expected_owner = ('@' + prefix + 'lua/src/linkedspec/interpreter.lua').encode()
        assert b'CALLABLE_PIPELINE_LUA_OWNER ' + expected_owner + b'\n' in result.stdout
        if is_private:
            expected = gzip.decompress((BASE / golden_phase / host / 'normal-stdout.log.gz').read_bytes())
            assert json.dumps(rows, sort_keys=True) == json.dumps(frames(expected), sort_keys=True)
            pattern = rb'CALLABLE_PIPELINE_LUA_SUMMARY ([0-9]+) checks ([0-9]+) failures'
            wanted = re.search(pattern, expected)
            actual = re.search(pattern, result.stdout)
            assert wanted and actual and wanted.groups() == actual.groups()
            assert result.returncode == (1 if int(wanted[2]) else 0)
        else:
            assert result.returncode in ((0, 1) if phase == 'before' else (0,))
        for name in native_rows:
            Path(name).unlink()
        native.rmdir()
        print(phase, host, 'exit' + str(result.returncode) + '; actual source/native/artifact/full-channel capture complete', flush=True)
    verify(records)
    if phase == 'restored':
        assert {p for p in private.rglob('*') if p.is_file()} == {private / p for p in set(source_paths)}
        shutil.rmtree(private)
    (out / 'complete.txt').write_text('Both installed host epochs complete; actual declared source inputs unchanged.\n')
except BaseException:
    (out / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
