"""Retain actual publication inputs, producer, channels and resulting documents."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
OUT = BASE / 'publication'
OUT.mkdir()
books = [
    'docs/linkedspec-book/src/appendix/backend-handoff.md',
    'docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
    'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md',
]
documents = books + ['docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md', 'git_message_brief.txt']
instruments = [str(REL / name) for name in ('publish_qualified2.py', 'run_publication_qualified2.py', 'review_publication_qualified2.py')]
instruments += ['tools/project_data_run.sh', 'tools/project_data_env.sh']
reports = [str(REL / 'launches' / tag / name) for tag in ('review-qualified2', 'current-qualified', 'format', 'review-publication')
    for name in ('stdout.log.gz', 'stderr.log.gz', 'exit.txt')]
reports += [str(REL / 'launches' / tag / name) for tag in (
    'direct', 'remaining', 'prepare-publication-qualified', 'prepare-publication-qualified2', 'review-qualified')
    for name in ('stdout.log.gz', 'stderr.log.gz', 'exit.txt')]
for name in books:
    assert (ROOT / name).read_bytes() == subprocess.check_output(['git', 'show', 'HEAD:' + name], cwd=ROOT)


def freeze(tag, names):
    records = {}
    with tarfile.open(OUT / (tag + '.tar.gz'), 'x:gz') as archive:
        for name in sorted(set(names)):
            path = ROOT / name
            assert not Path(name).is_absolute() and '..' not in Path(name).parts and not path.is_symlink()
            assert path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            records[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=name, recursive=False)
    with tarfile.open(OUT / (tag + '.tar.gz')) as archive:
        assert set(archive.getnames()) == records.keys()
        for member in archive:
            body = archive.extractfile(member).read(); row = records[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    (OUT / (tag + '.json')).write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
    return records


inputs = freeze('inputs-before-use', documents + instruments + reports)
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / 'publish_qualified2.py')]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and not result.stderr, 'Actual publication failure retained before qualification'
card = ROOT / 'docs/knowledge/rust-open-arity-concat-result-guards.md'
body = card.read_text()
anchor = '  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P ' + str(REL / 'review_qualified2.py') + '"\n'
assert body.count(anchor) == 1
card.write_text(body.replace(anchor, anchor + '  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P ' + str(REL / 'review_publication_qualified2.py') + '"\n', 1))
# Close temporary progress wording after preserving the precise pre-publication input.
task = ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'
body = task.read_text()
body = body.replace('Frozen normal is running on unchanged engine; no producer/signature/format change.',
    'The unchanged-engine normal later confirms18RED/486PASS before production; producer/signature/format stay exact.', 1)
body = body.replace('Same-path old/current and direct1205 are running serially; full CI remains deferred.',
    'Same-path old18-current504 and combined1205 unique focused checks pass; full CI remains deferred.', 1)
task.write_text(body)
review = ROOT / REL / 'REVIEW.md'
review.write_text(review.read_text() + '\nActual documentation producers, all consumed report/document inputs and resulting\noutputs are retained before/after use in publication/. Independent\nreview_publication_qualified2.py recovers that chain and rejects three report/handoff/count\ncorruptions without executing the SDK or publisher.\n')
for name in instruments + reports:
    path = ROOT / name; row = inputs[name]; body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
outputs = freeze('outputs-after-use', documents + ['docs/knowledge/rust-open-arity-concat-result-guards.md', str(REL / 'REVIEW.md')])
print(json.dumps(dict(publication_inputs=len(inputs), publication_outputs=len(outputs), actual_exit=result.returncode)))
