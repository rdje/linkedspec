"""Retain one finite normal epoch and actual loaded owner; never replay a completed phase."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
NORMAL = Path('t/array_concat_open_arity_result_guard_composition.t')
FIXTURE = Path('tests/fixtures/array_concat_open_arity_result_guard_perl_cases.json')
phase, = sys.argv[1:]
assert phase in ('before', 'after', 'inverse', 'restored', 'direct')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'b15ca562e8044d9a8a369e613926bf016598f708'
OUT = BASE / phase
OUT.mkdir()
private = BASE / 'control-owner'
private_owner = private / 'MethodLowering.pm'
is_private = phase in ('inverse', 'restored')
if is_private:
    if phase == 'inverse':
        assert not private.exists()
        private.mkdir()
    else:
        assert private.is_dir() and not private.is_symlink()
    image = gzip.decompress((BASE / ('owner-before.pm.gz' if phase == 'inverse' else 'owner-after.pm.gz')).read_bytes())
    private_owner.write_bytes(image)
    private_owner.chmod(OWNER.stat().st_mode & 0o777)
paths = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [NORMAL, FIXTURE, Path('t/array_transform_result_guard_composition.t'), Path('t/array_transform_callable_result_guard_composition.t')]
paths += [Path('tests/fixtures') / name for name in ('array_transform_result_guard_cases.json',
    'array_transform_result_guard_perl_profiles.json', 'array_transform_result_guard_perl_prefix_profiles.json',
    'array_transform_callable_result_guard_perl_cases.json')]
paths += [path for path in BASE.iterdir() if path.is_file()]
paths += [Path('tools/project_data_env.sh'), Path('tools/project_data_run.sh')]
if is_private:
    paths.append(private_owner)
rows = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and not path.is_absolute() and '..' not in path.parts
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        row = rows[member.name]; body = archive.extractfile(member).read()
        assert member.isfile() and len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
environment = dict(os.environ)
for key in ('LINKEDSPEC_ARRAY_TRANSFORM_COMPOSITION_CAPTURE', 'LINKEDSPEC_CALLABLE_TRANSFORM_RESULT_CAPTURE'):
    environment.pop(key, None)
environment.update(PERL5LIB='', LINKEDSPEC_ARRAY_CONCAT_CAPTURE=str(OUT))
commands = dict(memory=['bash', 'tools/project_data_run.sh', 'memory_pressure'],
    syntax=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', '-c', str(NORMAL)])
normal = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl']
if is_private:
    normal += [str(BASE / 'private_runner.pl'), str(private_owner), str(NORMAL)]
elif phase == 'direct':
    normal = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'prove', '-q', '-Iperl', str(NORMAL),
        't/array_transform_result_guard_composition.t', 't/array_transform_callable_result_guard_composition.t']
else:
    normal.append(str(NORMAL))
commands['normal'] = normal
for tag, argv in commands.items():
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=argv, cwd='.', environment={
        key: environment[key] for key in ('PERL5LIB', 'LINKEDSPEC_ARRAY_CONCAT_CAPTURE')},
        cleared_capture_variables=['LINKEDSPEC_ARRAY_TRANSFORM_COMPOSITION_CAPTURE', 'LINKEDSPEC_CALLABLE_TRANSFORM_RESULT_CAPTURE']), indent=2) + '\n')
    result = subprocess.run(argv, cwd=ROOT, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    if tag == 'memory':
        free = re.search(rb'System-wide memory free percentage: (\d+)%', result.stdout)
        assert result.returncode == 0 and free and int(free[1]) >= 30
    elif tag == 'syntax':
        assert result.returncode == 0 and result.stdout == b'' and result.stderr == (str(NORMAL) + ' syntax OK\n').encode()
    elif phase in ('before', 'inverse'):
        assert result.returncode > 0, 'Expected old normal RED was not observed'
    else:
        assert result.returncode == 0, 'Actual normal failure retained; never replay this phase'
    for name, row in rows.items():
        path = Path(name)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
    print(phase + '/' + tag + ': actual' + str(result.returncode) + '/full separate channels; inputs unchanged', flush=True)
assert len(list(OUT.glob('*.pm.gz'))) == len(list(OUT.glob('*.handler.pl.gz'))) == 504
if phase == 'restored':
    # The declared input archive is verified above before exact private retirement.
    private_owner.unlink()
    private.rmdir()
(OUT / 'complete.txt').write_text('Actual normal epoch completed with declared inputs/products/channels; inspect verdict separately.\n')
