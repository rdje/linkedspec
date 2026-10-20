"""Read exact checkpoint byte streams from bounded, hash-checked payload chunks."""
import base64
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import common as c

ROOT = c.ROOT
P = 'docs/checkpoints/type-values-selector/'
INDEXES = {
    'docs/checkpoints/type-values-admission/canonical1-candidate.patch.gz':
        P + 'parts/canonical1/index.json',
    P + 'preservation.json.gz': P + 'parts/preservation/index.json',
}
READS = {}
_native_read = c.read


def checked_target(path, root=ROOT):
    relative = PurePosixPath(path)
    assert not relative.is_absolute() and relative.as_posix() == path
    assert relative.parts and not set(relative.parts) & {'', '.', '..'}
    root = root.resolve()
    target = root / path
    assert target.resolve().is_relative_to(root)
    for candidate in (target, *target.parents):
        assert not candidate.is_symlink(), path
        if candidate == root:
            break
        assert not (candidate.is_dir() and (candidate / '.git').exists()), path
    existing = target
    while not existing.exists():
        existing = existing.parent
    assert existing.stat().st_dev == root.stat().st_dev
    return target


def physical(path, root=ROOT):
    target = checked_target(path, root)
    assert target.is_file(), path
    return target.read_bytes(), target.stat().st_mode & 0o7777


def read_partition(index_path, root=ROOT):
    raw, _ = physical(index_path, root)
    index = json.loads(raw)
    assert set(index) == {'version', 'logical_path', 'sha256', 'size', 'mode', 'parts'}
    assert type(index['version']) is int and index['version'] == 1
    assert type(index['size']) is int and index['size'] >= 0
    assert type(index['mode']) is int and 0 <= index['mode'] <= 0o7777
    directory = PurePosixPath(index_path).parent
    pieces, seen, total = [], set(), 0
    for number, part in enumerate(index['parts']):
        assert set(part) == {'path', 'file_sha256', 'payload_sha256', 'size', 'mode', 'offset', 'number'}
        assert part['number'] == number and part['offset'] == total
        assert PurePosixPath(part['path']).parent == directory and part['path'] not in seen
        seen.add(part['path'])
        packed, mode = physical(part['path'], root)
        assert mode == part['mode'] and c.sha(packed) == part['file_sha256']
        value = json.loads(gzip.decompress(packed))
        assert set(value) == {'version', 'payload_base64'} and value['version'] == 1
        payload = base64.b64decode(value['payload_base64'], validate=True)
        assert base64.b64encode(payload).decode() == value['payload_base64']
        assert len(payload) == part['size'] and c.sha(payload) == part['payload_sha256']
        pieces.append(payload)
        total += len(payload)
    data = b''.join(pieces)
    assert total == index['size'] and hashlib.sha256(data).hexdigest() == index['sha256']
    return data, index['mode'], index


def read_bytes(path):
    if path in INDEXES and (ROOT / INDEXES[path]).is_file():
        data, mode, index = read_partition(INDEXES[path])
        assert index['logical_path'] == path
        READS[path] = READS.get(path, 0) + 1
        return data, mode
    return physical(path)


def read(path):
    if path in INDEXES and (ROOT / INDEXES[path]).is_file():
        raw, mode = read_bytes(path)
        return dict(base64=c.encode(raw), sha256=c.sha(raw), mode=mode)
    return _native_read(path)


def load(name):
    raw, _ = read_bytes(P + name)
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


_history = None


def historical_version(path, wanted):
    global _history
    if _history is None:
        _history = load('historical-versions.json.gz')['versions']
    for item in _history.get(path, []):
        if item['sha256'] == wanted['sha256'] and item['mode'] == wanted['mode']:
            assert c.sha(c.decode(item['base64'])) == item['sha256']
            return item
    return None


def install_legacy(common, capsules):
    """Resolve only the two declared logical artifacts for unchanged retained readers."""
    assert common is c
    common.read = read
    if getattr(capsules, '_partition_storage_installed', False):
        return
    original = capsules.read_version

    def read_version(path, wanted):
        if path in INDEXES and (ROOT / INDEXES[path]).is_file():
            item = read(path)
            assert all(item[key] == wanted[key] for key in ('sha256', 'mode')), path
            return item
        historical = historical_version(path, wanted)
        if historical is not None:
            return historical
        return original(path, wanted)

    capsules.read_version = read_version
    capsules._partition_storage_installed = True
