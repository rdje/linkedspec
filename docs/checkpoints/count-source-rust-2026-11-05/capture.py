"""One-shot Rust public SDK acquisition with actual pre-first-run Cargo inputs."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile

ROOT = Path.cwd()
BASE = Path(__file__).resolve().parent.relative_to(ROOT.resolve())
phase = sys.argv[1]
assert phase in ('before', 'before-qualified', 'after')
is_baseline = phase.startswith('before')
OUT = BASE / phase
OUT.mkdir()  # Refuse historical replay.
env = dict(os.environ, CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
custody = []


def run(tag, arguments, accepted=(0,)):
    command = ['bash', 'tools/ram_guard.sh', '--danger-pct', '86',
               '--ceiling-mb', '2048', '--', 'bash', 'tools/run_cargo_local.sh', *arguments]
    (OUT / (tag + '-command.json')).write_text(json.dumps(command) + '\n')
    with (OUT / (tag + '-stdout.log')).open('wb') as stdout, (OUT / (tag + '-stderr.log')).open('wb') as stderr:
        result = subprocess.run(command, env=env, stdout=stdout, stderr=stderr)
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in accepted, f'{tag}: setup/run exit {result.returncode}; inspect raw channels'


def freeze(tag, paths):
    files = {}
    for path in paths:
        assert path.is_file() and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        files[path.as_posix()] = {'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw)}
    archive_path = OUT / (tag + '-before-first-run.tar.gz')
    with tarfile.open(archive_path, 'w:gz') as archive:
        for path in sorted(files):
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(archive_path) as archive:
        recovered = {item.name: hashlib.sha256(archive.extractfile(item).read()).hexdigest()
                     for item in archive.getmembers() if item.isfile()}
    assert recovered == {path: record['sha256'] for path, record in files.items()}
    custody.append({'archive': archive_path.as_posix(), 'files': files})


(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
cases = json.loads(Path('tests/fixtures/count_source_fallback_cases.json').read_text())
(OUT / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
run('cargo-version', ['--version'])
with (OUT / 'rustc-version.txt').open('wb') as handle:
    subprocess.run(['rustc', '-Vv'], stdout=handle, check=True, env=env)
freeze('root', [Path(name) for name in (
    'rust/Cargo.toml', 'rust/Cargo.lock', 'rust/linkedspec-core/Cargo.toml',
    'rust/linkedspec-runtime/Cargo.toml', 'rust/linkedspec-runtime/src/engine.rs',
    'rust/linkedspec-runtime/tests/count_source_fallback.rs',
    'rust/linkedspec-runtime/tests/count_result_guard_composition.rs',
    'rust/linkedspec-runtime/tests/count_length_receivers.rs',
    'rust/linkedspec-runtime/tests/copied_null_index_composition.rs',
    'tests/fixtures/count_source_fallback_cases.json')])
run('normal', ['test', '--manifest-path', 'rust/Cargo.toml', '--locked', '--offline',
               '-p', 'linkedspec-runtime', '--test', 'count_source_fallback',
               '--', '--nocapture', '--test-threads=1'], (0, 101) if is_baseline else (0,))

native = OUT / 'native'
fresh = OUT / 'fresh'
for directory in (native, fresh):
    (directory / 'src').mkdir(parents=True)
    dependencies = ('linkedspec-core = { path = "../../../../../rust/linkedspec-core" }\n'
                    if directory == native else '')
    name = 'count-copy-source-rust-' + ('native' if directory == native else 'fresh')
    (directory / 'Cargo.toml').write_text(
        f'[package]\nname = "{name}"\nversion = "0.0.0"\nedition = "2024"\npublish = false\n\n'
        '[dependencies]\n' + dependencies +
        'linkedspec-runtime = { path = "../../../../../rust/linkedspec-runtime" }\nserde_json = "1"\n')
(native / 'src/main.rs').write_bytes((BASE / 'observer.rs').read_bytes())
run('native-lock', ['generate-lockfile', '--manifest-path', str(native / 'Cargo.toml'), '--offline'])
freeze('native', list(native.rglob('*rs')) + [native / 'Cargo.toml', native / 'Cargo.lock', OUT / 'cases.json'])
run('native', ['run', '--manifest-path', str(native / 'Cargo.toml'), '--locked', '--offline', '--', str(fresh)])
run('fresh-lock', ['generate-lockfile', '--manifest-path', str(fresh / 'Cargo.toml'), '--offline'])
freeze('fresh', list(fresh.rglob('*rs')) + [fresh / 'Cargo.toml', fresh / 'Cargo.lock'])
run('fresh', ['run', '--manifest-path', str(fresh / 'Cargo.toml'), '--locked', '--offline'])

# Verify surviving actual inputs against their first captures, before removing
# only these two redundant acquisition directories. Global managed caches stay.
for record in custody:
    for name, expected in record['files'].items():
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == expected['sha256'], name
for directory in (native, fresh):
    assert not directory.is_symlink() and directory.parent == OUT
    shutil.rmtree(directory)
    assert not directory.exists()
(OUT / 'custody.json').write_text(json.dumps(custody, sort_keys=True, indent=2) + '\n')
print(f'{phase}: actual root/native/fresh Cargo inputs retained; owned acquisition workspaces sealed')
