"""Retain the actual monitor publisher and every consumed report/document image."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT).as_posix()
OUT = BASE / 'publication'
OUT.mkdir()
shared = ['docs/knowledge/github-size-safe-publication.md', 'docs/linkedspec-book/src/development/local-ci-and-regression.md',
    'docs/linkedspec-book/src/appendix/backend-handoff.md', 'ROADMAP.md', 'ROADMAP_V2.md']
documents = shared + ['docs/tasks/TYPE-REFERENCE-BOOK.overview.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md', 'git_message_brief.txt']
instruments = [REL + '/' + name for name in ('publish.py', 'run_publication.py', 'review_publication.py')]
instruments += ['tools/project_data_run.sh', 'tools/project_data_env.sh']
reports = [REL + '/launches/' + tag + '/' + name for tag in ('review', 'current', 'review-publication-query')
    for name in ('stdout.log.gz', 'stderr.log.gz', 'exit.txt')]
reports += [REL + '/measurement/result.json', REL + '/validation-qualified/result.json',
    'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.30.1.json']
for name in shared:
    assert (ROOT / name).read_bytes() == subprocess.check_output(['git', 'show', 'HEAD:' + name], cwd=ROOT)


def freeze(tag, names):
    records = {}
    with tarfile.open(OUT / (tag + '.tar.gz'), 'x:gz') as packed:
        for name in sorted(set(names)):
            path = ROOT / name
            assert not Path(name).is_absolute() and '..' not in Path(name).parts and not path.is_symlink()
            assert path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            records[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            packed.add(path, arcname=name, recursive=False)
    with tarfile.open(OUT / (tag + '.tar.gz')) as packed:
        assert set(packed.getnames()) == records.keys()
        for member in packed:
            body = packed.extractfile(member).read(); row = records[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    (OUT / (tag + '.json')).write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
    return records


inputs = freeze('inputs-before-use', documents + instruments + reports)
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', REL + '/publish.py']
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
actual = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(actual, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(actual.returncode) + '\n')
assert actual.returncode == 0 and not actual.stderr, 'Actual publication failure retained'
for name in instruments + reports:
    path = ROOT / name; row = inputs[name]; body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
outputs = freeze('outputs-after-use', documents + [REL + '/REVIEW.md'])
print(json.dumps(dict(publication_inputs=len(inputs), publication_outputs=len(outputs), actual_exit=actual.returncode)))
