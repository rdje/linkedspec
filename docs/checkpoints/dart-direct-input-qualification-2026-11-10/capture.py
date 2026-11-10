"""Qualify one unchanged Dart direct command with explicit before-use inputs."""
import gzip
import hashlib
import io
import json
import os
from pathlib import Path
import subprocess
import tarfile
import traceback

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
CONFIG = Path('dart/.dart_tool/package_config.json')
SPEC = json.loads((BASE / 'inputs.json').read_bytes())
ORIGINAL = Path(SPEC['original_packet'])
OUT = BASE / 'qualified'
OUT.mkdir()
environment = dict(os.environ, TERM='dumb', NO_COLOR='1')


def digest(body):
    return hashlib.sha256(body).hexdigest()


def original_files():
    archive_body = subprocess.check_output(
        ['git', 'archive', '--format=tar', SPEC['original_revision'], str(ORIGINAL)])
    with tarfile.open(fileobj=io.BytesIO(archive_body)) as archive:
        files = {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}
    for name, body in files.items():
        current = Path(name).read_bytes()
        if name == str(ORIGINAL / 'REVIEW.md'):
            assert current.startswith(body), 'Original explanation rewritten'
        else:
            assert current == body, 'Original packet changed: ' + name
    sealed = json.loads(files[str(ORIGINAL / 'sealed-identities.json')])
    for name, expected in sealed.items():
        assert digest(files[name]) == expected['sha256'] and len(files[name]) == expected['bytes']
        assert Path(name).read_bytes() == files[name], 'Original proof changed: ' + name
    return files


def freeze(tag, paths):
    records = {}
    target = OUT / (tag + '-before-first-run.tar.gz')
    with tarfile.open(target, 'w:gz') as archive:
        for path in sorted(set(paths)):
            assert not path.is_absolute() and '..' not in path.parts
            assert path.is_file() and not path.is_symlink()
            assert path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            records[str(path)] = dict(bytes=len(body), sha256=digest(body), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(target) as archive:
        assert set(archive.getnames()) == records.keys()
        for member in archive:
            row = records[member.name]
            body = archive.extractfile(member).read()
            assert digest(body) == row['sha256'] and len(body) == row['bytes']
            assert member.mode & 0o777 == row['mode']
    (OUT / (tag + '-identities.json')).write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
    return records


def verify(records, historical_config=False):
    for name, row in records.items():
        if historical_config and name == str(CONFIG):
            continue
        path = Path(name)
        assert path.is_file() and not path.is_symlink()
        assert digest(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], name


def run(tag, command):
    assert command['cwd'] == 'dart'
    (OUT / (tag + '-command.json')).write_text(json.dumps(command, indent=2) + '\n')
    result = subprocess.run(command['argv'], cwd=ROOT / command['cwd'], env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, tag + ': actual failure retained; no qualified credit'
    return result


def main():
    (OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
    old = original_files()
    old_custody = json.loads(old[str(ORIGINAL / 'direct/custody.json')])
    original_inputs = next(row['files'] for row in old_custody if row['tag'] == 'root')
    required = {SPEC['grammar'], *SPEC['consumers']}
    required.update(path for paths in SPEC['consumers'].values() for path in paths)
    missing = sorted(required - original_inputs.keys())
    assert missing == sorted(SPEC['additional_original_omissions'])
    original_check = dict(original_revision=SPEC['original_revision'],
        original_proof_preserved='PASS', explicit_original_binding='INCOMPLETE', missing=missing,
        limitation='Existing Git fixtures do not establish omitted actual first-use identities.')
    (OUT / 'original-preservation.json').write_text(json.dumps(original_check, indent=2) + '\n')
    # Verify actual unchanged owned Dart source before any SDK use. New fixtures
    # receive their own current bindings, without retroactive original credit.
    for name, expected in original_inputs.items():
        if name.startswith('dart/') and name != str(CONFIG):
            assert digest(Path(name).read_bytes()) == expected['sha256'], name
            assert Path(name).stat().st_mode & 0o777 == expected['mode'], name
    paths = [Path(p) for p in subprocess.check_output(
        ['git', 'ls-files', 'dart', 'tests/fixtures'], text=True).splitlines()]
    paths += [Path(p) for p in required]
    paths += list(BASE.glob('*.py')) + [BASE / 'inputs.json']
    paths += [Path('tools') / p for p in ('run_dart_project_data.sh', 'project_data_env.sh',
                                        'project_data_run.sh', 'run_python_project_data.sh')]
    if CONFIG.exists():
        paths.append(CONFIG)
    records = freeze('source', paths)
    assert not Path('dart/specs/user_function_definition.spec').exists(), 'Unexpected nearer default grammar'
    (OUT / 'default-grammar-resolution.json').write_text(json.dumps(dict(
        cwd='dart', nearer_candidate='dart/specs/user_function_definition.spec',
        nearer_candidate_exists=False, selected=SPEC['grammar'],
        selected_sha256=records[SPEC['grammar']]['sha256']), indent=2) + '\n')
    prefix = ['bash', '../tools/run_dart_project_data.sh']
    common = dict(cwd='dart', environment=dict(TERM='dumb', NO_COLOR='1'))
    run('version', dict(common, argv=prefix + ['--version']))
    run('resolution', dict(common, argv=prefix + ['pub', 'get', '--offline', '--enforce-lockfile']))
    resolved = freeze('resolved', [Path('dart/pubspec.yaml'), Path('dart/pubspec.lock'),
                                   *Path('dart/.dart_tool').glob('*.json')])
    command = json.loads(old[str(ORIGINAL / 'direct/normal-command.json')])
    assert command['argv'] == prefix + ['test', '--reporter', 'expanded', '--concurrency=1',
                                       *[path.removeprefix('dart/') for path in SPEC['consumers']]]
    run('normal', command)
    verify(records, historical_config=True)
    verify(resolved)
    original_files()
    print('Qualified unchanged direct run completed; original proof preserved and six formerly unbound fixture inputs captured before SDK use')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
