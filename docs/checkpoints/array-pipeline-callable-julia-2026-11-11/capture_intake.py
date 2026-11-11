"""One-shot Julia acquisition; retain actual inputs/channels/products, then grade."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile
import traceback

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'intake'
OUT.mkdir()
ACTIVATION = '580fe233a7d0299d177ecbd442ad8ba027bbe6da'
ENVIRONMENT = dict(JULIA_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', JULIA_PKG_PRECOMPILE_AUTO='0')
custody = []


def freeze(tag, paths):
    files = {}
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        files[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
    target = OUT / (tag + '-inputs.tar.gz')
    with tarfile.open(target, 'x:gz') as archive:
        for path in files:
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(target) as archive:
        assert len(archive.getnames()) == len(files) and set(archive.getnames()) == set(files)
        for member in archive:
            body = archive.extractfile(member).read()
            row = files[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    custody.append(dict(tag=tag, archive=str(target), files=files))
    (OUT / 'custody.json').write_text(json.dumps(custody, indent=2, sort_keys=True) + '\n')


def run(tag, arguments):
    command = ['bash', 'tools/run_julia_project_data.sh', '--project=julia', '--startup-file=no', '--history-file=no', '--depwarn=error', *arguments]
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.', environment=ENVIRONMENT), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, **ENVIRONMENT), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, tag + ': actual failure retained'
    return result


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    (OUT / 'activation.txt').write_text(ACTIVATION + '\n')
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'julia', 'tests/fixtures'], text=True).splitlines()]
    paths += [path for path in BASE.iterdir() if path.is_file() and path.suffix in ('.py', '.jl', '.json', '.gz')]
    paths += [Path('julia/test/callable_array_pipeline_observation.jl')]
    paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh', 'run_julia_project_data.sh')]
    freeze('root', paths)
    run('version', ['--version'])
    result = run('native', [str(BASE / 'observer.jl'), str(BASE / 'cases.json'), str(OUT)])
    assert b'CALLABLE_PIPELINE_JULIA_OWNER julia/src/LinkedSpecJulia.jl\n' in result.stdout
    rows = {}
    for line in result.stdout.decode().splitlines():
        if line.startswith('CALLABLE_PIPELINE_JULIA '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    cases = json.loads((BASE / 'cases.json').read_bytes())
    assert list(rows) == [row['id'] for row in cases], 'complete program census'
    prepared = {key for key, row in rows.items() if 'preparation_error' not in row}
    artifacts = list((OUT / 'emitted').glob('*.jl')) + list((OUT / 'parsed').glob('*.json'))
    assert {path.stem for path in artifacts if path.suffix == '.jl'} == prepared
    assert {path.stem for path in artifacts if path.suffix == '.json'} == prepared
    freeze('artifacts', artifacts)
    (OUT / 'program-census.json').write_text(json.dumps(dict(programs=len(rows), prepared=sorted(prepared),
        preparation_exclusions=sorted(set(rows)-prepared)), indent=2) + '\n')
    for packet in custody:
        for name, row in packet['files'].items():
            path = Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
    for path in artifacts:
        path.unlink()
    for name in ('emitted', 'parsed'):
        (OUT / name).rmdir()
    print('Original' + str(len(rows)) + ' Julia program observations/' + str(len(prepared)) + ' actual parsed-emitted pairs retained; grade actual routes/policies separately')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
