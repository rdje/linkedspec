"""Selected producer/result/arity/signature dependents; no broad regression run."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'direct'
OUT.mkdir()
tests = ['t/array_pipeline_value_contract.t', 't/variadic_user_function_contract.t',
    't/array_pipeline_result_guard_composition.t', 't/array_pipeline_callable_arity.t']
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [p for p in BASE.iterdir() if p.is_file()]
paths += [Path(p) for p in tests + ['t/phase0_regression.t',
    'tests/fixtures/array_pipeline_result_guard_perl_cases.json',
    'tests/fixtures/array_pipeline_callable_arity_perl_cases.json',
    'capability_conformance/callable_signature_contract.json',
    'capability_conformance/outward_descriptor_contract.json']]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
rows = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.is_file() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == set(rows)
    for member in archive:
        raw = archive.extractfile(member).read(); row = rows[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
commands = {
    'syntax-module': ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', '-c', 'perl/LinkedSpec.pm'],
    'syntax-phase0': ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', '-c', 't/phase0_regression.t'],
}
for test in tests:
    commands[Path(test).stem] = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
        'LINKEDSPEC_CALLABLE_PIPELINE_RESULT_CAPTURE=' + str(OUT), 'perl', '-Iperl', str(BASE / 'direct_runner.pl'), test]
for tag, command in commands.items():
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(cwd='.', argv=command), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    for name, row in rows.items():
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256'], name
        assert Path(name).stat().st_mode & 0o777 == row['mode'], name
    assert result.returncode == 0, 'Actual failed direct command retained; qualify separately'
    print(tag, 'actual0/full channels and unchanged input identities', flush=True)
(OUT / 'complete.txt').write_text('Four selected direct normals and syntax complete; actual API products retained.\n')
