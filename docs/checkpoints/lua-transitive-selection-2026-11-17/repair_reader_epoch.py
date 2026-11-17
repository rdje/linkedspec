"""Preserve the actual used reader epoch before restoring the frozen entry file."""
import difflib
import gzip
import hashlib
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def main():
    assert not (BASE / 'reader-epoch.json').exists(), 'one-shot epoch preservation'
    reader = BASE / 'review.py'
    expanded = reader.read_bytes()
    with tarfile.open(BASE / 'instruments.tar.gz') as archive:
        original = archive.extractfile(str(reader)).read()
    assert expanded != original
    keep = [reader, BASE / 'review_support.py', BASE / 'support-inputs.tar.gz', BASE / 'probes.py',
        BASE / 'probes.json', BASE / 'selection.json', BASE / 'repair_reader_epoch.py',
        Path('.linkedspec-data/lua-transitive-probes.log'), Path('.linkedspec-data/lua-transitive-review.log')]
    identities = {}
    with tarfile.open(BASE / 'reader-epoch-after-use.tar.gz', 'x:gz') as archive:
        for path in keep:
            assert path.is_file() and not path.is_symlink()
            body = path.read_bytes()
            identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=str(path), recursive=False)
    old, new = original.decode(), expanded.decode()
    edits = []
    for operation, begin, end, other_begin, other_end in difflib.SequenceMatcher(None, old, new, autojunk=False).get_opcodes():
        if operation != 'equal':
            edits.append(dict(begin=begin, end=end, original=old[begin:end], replacement=new[other_begin:other_end]))
    body = old
    for edit in reversed(edits):
        assert body[edit['begin']:edit['end']] == edit['original']
        body = body[:edit['begin']] + edit['replacement'] + body[edit['end']:]
    assert body.encode() == expanded
    record = dict(original_sha256=hashlib.sha256(original).hexdigest(), used_sha256=hashlib.sha256(expanded).hexdigest(),
        original_entry=str(reader), used_body_retained_as=str(BASE / 'used_review_expanded.py'), identities=identities,
        edits=edits, derived_source=body,
        incident='Support was added after the frozen original capture. A pre-derivation assertion failed; the next grouped shell continued after missing support-derivation.json into the probe producer, which imported the expanded reader. The following support reader failed because its identities file was absent. Its partial archive remains unchanged.',
        missing='The used expanded reader was not captured before that probe import. First failed setup channels were shown by the tool but not retained as original raw files; outer probe-producer exit was not separately recorded. Do not assign retroactive first-use custody or a separately observed outer producer exit. Actual four Bash child exits/inputs/channels survive.',
        repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2')
    (BASE / 'reader-epoch.json').write_text(json.dumps(record, indent=2, sort_keys=True) + '\n')
    (BASE / 'used_review_expanded.py').write_bytes(expanded)
    reader.write_bytes(original)
    assert reader.read_bytes() == original
    print(json.dumps(dict(result='PASS', edits=len(edits), retained_used_bytes=len(expanded), restored_original_bytes=len(original),
        limit=record['missing']), sort_keys=True))


if __name__ == '__main__':
    main()
