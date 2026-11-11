"""Fresh unchanged178 acquisition after the clean first-call arity landing."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = Path('docs/checkpoints/array-pipeline-callable-perl-2026-11-11')
ACTIVATION = '5f22dae8d3a10cd10f4d2ecfbc6d0be9fd71e172'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'specs']).strip()
raw = (OLD / 'observer.pl').read_bytes()
assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(OLD / 'observer.pl')])
template = BASE / 'observer-template.pl.gz'; assert not template.exists()
template.write_bytes(gzip.compress(raw, mtime=0))
text = raw.decode()
old = r'\Adocs/checkpoints/array-pipeline-callable-perl-2026-11-11/[a-z_]+'
assert text.count(old) == 1
observer = BASE / 'observer.pl'
assert not observer.exists()
observer.write_text(text.replace(old, r'\A' + str(BASE) + '/[a-z_]+'))
OUT = BASE / 'intake'; OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [p for p in BASE.iterdir() if p.is_file()]
paths += [OLD / name for name in ('observer.pl', 'cases.json', 'classification.json', 'arity-cases.json')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
paths += [Path('docs/checkpoints/type-operation-inventory/array-pipeline-callable-result-guard-composition.md'),
    Path('t/array_pipeline_callable_arity.t'), Path('tests/fixtures/array_pipeline_callable_arity_perl_cases.json')]
rows = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == set(rows)
    for member in archive:
        body = archive.extractfile(member).read(); row = rows[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_text(ACTIVATION + '\n')
commands = {
    'version': ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V'],
    'run': ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', str(observer), str(OLD / 'cases.json'), str(OUT)],
}
for tag, command in commands.items():
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(cwd='.', argv=command), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    for name, row in rows.items():
        path = Path(name)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], name
        assert path.stat().st_mode & 0o777 == row['mode'], name
    assert result.returncode == 0 and not result.stderr, 'Actual failed intake retained; separate qualification required'
    print(tag, 'actual0/empty outer stderr; declared inputs unchanged', flush=True)
(OUT / 'complete.txt').write_text('Fresh178 acquisition complete; no production edit.\n')
