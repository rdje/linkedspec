"""One immutable source/artifact epoch; no SDK invocation before input capture."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
INTAKE = Path('docs/checkpoints/array-pipeline-callable-perl-2026-11-11')
OWNER = Path('.linkedspec-data/scratch/callable-pipeline-arity-perl/owner.pm')
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--phase', required=True, choices=('before', 'after', 'private_old', 'private_current', 'preservation'))
args = parser.parse_args()
OUT = BASE / args.phase
OUT.mkdir()
paths = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'perl', 'specs', str(INTAKE)], text=True).splitlines()]
paths += [p for p in BASE.iterdir() if p.is_file()]
paths += [Path('tests/fixtures/array_pipeline_callable_arity_perl_cases.json'), Path('t/array_pipeline_callable_arity.t')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
paths += [Path('docs/checkpoints/type-operation-inventory/array-pipeline-callable-result-guard-composition.md')]
if args.phase.startswith('private_'):
    paths.append(OWNER)
records = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        records[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == set(records)
    for member in archive:
        body = archive.extractfile(member).read(); row = records[member.name]
        assert member.isfile() and len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))


def run(tag, command):
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(cwd='.', argv=command), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    for name, row in records.items():
        path = Path(name)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], name
        assert path.stat().st_mode & 0o777 == row['mode'], name
    return result


version = run('version', ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V'])
assert version.returncode == 0 and not version.stderr
if args.phase == 'preservation':
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
        str(BASE / 'preservation_observer.pl'), str(INTAKE / 'cases.json'), str(OUT)]
else:
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
        'LINKEDSPEC_CALLABLE_PIPELINE_ARITY_CAPTURE=' + str(OUT), 'perl', '-Iperl']
    if args.phase.startswith('private_'):
        command += [str(BASE / 'private_runner.pl'), str(OWNER)]
    command += ['t/array_pipeline_callable_arity.t']
result = run('run', command)
red = args.phase in ('before', 'private_old')
assert (result.returncode != 0) if red else (result.returncode == 0), 'Actual unexpected failure retained; qualify separately'
(OUT / 'complete.txt').write_text('Original epoch complete; actual channels/exit retained and declared inputs unchanged.\n')
print(args.phase, 'actual exit', result.returncode, '; full inputs/artifacts/channels retained', flush=True)
