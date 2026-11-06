"""Same-path historical/current owner controls with actual pre-use own inputs."""
import gzip
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
ACTIVATION = '6845971744426a9c897a994bddfcee3a5f2171b6'
original = OWNER.read_bytes()
historical = subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(OWNER)])
with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git', 'archive', '--format=tar', ACTIVATION, 'perl']))) as archive:
    for member in archive:
        if member.isfile() and member.name != str(OWNER):
            assert Path(member.name).read_bytes() == archive.extractfile(member).read(), 'non-owner SDK changed; qualify before use'
owner_path = BASE / 'seed-owner.pm'
assert not owner_path.exists()
paths = [Path(path) for path in subprocess.check_output(['git', 'ls-files', 'perl'], text=True).splitlines()]
paths += [BASE / name for name in ('capture_seed.py', 'prepare_seed.py', 'seed_observer.pl', 'seed-cases.json', 'seed-owner.pm')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
for phase, body in (('historical', historical), ('current', original)):
    output = BASE / 'seed' / phase
    output.mkdir(parents=True)
    owner_path.write_bytes(body)
    records = {}
    archive_path = output / 'inputs-before-first-run.tar.gz'
    with tarfile.open(archive_path, 'x:gz') as archive:
        for path in sorted(set(paths)):
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            assert not path.is_absolute() and '..' not in path.parts
            raw = path.read_bytes()
            records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
    (output / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
    (output / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
               str(BASE / 'seed_observer.pl'), str(owner_path), str(BASE / 'seed-cases.json'), str(output)]
    (output / 'command.json').write_text(json.dumps(dict(argv=command), indent=2) + '\n')
    with (output / 'stdout.log').open('wb') as stdout, (output / 'stderr.log').open('wb') as stderr:
        result = subprocess.run(command, cwd=ROOT, stdout=stdout, stderr=stderr)
    (output / 'exit.txt').write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, 'retain original channels; any instrument correction needs a separate epoch'
    assert all(hashlib.sha256(Path(path).read_bytes()).hexdigest() == row['sha256'] for path, row in records.items())
    with tarfile.open(archive_path) as archive:
        assert archive.extractfile(str(owner_path)).read() == body
    for name in ('stdout.log', 'stderr.log'):
        path = output / name
        raw = path.read_bytes()
        capsule = Path(str(path) + '.gz')
        capsule.write_bytes(gzip.compress(raw, mtime=0))
        assert gzip.decompress(capsule.read_bytes()) == path.read_bytes()
        path.unlink()
    print(phase, 'actual4 localized source-seed observations and complete declared inputs/channels retained', flush=True)
assert OWNER.read_bytes() == original and owner_path.read_bytes() == original
owner_path.unlink()  # Both exact private owner images survive in verified pre-use archives.
print('Same private owner path/own SDK/source population; checkout owner unchanged')
