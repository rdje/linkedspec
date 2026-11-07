"""Capture each one-shot source normal with its actual first inputs and channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'after', 'private_inverse', 'private_restored')
phase = sys.argv[1]
OUT = BASE / phase
OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl'], text=True).splitlines()]
paths += sorted(p for p in BASE.iterdir() if p.suffix in ('.py', '.pl', '.json', '.pm'))
paths += [Path('t/array_transform_source_isolation.t')]
paths += [Path('tests/fixtures') / name for name in ('array_transform_source_isolation_perl_cases.json', 'array_transform_result_guard_perl_profiles.json', 'array_transform_result_guard_cases.json')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for p in sorted(set(paths)):
        assert p.is_file() and not p.is_symlink() and not p.is_absolute() and '..' not in p.parts
        assert p.stat().st_dev == ROOT.stat().st_dev
        raw = p.read_bytes()
        records[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=p.stat().st_mode & 0o777)
        archive.add(p, arcname=p, recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
           'LINKEDSPEC_ARRAY_TRANSFORM_SOURCE_CAPTURE=' + str(OUT), 'prove', '-v', '-j1']
if phase.startswith('private_'):
    command += ['--exec', 'perl -Iperl ' + str(BASE / 'private_runner.pl') + ' ' + str(BASE / 'control-owner.pm')]
else:
    command += ['-Iperl']
command += ['t/array_transform_source_isolation.t']
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (OUT / (name + '.log.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == row['sha256'] for p, row in records.items())
print('Actual source normal', phase, 'retained, exit', result.returncode)
assert result.returncode == (1 if phase in ('before', 'private_inverse') else 0), 'preserve unexpected epoch; qualify separately'
