"""One-shot focused proof epochs; retain actual declared inputs before SDK use."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
phase, = sys.argv[1:]
assert phase == 'direct-qualified'
OUT = BASE / phase
OUT.mkdir()
artifacts = OUT / 'artifacts'
artifacts.mkdir()
tests = ['t/hash_view_result_guard_composition.t']
if phase == 'direct-qualified':
    tests += ['t/sorted_values_scalar_isolation.t', 't/copy_result_guard_composition.t',
              't/constructor_result_composition.t']
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl', 'tests/fixtures'], text=True).splitlines()]
paths += [Path(p) for p in tests]
paths += [BASE / name for name in ('capture_qualified.py', 'prepare_qualified.py', 'prepare.py', 'observe_profiles.pl', 'profiles.json')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
env = dict(os.environ)
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=']
if phase.startswith('profile-'):
    command += ['perl', '-Iperl', str(BASE / 'observe_profiles.pl'), str(BASE / 'profiles.json'), str(artifacts)]
else:
    command += ['prove', '-j1', '-v', '-Iperl', *tests]
    env['LINKEDSPEC_HASH_VIEW_RESULT_CAPTURE'] = str(artifacts)
(OUT / 'command.json').write_text(json.dumps(dict(argv=command,
    environment={key: env[key] for key in ('LINKEDSPEC_HASH_VIEW_RESULT_CAPTURE',) if key in env}), indent=2) + '\n')
with (OUT / 'stdout.log').open('wb') as stdout, (OUT / 'stderr.log').open('wb') as stderr:
    result = subprocess.run(command, cwd=ROOT, env=env, stdout=stdout, stderr=stderr)
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == row['sha256'] for p, row in records.items())
for name in ('stdout.log', 'stderr.log'):
    path = OUT / name
    raw = path.read_bytes()
    destination = Path(str(path) + '.gz')
    destination.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(destination.read_bytes()) == path.read_bytes()
    path.unlink()
print(phase, 'actual focused exit', result.returncode, 'declared inputs/modules/full channels retained')
if phase != 'before':
    assert result.returncode == 0, 'inspect retained failure; corrections require a separate epoch'
