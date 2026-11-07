"""One-shot finite Rust acquisition with first-use inputs and complete channels."""
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
ACTIVATION = 'b0376420ba6258420b146981b848d4646fb3ff55'
OWNER = Path('rust/linkedspec-runtime/src/engine.rs')
NORMAL = Path('rust/linkedspec-runtime/tests/array_transform_result_guard_composition.rs')
PROFILE = Path('tests/fixtures/array_transform_result_guard_rust_profiles.json')
CONTROL = BASE / 'control-owner'
phase, mode = sys.argv[1:]
assert (phase, mode) in {('intake', 'routes'), ('before', 'test'), ('after', 'routes'),
                        ('private-old', 'private'), ('private-fixed', 'private'),
                        ('direct', 'direct'), ('format', 'format')}
OUT = BASE / phase
OUT.mkdir()
environment = dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
custody = []


def run(tag, command, accepted=(0,)):
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(
        argv=command, cwd='.', environment=environment), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, **environment),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(
            gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in accepted, f'{tag} exit{result.returncode}; full channels retained'


def cargo(tag, arguments, accepted=(0,)):
    run(tag, ['bash', 'tools/run_cargo_local.sh', *arguments], accepted)


def freeze(tag, paths):
    files = {}
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts
        assert path.is_file() and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        files[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body),
                                mode=path.stat().st_mode & 0o777)
    archive_path = OUT / (tag + '-before-first-run.tar.gz')
    with tarfile.open(archive_path, 'w:gz') as archive:
        for path in files:
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(archive_path) as archive:
        actual = {m.name: (hashlib.sha256(archive.extractfile(m).read()).hexdigest(), m.mode & 0o777)
                  for m in archive}
    assert actual == {p: (r['sha256'], r['mode']) for p, r in files.items()}
    custody.append(dict(archive=str(archive_path), files=files))
    (OUT / 'custody.json').write_text(json.dumps(custody, indent=2, sort_keys=True) + '\n')


def verify():
    for record in custody:
        for name, row in record['files'].items():
            path = Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
            assert path.stat().st_mode & 0o777 == row['mode']


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    (OUT / 'activation.txt').write_text(ACTIVATION + '\n')
    paths = [Path(p) for p in subprocess.check_output(
        ['git', 'ls-files', 'rust', 'tests/fixtures'], text=True).splitlines()]
    paths += [Path(p) for p in ('tools/project_data_env.sh', 'tools/run_cargo_local.sh',
                               'tools/run_python_project_data.sh', 'tools/project_data_run.sh',
                               'cli_conformance/cases/help/stdout.txt')]
    paths += [p for p in BASE.iterdir() if p.is_file() and p.suffix in ('.py', '.rs', '.json', '.gz')]
    paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths += [p for p in (NORMAL, PROFILE) if p.exists()]
    sdk = Path('rust')
    if mode == 'private':
        if phase == 'private-old':
            assert not CONTROL.exists()
            for source in sorted(set(paths)):
                if source.parts[0] not in ('rust', 'specs', 'tests', 'cli_conformance'):
                    continue
                target = CONTROL / source
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, target)
            manifest = CONTROL / 'rust/Cargo.toml'
            original = manifest.read_text()
            dependency = os.path.relpath(ROOT / 'rgx/rgx-core', (ROOT / manifest).parent)
            assert original.count('path = "../rgx/rgx-core"') == 1
            manifest.write_text(original.replace('path = "../rgx/rgx-core"', 'path = "' + dependency + '"'))
            (CONTROL / OWNER).write_bytes(subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(OWNER)]))
        else:
            prior = json.loads((BASE / 'private-old/custody.json').read_bytes())[0]['files']
            for name, row in prior.items():
                if name.startswith(str(CONTROL) + '/'):
                    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256']
            (CONTROL / OWNER).write_bytes(OWNER.read_bytes())
        sdk = CONTROL / 'rust'
        paths += [p for p in CONTROL.rglob('*') if p.is_file()]
    if mode == 'routes':
        cases = json.loads(Path('tests/fixtures/array_transform_result_guard_cases.json').read_bytes())
        cases += json.loads((BASE / 'additional-targets.json').read_bytes())
        cases += json.loads((BASE / 'profile-sources.json').read_bytes())
        assert len(cases) == len({c['id'] for c in cases}) == 195
        (OUT / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
        paths.append(OUT / 'cases.json')
    freeze('root', paths)
    cargo('cargo-version', ['--version'])
    run('rustc-version', ['rustc', '-Vv'])
    if mode == 'routes':
        native, fresh = OUT / 'native', OUT / 'fresh'
        for directory in (native, fresh):
            (directory / 'src').mkdir(parents=True)
            core = os.path.relpath(ROOT / sdk / 'linkedspec-core', ROOT / directory)
            runtime = os.path.relpath(ROOT / sdk / 'linkedspec-runtime', ROOT / directory)
            name = 'array-transform-result-rust-' + ('native' if directory == native else 'fresh')
            dependencies = 'linkedspec-core = { path = "' + core + '" }\n' if directory == native else ''
            (directory / 'Cargo.toml').write_text(
                f'[package]\nname = "{name}"\nversion = "0.0.0"\nedition = "2024"\npublish = false\n\n'
                '[dependencies]\n' + dependencies + 'linkedspec-runtime = { path = "' + runtime + '" }\nserde_json = "1"\n')
        (native / 'src/main.rs').write_bytes((BASE / 'observer.rs').read_bytes())
        cargo('native-lock', ['generate-lockfile', '--manifest-path', str(native / 'Cargo.toml'), '--offline'])
        freeze('native', list(native.rglob('*.rs')) + [native / 'Cargo.toml', native / 'Cargo.lock', OUT / 'cases.json'])
        cargo('native', ['run', '--manifest-path', str(native / 'Cargo.toml'), '--locked', '--offline', '-j', '1', '--', str(fresh)])
        cargo('fresh-lock', ['generate-lockfile', '--manifest-path', str(fresh / 'Cargo.toml'), '--offline'])
        freeze('fresh', list(fresh.rglob('*.rs')) + list((fresh / 'inputs').glob('*.json')) + [fresh / 'Cargo.toml', fresh / 'Cargo.lock'])
        cargo('fresh', ['run', '--manifest-path', str(fresh / 'Cargo.toml'), '--locked', '--offline', '-j', '1'])
        verify()
        for directory in (native, fresh):
            assert directory.parent == OUT and not directory.is_symlink()
            shutil.rmtree(directory)
    elif mode in ('test', 'direct', 'private'):
        names = ['array_transform_result_guard_composition']
        if mode == 'direct':
            names += ['hash_value_result_guard_composition', 'value_copy']
        arguments = ['test', '--manifest-path', str(sdk / 'Cargo.toml'), '--locked', '--offline', '-j', '1', '-p', 'linkedspec-runtime']
        for name in names:
            arguments += ['--test', name]
        cargo('normal', arguments + ['--', '--nocapture', '--test-threads=1'],
              (0, 101) if phase in ('before', 'private-old') else (0,))
        stdout = gzip.decompress((OUT / 'normal-stdout.log.gz').read_bytes()).decode()
        stderr = gzip.decompress((OUT / 'normal-stderr.log.gz').read_bytes()).decode()
        frames = [line for line in stderr.splitlines() if line.startswith('ARRAY_TRANSFORM_RUST_NORMAL ')]
        assert len(frames) == 195 and len({line.split(' ', 2)[1] for line in frames}) == 195
        assert 'test result:' in stdout and '0 ignored; 0 measured; 0 filtered out' in stdout
        verify()
        if phase == 'private-fixed':
            assert CONTROL.parent == BASE and not CONTROL.is_symlink()
            shutil.rmtree(CONTROL)
    else:
        run('format', ['rustfmt', '--edition', '2024', '--check', str(OWNER), str(NORMAL)])
        verify()
    print(phase + ': declared first-use inputs, actual artifacts and full command channels retained')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
