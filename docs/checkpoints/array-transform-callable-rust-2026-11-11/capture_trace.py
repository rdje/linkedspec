"""One-shot Rust four-route acquisition with inputs/products before execution."""
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
OUT = BASE / 'trace'
OUT.mkdir()
ACTIVATION = '238da4cc727e9f5921990ef5e8575b45ceac2887'
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
    ids = {'drop_logical_later_with', 'take_receiver_hash_guard', 'initial_number_composed', 'reverse_copy_later_with', 'take_later_with', 'own_signature_variadic_multi_composed', 'source_effect_before_rejection'}
    cases = [case for case in json.loads((BASE / 'intake/cases.json').read_bytes()) if case['id'] in ids]
    assert len(cases) == len(ids) == 7
    (OUT / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
    project = OUT / 'runner'
    (project / 'src').mkdir(parents=True)
    runtime = os.path.relpath(ROOT / 'rust/linkedspec-runtime', ROOT / project)
    core = os.path.relpath(ROOT / 'rust/linkedspec-core', ROOT / project)
    (project / 'Cargo.toml').write_text('[package]\nname="callable-transform-trace-rust"\nversion="0.0.0"\nedition="2024"\npublish=false\n[dependencies]\nlinkedspec-core={path="' + core + '"}\nlinkedspec-runtime={path="' + runtime + '"}\nserde_json="1"\n')
    (project / 'src/main.rs').write_bytes((BASE / 'trace_observer.rs').read_bytes())
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'rust'], text=True).splitlines()]
    paths += [Path(p) for p in ('tools/project_data_env.sh', 'tools/project_data_run.sh',
        'tools/run_cargo_local.sh', 'cli_conformance/cases/help/stdout.txt')]
    paths += [Path('specs') / p for p in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
    paths += [BASE / name for name in ('capture_trace.py', 'trace_observer.rs', 'intake/cases.json')]
    paths += [OUT / 'cases.json', project / 'src/main.rs', project / 'Cargo.toml']
    freeze('root', paths)
    cargo('lock', ['generate-lockfile', '--manifest-path', str(project / 'Cargo.toml'), '--offline'])
    freeze('source', [project / 'src/main.rs', project / 'Cargo.toml', project / 'Cargo.lock', OUT / 'cases.json'])
    meta = json.loads(cargo('metadata', ['metadata', '--manifest-path', str(project / 'Cargo.toml'), '--locked', '--offline', '--no-deps', '--format-version', '1']))
    cargo('build', ['build', '--manifest-path', str(project / 'Cargo.toml'), '--locked', '--offline', '-j', '1'])
    executable = product('trace', meta, 'callable-transform-trace-rust')
    run('trace', ['bash', 'tools/project_data_run.sh', str(executable), str(OUT)])
    freeze('actual-traces', list(OUT.glob('*.trace.log')) + list((OUT / 'inputs').glob('*.json')) + list((OUT / 'parsed-inputs').glob('*.json')))
    for packet in custody:
        for name, row in packet['files'].items():
            assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256'], name
    print('Seven public traced Engine probes complete; inputs/products/channels and actual traces retained')


try:
    main()
except BaseException:
    (OUT / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
