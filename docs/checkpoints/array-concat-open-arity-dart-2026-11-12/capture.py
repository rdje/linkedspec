"""One-shot Dart proof epochs with explicit own/external fixture closure."""
import gzip
import hashlib
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import traceback
from urllib.parse import unquote, urljoin, urlparse

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '1753884257bed7ce0b842bc406c665671403a828'
PROBE = Path('dart/tool/probe_open_arity_array_concat_results.dart')
NORMAL = Path('dart/test/array_concat_open_arity_result_guard_composition_test.dart')
PROFILE = Path('tests/fixtures/array_concat_open_arity_result_guard_dart_profiles.json')
CONFIG = Path('dart/.dart_tool/package_config.json')
phase, mode = sys.argv[1:]
assert (phase, mode) in {('before', 'test'), ('after', 'routes'), ('direct', 'test'), ('format', 'format')}
OUT = BASE / phase
OUT.mkdir()
ENVIRONMENT = dict(TERM='dumb', NO_COLOR='1')
if mode == 'test':
    ENVIRONMENT['LINKEDSPEC_ARRAY_CONCAT_DART_CAPTURE'] = phase
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


def run(tag, arguments, cwd=Path('dart'), accepted=(0,)):
    command = ['bash', os.path.relpath(ROOT / 'tools/run_dart_project_data.sh', ROOT / cwd), *arguments]
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd=str(cwd), environment=ENVIRONMENT), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT / cwd, env=dict(os.environ, **ENVIRONMENT), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in accepted, tag + ': actual failure retained'
    return result


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    (OUT / 'activation.txt').write_text(ACTIVATION + '\n')
    command = ['bash', 'tools/project_data_run.sh', 'memory_pressure']
    (OUT / 'memory-command.json').write_text(json.dumps(dict(argv=command, cwd='.', environment=ENVIRONMENT), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, **ENVIRONMENT), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / ('memory-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / 'memory-exit.txt').write_text(str(result.returncode) + '\n')
    free = re.search(rb'System-wide memory free percentage: (\d+)%', result.stdout)
    assert result.returncode == 0 and free and int(free[1]) >= 45, 'Need conservative shared24GiB headroom before serial Dart work'
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'dart', 'tests/fixtures'], text=True).splitlines()]
    paths += [PROBE, NORMAL, PROFILE, Path('tests/fixtures/array_concat_open_arity_dart_cases.json'), Path('dart/tool/callable_array_transform_observation.dart')]
    paths += [p for p in BASE.iterdir() if p.is_file()]
    paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh', 'run_dart_project_data.sh')]
    # The selected old normal reads cases outside dart. Copy fixtures/default
    # grammar are also actual inputs, not implied by a passing test command.
    paths += [Path(name) for name in ('docs/checkpoints/array-transform-result-guard-dart-2026-11-10/cases.json', 'docs/checkpoints/array-pipeline-callable-dart-2026-11-11/cases.json', 'docs/checkpoints/array-transform-callable-dart-2026-11-12/cases.json')]
    if CONFIG.exists():
        paths.append(CONFIG)
    if mode == 'routes':
        (OUT / 'cases.json').write_bytes((BASE / 'cases.json').read_bytes())
        paths.append(OUT / 'cases.json')
    freeze('root', paths)
    assert not Path('dart/specs/user_function_definition.spec').exists()
    (OUT / 'default-grammar-resolution.json').write_text(json.dumps(dict(cwd='dart',
        nearer_candidate='dart/specs/user_function_definition.spec', nearer_candidate_exists=False,
        selected='specs/user_function_definition.spec',
        selected_sha256=hashlib.sha256(Path('specs/user_function_definition.spec').read_bytes()).hexdigest()), indent=2) + '\n')
    run('version', ['--version'])
    run('resolution', ['pub', 'get', '--offline', '--enforce-lockfile'])
    own = next(p for p in json.loads(CONFIG.read_bytes())['packages'] if p['name'] == 'linkedspec_dart')
    uri = urlparse(urljoin((ROOT / CONFIG).as_uri(), own['rootUri']))
    assert uri.scheme == 'file' and not uri.netloc
    assert Path(unquote(uri.path)).resolve() == (ROOT / 'dart').resolve(), 'actual own SDK routing'
    (OUT / 'sdk-routing.json').write_text(json.dumps(dict(package='linkedspec_dart', config=str(CONFIG), root='dart'), indent=2) + '\n')
    freeze('resolved', [Path('dart/pubspec.yaml'), Path('dart/pubspec.lock'), *Path('dart/.dart_tool').glob('*.json')])
    if mode == 'routes':
        run('analysis', ['analyze', '--fatal-infos', '--fatal-warnings', str(PROBE.relative_to('dart'))])
        fresh = OUT / 'fresh'
        fresh.mkdir()
        own_path = os.path.relpath(ROOT / 'dart', ROOT / fresh)
        (fresh / 'pubspec.yaml').write_text('name: array_concat_open_arity_dart_fresh\npublish_to: none\nenvironment:\n  sdk: ">=3.9.0 <4.0.0"\ndependencies:\n  linkedspec_dart:\n    path: ' + own_path + '\n')
        freeze('native', [PROBE, Path('dart/tool/callable_array_transform_observation.dart'), OUT / 'cases.json', fresh / 'pubspec.yaml'])
        run('native', ['run', str(PROBE.relative_to('dart')), str(OUT)])
        artifacts = list(fresh.rglob('*.dart')) + list((fresh / 'inputs').glob('*.json'))
        assert len(list((fresh / 'inputs').glob('*.json'))) == 508
        freeze('emitted', artifacts + [fresh / 'pubspec.yaml'])
        run('fresh-resolution', ['pub', 'get', '--offline'], fresh)
        freeze('fresh', artifacts + [fresh / 'pubspec.yaml', fresh / 'pubspec.lock', *list((fresh / '.dart_tool').glob('*.json'))])
        run('fresh-analysis', ['analyze', '--fatal-infos', '--fatal-warnings'], fresh)
        run('fresh', ['run', 'bin/main.dart'], fresh)
    elif mode == 'test':
        tests = [str(NORMAL.relative_to('dart'))]
        if phase == 'direct':
            tests += ['test/array_transform_callable_result_guard_composition_test.dart', 'test/array_transform_result_guard_composition_test.dart', 'test/array_pipeline_callable_result_guard_composition_test.dart']
        run('analysis', ['analyze', '--fatal-infos', '--fatal-warnings', 'lib/src/runtime/interpreter.dart', *tests, str(PROBE.relative_to('dart'))])
        result = run('normal', ['test', '--reporter', 'expanded', '--concurrency=1', *tests], accepted=(1,) if phase == 'before' else (0,))
        frames = [line for line in result.stdout.decode().splitlines() if line.startswith('ARRAY_CONCAT_DART_NORMAL ')]
        assert len(frames) == len({line.split(' ', 2)[1] for line in frames}) == 508
        expected = b'+484 -24: Some tests failed.' if phase == 'before' else b'+1155: All tests passed!'
        assert expected in result.stdout, 'actual finite semantic count'
    else:
        run('format', ['format', '--output=none', '--set-exit-if-changed', 'lib/src/runtime/interpreter.dart',
            str(NORMAL.relative_to('dart')), str(PROBE.relative_to('dart'))])
    if mode == 'test':
        parsed = Path('.linkedspec-data/scratch/open-arity-concat-dart-normal') / phase
        assert len(list(parsed.glob('*.json'))) == 508
        freeze('normal-parsed', list(parsed.glob('*.json')))
    for packet in custody:
        for name, row in packet['files'].items():
            if packet['tag'] == 'root' and name == str(CONFIG):
                continue
            path = Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
    if mode == 'routes':
        assert fresh.parent == OUT and not fresh.is_symlink()
        shutil.rmtree(fresh)
    print(phase + ': complete declared own/external fixture inputs, routing, artifacts and full channels retained')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
