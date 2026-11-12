"""One-shot Rust four-route acquisition with inputs/products before execution."""
import gzip
import hashlib
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import tarfile
import traceback

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'intake'
OUT.mkdir()
ACTIVATION = 'b3b9795f5c983e4dfb7ffa353b8368657c06bb65'
ENVIRONMENT = dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
custody = []


def run(tag, command):
    target = OUT / (tag + '-command.json')
    assert not target.exists()
    target.write_text(json.dumps(dict(argv=command, cwd='.', environment=ENVIRONMENT), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, **ENVIRONMENT), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, tag + ': actual failure retained before retry'
    return result.stdout


def cargo(tag, args):
    return run(tag, ['bash', 'tools/run_cargo_local.sh', *args])


def freeze(tag, paths):
    records = {}
    for p in sorted(set(paths)):
        assert not p.is_absolute() and '..' not in p.parts and p.is_file() and not p.is_symlink()
        assert p.stat().st_dev == ROOT.stat().st_dev
        raw = p.read_bytes()
        records[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=p.stat().st_mode & 0o777)
    target = OUT / (tag + '-inputs.tar.gz')
    with tarfile.open(target, 'x:gz') as archive:
        for p in records:
            archive.add(p, arcname=p, recursive=False)
    with tarfile.open(target) as archive:
        assert len(archive.getnames()) == len(records) and set(archive.getnames()) == set(records)
        for member in archive:
            raw = archive.extractfile(member).read()
            row = records[member.name]
            assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    custody.append(dict(archive=str(target), files=records))
    (OUT / 'custody.json').write_text(json.dumps(custody, indent=2, sort_keys=True) + '\n')


def product(tag, metadata, binary):
    target = Path(metadata['target_directory']).resolve()
    assert target.stat().st_dev == ROOT.stat().st_dev
    built = target / 'debug' / binary
    source = built.relative_to(ROOT)
    raw = built.read_bytes()
    (OUT / (tag + '-built-product.json')).write_text(json.dumps(dict(path=str(source), bytes=len(raw),
        sha256=hashlib.sha256(raw).hexdigest(), mode=built.stat().st_mode & 0o777,
        scope='Unstripped build-product identity only; complete upstream native/toolchain custody remains4.2. The actual executed copy below is retained after strip -S.'), indent=2) + '\n')
    executable = OUT / (tag + '-exec')
    assert not executable.exists()
    shutil.copy2(built, executable)
    run(tag + '-strip', ['bash', 'tools/project_data_run.sh', 'strip', '-S', str(executable)])
    # The stripped executable is the actual owned SDK instrument. Preserve its
    # bytes before execution; full toolchain/OS/dependency custody stays4.2.
    freeze(tag + '-product', [executable])
    return executable


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    (OUT / 'activation.txt').write_text(ACTIVATION + '\n')
    memory = run('memory', ['bash', 'tools/project_data_run.sh', 'memory_pressure'])
    free = re.search(rb'System-wide memory free percentage: (\d+)%', memory)
    assert free and int(free[1]) >= 45, 'Need conservative shared24GiB headroom before serial Rust builds'
    pin = subprocess.check_output(['git', 'ls-tree', 'HEAD', 'rgx'], text=True).split()[2]
    assert subprocess.check_output(['git', '-C', 'rgx', 'rev-parse', 'HEAD'], text=True).strip() == pin
    public = Path('rgx/docs/INTEGRATION.md')
    assert public.read_bytes() == subprocess.check_output(['git', '-C', 'rgx', 'show', pin + ':docs/INTEGRATION.md'])
    (OUT / 'rgx-public-contract.json').write_text(json.dumps(dict(pin=pin, published_guide=str(public),
        sha256=hashlib.sha256(public.read_bytes()).hexdigest(),
        scope='Published contract/pin metadata only. Prepared outputs are reused through normal own Cargo builds; no submodule writes, implementation inspection or transitive preparation recipe. Complete native/cache/toolchain closure remains4.2/SESSION5.'), indent=2) + '\n')
    cases = json.loads((BASE / 'cases.json').read_bytes())
    assert len(cases) == len({c['id'] for c in cases}) == 504
    (OUT / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
    native, fresh = OUT / 'native', OUT / 'fresh'
    for directory in (native, fresh):
        (directory / 'src').mkdir(parents=True)
        runtime = os.path.relpath(ROOT / 'rust/linkedspec-runtime', ROOT / directory)
        core = os.path.relpath(ROOT / 'rust/linkedspec-core', ROOT / directory)
        name = 'array-concat-open-arity-rust-' + ('native' if directory == native else 'fresh')
        deps = 'linkedspec-core = { path = "' + core + '" }\n' if directory == native else ''
        (directory / 'Cargo.toml').write_text('[package]\nname = "' + name + '"\nversion = "0.0.0"\nedition = "2024"\npublish = false\n\n[dependencies]\n'
            + deps + 'linkedspec-runtime = { path = "' + runtime + '" }\nserde_json = "1"\n')
    (native / 'src/main.rs').write_bytes((BASE / 'observer.rs').read_bytes())
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'rust', 'tests/fixtures'], text=True).splitlines()]
    paths += [Path(p) for p in ('tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_cargo_local.sh',
                               'tools/run_python_project_data.sh', 'cli_conformance/cases/help/stdout.txt')]
    paths += [Path('specs') / p for p in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths += [p for p in BASE.iterdir() if p.is_file()]
    paths += [OUT / 'cases.json', native / 'src/main.rs', native / 'Cargo.toml', fresh / 'Cargo.toml']
    paths += [public, OUT / 'rgx-public-contract.json']
    freeze('root', paths)
    cargo('cargo-version', ['--version'])
    run('rustc-version', ['bash', 'tools/project_data_run.sh', 'rustc', '-Vv'])
    cargo('native-lock', ['generate-lockfile', '--manifest-path', str(native / 'Cargo.toml'), '--offline'])
    freeze('native-source', list(native.rglob('*.rs')) + [native / 'Cargo.toml', native / 'Cargo.lock', OUT / 'cases.json'])
    meta = json.loads(cargo('native-metadata', ['metadata', '--manifest-path', str(native / 'Cargo.toml'), '--locked', '--offline', '--no-deps', '--format-version', '1']))
    cargo('native-build', ['build', '--manifest-path', str(native / 'Cargo.toml'), '--locked', '--offline', '-j', '1'])
    executable = product('native', meta, 'array-concat-open-arity-rust-native')
    run('native', ['bash', 'tools/project_data_run.sh', str(executable), str(fresh)])
    cargo('fresh-lock', ['generate-lockfile', '--manifest-path', str(fresh / 'Cargo.toml'), '--offline'])
    freeze('fresh-source', list(fresh.rglob('*.rs')) + list((fresh / 'inputs').glob('*.json')) + list((fresh / 'parsed-inputs').glob('*.json')) + [fresh / 'Cargo.toml', fresh / 'Cargo.lock'])
    meta = json.loads(cargo('fresh-metadata', ['metadata', '--manifest-path', str(fresh / 'Cargo.toml'), '--locked', '--offline', '--no-deps', '--format-version', '1']))
    cargo('fresh-build', ['build', '--manifest-path', str(fresh / 'Cargo.toml'), '--locked', '--offline', '-j', '1'])
    executable = product('fresh', meta, 'array-concat-open-arity-rust-fresh')
    run('fresh', ['bash', 'tools/project_data_run.sh', str(executable)])
    for packet in custody:
        for name, row in packet['files'].items():
            p = Path(name)
            assert hashlib.sha256(p.read_bytes()).hexdigest() == row['sha256'] and p.stat().st_mode & 0o777 == row['mode']
    print('Independent504 public native/restored/plan/fresh observations and actual first-use source/products retained')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
