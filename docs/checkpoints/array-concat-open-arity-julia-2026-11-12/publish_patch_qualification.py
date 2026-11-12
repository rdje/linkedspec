"""Record the exact compressed-patch qualification without revising used proof."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'patch-publication'
OUT.mkdir()
folder = BASE / 'launches/review-qualified'
assert (folder / 'exit.txt').read_text() == '0\n'
assert gzip.decompress((folder / 'stderr.log.gz').read_bytes()) == b''
reports = [json.loads(line) for line in gzip.decompress((folder / 'stdout.log.gz').read_bytes()).splitlines()]
assert len(reports) == 2 and reports[0]['historical_recovery'] == reports[1]['patch_qualification'] == 'PASS'
assert len(reports[0]['reason_sensitive_controls']) == 10 and len(reports[1]['compressed_patch_controls']) == 2
paths = [BASE / 'REVIEW.md', Path('docs/knowledge/julia-open-arity-concat-result-guards.md'),
    Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'), Path('MEMORY.md'), Path('CHANGES.md'),
    Path('DEVELOPMENT_NOTES.md'), Path('docs/linkedspec-book/src/appendix/backend-handoff.md')]
instruments = [Path(__file__).relative_to(ROOT), BASE / 'qualify_patch.py', BASE / 'review_qualified.py',
    BASE / 'patch-retention.json'] + [folder / name for name in ('stdout.log.gz', 'stderr.log.gz', 'exit.txt')]


def freeze(tag, names):
    rows = {}
    with tarfile.open(OUT / (tag + '.tar.gz'), 'x:gz') as archive:
        for path in names:
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
    with tarfile.open(OUT / (tag + '.tar.gz')) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            body = archive.extractfile(member).read()
            assert len(body) == rows[member.name]['bytes'] and hashlib.sha256(body).hexdigest() == rows[member.name]['sha256']
            assert member.mode & 0o777 == rows[member.name]['mode']
    (OUT / (tag + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


freeze('before', paths + instruments)
review = paths[0]
review.write_text(review.read_text() + '''
Staging qualification: The first cached whitespace check exits2 because a plain
unified source.diff has a blank context line containing its required leading
space. Store that exact already-sealed artifact as source.diff.gz, verify bytes/
digest/full original mode and readback before retiring only the plain duplicate.
The original seal/first readonly0/all archives/producers/SDK results stay exact.
Current historical entrypoint is review_qualified.py: it imports the unchanged
original reader, substitutes only the one compressed artifact read, recovers all
original proof/ten controls and rejects two own bad-digest/truncation controls.
No SDK/native/repair producer is replayed. Original publication images stay
historical; patch-publication/ retains this separate report/document qualification.
''')
card = paths[1]
source = card.read_text()
old = 'python3 -P ' + str(BASE / 'review.py') + '"'
assert source.count(old) == 1
source = source.replace(old, 'python3 -P ' + str(BASE / 'review_qualified.py') + '"', 1)
card.write_text(source + '''
The retained unified diff is compressed byte-exactly after the cached whitespace
check rejects its blank context line. Use review_qualified.py: the original
reader/seal/first0 remain unchanged; only the exact compressed-patch read is
substituted. All ten original controls and two patch corruption controls pass.
Original document publication images remain historical; separate patch-publication
images retain the current entrypoint qualification. No SDK/producer replay.
''')
task = paths[2]
source = task.read_text()
start = source.index('- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.80.4`')
end = source.index('\n- ID:', start + 1)
part = source[start:end]
assert 'historical review.py/review_publication.py' in part
part = part.replace('historical review.py/review_publication.py', 'historical review_qualified.py/review_publication.py', 1)
part += '''
  Landing artifact defect and fix: First cached git diff --check exits2 on source.diff's blank unified-diff context line. Impact: blocks clean staging, not runtime behavior. Original plain bytes were already sealed/archived; exact gzip readback/digest/full original mode is retained before retiring only that plain duplicate. Separate review_qualified.py imports the byte-identical original reader and substitutes only this compressed-artifact read; actual0/empty stderr recovers all proof/ten original controls and rejects two patch digest/truncation controls. Original reader/first0/seal/producer/runtime/publication images remain unchanged. New patch-publication/ retains actual report/document qualification; no SDK or old producer replay. Current fact-card entrypoint is corrected before normal commit. Normal hooks still govern landing.
'''
task.write_text(source[:start] + part + source[end:])
memory = paths[3]
source = memory.read_text()
assert 'Historical review.py/review_publication.py' in source
source = source.replace('Historical review.py/review_publication.py', 'Historical review_qualified.py/review_publication.py', 1)
source = source.replace('check_current.py is activation/pre-staging only.', 'check_current.py is activation/pre-staging only. Staging whitespace2 is qualified by exact compressed diff retention; original reader/seal/first0 remain, qualified recovery/ten original plus two patch controls pass.', 1)
memory.write_text(source)
for path in paths[4:6]:
    source = path.read_text()
    anchor = 'Evidence: ' + str(BASE / 'REVIEW.md') + '.'
    assert source.count(anchor) == 1
    source = source.replace(anchor, 'The initial staged whitespace2 on a plain diff context line is qualified by\nexact compressed retention and unchanged-reader recovery/ten original plus two\npatch controls. Original proof stays immutable; no runtime replay.\n' + anchor, 1)
    path.write_text(source)
handoff = paths[6]
source = handoff.read_text()
anchor = 'Evidence: ' + str(BASE / 'REVIEW.md') + '.'
assert source.count(anchor) == 1
source = source.replace(anchor, 'The exact retained diff is compressed; qualified historical recovery preserves the original proof and adds two patch controls. ' + anchor, 1)
assert len(source.splitlines()) == 4999
handoff.write_text(source)
freeze('after', paths)
print(json.dumps(dict(patch_document_qualification='PASS', original_reader_controls=10,
    additional_patch_controls=2, retained_before_after_documents=len(paths))))
