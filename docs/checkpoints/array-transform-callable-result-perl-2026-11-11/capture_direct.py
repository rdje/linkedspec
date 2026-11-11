"""Changed-owner syntax and two directly dependent original normals; no broad gate."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
OUT = BASE / 'direct'
OUT.mkdir()
tests = ['t/array_transform_result_guard_composition.t', 't/array_pipeline_callable_result_guard_composition.t']
fixtures = ['tests/fixtures/array_transform_result_guard_cases.json', 'tests/fixtures/array_transform_result_guard_perl_profiles.json', 'tests/fixtures/array_transform_result_guard_perl_prefix_profiles.json', 'tests/fixtures/array_pipeline_callable_result_guard_perl_cases.json']
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [p for p in BASE.iterdir() if p.is_file()]
paths += [BASE / 'direct-direct-launch' / name for name in ('producer-images.json.gz', 'command.json')]
paths += [Path(p) for p in tests + fixtures + ['t/array_transform_callable_result_guard_composition.t', 'tests/fixtures/array_transform_callable_result_guard_perl_cases.json']]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
rows = {}
with tarfile.open(OUT / 'inputs-before-sdk.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        relative = path.resolve().relative_to(ROOT)
        raw = path.read_bytes()
        rows[str(relative)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=relative, recursive=False)
with tarfile.open(OUT / 'inputs-before-sdk.tar.gz') as archive:
    assert set(archive.getnames()) == set(rows)
    for member in archive:
        raw = archive.extractfile(member).read(); row = rows[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, sort_keys=True, indent=2) + '\n')
prefix = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=']
commands = {
    'syntax-owner': prefix + ['perl', '-Iperl', '-c', 'perl/LinkedSpec/ActionIR/MethodLowering.pm'],
    'syntax-normal': prefix + ['perl', '-Iperl', '-c', 't/array_transform_callable_result_guard_composition.t'],
}
for test in tests:
    commands[Path(test).stem] = prefix + ['LINKEDSPEC_CALLABLE_TRANSFORM_DIRECT_CAPTURE=' + str(REL / 'direct'), 'perl', '-Iperl', str(REL / 'direct_runner.pl'), test]
for tag, command in commands.items():
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    for name, row in rows.items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == row['sha256'], name
        assert (ROOT / name).stat().st_mode & 0o777 == row['mode'], name
    assert result.returncode == 0, 'Actual failed direct command retained; qualify separately'
    print(tag, 'actual0/full channels and named inputs unchanged', flush=True)
(OUT / 'complete.txt').write_text('Two selected original normals and changed-owner/new-normal syntax complete; actual API modules/dumps retained.\n')
