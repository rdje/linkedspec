"""Independently recover complete-record rollover and the permitted EOF separator."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
FOLDER = BASE / 'history-rollover'


def image(label):
    identities = json.loads((FOLDER / (label + '-identities.json')).read_bytes())
    sources = {}
    with tarfile.open(FOLDER / (label + '.tar.gz')) as archive:
        assert len(archive.getmembers()) == len(identities)
        for member in archive:
            assert member.isfile() and member.name in identities and member.name not in sources
            assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            body = archive.extractfile(member).read()
            row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert stat.S_IMODE(member.mode) == row['mode']
            sources[member.name] = body
    return sources, identities


def validate(before, after, archived_before, archived_after, separator):
    assert archived_before and archived_after.endswith(archived_before), 'old archive stream'
    moved = archived_after[:-len(archived_before)]
    assert moved and before.endswith(moved), 'exact archived source suffix'
    assert before == after + separator + moved, 'hot source reconstruction'
    assert separator == b'' or set(separator) == {10}, 'only LF separator'
    assert after == (after + separator).rstrip(b'\n') + b'\n', 'existing EOF normalization'
    assert before + archived_before == after + separator + archived_after, 'whole history bytes'


def main():
    actual_reader = str(BASE / 'review_hot_history.py')
    reader_identity = json.loads((FOLDER / 'reader-before-use-identities.json').read_bytes())
    with tarfile.open(FOLDER / 'reader-before-use.tar.gz') as archive:
        members = archive.getmembers()
        assert len(members) == 1 and members[0].isfile() and members[0].name == actual_reader
        body = archive.extractfile(members[0]).read()
        row = reader_identity[actual_reader]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert stat.S_IMODE(members[0].mode) == row['mode']
        assert Path(actual_reader).read_bytes() == body and stat.S_IMODE(Path(actual_reader).stat().st_mode) == row['mode']
    before, _ = image('before')
    after, _ = image('after')
    record = json.loads((FOLDER / 'result.json').read_bytes())
    old = gzip.decompress((FOLDER / 'archive-before-stdout.gz').read_bytes())
    new = gzip.decompress((FOLDER / 'archive-after-stdout.gz').read_bytes())
    separator = bytes.fromhex(record['omitted_hot_separator_hex'])
    validate(before['CHANGES.md'], after['CHANGES.md'], old, new, separator)
    combined = before['CHANGES.md'] + old
    assert len(combined) == record['combined_bytes'] and hashlib.sha256(combined).hexdigest() == record['combined_sha256']
    for label in ('archive-before', 'apply', 'archive-after', 'final-check'):
        assert (FOLDER / (label + '-exit.txt')).read_text() == '0\n'
        assert gzip.decompress((FOLDER / (label + '-stderr.gz')).read_bytes()) == b''
    assert (FOLDER / 'required-check-exit.txt').read_text() != '0\n'
    assert b'rollover required' in gzip.decompress((FOLDER / 'required-check-stderr.gz').read_bytes())
    old_files = json.loads((FOLDER / 'old-store-identities.json').read_bytes())
    after_old_files = json.loads((FOLDER / 'after-old-store-identities.json').read_bytes())
    assert old_files == after_old_files and len(old_files) == record['old_files_unchanged'], 'old store identities'
    controls = {}
    for label, changed, gap in [('changed-current-byte', after['CHANGES.md'] + b'x', separator),
        ('extra-source-separator-LF', after['CHANGES.md'], separator + b'\n'),
        ('changed-archive-byte', after['CHANGES.md'], separator)]:
        archived = new + b'x' if label == 'changed-archive-byte' else new
        try:
            validate(before['CHANGES.md'], changed, old, archived, gap)
        except AssertionError:
            controls[label] = 'RED'
        else:
            raise AssertionError('history corruption accepted')
    for label in ('lost-old-entry', 'changed-old-mode', 'changed-old-body'):
        changed = copy.deepcopy(after_old_files)
        name = sorted(changed)[0]
        if label == 'lost-old-entry':
            changed.pop(name)
        elif label == 'changed-old-mode':
            changed[name]['mode'] ^= 0o100
        else:
            changed[name]['sha256'] = '0' * 64
        try:
            assert changed == old_files, label
        except AssertionError as error:
            assert str(error) == label
            controls[label] = 'RED'
        else:
            raise AssertionError('old store corruption accepted')
    bindings = json.loads((FOLDER / 'prior-bindings.json').read_bytes())
    assert all(row['mode'] == 'historical' for row in bindings)
    print(json.dumps(dict(result='PASS', combined_bytes=record['combined_bytes'], combined_sha256=record['combined_sha256'],
        before_bytes=record['before_bytes'], after_bytes=record['after_bytes'], archived_bytes=record['archived_bytes'],
        omitted_hot_separator_hex=record['omitted_hot_separator_hex'], old_files_unchanged=record['old_files_unchanged'],
        new_files=record['new_files'], controls=controls, limits=record['limits']), indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
