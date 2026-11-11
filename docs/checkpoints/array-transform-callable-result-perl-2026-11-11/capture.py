"""One source-bound acquisition epoch; standalone dumps follow native compilation."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
OLD = Path('docs/checkpoints/array-transform-callable-perl-2026-11-11')
phase = sys.argv[1]
assert phase in ('intake', 'before', 'after', 'private_old', 'private_current', 'direct')
OUT = BASE / phase
OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [p for p in BASE.iterdir() if p.is_file()]
paths += [BASE / (phase + '-launch') / name for name in ('producer-images.json.gz', 'command.json')]
paths += [OLD / name for name in ('cases.json', 'terminal-cases.json', 'policy-contract.json', 'observations.json', 'terminal-observations.json', 'review.py', 'sealed-identities.json')]
paths += [Path('tools') / name for name in ('project_data_run.sh', 'project_data_env.sh', 'run_python_project_data.sh')]
paths += [Path('docs/checkpoints/type-operation-inventory/array-transform-callable-result-guard-composition.md'), Path('docs/knowledge/perl-native-source-dump-custody.md')]
normal = Path('t/array_transform_callable_result_guard_composition.t')
fixture = Path('tests/fixtures/array_transform_callable_result_guard_perl_cases.json')
if phase != 'intake':
    paths += [normal, fixture]
if phase.startswith('private_'):
    paths.append(Path('.linkedspec-data/scratch/callable-transform-result-perl/owner.pm'))
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
        raw = archive.extractfile(member).read()
        row = rows[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, sort_keys=True, indent=2) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
prefix = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=']
commands = {'version': prefix + ['perl', '-V']}
if phase == 'intake':
    commands['run'] = prefix + ['perl', '-Iperl', str(REL / 'observer.pl'), str(REL / 'cases.json'), str(OUT.relative_to(ROOT))]
else:
    run = prefix + ['LINKEDSPEC_CALLABLE_TRANSFORM_RESULT_CAPTURE=' + str(OUT.relative_to(ROOT)), 'perl', '-Iperl']
    if phase.startswith('private_'):
        run += [str(REL / 'private_runner.pl'), '.linkedspec-data/scratch/callable-transform-result-perl/owner.pm']
    commands['run'] = run + [str(normal)]
assert phase != 'direct', 'Direct phase must be separately prepared with explicit selected inputs'
for tag, command in commands.items():
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    for name, row in rows.items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == row['sha256'], name
        assert (ROOT / name).stat().st_mode & 0o777 == row['mode'], name
    red = tag == 'run' and phase in ('before', 'private_old')
    assert (result.returncode != 0) if red else (result.returncode == 0), 'Actual unexpected result retained; qualify separately'
    print(phase, tag, 'actual exit', result.returncode, flush=True)
(OUT / 'complete.txt').write_text('Actual epoch complete; declared inputs unchanged. Native dumps are post-compilation/pre-invocation.\n')
