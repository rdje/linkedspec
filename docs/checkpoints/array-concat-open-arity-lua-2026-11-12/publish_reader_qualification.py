"""Retain actual qualification report/document images before updating reader guidance."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile
BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OUT = BASE / 'reader-qualification-publication'
OUT.mkdir()
report = BASE / 'launches/review-qualified'
assert (report / 'exit.txt').read_text() == '0\n'
assert gzip.decompress((report / 'stderr.log.gz').read_bytes()) == b''
result = json.loads(gzip.decompress((report / 'stdout.log.gz').read_bytes()))
assert len(result['reason_sensitive_controls']) == 11 and len(result['qualification_controls']) == 2
assert (BASE / 'launches/cached-whitespace/exit.txt').read_text() == '2\n'
assert gzip.decompress((BASE / 'launches/cached-whitespace/stderr.log.gz').read_bytes()) == b''
card = Path('docs/knowledge/lua-open-arity-concat-result-guards.md')
review = BASE / 'REVIEW.md'
task = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
paths = [card, review, task, Path('MEMORY.md'), Path('CHANGES.md'), Path('DEVELOPMENT_NOTES.md')]
inputs = paths + [Path(__file__).relative_to(Path.cwd().resolve()), BASE / 'review_qualified.py', BASE / 'review.py', BASE / 'semantic_oracle.py.gz', BASE / 'oracle-retention.json', BASE / 'sealed-identities.json']
inputs += [report / name for name in ('stdout.log.gz','stderr.log.gz','exit.txt')]
inputs += [BASE / 'launches/cached-whitespace' / name for name in ('stdout.log.gz','stderr.log.gz','exit.txt')]
inputs += [Path('tools/project_data_run.sh'), Path('tools/project_data_env.sh')]
def freeze(tag, names):
    rows = {}
    with tarfile.open(OUT / (tag + '.tar.gz'), 'x:gz') as archive:
        for path in sorted(set(names)):
            assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
            raw = path.read_bytes()
            rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
    with tarfile.open(OUT / (tag + '.tar.gz')) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            raw = archive.extractfile(member).read()
            row = rows[member.name]
            assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    (OUT / (tag + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
freeze('before', inputs)
body = card.read_text()
old = str(BASE / 'review.py')
assert body.count(old) == 1
body = body.replace(old, str(BASE / 'review_qualified.py'), 1)
body += '''
The staged whitespace check found an extra EOF blank line in the used semantic
oracle source. Exact original bytes now live in semantic_oracle.py.gz; only the
plain duplicate retires after readback. Default review_qualified.py loads the
unchanged original reader and substitutes only that exact read/import path. It
recovers all eleven original controls and rejects two additional oracle digest/
truncation controls. Original reader/first0/seal/producer/runtime bytes stay exact;
standalone original review.py still expects the retired plain file. No SDK replay.
'''
card.write_text(body)
body = review.read_text()
old = 'Historical review.py runs no SDK or producer.'
assert body.count(old) == 1
body = body.replace(old, 'Default historical review_qualified.py runs the unchanged original reader with only the retained-oracle read/import path qualified, without SDK or producer execution.', 1)
body += '''
Staging packaging qualification: the first cached inspection reported an extra
blank line at EOF in semantic_oracle.py; its individual exit was not retained by
that combined shell. A separate captured cached check then returns2/empty stderr
for exactly that line. No normal commit was attempted. The used source is never
edited: exact gzip readback/digest/full original mode precedes retirement of only
its plain duplicate. Separate review_qualified.py recovers the original sealed
proof and all eleven controls, then rejects two oracle-body/truncation controls.
Original review.py/first0/seal/templates/SDK/producers/outcomes remain immutable.
The standalone original reader expects the retired plain path; the current
Knowledge card names the qualified default. Separate actual report/document
before/after images live in reader-qualification-publication/. No SDK epoch or
old publisher is replayed. Current266 remains the earlier pre-staging result,
before this packaging move; it is not a future current-file promise.
'''
review.write_text(body)
body = task.read_text()
body += '''

  Staged packaging defect and correction: Cached inspection reports an extra EOF blank line in the used semantic_oracle.py; its first individual exit was not captured by the combined shell. Separate retained cached-whitespace exits2/empty stderr for that exact line. No normal commit attempt yet. Own80.5 retains exact gzip bytes/digest/full original mode before retiring only the plain duplicate. Separate review_qualified.py imports the unchanged original reader and substitutes only that retained-source read/import path; actual0/empty stderr recovers all eleven original corruptions and rejects two added oracle digest/truncation controls. Original reader/first0/seal/producer/SDK outcomes remain immutable, no SDK replay. Current Knowledge card names qualified default; original standalone reader expects the retired plain path. Separate actual report/document before-after custody retained; prior current266 remains point-in-time before this packaging change. Normal hooks still govern landing.
'''
task.write_text(body)
p = Path('MEMORY.md')
body = p.read_text()
old = 'Historical review.py/review_publication.py execute no SDK; current is point-in-time only.'
assert body.count(old) == 1
body = body.replace(old, 'Default historical review_qualified.py/review_publication.py execute no SDK. Exact used semantic oracle is gzip-retained after cached whitespace2; unchanged original reader/first0/seal remain, with eleven original plus two qualification controls passing. Original standalone reader expects the retired plain oracle. Current266 is point-in-time before packaging only.', 1)
p.write_text(body)
for name in ('CHANGES.md','DEVELOPMENT_NOTES.md'):
    p = Path(name)
    body = p.read_text()
    start = body.index('TYPE-REFERENCE-BOOK.1.2.23.3.80.5')
    end = body.find('\n## ', start)
    end = len(body) if end < 0 else end
    section = body[:end].rstrip()
    section += ' Staged whitespace2 is resolved by exact used-oracle compression and a separate qualified read/import path; original reader/first0/seal remain, eleven original plus two qualification controls pass without SDK replay.\n\n'
    p.write_text(section + body[end:])
freeze('after', paths)
print(json.dumps(dict(reader_qualification_publication='PASS', original_controls=11, extra_oracle_controls=2, source='exact original gzip bytes; original standalone reader expects retired plain source', sdk_replay=False)))
