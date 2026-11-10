"""Retain one-shot focused epochs, inputs before SDK and complete channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 2
phase = sys.argv[1]
assert phase in ('before', 'after', 'private_inverse', 'private_restored', 'private_restored_qualified', 'preservation', 'direct', 'direct_qualified')
OUT = BASE / phase
OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl', 'tests/fixtures'], text=True).splitlines()]
paths += [Path('tests/fixtures/array_pipeline_source_isolation_perl_cases.json')]
paths += [Path('t') / p for p in ('array_pipeline_source_isolation.t', 'array_pipeline_value_contract.t', 'array_transform_source_isolation.t')]
paths += [Path('specs') / p for p in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / p for p in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
paths += [p for p in BASE.rglob('*') if p.is_file() and p.parent in (BASE, BASE / 'templates')]
if phase.startswith('private_'):
    paths += [Path('.linkedspec-data/scratch/array-pipeline-source-perl/owner.pm')]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for p in sorted(set(paths)):
        assert p.is_file() and not p.is_symlink() and not p.is_absolute() and '..' not in p.parts
        assert p.stat().st_dev == ROOT.stat().st_dev
        raw = p.read_bytes()
        records[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=p.stat().st_mode & 0o777)
        archive.add(p, arcname=p, recursive=False)
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == set(records)
    for member in archive:
        row = records[member.name]
        raw = archive.extractfile(member).read()
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=']
if phase == 'preservation':
    command += ['perl', '-Iperl', str(BASE / 'observer.pl'), str(BASE / 'cases.json'), str(OUT)]
else:
    command += ['LINKEDSPEC_ARRAY_PIPELINE_SOURCE_CAPTURE=' + str(OUT), 'prove', '-v', '-j1']
    if phase.startswith('private_'):
        command += ['--exec', 'perl -Iperl ' + str(BASE / 'private_runner.pl') + ' .linkedspec-data/scratch/array-pipeline-source-perl/owner.pm']
    elif phase.startswith('direct'):
        command += ['--exec', 'perl -Iperl ' + str(BASE / 'direct_runner.pl')]
    else:
        command += ['-Iperl']
    command += (['t/array_pipeline_value_contract.t', 't/array_transform_source_isolation.t'] if phase.startswith('direct') else ['t/array_pipeline_source_isolation.t'])
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
for p, row in records.items():
    assert hashlib.sha256(Path(p).read_bytes()).hexdigest() == row['sha256'] and Path(p).stat().st_mode & 0o777 == row['mode']
print('Actual', phase, 'retained, exit', result.returncode)
assert result.returncode == (1 if phase in ('before', 'private_inverse') else 0), 'Unexpected result retained; qualify a separate epoch before retry'
