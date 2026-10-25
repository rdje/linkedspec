"""Retain the actual owned executable as a bounded, recoverable gzip stream."""
import hashlib
import zlib
import common as c

CHUNK_BYTES = 32 * 1024 * 1024 - 1024


def archive(path, stem):
    assert path.is_file() and not path.is_symlink()
    assert path.stat().st_dev == c.ROOT.stat().st_dev
    path.relative_to(c.ROOT)
    digest = hashlib.sha256()
    compressor = zlib.compressobj(level=6, wbits=31)
    pending = bytearray()
    parts = []
    size = 0

    def flush(final=False):
        while len(pending) >= CHUNK_BYTES or (final and pending):
            raw = bytes(pending[:CHUNK_BYTES])
            del pending[:len(raw)]
            name = stem + '-' + str(len(parts) + 1).zfill(3) + '.part'
            target = c.ROOT / c.PREFIX / name
            with target.open('xb') as stream:
                stream.write(raw)
            parts.append(dict(path=c.PREFIX + name, **c.identity(c.PREFIX + name), bytes=len(raw)))

    with path.open('rb') as stream:
        for raw in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(raw)
            size += len(raw)
            pending.extend(compressor.compress(raw))
            flush()
    pending.extend(compressor.flush())
    flush(True)
    return dict(sha256=digest.hexdigest(), bytes=size, mode=path.stat().st_mode & 0o7777,
        parts=parts, encoding='gzip stream split into ordered bounded parts')
