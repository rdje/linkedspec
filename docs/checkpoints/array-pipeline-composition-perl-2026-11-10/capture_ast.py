"""One-shot prefix acquisition with frozen pre-SDK inputs and full channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'ast_intake'
OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl', 'tests/fixtures'], text=True).splitlines()]
paths += [Path('specs') / p for p in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / p for p in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
paths += [p for p in BASE.iterdir() if p.is_file()]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for p in sorted(set(paths)):
        assert p.is_file() and not p.is_symlink() and not p.is_absolute() and '..' not in p.parts
        assert p.stat().st_dev == ROOT.stat().st_dev
        raw = p.read_bytes()
        records[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=p.stat().st_mode & 0o777)
        archive.add(p, arcname=p, recursive=False)
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert len(archive.getnames()) == len(records) and set(archive.getnames()) == set(records)
    for member in archive:
        raw = archive.extractfile(member).read()
        row = records[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
packet = dict(cwd='.', argv=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
                           str(BASE / 'inspect_ast.pl')])
(OUT / 'command.json').write_text(json.dumps(packet, indent=2) + '\n')
result = subprocess.run(packet['argv'], cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
for name, row in records.items():
    p = Path(name)
    assert hashlib.sha256(p.read_bytes()).hexdigest() == row['sha256'] and p.stat().st_mode & 0o777 == row['mode']
assert result.returncode == 0, 'Original failed epoch retained; qualify separately before retry'
print('Actual six AST/public lowering records and before-use inputs retained')
