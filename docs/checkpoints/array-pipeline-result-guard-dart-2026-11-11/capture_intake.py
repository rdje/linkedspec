"""One-shot original Dart four-route epoch with actual inputs before SDK use."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import traceback

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'intake'
OUT.mkdir()
PROBE = Path('dart/tool/probe_array_pipeline_results.dart')
CONFIG = Path('dart/.dart_tool/package_config.json')
ACTIVATION = '52cc3fa8073106154e8a3646ae27ee8e77d5d401'
custody = []
ENVIRONMENT = dict(TERM='dumb', NO_COLOR='1')


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


def run(tag, arguments, cwd=Path('dart')):
    command = ['bash', os.path.relpath(ROOT / 'tools/run_dart_project_data.sh', ROOT / cwd), *arguments]
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd=str(cwd), environment=ENVIRONMENT), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT / cwd, env=dict(os.environ, **ENVIRONMENT), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, tag + ': actual failure retained'


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    (OUT / 'activation.txt').write_text(ACTIVATION + '\n')
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'dart', 'tests/fixtures'], text=True).splitlines()]
    paths += [PROBE, BASE / 'prepare.py', BASE / 'capture_intake.py', BASE / 'cases.json', BASE / 'profile-sources.json',
              BASE / 'probe-template.dart.gz', BASE / 'probe-template-identity.json']
    paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh', 'run_dart_project_data.sh')]
    if CONFIG.exists():
        paths.append(CONFIG)
    (OUT / 'cases.json').write_bytes((BASE / 'cases.json').read_bytes())
    paths.append(OUT / 'cases.json')
    freeze('root', paths)
    run('version', ['--version'])
    run('resolution', ['pub', 'get', '--offline', '--enforce-lockfile'])
    freeze('resolved', [Path('dart/pubspec.yaml'), Path('dart/pubspec.lock'), *Path('dart/.dart_tool').glob('*.json')])
    run('analysis', ['analyze', '--fatal-infos', '--fatal-warnings', str(PROBE.relative_to('dart'))])
    fresh = OUT / 'fresh'
    fresh.mkdir()
    own_path = os.path.relpath(ROOT / 'dart', ROOT / fresh)
    (fresh / 'pubspec.yaml').write_text('name: array_pipeline_dart_fresh\npublish_to: none\nenvironment:\n  sdk: ">=3.9.0 <4.0.0"\ndependencies:\n  linkedspec_dart:\n    path: ' + own_path + '\n')
    freeze('native', [PROBE, OUT / 'cases.json', fresh / 'pubspec.yaml'])
    run('native', ['run', str(PROBE.relative_to('dart')), str(OUT)])
    artifacts = list(fresh.rglob('*.dart')) + list((fresh / 'inputs').glob('*.json'))
    assert len(list((fresh / 'inputs').glob('*.json'))) == 173
    freeze('emitted', artifacts + [fresh / 'pubspec.yaml'])
    run('fresh-resolution', ['pub', 'get', '--offline'], fresh)
    freeze('fresh', artifacts + [fresh / 'pubspec.yaml', fresh / 'pubspec.lock', *list((fresh / '.dart_tool').glob('*.json'))])
    run('fresh-analysis', ['analyze', '--fatal-infos', '--fatal-warnings'], fresh)
    run('fresh', ['run', 'bin/main.dart'], fresh)
    for packet in custody:
        for name, row in packet['files'].items():
            if packet['tag'] == 'root' and name == str(CONFIG):
                continue  # Its actual resolved successor precedes every SDK call.
            path = Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
    assert fresh.parent == OUT and not fresh.is_symlink()
    shutil.rmtree(fresh)
    print('Original173 independent Dart programs/four public routes and complete declared own inputs/artifact pairs retained')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
