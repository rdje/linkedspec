"""Retain actual documentation producer, consumed reports and full document images."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'publication'
OUT.mkdir()
books = ['docs/linkedspec-book/src/appendix/backend-handoff.md',
    'docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
    'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md']
documents = books + ['ROADMAP.md', 'ROADMAP_V2.md', 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
    'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md', 'git_message_brief.txt']
instruments = [str(BASE / name) for name in ('publish.py', 'run_publication.py', 'review_publication.py')]
instruments += ['tools/project_data_run.sh', 'tools/project_data_env.sh', 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.3.80.5.json']
reports = [str(BASE / 'launches' / tag / name) for tag in ('review', 'current', 'review-publication-query')
    for name in ('stdout.log.gz', 'stderr.log.gz', 'exit.txt')]
for name in books + ['ROADMAP.md', 'ROADMAP_V2.md']:
    assert Path(name).read_bytes() == subprocess.check_output(['git', 'show', 'HEAD:' + name])


def freeze(tag, names):
    rows = {}
    with tarfile.open(OUT / (tag + '.tar.gz'), 'x:gz') as archive:
        for name in sorted(set(names)):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
            assert path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            rows[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=name, recursive=False)
    with tarfile.open(OUT / (tag + '.tar.gz')) as archive:
        assert len(archive.getnames()) == len(rows) and set(archive.getnames()) == rows.keys()
        for member in archive:
            body = archive.extractfile(member).read()
            row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
    (OUT / (tag + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
    return rows


inputs = freeze('inputs-before-use', documents + instruments + reports)
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'publish.py')]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b'', 'actual document publication failure retained'
for name in instruments + reports:
    body = Path(name).read_bytes()
    assert len(body) == inputs[name]['bytes'] and hashlib.sha256(body).hexdigest() == inputs[name]['sha256']
    assert Path(name).stat().st_mode & 0o777 == inputs[name]['mode']
outputs = freeze('outputs-after-use', documents + ['docs/knowledge/lua-open-arity-concat-result-guards.md',
    str(BASE / 'REVIEW.md'), str(OUT / 'rotated-live-row.txt')])
print(json.dumps(dict(publication_inputs=len(inputs), publication_outputs=len(outputs), actual_exit=result.returncode)))
