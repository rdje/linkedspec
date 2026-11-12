"""Finite Julia normal/private proof epochs with all declared inputs before use."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile
import traceback

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '3767c87c7167bdcb29b0092be35bc139520e3509'
OWNER = Path('julia/src/runtime/Interpreter.jl')
NORMAL = Path('julia/test/array_transform_callable_result_guard_composition_test.jl')
CASES = Path('tests/fixtures/array_transform_callable_result_guard_julia_cases.json')
PROFILE = Path('tests/fixtures/array_transform_callable_result_guard_julia_profiles.json')
CONTROL = BASE / 'control-owner'
phase = sys.argv[1]
assert phase in ('before', 'after', 'direct', 'private-old', 'private-fixed')
OUT = BASE / phase
OUT.mkdir()
ENVIRONMENT = dict(JULIA_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', JULIA_PKG_PRECOMPILE_AUTO='0', JULIA_NUM_PRECOMPILE_TASKS='1',
    LINKEDSPEC_CALLABLE_TRANSFORM_JULIA_CAPTURE=str(OUT))
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


def run(tag, command, accepted=(0,)):
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.', environment=ENVIRONMENT), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, **ENVIRONMENT), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in accepted, tag + ': actual failure retained'
    return result


def frames(body):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith('CALLABLE_TRANSFORM_JULIA_NORMAL '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    (OUT / 'activation.txt').write_text(ACTIVATION + '\n')
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'julia', 'tests/fixtures'], text=True).splitlines()]
    paths += [NORMAL, CASES, PROFILE, Path('julia/test/callable_array_transform_observation.jl')]
    paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh', 'run_julia_project_data.sh')]
    paths += [path for path in BASE.iterdir() if path.is_file() and path.suffix in ('.py', '.jl', '.json', '.gz')]

    sdk = Path('julia')
    normal = NORMAL
    if phase.startswith('private-'):
        sdk_paths = [path for path in sorted(set(paths)) if path.parts[0] in ('julia', 'tests', 'specs')]
        if phase == 'private-old':
            assert not CONTROL.exists()
            for source in sdk_paths:
                target = CONTROL / source
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, target)
        else:
            previous = json.loads((BASE / 'private-old/custody.json').read_bytes())[0]['files']
            for name, row in previous.items():
                if name.startswith(str(CONTROL) + '/'):
                    path = Path(name)
                    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
        candidate = OWNER.read_bytes()
        old = gzip.decompress((BASE / 'owner-before.jl.gz').read_bytes())
        assert old != candidate
        (CONTROL / OWNER).write_bytes(old if phase == 'private-old' else candidate)
        paths += [CONTROL / source for source in sdk_paths]
        sdk = CONTROL / 'julia'
        normal = CONTROL / NORMAL
    freeze('root', paths)
    prefix = ['bash', 'tools/run_julia_project_data.sh', '--project=' + str(sdk), '--startup-file=no', '--history-file=no', '--depwarn=error']
    if phase.startswith('private-'):
        prefix.append('--compiled-modules=no')
    # Check the shared host before any Julia compilation/precompilation. Keep
    # both complete channels and the actual command, not only its percentage.
    memory_command = ['bash', 'tools/project_data_run.sh', 'memory_pressure']
    (OUT / 'memory-command.json').write_text(json.dumps(dict(argv=memory_command, cwd='.', environment={}), indent=2) + '\n')
    memory = subprocess.run(memory_command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / ('memory-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(memory, channel), mtime=0))
    (OUT / 'memory-exit.txt').write_text(str(memory.returncode) + '\n')
    assert memory.returncode == 0
    import re
    match = re.search(rb'System-wide memory free percentage: (\d+)%', memory.stdout)
    assert match and int(match[1]) >= 30, 'Defer Julia job: conservative4GiB peak plus headroom unavailable'
    run('version', prefix + ['--version'])
    tests = [str(normal)]
    if phase == 'direct':
        tests += ['julia/test/array_transform_result_guard_composition_test.jl', 'julia/test/array_pipeline_callable_result_guard_composition_test.jl']
    expression = 'using LinkedSpecJulia,JSON3,Test; println("CALLABLE_TRANSFORM_JULIA_OWNER ",relpath(pathof(LinkedSpecJulia),pwd())); for path in ARGS; include(path); end'
    result = run('normal', prefix + ['-e', expression, *tests], (1,) if phase in ('before', 'private-old') else (0,))
    observed = frames(result.stdout)
    assert len(observed) == 312 and set(observed) == {row['id'] for row in json.loads(CASES.read_bytes())}
    owner_path = ('CALLABLE_TRANSFORM_JULIA_OWNER ' + str(sdk / 'src/LinkedSpecJulia.jl') + '\n').encode()
    assert owner_path in result.stdout, 'actual loaded own SDK path'
    before = phase in ('before', 'private-old')
    pattern = rb'Julia callable Array-transform result guards\s*\|\s*1124\s+124\s+1248\s' if before else rb'Julia callable Array-transform result guards\s*\|\s*1248\s+1248\s'
    assert re.search(pattern, result.stdout), 'actual finite semantic count'
    if phase == 'direct':
        assert re.search(rb'Julia ordinary Array-transform result guards\s*\|\s*903\s+903\s', result.stdout)
        assert re.search(rb'Julia callable Array-pipeline result guards\s*\|\s*776\s+776\s', result.stdout)
    baseline = json.loads((BASE / 'baseline.json').read_bytes())
    expected_rows = baseline['observed' if before else 'expected']
    assert json.dumps(observed, sort_keys=True) == json.dumps(expected_rows, sort_keys=True), 'own frozen complete records'
    if phase.startswith('private-'):
        peer = 'before' if before else 'after'
        expected = frames(gzip.decompress((BASE / peer / 'normal-stdout.log.gz').read_bytes()))
        assert json.dumps(observed, sort_keys=True) == json.dumps(expected, sort_keys=True), 'private normal observations'
        assert OWNER.read_bytes() == candidate
    artifacts = list((OUT / 'emitted').glob('*.jl')) + list((OUT / 'parsed').glob('*.json'))
    assert {path.stem for path in artifacts if path.suffix == '.jl'} == set(observed)
    assert {path.stem for path in artifacts if path.suffix == '.json'} == set(observed)
    freeze('artifacts', artifacts)
    for packet in custody:
        for name, row in packet['files'].items():
            path = Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
    for path in artifacts:
        path.unlink()
    for name in ('emitted', 'parsed'):
        (OUT / name).rmdir()
    if phase == 'private-fixed':
        assert CONTROL.parent == BASE and not CONTROL.is_symlink()
        shutil.rmtree(CONTROL)
    print(phase + ': actual312 four-route frames/counts, own SDK path, inputs and parsed/emitted pairs retained')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
