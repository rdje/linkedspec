"""Qualify the old plan archive without changing its original bytes or producer."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'plan-archive'
ACTIVATION = 'e3940a675d6313b226c6492198cbdb60c18b78dd'
LEGACY = Path('docs/checkpoints/canonical-discovery-plan-2026-11-16/before.tar.gz')
SOURCE = 'docs/checkpoints/canonical-discovery-plan-2026-11-16/publish.py'


def native(tag, command):
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and result.stderr == b'', 'native archive proof:' + tag
    return result.stdout


def canonical(name):
    parsed = PurePosixPath(name)
    return bool(name) and not parsed.is_absolute() and str(parsed) == name and not set(parsed.parts) & {'.', '..', '.git'}


def validate(rows, expected):
    assert len(rows) == len(expected) and len({name for name, _, _ in rows}) == len(rows), 'archive population'
    for row, wanted in zip(rows, expected):
        assert canonical(row[0]) and row[0] == wanted[0], 'archive namespace'
        assert row[1:] == wanted[1:], 'archive body/mode'


def main():
    OUT.mkdir()
    assert not LEGACY.is_symlink() and LEGACY.resolve().is_relative_to(ROOT)
    original = LEGACY.read_bytes()
    blob = native('legacy-blob', ['git', 'rev-parse', ACTIVATION + ':' + str(LEGACY)]).decode().strip()
    assert hashlib.sha1(b'blob ' + str(len(original)).encode() + b'\0' + original).hexdigest() == blob
    source = native('publisher-source', ['git', 'show', ACTIVATION + ':' + SOURCE])
    tree = native('root-tree', ['git', 'ls-tree', '-rz', ACTIVATION])
    registered = {row.split(b'\t', 1)[1].decode() for row in tree.split(b'\0') if row and row.split(b' ', 1)[0] in (b'100644', b'100755')}
    before = []
    with tarfile.open(fileobj=io.BytesIO(original), mode='r:gz') as archive:
        for member in archive:
            assert member.isfile() and not member.linkname, 'regular archive inputs only'
            before.append((member, archive.extractfile(member).read()))
    aliases = [(member, body) for member, body in before if member.name not in registered]
    assert len(aliases) == 1 and aliases[0][0].name.endswith('/' + SOURCE)
    assert aliases[0][1] == source
    expected = [(SOURCE if member is aliases[0][0] else member.name, body, member.mode) for member, body in before]
    assert all(name in registered and canonical(name) for name, _, _ in expected)
    try:
        validate([(member.name, body, member.mode) for member, body in before], expected)
    except AssertionError as error:
        assert str(error) == 'archive namespace'
    else:
        raise AssertionError('legacy namespace RED was ineffective')
    qualified = OUT / 'before-qualified.tar.gz'
    with tarfile.open(qualified, 'x:gz') as archive:
        for (member, body), (name, _, _) in zip(before, expected):
            info = copy.copy(member)
            info.name = name
            info.pax_headers = {key: value for key, value in member.pax_headers.items() if key not in ('path', 'linkpath')}
            archive.addfile(info, io.BytesIO(body))
    recovered = []
    with tarfile.open(qualified) as archive:
        for member in archive:
            assert member.isfile()
            recovered.append((member.name, archive.extractfile(member).read(), member.mode))
    validate(recovered, expected)
    listing = native('native-names', ['tar', '-tzf', str(qualified)]).decode().splitlines()
    assert listing == [name for name, _, _ in expected]
    modes = native('native-modes', ['tar', '-tvzf', str(qualified)]).decode().splitlines()
    assert len(modes) == len(expected)
    for line, (name, _, mode) in zip(modes, expected):
        assert line.startswith(stat.filemode(stat.S_IFREG | mode)) and line.endswith(' ' + name)
    all_bodies = native('native-bodies', ['tar', '-xOzf', str(qualified)])
    assert all_bodies == b''.join(body for _, body, _ in expected), 'independent full native recovery'
    rejected = []
    for label in ('missing', 'duplicate', 'unsafe-path', 'body', 'mode'):
        changed = list(recovered)
        if label == 'missing':
            changed.pop()
        elif label == 'duplicate':
            changed.append(changed[-1])
        elif label == 'unsafe-path':
            changed[0] = ('../outside', *changed[0][1:])
        elif label == 'body':
            changed[0] = (changed[0][0], changed[0][1] + b' ', changed[0][2])
        else:
            changed[0] = (*changed[0][:2], changed[0][2] ^ 0o100)
        try:
            validate(changed, expected)
        except AssertionError as error:
            assert str(error) in ('archive population', 'archive namespace', 'archive body/mode')
            rejected.append(label)
        else:
            raise AssertionError('ineffective archive control:' + label)
    assert LEGACY.read_bytes() == original
    result = dict(result='PASS', legacy_archive=str(LEGACY), legacy_archive_sha256=hashlib.sha256(original).hexdigest(),
        legacy_git_blob=blob, activation=ACTIVATION, canonical_source=SOURCE,
        legacy_source_name_sha256=hashlib.sha256(aliases[0][0].name.encode()).hexdigest(),
        qualified_archive=str(qualified), qualified_sha256=hashlib.sha256(qualified.read_bytes()).hexdigest(),
        members=[dict(path=name, bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=mode) for name, body, mode in expected],
        rejected=rejected, legacy_namespace='observed RED', native_recovery='all member bodies and modes',
        limits='Original archive/producer stay exact. New logical namespace qualification gives no retroactive first-use or complete native/OS custody credit. No filesystem extraction or SDK run.')
    (OUT / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(result='PASS', portable_archive=str(qualified), original_retained=True, controls=rejected), sort_keys=True))


if __name__ == '__main__':
    main()
