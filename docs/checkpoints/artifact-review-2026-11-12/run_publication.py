"""Retain the actual maintenance document producer, consumed results and images."""
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
documents = ['docs/ARTIFACT_CLEANUP.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
    'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md', 'ROADMAP_V2.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/linkedspec-book/src/appendix/backend-handoff.md', 'git_message_brief.txt']
instruments = [str(BASE / name) for name in ('publish.py', 'run_publication.py', 'review_publication.py', 'run_stage.py')]
instruments += ['tools/project_data_run.sh', 'tools/project_data_env.sh',
    'docs/checkpoints/array-concat-open-arity-julia-2026-11-12/run_stage.py',
    'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.31.json']
reports = [str(BASE / 'launches' / tag / name) for tag in ('readonly', 'task-links', 'review-publication-query')
    for name in ('stdout.log.gz', 'stderr.log.gz', 'exit.txt')]
reports += [str(BASE / name) for name in ('retirement.json', 'observation.json.gz', 'push-monitor-current/result.json')]
for name in ('ROADMAP.md', 'ROADMAP_V2.md', 'docs/linkedspec-book/src/development/documentation-workflow.md', 'docs/linkedspec-book/src/appendix/backend-handoff.md'):
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
origin_path = 'docs/checkpoints/array-concat-open-arity-julia-2026-11-12/run_stage.py'
origin = subprocess.check_output(['git', 'show', 'a3faaf97292550ba1e3001604e1e379d478bcdd4:' + origin_path])
assert origin == Path(origin_path).read_bytes()
anchor = b"paths += [ROOT / p for p in ('tools/project_data_run.sh', 'tools/project_data_env.sh')]\n"
prefix, suffix = origin.split(anchor)
actual = (BASE / 'run_stage.py').read_bytes()
assert actual.startswith(prefix + anchor) and actual.endswith(suffix)
addition = actual[len(prefix + anchor):len(actual)-len(suffix)]
assert addition.startswith(b'paths += [ROOT / p for p in (\n') and addition.endswith(b')]\n')
with tarfile.open(BASE / 'launches/prepare/inputs.tar.gz') as archive:
    assert archive.extractfile(str(BASE / 'run_stage.py')).read() == actual
(OUT / 'driver-origin.json').write_text(json.dumps(dict(source_revision='a3faaf97292550ba1e3001604e1e379d478bcdd4',
    source_path=origin_path, source_bytes=len(origin), source_sha256=hashlib.sha256(origin).hexdigest(),
    actual_launcher_sha256=hashlib.sha256(actual).hexdigest(), added_source_list_bytes=len(addition),
    scope='Late explicit origin relation, not new original first-use credit. Source was already held at activation Git; actual modified launcher is byte-equal to the before-delegation prepare capsule. Native/toolchain/authoring closure remains4.2/SESSION5.'), indent=2) + '\n')
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
outputs = freeze('outputs-after-use', documents + [str(BASE / 'REVIEW.md'), str(OUT / 'rotated-live-row.txt'),
    str(OUT / 'driver-origin.json'), 'docs/knowledge/daily-artifact-log-archival-2026-11-12.md'])
print(json.dumps(dict(publication_inputs=len(inputs), publication_outputs=len(outputs), actual_exit=result.returncode)))
