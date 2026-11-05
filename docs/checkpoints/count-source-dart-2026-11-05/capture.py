"""One-shot Dart source-guard observation and actual first-execution inputs."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
phase = sys.argv[1]
assert phase in ('before', 'after')
OUT = BASE / phase
OUT.mkdir()
env = dict(os.environ, TERM='dumb', NO_COLOR='1')
custody = []


def run(tag, arguments, cwd=Path('dart'), accepted=(0,)):
    guard = os.path.relpath(ROOT / 'tools/ram_guard.sh', ROOT / cwd)
    wrapper = os.path.relpath(ROOT / 'tools/run_dart_project_data.sh', ROOT / cwd)
    command = ['bash', guard, '--danger-pct', '86', '--ceiling-mb', '2048', '--', 'bash', wrapper, *arguments]
    (OUT / (tag + '-command.json')).write_text(json.dumps({'cwd': str(cwd), 'command': command}) + '\n')
    with (OUT / (tag + '-stdout.log')).open('wb') as stdout, (OUT / (tag + '-stderr.log')).open('wb') as stderr:
        result = subprocess.run(command, cwd=ROOT / cwd, env=env, stdout=stdout, stderr=stderr)
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in accepted, f'{tag}: setup/run exit {result.returncode}; inspect raw channels'


def freeze(tag, paths):
    images = {}
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        images[str(path)] = {'bytes': len(body), 'sha256': hashlib.sha256(body).hexdigest()}
    archive_path = OUT / (tag + '-before-first-run.tar.gz')
    with tarfile.open(archive_path, 'w:gz') as archive:
        for name in sorted(images):
            archive.add(name, arcname=name, recursive=False)
    with tarfile.open(archive_path) as archive:
        actual = {m.name: hashlib.sha256(archive.extractfile(m).read()).hexdigest()
                  for m in archive.getmembers() if m.isfile()}
    assert actual == {name: record['sha256'] for name, record in images.items()}
    custody.append({'archive': str(archive_path), 'files': images})


(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
fixture = Path('tests/fixtures/count_boolean_source_cases.json')
(OUT / 'cases.json').write_bytes(fixture.read_bytes())
run('version', ['--version'])
run('root-resolution', ['pub', 'get', '--offline', '--enforce-lockfile'])
root_inputs = [Path(name) for name in (
    'dart/pubspec.yaml', 'dart/pubspec.lock', 'dart/.dart_tool/package_config.json',
    'dart/analysis_options.yaml', 'dart/lib/src/runtime/interpreter.dart',
    'dart/test/count_source_fallback_test.dart', 'dart/tool/probe_count_source_fallback.dart',
    'tests/fixtures/count_boolean_source_cases.json')]
freeze('root', root_inputs)
run('root-analysis', ['analyze', '--fatal-infos', '--fatal-warnings',
                      'lib/src/runtime/interpreter.dart', 'test/count_source_fallback_test.dart',
                      'tool/probe_count_source_fallback.dart'])
run('normal', ['test', '--reporter', 'expanded', '--concurrency=1', 'test/count_source_fallback_test.dart'],
    accepted=(0, 1) if phase == 'before' else (0,))
fresh = OUT / 'fresh'
fresh.mkdir()
(fresh / 'pubspec.yaml').write_text('''name: count_copy_source_dart_fresh
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ../../../../../dart
''')
run('native', ['run', 'tool/probe_count_source_fallback.dart', str(OUT)])
run('fresh-resolution', ['pub', 'get', '--offline'], cwd=fresh)
freeze('fresh', list(fresh.rglob('*.dart')) + [fresh / 'pubspec.yaml', fresh / 'pubspec.lock',
                                           fresh / '.dart_tool/package_config.json'])
run('fresh-analysis', ['analyze', '--fatal-infos', '--fatal-warnings'], cwd=fresh)
run('fresh', ['run', 'bin/main.dart'], cwd=fresh)
for record in custody:
    for name, expected in record['files'].items():
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == expected['sha256'], name
# Retain declared generated source/resolution inputs before removing the owned project.
assert fresh.parent == OUT and not fresh.is_symlink()
shutil.rmtree(fresh)
assert not fresh.exists()
(OUT / 'custody.json').write_text(json.dumps(custody, sort_keys=True, indent=2) + '\n')
print(f'{phase}: Dart root/native and compiled emitted inputs retained and verified')
