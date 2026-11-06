"""One-shot full-source public Perl acquisition; declare inputs before first use."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'copy-controls'
OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl'], text=True).splitlines()]
paths += [BASE / name for name in ('capture_copy.py', 'observer.pl', 'copy_cases.py', 'copy-controls.json')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
paths += [Path('docs/checkpoints/type-operation-inventory/constructor-result-composition.md'),
          Path('docs/knowledge/perl-sorted-values-scalar-host-isolation.md')]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
           str(BASE / 'observer.pl'), str(BASE / 'copy-controls.json'), str(OUT)]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command), indent=2) + '\n')
with (OUT / 'stdout.log').open('wb') as stdout, (OUT / 'stderr.log').open('wb') as stderr:
    result = subprocess.run(command, cwd=ROOT, stdout=stdout, stderr=stderr)
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == row['sha256'] for p, row in records.items())
for name in ('stdout.log', 'stderr.log'):
    path = OUT / name
    raw = path.read_bytes()
    Path(str(path) + '.gz').write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(Path(str(path) + '.gz').read_bytes()) == path.read_bytes()
    path.unlink()
print('Actual first declared inputs/modules/handlers/full channels retained, exit', result.returncode)
assert result.returncode == 0, 'retain original failure and own any separate corrected epoch'
