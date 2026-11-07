"""Capture declared inputs before the one-shot public Array-transform observer."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 2 and sys.argv[1] in ('preserved_results',)
OUT = BASE / sys.argv[1]
OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl'], text=True).splitlines()]
paths += sorted(p for p in BASE.iterdir() if p.suffix in ('.py', '.pl', '.json'))
paths += [Path('specs') / n for n in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / n for n in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
paths += [Path('tests/fixtures/array_transform_result_guard_cases.json'),
          Path('docs/checkpoints/type-operation-inventory/array-transform-result-guard-composition.md')]
identities = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for p in sorted(set(paths)):
        assert p.is_file() and not p.is_symlink() and not p.is_absolute() and '..' not in p.parts
        assert p.stat().st_dev == ROOT.stat().st_dev
        raw = p.read_bytes()
        identities[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=p.stat().st_mode & 0o777)
        archive.add(p, arcname=p, recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', str(BASE / 'observe_results.pl'), str(Path('tests/fixtures/array_transform_result_guard_cases.json')), str(OUT)]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (OUT / (name + '.log.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == r['sha256'] for p, r in identities.items())
print('Actual public observer', sys.argv[1], 'retained, exit', result.returncode)
assert result.returncode == 0, 'preserve unexpected first epoch; qualify separately'
