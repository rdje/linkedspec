"""One-shot focused normal epochs with actual inputs before Perl loads."""
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
assert phase in ('before', 'after', 'direct')
OUT = BASE / phase
OUT.mkdir()
artifact_root = OUT / 'artifacts'
artifact_root.mkdir()
tests = ['t/copy_result_guard_composition.t']
if phase == 'direct':
    tests += ['t/value_copy_function.t', 't/value_copy_receiver.t',
              't/constructor_result_composition.t', 't/count_copy_source_composition.t']
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl', 'tests/fixtures'], text=True).splitlines()]
paths += [Path(p) for p in tests]
paths += [BASE / name for name in ('capture.py', 'write_preservation.py')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tests/fixtures/copy_result_guard_perl_preservation_cases.json')]
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
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'prove', '-v', '-Iperl', *tests]
env = dict(os.environ, LINKEDSPEC_COPY_RESULT_CAPTURE=str(artifact_root))
(OUT / 'command.json').write_text(json.dumps(dict(argv=command,
    environment=dict(LINKEDSPEC_COPY_RESULT_CAPTURE=str(artifact_root))), indent=2) + '\n')
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
print(phase, 'actual focused normal exit', result.returncode, 'all declared inputs/modules/full channels retained')
assert result.returncode == (1 if phase == 'before' else 0), 'inspect complete original channels before any separate correction epoch'
