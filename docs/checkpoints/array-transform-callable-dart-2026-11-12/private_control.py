"""Same private own-Dart SDK path; semantic old/current frames and routing."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import traceback
from urllib.parse import unquote, urljoin, urlparse

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
CONTROL = BASE / 'control-owner'
OWNER = Path('dart/lib/src/runtime/interpreter.dart')
PROBE = Path('dart/tool/probe_callable_array_transform_results.dart')
NORMAL = Path('dart/test/array_transform_callable_result_guard_composition_test.dart')
PROFILE = Path('tests/fixtures/array_transform_callable_result_guard_dart_profiles.json')
ACTIVATION = '5ac1fac5eb7126cd8f952858f8df194914884830'
phase = sys.argv[1]
assert phase in ('private-old', 'private-fixed')
OUT = BASE / phase
OUT.mkdir()
ENVIRONMENT = dict(TERM='dumb', NO_COLOR='1', LINKEDSPEC_CALLABLE_TRANSFORM_DART_CAPTURE=phase)
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


def run(tag, arguments, accepted=(0,)):
    cwd = CONTROL / 'dart'
    command = ['bash', os.path.relpath(ROOT / 'tools/run_dart_project_data.sh', ROOT / cwd), *arguments]
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd=str(cwd), environment=ENVIRONMENT), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT / cwd, env=dict(os.environ, **ENVIRONMENT), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in accepted, tag + ': actual failure retained'
    return result


def frames(body, tag):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'dart', 'tests/fixtures'], text=True).splitlines()]
    paths += [NORMAL, PROFILE, PROBE, Path('dart/tool/callable_array_transform_observation.dart'), BASE / 'cases.json']
    paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths = sorted(set(paths))
    if phase == 'private-old':
        assert not CONTROL.exists()
        for source in paths:
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
    old = gzip.decompress((BASE / 'owner-before.dart.gz').read_bytes())
    assert old != candidate
    (CONTROL / OWNER).write_bytes(old if phase == 'private-old' else candidate)
    declared = [CONTROL / path for path in paths] + [OWNER, BASE / 'private_control.py', BASE / 'owner-before.dart.gz']
    declared += [BASE / name for name in ('prepare.py', 'prepare_epochs.py', 'freeze_policy.py', 'baseline.json', 'own-questions.json')]
    declared += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh', 'run_dart_project_data.sh')]
    (OUT / 'activation.txt').write_text(ACTIVATION + '\n')
    freeze('root', declared)
    run('version', ['--version'])
    run('resolution', ['pub', 'get', '--offline', '--enforce-lockfile'])
    config = CONTROL / 'dart/.dart_tool/package_config.json'
    own = next(p for p in json.loads(config.read_bytes())['packages'] if p['name'] == 'linkedspec_dart')
    uri = urlparse(urljoin((ROOT / config).as_uri(), own['rootUri']))
    assert uri.scheme == 'file' and not uri.netloc
    assert Path(unquote(uri.path)).resolve() == (ROOT / CONTROL / 'dart').resolve(), 'private SDK routing required'
    (OUT / 'sdk-routing.json').write_text(json.dumps(dict(package='linkedspec_dart', config=str(config), root=str(CONTROL / 'dart')), indent=2) + '\n')
    freeze('resolved', [CONTROL / 'dart/pubspec.yaml', CONTROL / 'dart/pubspec.lock', *list((CONTROL / 'dart/.dart_tool').glob('*.json'))])
    run('analysis', ['analyze', '--fatal-infos', '--fatal-warnings', 'lib/src/runtime/interpreter.dart', str(NORMAL.relative_to('dart'))])
    result = run('normal', ['test', '--reporter', 'expanded', '--concurrency=1', str(NORMAL.relative_to('dart'))], (1,) if phase == 'private-old' else (0,))
    observed = frames(result.stdout, 'CALLABLE_TRANSFORM_DART_NORMAL')
    expected_phase = 'intake' if phase == 'private-old' else 'after'
    expected = frames(gzip.decompress((BASE / expected_phase / 'native-stdout.log.gz').read_bytes()), 'CALLABLE_TRANSFORM_DART')
    assert json.dumps(observed, sort_keys=True, separators=(',', ':')) == json.dumps(expected, sort_keys=True, separators=(',', ':')) and len(observed) == 312, 'actual private normal observations'
    count = b'+281 -31: Some tests failed.' if phase == 'private-old' else b'+312: All tests passed!'
    assert count in result.stdout, 'actual semantic counts'
    parsed = CONTROL / '.linkedspec-data/scratch/callable-transform-dart-normal' / phase
    assert len(list(parsed.glob('*.json'))) == 312
    freeze('normal-parsed', list(parsed.glob('*.json')))
    for packet in custody:
        for name, row in packet['files'].items():
            path = Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
    assert OWNER.read_bytes() == candidate
    if phase == 'private-fixed':
        assert CONTROL.parent == BASE and not CONTROL.is_symlink()
        shutil.rmtree(CONTROL)
        assert not CONTROL.exists()
    print(phase + ': actual312 semantic frames/counts, exact own SDK image and routing verified; checkout unchanged')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
