"""One-shot focused Rust phases using only published LinkedSpec SDK entrypoints.

Declared own inputs and resolved Cargo inputs precede compilation/execution.
Complete native/transitive closure stays with23.4.2; raw phases are immutable.
"""
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
assert phase in ('rust-probe', 'rust-normal')
OUT = BASE / phase
OUT.mkdir()
env = dict(os.environ, CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
custody = []


def run(tag, arguments, accepted=(0,)):
    command = ['bash', 'tools/run_cargo_local.sh', *arguments]
    (OUT / (tag+'-command.json')).write_text(json.dumps(dict(argv=command,
        environment=dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')), indent=2)+'\n')
    with (OUT / (tag+'-stdout.log')).open('wb') as stdout, (OUT / (tag+'-stderr.log')).open('wb') as stderr:
        result = subprocess.run(command, cwd=ROOT, env=env, stdout=stdout, stderr=stderr)
    (OUT / (tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
    assert result.returncode in accepted, f'{tag}: exit {result.returncode}; raw channels retained'


def freeze(tag, paths):
    files = {}
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts
        assert path.is_file() and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        files[path.as_posix()] = dict(sha256=hashlib.sha256(body).hexdigest(),
            bytes=len(body), mode=path.stat().st_mode & 0o777)
    name = OUT / (tag+'-before-first-run.tar.gz')
    with tarfile.open(name, 'w:gz') as archive:
        for path in files:
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(name) as archive:
        recovered = {m.name: hashlib.sha256(archive.extractfile(m).read()).hexdigest()
                     for m in archive.getmembers() if m.isfile()}
    assert recovered == {p:r['sha256'] for p,r in files.items()}
    custody.append(dict(archive=name.as_posix(), files=files))


(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
paths = [Path(p) for p in subprocess.check_output(['git','ls-files','rust','tests/fixtures'],text=True).splitlines()]
paths += [Path(p) for p in ('tools/project_data_env.sh','tools/run_cargo_local.sh',
    'tools/run_python_project_data.sh','tools/project_data_run.sh')]
paths += [BASE/'capture_rust.py', BASE/'observer.rs', Path('tests/fixtures/key_count_count_source_ownership_cases.json')]
# Explicitly include new/untracked direct consumers and fixture profiles.
for name in ('rust/linkedspec-runtime/tests/key_count_result_guard_composition.rs',
             'tests/fixtures/key_count_result_guard_rust_domain.json'):
    if Path(name).is_file():
        paths.append(Path(name))
freeze('root', paths)
run('cargo-version',['--version'])
with (OUT/'rustc-version.txt').open('wb') as output:
    subprocess.run(['rustc','-Vv'], stdout=output, check=True, env=env)

if phase=='rust-probe':
    cases = []
    for name in ('tests/fixtures/key_count_count_source_ownership_cases.json',):
        cases.extend(json.loads(Path(name).read_text()))
    assert len({r['id'] for r in cases}) == len(cases)
    (OUT/'cases.json').write_text(json.dumps(cases,indent=2)+'\n')
    native, fresh = OUT/'native', OUT/'fresh'
    for directory in (native,fresh):
        (directory/'src').mkdir(parents=True)
        dependencies = ('linkedspec-core = { path = "../../../../../rust/linkedspec-core" }\n'
                        if directory == native else '')
        name = 'key-count-source-rust-'+('native' if directory == native else 'fresh')
        (directory/'Cargo.toml').write_text(
            f'[package]\nname = "{name}"\nversion = "0.0.0"\nedition = "2024"\npublish = false\n\n'
            '[dependencies]\n'+dependencies+
            'linkedspec-runtime = { path = "../../../../../rust/linkedspec-runtime" }\nserde_json = "1"\n')
    (native/'src/main.rs').write_bytes((BASE/'observer.rs').read_bytes())
    run('native-lock',['generate-lockfile','--manifest-path',str(native/'Cargo.toml'),'--offline'])
    freeze('native',list(native.rglob('*.rs'))+[native/'Cargo.toml',native/'Cargo.lock',OUT/'cases.json'])
    run('native',['run','--manifest-path',str(native/'Cargo.toml'),'--locked','--offline','-j','1','--',str(fresh)])
    run('fresh-lock',['generate-lockfile','--manifest-path',str(fresh/'Cargo.toml'),'--offline'])
    freeze('fresh',list(fresh.rglob('*.rs'))+list((fresh/'inputs').glob('*.json'))+
        [fresh/'Cargo.toml',fresh/'Cargo.lock'])
    run('fresh',['run','--manifest-path',str(fresh/'Cargo.toml'),'--locked','--offline','-j','1'])
    for record in custody:
        for name,expected in record['files'].items():
            assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==expected['sha256']
            assert Path(name).stat().st_mode & 0o777 == expected['mode']
    for directory in (native,fresh):
        assert directory.parent == OUT and not directory.is_symlink()
        shutil.rmtree(directory)
        assert not directory.exists()
else:
    tests = (['count_length_receivers','count_result_guard_composition','length_result_guard_composition'] if phase=='nearest'
             else ['key_count_result_guard_composition'])
    arguments = ['test','--manifest-path','rust/Cargo.toml','--locked','--offline','-j','1','-p','linkedspec-runtime']
    for test in tests:
        arguments += ['--test',test]
    arguments += ['--','--nocapture','--test-threads=1']
    run('normal',arguments,(0,101) if phase=='normal-before' else (0,))
    for record in custody:
        for name,expected in record['files'].items():
            assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==expected['sha256']

(OUT/'custody.json').write_text(json.dumps(custody,indent=2,sort_keys=True)+'\n')
print(f'{phase}: completed declared root/native/fresh custody; inspect raw outcomes before grading')
