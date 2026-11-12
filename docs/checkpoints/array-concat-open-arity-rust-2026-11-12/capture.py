"""Finite one-shot Rust proof epochs; archive own inputs and executed products."""
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

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'b3b9795f5c983e4dfb7ffa353b8368657c06bb65'
OWNER = Path('rust/linkedspec-runtime/src/engine.rs')
NORMAL = Path('rust/linkedspec-runtime/tests/array_concat_open_arity_result_guard_composition.rs')
PROFILE = Path('tests/fixtures/array_concat_open_arity_result_guard_rust_profiles.json')
CASES = Path('tests/fixtures/array_concat_open_arity_rust_cases.json')
CONTROL = BASE / 'control-owner'
phase, mode = sys.argv[1:]
assert (phase, mode) in {('before', 'test'), ('after', 'routes'), ('private-old', 'private'),
                        ('private-fixed', 'private'), ('direct', 'direct'), ('format', 'format')}
OUT = BASE / phase
OUT.mkdir()
ENVIRONMENT = dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1', LINKEDSPEC_ARRAY_CONCAT_RUST_CAPTURE=str(OUT))
custody = []


def run(tag, command, accepted=(0,)):
    target = OUT / (tag + '-command.json')
    assert not target.exists()
    target.write_text(json.dumps(dict(argv=command, cwd='.', environment=ENVIRONMENT), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, **ENVIRONMENT),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in accepted, f'{tag}: actual exit{result.returncode} retained'
    return result.stdout


def cargo(tag, arguments):
    return run(tag, ['bash', 'tools/run_cargo_local.sh', *arguments])


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
    custody.append(dict(archive=str(target), files=files))
    (OUT / 'custody.json').write_text(json.dumps(custody, indent=2, sort_keys=True) + '\n')


def product(tag, built):
    built = built.resolve()
    assert built.stat().st_dev == ROOT.stat().st_dev
    body = built.read_bytes()
    (OUT / (tag + '-built-product.json')).write_text(json.dumps(dict(path=str(built.relative_to(ROOT)),
        bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=built.stat().st_mode & 0o777,
        scope='Unstripped identity only; executed stripped copy retained before use. Complete native/toolchain/OS/transitive custody remains4.2.'), indent=2) + '\n')
    executable = OUT / (tag + '-exec')
    assert not executable.exists()
    shutil.copy2(built, executable)
    run(tag + '-strip', ['bash', 'tools/project_data_run.sh', 'strip', '-S', str(executable)])
    freeze(tag + '-product', [executable])
    return executable


def verify():
    for packet in custody:
        for name, row in packet['files'].items():
            path = Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    (OUT / 'activation.txt').write_text(ACTIVATION + '\n')
    memory = run('memory', ['bash', 'tools/project_data_run.sh', 'memory_pressure'])
    free = re.search(rb'System-wide memory free percentage: (\d+)%', memory)
    assert free and int(free[1]) >= 45, 'Need conservative serial-build headroom'
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'rust', 'tests/fixtures'], text=True).splitlines()]
    paths += [Path(p) for p in ('tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_cargo_local.sh',
                               'tools/run_python_project_data.sh', 'cli_conformance/cases/help/stdout.txt')]
    paths += [Path('specs') / p for p in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths += [NORMAL, PROFILE, CASES]
    # Exact SDK instruments only. Later readonly review metadata is not an SDK
    # build input and must never become part of a changing all-directory selector.
    paths += [p for p in BASE.iterdir() if p.is_file()]
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
            (CONTROL / OWNER).write_bytes(gzip.decompress((BASE / 'owner-before.rs.gz').read_bytes()))
        else:
            previous = json.loads((BASE / 'private-old/custody.json').read_bytes())[0]['files']
            for name, row in previous.items():
                if name.startswith(str(CONTROL) + '/'):
                    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256']
            (CONTROL / OWNER).write_bytes(OWNER.read_bytes())
        sdk = CONTROL / 'rust'
        paths += [p for p in CONTROL.rglob('*') if p.is_file()]
    if mode == 'routes':
        cases = json.loads(CASES.read_bytes())
        assert len(cases) == len({c['id'] for c in cases}) == 504
        (OUT / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
        paths.append(OUT / 'cases.json')
    freeze('root', paths)
    cargo('cargo-version', ['--version'])
    run('rustc-version', ['bash', 'tools/project_data_run.sh', 'rustc', '-Vv'])
    cleanup = []
    if mode == 'routes':
        native, fresh = OUT / 'native', OUT / 'fresh'
        for directory in (native, fresh):
            (directory / 'src').mkdir(parents=True)
            core = os.path.relpath(ROOT / sdk / 'linkedspec-core', ROOT / directory)
            runtime = os.path.relpath(ROOT / sdk / 'linkedspec-runtime', ROOT / directory)
            name = 'array-concat-open-arity-rust-' + ('native' if directory == native else 'fresh')
            deps = 'linkedspec-core = { path = "' + core + '" }\n' if directory == native else ''
            (directory / 'Cargo.toml').write_text('[package]\nname = "' + name + '"\nversion = "0.0.0"\nedition = "2024"\npublish = false\n\n[dependencies]\n'
                + deps + 'linkedspec-runtime = { path = "' + runtime + '" }\nserde_json = "1"\n')
        (native / 'src/main.rs').write_bytes((BASE / 'observer.rs').read_bytes())
        for label, directory in [('native', native), ('fresh', fresh)]:
            cargo(label + '-lock', ['generate-lockfile', '--manifest-path', str(directory / 'Cargo.toml'), '--offline'])
            freeze(label + '-source', list(directory.rglob('*.rs')) + list((directory / 'inputs').glob('*.json')) + list((directory / 'parsed-inputs').glob('*.json'))
                + [directory / 'Cargo.toml', directory / 'Cargo.lock'] + ([OUT / 'cases.json'] if label == 'native' else []))
            metadata = json.loads(cargo(label + '-metadata', ['metadata', '--manifest-path', str(directory / 'Cargo.toml'), '--locked', '--offline', '--no-deps', '--format-version', '1']))
            cargo(label + '-build', ['build', '--manifest-path', str(directory / 'Cargo.toml'), '--locked', '--offline', '-j', '1'])
            executable = product(label, Path(metadata['target_directory']) / 'debug' / ('array-concat-open-arity-rust-' + label))
            run(label, ['bash', 'tools/project_data_run.sh', str(executable)] + ([str(fresh)] if label == 'native' else []))
            cleanup += [executable]
        cleanup += [native, fresh]
    elif mode in ('test', 'private', 'direct'):
        names = ['array_concat_open_arity_result_guard_composition']
        if mode == 'direct':
            names += ['array_transform_result_guard_composition', 'array_transform_callable_result_guard_composition', 'array_pipeline_callable_result_guard_composition']
        arguments = ['test', '--manifest-path', str(sdk / 'Cargo.toml'), '--locked', '--offline', '-j', '1', '-p', 'linkedspec-runtime', '--no-run', '--message-format=json']
        for name in names:
            arguments += ['--test', name]
        messages = cargo('normal-build', arguments)
        products = {}
        for line in messages.decode().splitlines():
            if not line.startswith('{'):
                continue
            row = json.loads(line)
            if row.get('reason') == 'compiler-artifact' and row.get('profile', {}).get('test') and row.get('executable') and row['target']['name'] in names:
                name = row['target']['name']
                assert name not in products
                products[name] = Path(row['executable'])
        assert set(products) == set(names)
        for index, name in enumerate(names):
            tag = 'normal' if index == 0 else name
            executable = product(tag, products[name])
            run(tag, ['bash', 'tools/project_data_run.sh', str(executable), '--nocapture', '--test-threads=1'],
                (101,) if phase in ('before', 'private-old') and index == 0 else (0,))
            stdout = gzip.decompress((OUT / (tag + '-stdout.log.gz')).read_bytes()).decode()
            if index == 0:
                stderr = gzip.decompress((OUT / (tag + '-stderr.log.gz')).read_bytes()).decode()
                frames = [line for line in stderr.splitlines() if line.startswith('ARRAY_CONCAT_RUST_NORMAL ')]
                assert len(frames) == len({line.split(' ', 2)[1] for line in frames}) == 504
                count = '486 passed; 18 failed' if phase in ('before', 'private-old') else '504 passed; 0 failed'
                assert count in stdout
            else:
                assert ('195 passed; 0 failed' if index == 1 else '312 passed; 0 failed' if index == 2 else '194 passed; 0 failed') in stdout
            cleanup += [executable]
    else:
        run('format', ['bash', 'tools/project_data_run.sh', 'rustfmt', '--edition', '2024', '--check', str(OWNER), str(NORMAL)])
    if mode in ('test', 'private', 'direct'):
        freeze('normal-serialized', list((OUT / 'normal-inputs').glob('*.json')))
        freeze('normal-parsed', list((OUT / 'normal-parsed').glob('*.json')))
    verify()
    if phase == 'private-fixed':
        cleanup += [CONTROL]
    for path in cleanup:
        assert str(path).startswith(str(BASE) + '/') and not path.is_symlink()
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()
    print(phase + ': actual first-use inputs/executed products and complete channels retained')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
