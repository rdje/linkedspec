"""Capture one finite composition normal and its direct dependents with full inputs."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'after', 'private_inverse', 'private_restored', 'direct')
phase = sys.argv[1]
OUT = BASE / phase
OUT.mkdir()
tests = ['t/array_transform_result_guard_composition.t']
extra_fixtures = []
locations = dict(composition=str(OUT))
if phase == 'direct':
    tests += ['t/array_transform_source_isolation.t', 't/hash_value_result_guard_composition.t']
    extra_fixtures = ['array_transform_source_isolation_perl_cases.json', 'hash_value_result_guard_perl_cases.json', 'hash_value_result_guard_perl_profiles.json']
    locations.update(source='docs/checkpoints/array-transform-source-perl-2026-11-07/direct_array_composition',
                     hash='docs/checkpoints/hash-value-composition-perl-2026-11-07/direct_array_composition')
    for key in ('source', 'hash'):
        directory = Path(locations[key])
        directory.mkdir()
        (directory / 'owner.json').write_text(json.dumps(dict(owner='TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1', purpose='new direct artifacts; prior proof files unchanged'), indent=2) + '\n')
(OUT / 'artifact-locations.json').write_text(json.dumps(locations, indent=2) + '\n')
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl'], text=True).splitlines()]
paths += [Path(p) for p in tests]
paths += sorted(p for p in BASE.iterdir() if p.suffix in ('.py', '.pl', '.json', '.pm'))
paths += [Path('tests/fixtures') / name for name in (
    'array_transform_result_guard_cases.json', 'array_transform_result_guard_perl_profiles.json',
    'array_transform_result_guard_perl_prefix_profiles.json', *extra_fixtures)]
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
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'LINKEDSPEC_ARRAY_TRANSFORM_COMPOSITION_CAPTURE=' + str(OUT)]
if phase == 'direct':
    command += ['LINKEDSPEC_ARRAY_TRANSFORM_SOURCE_CAPTURE=' + locations['source'], 'LINKEDSPEC_HASH_VALUE_COMPOSITION_CAPTURE=' + locations['hash']]
command += ['prove', '-v', '-j1']
if phase.startswith('private_'):
    command += ['--exec', 'perl -Iperl ' + str(BASE / 'private_runner.pl') + ' ' + str(BASE / 'control-owner.pm')]
else:
    command += ['-Iperl']
command += tests
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (OUT / (name + '.log.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == row['sha256'] for p, row in records.items())
print('Actual composition normal', phase, 'retained, exit', result.returncode)
assert result.returncode == (1 if phase in ('before', 'private_inverse') else 0), 'preserve unexpected epoch; qualify separately'
