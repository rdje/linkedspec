"""Verify the exact repaired parent and selected leaves through the public reader."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'task-queries'
OUT.mkdir()
paths = [Path(__file__).relative_to(ROOT), Path('tools/read_task_tree.pl'),
    Path('docs/tasks/TYPE-REFERENCE-BOOK.md'), Path('docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl'),
    Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'), Path('tools/project_data_run.sh'), Path('tools/project_data_env.sh')]
rows, bodies = {}, {}
with tarfile.open(OUT / 'inputs-before-query.tar.gz', 'x:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        bodies[str(path)] = body
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-query.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        assert archive.extractfile(member).read() == bodies[member.name] and member.mode & 0o777 == rows[member.name]['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


def block(body, identifier):
    start = body.index(('- ID: `' + identifier + '`').encode())
    end = body.find(b'\n- ID:', start + 1)
    return body[start:] if end < 0 else body[start:end]


original = bodies['docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
prepared = gzip.decompress((BASE / 'task-parent-after.md.gz').read_bytes())
assert block(original, 'TYPE-REFERENCE-BOOK.1.2.23.4') == block(prepared, 'TYPE-REFERENCE-BOOK.1.2.23.4')
for suffix in ('4', '4.30', '4.31'):
    identifier = 'TYPE-REFERENCE-BOOK.1.2.23.' + suffix
    command = ['perl', 'tools/read_task_tree.pl', '--tree', 'TYPE-REFERENCE-BOOK', '--id', identifier]
    (OUT / (suffix + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (suffix + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (suffix + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and result.stderr == b''
    assert block(result.stdout, identifier) == block(original, identifier), 'exact public node recovery'
print(json.dumps(dict(task_links='PASS', public_queries=3, added_children=[30, 31],
    scope='Exact selected public parent/leaf recovery and retained inputs/channels. The before/after parent contract has two separate RED controls. No whole-tree hierarchy prevention or complete native/transitive tool-input claim.')))
