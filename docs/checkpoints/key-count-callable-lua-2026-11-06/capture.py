"""One-shot sequential installed Lua acquisition with explicit grammar input."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
phase, = sys.argv[1:]
assert phase in ('intake', 'direct'), 'unknown one-shot phase'
OUT = BASE / phase
OUT.mkdir()
FIXTURE = Path('tests/fixtures/key_count_callable_result_cases.json')
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'lua'], text=True).splitlines()]
paths += [BASE / 'capture.py', BASE / 'observer.lua', FIXTURE,
          Path('specs/user_function_definition.spec')]
paths += [Path('tools') / p for p in ('run_lua_project_data.sh', 'build_lua_native.sh',
          'project_data_env.sh', 'run_python_project_data.sh', 'project_data_run.sh')]
if phase == 'intake':
    (OUT / 'cases.json').write_bytes(FIXTURE.read_bytes())
    paths.append(OUT / 'cases.json')
else:
    paths += [BASE / 'freeze_profiles.py',
              Path('lua/test/key_count_callable_result_guard_composition_test.lua'),
              Path('tests/fixtures/key_count_callable_lua_profiles.json')]
    paths += [Path('tests/fixtures') / p for p in (
        'key_count_result_guard_cases.json', 'key_count_result_guard_lua_domain.json',
        'key_count_result_guard_lua_errors.json', 'key_count_count_source_ownership_cases.json')]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.is_file() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(),
                                 bytes=len(body), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
for host in ('puc', 'luajit'):
    target = OUT / host
    target.mkdir()
    for name in ('emitted', 'parsed'):
        (target / name).mkdir()
    if phase == 'intake':
        args = [str(BASE / 'observer.lua'), str(OUT / 'cases.json'), str(target)]
    else:
        args = ['-e', 'dofile("lua/test/key_count_callable_result_guard_composition_test.lua"); '
                'dofile("lua/test/key_count_result_guard_composition_test.lua")']
    for tag, arguments in (('version', ['-v']), ('normal', args)):
        command = ['bash', 'tools/run_lua_project_data.sh', host, *arguments]
        env = dict(os.environ, LINKEDSPEC_CALLABLE_KEY_COUNT_CAPTURE=str(target))
        (target / (tag + '-command.json')).write_text(json.dumps(dict(
            argv=command, environment=dict(LINKEDSPEC_CALLABLE_KEY_COUNT_CAPTURE=str(target))
        ), indent=2) + '\n')
        with (target / (tag + '-stdout.log')).open('wb') as stdout, (target / (tag + '-stderr.log')).open('wb') as stderr:
            result = subprocess.run(command, cwd=ROOT, env=env, stdout=stdout, stderr=stderr)
        (target / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
        print(phase, host, tag, 'exit', result.returncode, flush=True)
        for channel in ('stdout', 'stderr'):
            path = target / (tag + '-' + channel + '.log')
            body = path.read_bytes()
            packed = gzip.compress(body, mtime=0)
            Path(str(path) + '.gz').write_bytes(packed)
            assert gzip.decompress(Path(str(path) + '.gz').read_bytes()) == path.read_bytes()
            path.unlink()
        assert result.returncode == 0, 'inspect retained full channels before any separate retry epoch'
    artifacts = {}
    paths = sorted((target / 'emitted').glob('*.lua')) + sorted((target / 'parsed').glob('*.json'))
    assert len(paths) == 2 * len(json.loads(FIXTURE.read_bytes()))
    with tarfile.open(target / 'actual-emitted-parsed.tar.gz', 'x:gz') as archive:
        for path in paths:
            body = path.read_bytes()
            artifacts[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(),
                                       bytes=len(body), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
    with tarfile.open(target / 'actual-emitted-parsed.tar.gz') as archive:
        assert archive.getnames() == [str(p) for p in paths]
        for path in paths:
            assert archive.extractfile(str(path)).read() == path.read_bytes()
    (target / 'artifact-identities.json').write_text(json.dumps(artifacts, indent=2, sort_keys=True) + '\n')
    for path in paths:
        path.unlink()
    (target / 'emitted').rmdir()
    (target / 'parsed').rmdir()
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == r['sha256'] for p, r in records.items())
print(phase + ': declared direct sources unchanged through both installed hosts')
