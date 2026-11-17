"""Preserve the actual stopped publisher; prepare only its unperformed tail."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
original = (BASE / 'publish.py').read_text()
prefix = original[:original.index('bindings = []')]
old_guard = "assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'"
assert prefix.count(old_guard) == 1
prefix = prefix.replace(old_guard, "assert not (BASE / 'qualified-publication-ready.json').exists(), 'one-shot qualified continuation'")
failure = Path('.linkedspec-data/task-headroom-staged-publication.log').read_bytes()
assert b'line 56' in failure and b'FileExistsError' in failure and b'/telemetry' in failure
with (BASE / 'first-publication-failure.log.gz').open('xb') as stream:
    stream.write(gzip.compress(failure, mtime=0))
with tarfile.open(BASE / 'qualified-composition-before.tar.gz', 'x:gz') as archive:
    for name in ('publish.py', 'prepare_publication.py', 'prepare_qualified_publication.py',
                 'publication-before-identities.json', 'telemetry-identities.json', 'first-publication-failure.log.gz'):
        path = BASE / name
        archive.add(path, arcname=str(path), recursive=False)
validation = r'''
# The stopped prefix produced these images, but reached no document mutation.
before_ids = json.loads((BASE / 'publication-before-identities.json').read_bytes())
bound = set()
with tarfile.open(BASE / 'publication-before.tar.gz') as archive:
    for member in archive:
        name = member.name
        assert member.isfile() and not Path(name).is_absolute() and '..' not in Path(name).parts and name not in bound
        body = archive.extractfile(member).read()
        row = before_ids[name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert stat.S_IMODE(member.mode) == row['mode']
        path = Path(name)
        assert not path.is_symlink() and path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'first prefix changed a guarded input'
        bound.add(name)
assert bound == set(before_ids)
assert not (BASE / 'telemetry-copies.json').exists()
copies = []
for target, row in sorted(json.loads((BASE / 'telemetry-identities.json').read_bytes()).items()):
    path = Path(target)
    body = path.read_bytes()
    assert not path.is_symlink() and hashlib.sha256(body).hexdigest() == row['sha256']
    assert stat.S_IMODE(path.stat().st_mode) == row['mode']
    source = Path(row['source'])
    assert source.read_bytes() == body and stat.S_IMODE(source.stat().st_mode) == row['mode']
    copies.append(dict(source=row['source'], target=target, bytes=len(body), sha256=row['sha256'], mode=row['mode']))
with (BASE / 'telemetry-copies.json').open('x') as stream:
    json.dump(copies, stream, indent=2)
    stream.write(chr(10))
with (BASE / 'qualified-publication-ready.json').open('x') as stream:
    json.dump(dict(result='guarded tail ready', original_documents_unchanged=True,
        reused_existing_telemetry=True, first_prefix_replayed=False,
        limits='Original first prefix/failure and exact images retained. This is a separately named continuation; full native/outer-first-use/per-read/source-origin/physical closure remains4.2/SESSION5.'), stream, indent=2)
    stream.write(chr(10))
'''
tail = original[original.index('summary = ('):]
body = (prefix + validation + tail).encode()
with (BASE / 'publish_qualified.py').open('xb') as stream:
    stream.write(body)
(BASE / 'qualified-composition.json').write_text(json.dumps(dict(original_publisher_sha256=hashlib.sha256(original.encode()).hexdigest(),
    actual_qualified_publisher_sha256=hashlib.sha256(body).hexdigest(), observed_original_exit=1,
    scope='Reuse only original readonly preamble and exact unperformed summary/document/claim tail. Existing before-images/log copies/telemetry are preserved, never reset. New guards verify every first before-image against current bytes/modes before mutation.'), indent=2) + chr(10))
print('Prepared separate guarded publication continuation')
