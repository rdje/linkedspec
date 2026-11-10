"""Retain declared current source, actual artifacts and full execution channels."""
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

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
PROBE = Path('dart/tool/probe_array_transform_results.dart')
NORMAL = Path('dart/test/array_transform_result_guard_composition_test.dart')
PROFILE = Path('tests/fixtures/array_transform_result_guard_dart_profiles.json')
CONFIG = Path('dart/.dart_tool/package_config.json')
phase, mode = sys.argv[1:]
assert phase in ('intake', 'before', 'after', 'after-intake', 'formatted-intake', 'direct', 'format')
assert mode in ('routes', 'test', 'format')
OUT = BASE / phase
OUT.mkdir()
custody = []
environment = dict(os.environ, TERM='dumb', NO_COLOR='1')


def freeze(tag, paths):
    files = {}
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts
        assert path.is_file() and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        files[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
                                mode=path.stat().st_mode & 0o777)
    target = OUT / (tag + '-before-first-run.tar.gz')
    with tarfile.open(target, 'w:gz') as archive:
        for path in files:
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(target) as archive:
        actual = {m.name: (hashlib.sha256(archive.extractfile(m).read()).hexdigest(),
                           m.mode & 0o777) for m in archive}
    assert actual == {p: (r['sha256'], r['mode']) for p, r in files.items()}
    custody.append(dict(tag=tag, archive=str(target), files=files))
    (OUT / 'custody.json').write_text(json.dumps(custody, indent=2, sort_keys=True) + '\n')


def run(tag, arguments, cwd=Path('dart'), accepted=(0,)):
    command = ['bash', os.path.relpath(ROOT / 'tools/run_dart_project_data.sh', ROOT / cwd),
               *arguments]
    packet = dict(cwd=str(cwd), argv=command, environment=dict(TERM='dumb', NO_COLOR='1'))
    (OUT / (tag + '-command.json')).write_text(json.dumps(packet, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT / cwd, env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(
            gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in accepted, tag + ': nonaccepted exit; complete channels retained'
    return result


def main():
    (OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'dart'], text=True).splitlines()]
    paths += [PROBE, Path('specs/user_function_definition.spec'),
              Path('tests/fixtures/array_transform_result_guard_cases.json')]
    paths += list(BASE.glob('*.py')) + [BASE / 'cases.json', BASE / 'profile-sources.json']
    paths += [Path(p) for p in ('tools/run_dart_project_data.sh', 'tools/project_data_env.sh',
                              'tools/project_data_run.sh', 'tools/run_python_project_data.sh')]
    paths += [p for p in (CONFIG, NORMAL, PROFILE) if p.exists()]
    if mode == 'routes':
        (OUT / 'cases.json').write_bytes((BASE / 'cases.json').read_bytes())
        paths.append(OUT / 'cases.json')
    freeze('root', paths)
    run('version', ['--version'])
    run('resolution', ['pub', 'get', '--offline', '--enforce-lockfile'])
    freeze('resolved', [Path('dart/pubspec.yaml'), Path('dart/pubspec.lock'),
                        *Path('dart/.dart_tool').glob('*.json')])
    if mode == 'routes':
        run('analysis', ['analyze', '--fatal-infos', '--fatal-warnings', str(PROBE.relative_to('dart'))])
        fresh = OUT / 'fresh'
        fresh.mkdir()
        own_path = os.path.relpath(ROOT / 'dart', ROOT / fresh)
        (fresh / 'pubspec.yaml').write_text(
            'name: array_transform_dart_fresh\npublish_to: none\nenvironment:\n'
            '  sdk: ">=3.9.0 <4.0.0"\ndependencies:\n  linkedspec_dart:\n'
            '    path: ' + own_path + '\n')
        run('native', ['run', str(PROBE.relative_to('dart')), str(OUT)])
        artifacts = list(fresh.rglob('*.dart')) + list((fresh / 'inputs').glob('*.json'))
        freeze('emitted', artifacts + [fresh / 'pubspec.yaml'])
        run('fresh-resolution', ['pub', 'get', '--offline'], fresh)
        freeze('fresh', artifacts + [fresh / 'pubspec.yaml', fresh / 'pubspec.lock',
                                     *list((fresh / '.dart_tool').glob('*.json'))])
        run('fresh-analysis', ['analyze', '--fatal-infos', '--fatal-warnings'], fresh)
        run('fresh', ['run', 'bin/main.dart'], fresh)
    elif mode == 'test':
        tests = [str(NORMAL.relative_to('dart'))]
        if phase == 'direct':
            tests += ['test/with_hash_results_test.dart', 'test/hash_value_result_guard_composition_test.dart',
                      'test/hash_view_result_guard_composition_test.dart',
                      'test/constructor_result_composition_test.dart']
        run('analysis', ['analyze', '--fatal-infos', '--fatal-warnings',
                         'lib/src/runtime/interpreter.dart', *tests, str(PROBE.relative_to('dart'))])
        run('normal', ['test', '--reporter', 'expanded', '--concurrency=1', *tests],
            accepted=(0, 1) if phase == 'before' else (0,))
    else:
        run('format', ['format', '--output=none', '--set-exit-if-changed',
                       'lib/src/runtime/interpreter.dart', str(NORMAL.relative_to('dart')),
                       str(PROBE.relative_to('dart'))] if NORMAL.exists() else
            ['format', str(PROBE.relative_to('dart'))])
    for row in custody:
        for name, expected in row['files'].items():
            if row['tag'] == 'root' and name == str(CONFIG):
                continue
            if mode == 'format' and name == str(PROBE):
                continue  # Formatter input is retained; final bytes are separately captured.
            path = Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest() == expected['sha256'], name
            assert path.stat().st_mode & 0o777 == expected['mode'], name
    if mode == 'routes':
        assert fresh.parent == OUT and not fresh.is_symlink()
        shutil.rmtree(fresh)  # Exact owned duplicate; recoverable bytes remain in verified archives.
    print(phase + ': acquisition complete; grade actual retained observations separately')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
