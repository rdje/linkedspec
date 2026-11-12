"""Acquire the finite Perl selection with actual before-use inputs and full channels."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'intake'
OUT.mkdir()
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'd21b84a4c8da663ee2a7600a2dc814d354502612'
paths = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [path for path in BASE.iterdir() if path.is_file()]
paths += [Path(name) for name in ('tools/project_data_env.sh', 'tools/project_data_run.sh',
    'docs/knowledge/perl-callable-array-transform-intake.md',
    'docs/checkpoints/type-operation-inventory/array-transform-result-guard-composition.md',
    'docs/checkpoints/type-operation-inventory/array-transform-callable-result-guard-composition.md',
    'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md',
    'docs/linkedspec-book/src/appendix/helper-contract-catalog.md')]
paths += [Path(name) for name in json.loads((BASE / 'template-identities.json').read_bytes())]
rows = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        body = archive.extractfile(member).read(); row = rows[member.name]
        assert member.isfile() and len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
commands = dict(memory=['bash', 'tools/project_data_run.sh', 'memory_pressure'],
    version=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V'],
    syntax=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', '-c', str(BASE / 'observer.pl')],
    observer=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', str(BASE / 'observer.pl'), str(BASE / 'cases.json'), str(OUT)])
for tag, argv in commands.items():
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
    result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, 'Original failure retained; never replay this epoch'
    if tag == 'memory':
        free = re.search(rb'System-wide memory free percentage: (\d+)%', result.stdout)
        assert free and int(free[1]) >= 30
    elif tag == 'syntax':
        assert result.stdout == b'' and result.stderr == (str(BASE / 'observer.pl') + ' syntax OK\n').encode()
    else:
        assert result.stderr == b'', 'Unexpected stderr retained for root-cause review'
    for name, row in rows.items():
        path = Path(name)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
    print(tag + ': actual0/complete separate channels; declared inputs unchanged', flush=True)
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'specs']) == b''
(OUT / 'complete.txt').write_text('Own84 public Perl questions acquired once; no production change.\n')
