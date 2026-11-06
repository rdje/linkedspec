"""One-shot finite Julia callable observations; explicit grammar input precedes SDK use."""
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
assert phase in ('intake', 'normal', 'direct'), 'unknown one-shot phase'
OUT = BASE / phase
OUT.mkdir()
FIXTURE = Path('tests/fixtures/key_count_callable_result_cases.json')
paths = [Path(p) for p in subprocess.check_output(
    ['git', 'ls-files', 'julia'], text=True).splitlines()]
paths += [BASE / 'capture.py', BASE / 'observer.jl', FIXTURE,
          Path('specs/user_function_definition.spec')]
paths += [Path('tools') / p for p in (
    'run_julia_project_data.sh', 'project_data_env.sh',
    'run_python_project_data.sh', 'project_data_run.sh')]
if phase == 'intake':
    (OUT / 'cases.json').write_bytes(FIXTURE.read_bytes())
    paths.append(OUT / 'cases.json')
else:
    paths += [Path('julia/test/key_count_callable_result_guard_composition_test.jl'),
              Path('tests/fixtures/key_count_callable_julia_profiles.json')]
    paths += [Path('tests/fixtures') / p for p in (
        'key_count_result_guard_cases.json', 'key_count_result_guard_julia_domain.json',
        'key_count_result_guard_julia_errors.json',
        'key_count_count_source_ownership_julia_cases.json')]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'w:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.is_file() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(),
                                 bytes=len(body), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
env = dict(os.environ, JULIA_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', JULIA_PKG_PRECOMPILE_AUTO='0')
if phase == 'intake':
    args = [str(BASE / 'observer.jl'), str(OUT / 'cases.json'), str(OUT)]
else:
    env['LINKEDSPEC_CALLABLE_KEY_COUNT_CAPTURE'] = str(OUT)
    tests = ['julia/test/key_count_callable_result_guard_composition_test.jl']
    if phase == 'direct':
        tests += ['julia/test/key_count_result_guard_composition_test.jl',
                  'julia/test/user_function_parser_context_boundary_test.jl']
    args = ['-e', 'using LinkedSpecJulia,JSON3,Test; for path in ARGS; include(path); end', *tests]
command = ['bash', 'tools/run_julia_project_data.sh', '--project=julia',
           '--startup-file=no', '--history-file=no', '--depwarn=error', *args]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, environment={
    k: env[k] for k in ('JULIA_NUM_THREADS', 'OPENBLAS_NUM_THREADS', 'JULIA_PKG_PRECOMPILE_AUTO',
                       'LINKEDSPEC_CALLABLE_KEY_COUNT_CAPTURE') if k in env
}), indent=2) + '\n')
with (OUT / 'stdout.log').open('wb') as stdout, (OUT / 'stderr.log').open('wb') as stderr:
    result = subprocess.run(command, cwd=ROOT, env=env, stdout=stdout, stderr=stderr)
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == r['sha256'] for p, r in records.items())
for name in ('stdout.log', 'stderr.log'):
    path = OUT / name
    body = path.read_bytes()
    packed = gzip.compress(body, mtime=0)
    assert gzip.decompress(packed) == body
    Path(str(path) + '.gz').write_bytes(packed)
    assert gzip.decompress(Path(str(path) + '.gz').read_bytes()) == path.read_bytes()
    path.unlink()
if phase in ('intake', 'normal', 'direct'):
    artifacts = {}
    paths = sorted((OUT / 'emitted').glob('*.jl')) + sorted((OUT / 'parsed').glob('*.json'))
    assert len(paths) == 2 * len(json.loads(FIXTURE.read_bytes()))
    with tarfile.open(OUT / 'actual-emitted-parsed.tar.gz', 'w:gz') as archive:
        for path in paths:
            body = path.read_bytes()
            artifacts[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(),
                                       bytes=len(body), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
    with tarfile.open(OUT / 'actual-emitted-parsed.tar.gz') as archive:
        assert archive.getnames() == [str(p) for p in paths]
        for path in paths:
            assert archive.extractfile(str(path)).read() == path.read_bytes()
    (OUT / 'artifact-identities.json').write_text(json.dumps(artifacts, indent=2, sort_keys=True) + '\n')
    for path in paths:
        path.unlink()
    (OUT / 'emitted').rmdir()
    (OUT / 'parsed').rmdir()
print(f'{phase}: exit{result.returncode}; actual declared inputs and full channels retained')
assert result.returncode == 0, 'inspect retained channels before retrying under a new owned epoch'
