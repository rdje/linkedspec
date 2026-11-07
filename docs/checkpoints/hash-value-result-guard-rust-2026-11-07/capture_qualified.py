"""One-shot Rust public-route or focused-test capture; no dependency introspection."""
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
phase, mode = sys.argv[1:]
assert phase in ('qualified-old','qualified-fixed','qualified-direct','qualified-format')
assert mode in ('routes', 'test', 'format')
OUT = BASE / phase
OUT.mkdir()
env = dict(os.environ, CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
custody = []
CONTROL=BASE/'control-owner'
OWNER=Path('rust/linkedspec-runtime/src/engine.rs')
HELP=Path('cli_conformance/cases/help/stdout.txt')
ACTIVATION='4eeb2de5dbe3c6a602bd756a41eb51c0b457692d'
SDK=CONTROL/'rust' if mode=='routes' else Path('rust')


def run(tag, command, accepted=(0,)):
    (OUT / (tag+'-command.json')).write_text(json.dumps(dict(argv=command,
        environment=dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')), indent=2)+'\n')
    result = subprocess.run(command, cwd=ROOT, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag+'-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
    assert result.returncode in accepted, f'{tag}: exit {result.returncode}; full raw channels retained'


def cargo(tag, arguments, accepted=(0,)):
    run(tag, ['bash', 'tools/run_cargo_local.sh', *arguments], accepted)


def freeze(tag, paths):
    files = {}
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts
        assert path.is_file() and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        files[path.as_posix()] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), mode=path.stat().st_mode & 0o777)
    name = OUT / (tag+'-before-first-run.tar.gz')
    with tarfile.open(name, 'w:gz') as archive:
        for path in files:
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(name) as archive:
        recovered = {m.name: (hashlib.sha256(archive.extractfile(m).read()).hexdigest(), m.mode & 0o777)
                     for m in archive.getmembers() if m.isfile()}
    assert recovered == {p:(r['sha256'],r['mode']) for p,r in files.items()}
    custody.append(dict(archive=name.as_posix(), files=files))
    (OUT/'custody.json').write_text(json.dumps(custody,indent=2,sort_keys=True)+'\n')


def verify():
    for record in custody:
        for name, expected in record['files'].items():
            path = Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest() == expected['sha256']
            assert path.stat().st_mode & 0o777 == expected['mode']


def main():
    (OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
    paths = [Path(p) for p in subprocess.check_output(['git','ls-files','rust','tests/fixtures'], text=True).splitlines()]
    paths += [Path(p) for p in ('tools/project_data_env.sh','tools/run_cargo_local.sh','tools/run_python_project_data.sh','tools/project_data_run.sh')]
    paths += [p for p in BASE.iterdir() if p.is_file() and p.suffix in ('.py','.rs','.json')]
    paths += [Path('specs')/name for name in ('spec.spec','user_function_definition.spec','pplugin.spec')]
    paths += [HELP]
    assert HELP.read_bytes()==subprocess.check_output(['git','show',ACTIVATION+':'+str(HELP)])
    if mode=='routes':
        assert CONTROL.is_dir() and not CONTROL.is_symlink()
        if phase=='qualified-old':
            prior=json.loads((BASE/'private-restored/input-identities.json').read_bytes())
        else:
            prior=json.loads((BASE/'qualified-old/custody.json').read_bytes())[0]['files']
        for name,row in prior.items():
            if name.startswith(str(CONTROL)+'/'):
                path=Path(name)
                assert hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256']
                assert path.stat().st_mode & 0o777==row['mode']
        if phase=='qualified-old':
            (CONTROL/HELP).parent.mkdir(parents=True)
            shutil.copy2(HELP,CONTROL/HELP)
        image=subprocess.check_output(['git','show',ACTIVATION+':'+str(OWNER)]) if phase=='qualified-old' else OWNER.read_bytes()
        (CONTROL/OWNER).write_bytes(image)
        paths += [p for p in CONTROL.rglob('*') if p.is_file()]

    for name in ('rust/linkedspec-runtime/tests/hash_value_result_guard_composition.rs','tests/fixtures/hash_value_result_guard_rust_profiles.json'):
        if Path(name).is_file(): paths.append(Path(name))
    if mode == 'routes':
        cases = json.loads(Path('tests/fixtures/hash_value_result_guard_cases.json').read_bytes())
        cases += json.loads((BASE/'profile-sources.json').read_bytes())
        assert len(cases) == len({r['id'] for r in cases}) == 89
        (OUT/'cases.json').write_text(json.dumps(cases,indent=2)+'\n')
        paths += [OUT/'cases.json']
    freeze('root', paths)
    cargo('cargo-version',['--version'])
    run('rustc-version',['rustc','-Vv'])
    if mode == 'routes':
        native, fresh = OUT/'native', OUT/'fresh'
        for directory in (native, fresh):
            (directory/'src').mkdir(parents=True)
            core=os.path.relpath(ROOT/SDK/'linkedspec-core',ROOT/directory)
            runtime=os.path.relpath(ROOT/SDK/'linkedspec-runtime',ROOT/directory)
            dependency = 'linkedspec-core = { path = "'+core+'" }\n' if directory == native else ''
            name = 'hash-value-result-rust-'+('native' if directory == native else 'fresh')
            (directory/'Cargo.toml').write_text(f'[package]\nname = "{name}"\nversion = "0.0.0"\nedition = "2024"\npublish = false\n\n[dependencies]\n'+dependency+'linkedspec-runtime = { path = "'+runtime+'" }\nserde_json = "1"\n')
        (native/'src/main.rs').write_bytes((BASE/'observer.rs').read_bytes())
        cargo('native-lock',['generate-lockfile','--manifest-path',str(native/'Cargo.toml'),'--offline'])
        freeze('native',list(native.rglob('*.rs'))+[native/'Cargo.toml',native/'Cargo.lock',OUT/'cases.json'])
        cargo('native',['run','--manifest-path',str(native/'Cargo.toml'),'--locked','--offline','-j','1','--',str(fresh)])
        cargo('fresh-lock',['generate-lockfile','--manifest-path',str(fresh/'Cargo.toml'),'--offline'])
        freeze('fresh',list(fresh.rglob('*.rs'))+list((fresh/'inputs').glob('*.json'))+[fresh/'Cargo.toml',fresh/'Cargo.lock'])
        cargo('fresh',['run','--manifest-path',str(fresh/'Cargo.toml'),'--locked','--offline','-j','1'])
        command=['test','--manifest-path',str(SDK/'Cargo.toml'),'--locked','--offline','-j','1','-p','linkedspec-runtime','--test','hash_value_result_guard_composition','--','--nocapture','--test-threads=1']
        cargo('normal',command,(101,) if phase=='qualified-old' else (0,))
        stdout=gzip.decompress((OUT/'normal-stdout.log.gz').read_bytes()).decode()
        stderr=gzip.decompress((OUT/'normal-stderr.log.gz').read_bytes()).decode()
        frames=[line for line in stderr.splitlines() if line.startswith('HASH_VALUE_RUST_NORMAL ')]
        assert len(frames)==89 and len({line.split(' ',2)[1] for line in frames})==89
        expected='76 passed; 13 failed' if phase=='qualified-old' else '89 passed; 0 failed'
        assert expected in stdout and '0 ignored; 0 measured; 0 filtered out' in stdout
        verify()
        for directory in (native,fresh):
            assert directory.parent == OUT and not directory.is_symlink()
            shutil.rmtree(directory)
        if phase=='qualified-fixed':
            assert CONTROL.parent==BASE and not CONTROL.is_symlink()
            shutil.rmtree(CONTROL)
            assert not CONTROL.exists()
    elif mode == 'test':
        names = (['hash_value_result_guard_composition','hash_view_result_guard_composition','value_copy','constructor_result_composition'] if phase == 'qualified-direct' else ['hash_value_result_guard_composition'])
        arguments = ['test','--manifest-path','rust/Cargo.toml','--locked','--offline','-j','1','-p','linkedspec-runtime']
        for name in names: arguments += ['--test',name]
        cargo('normal',arguments+['--','--nocapture','--test-threads=1'],(0,))
        verify()
    else:
        run('format',['rustfmt','--edition','2024','--check','rust/linkedspec-runtime/src/engine.rs','rust/linkedspec-runtime/tests/hash_value_result_guard_composition.rs'])
        verify()
    print(phase+': declared input/artifact/full-channel capture completed')


try:
    main()
except BaseException:
    (OUT/'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    raise
