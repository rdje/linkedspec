"""One-shot actual public epochs with all owned input bytes before first use."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'after', 'inverse', 'restored')
OUT = BASE / sys.argv[1]
OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl'], text=True).splitlines()]
paths += [BASE / name for name in ('capture.py', 'observer.pl', 'cases.py', 'cases.json')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
paths += [Path('tests/fixtures/hash_value_result_guard_cases.json'),
          Path('docs/checkpoints/type-operation-inventory/hash-value-result-guard-composition.md'),
          Path('docs/checkpoints/hash-value-result-selection-2026-11-07/REVIEW.md')]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and not path.is_absolute() and '..' not in path.parts
        assert path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
           str(BASE / 'observer.pl'), str(BASE / 'cases.json'), str(OUT)]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name, raw in (('stdout', result.stdout), ('stderr', result.stderr)):
    (OUT / (name + '.log.gz')).write_bytes(gzip.compress(raw, mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == r['sha256'] for p, r in records.items())
print('Actual', sys.argv[1], 'full source/inputs/modules/handlers/channels retained, exit', result.returncode)
assert result.returncode == 0, 'preserve failed epoch unchanged and qualify separately'
