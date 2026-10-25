"""Repository-local custody helpers for the Rust canonical repair."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import zlib

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/signed-array-rust-admission/'
encode = lambda raw: base64.b64encode(raw).decode()
decode = base64.b64decode
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def source(path):
    name = Path(path)
    assert not name.is_absolute() and '..' not in name.parts
    file = ROOT / name
    assert file.is_file() and not file.is_symlink(), path
    return file


def read(path):
    file = source(path)
    raw = file.read_bytes()
    return dict(base64=encode(raw), sha256=sha(raw), mode=file.stat().st_mode & 0o7777)


def identity(path):
    file = source(path)
    digest = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(sha256=digest.hexdigest(), mode=file.stat().st_mode & 0o7777)


def save(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()
    if name.endswith('.gz'):
        raw = gzip.compress(raw, mtime=0)
    with (ROOT / PREFIX / name).open('xb') as output:
        output.write(raw)


def load(name):
    raw = source(PREFIX + name).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def run(command, *, cwd=None, env=None):
    result = subprocess.run(command, cwd=cwd or ROOT, env=env, capture_output=True)
    return dict(command=[str(arg) for arg in command], returncode=result.returncode,
                stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr))


def context(extras=()):
    # Reuse the sealed pure input collector, never any capture/writer entrypoint.
    import sys
    sys.path.insert(0, str(ROOT / 'docs/checkpoints/signed-array-rust'))
    import epoch
    own = [file.relative_to(ROOT).as_posix() for file in (ROOT / PREFIX).glob('*.py')]
    return epoch.snapshot(own + list(extras))


def unchanged(inputs):
    return all(identity(path) == item for path, item in inputs.items())


def archive(file, stem):
    file.relative_to(ROOT)
    assert file.is_file() and not file.is_symlink()
    assert file.stat().st_dev == ROOT.stat().st_dev
    compressor = zlib.compressobj(level=6, wbits=31)
    digest = hashlib.sha256()
    pending = bytearray()
    parts, size = [], 0
    limit = 32 * 1024 * 1024 - 1024

    def flush(final=False):
        while len(pending) >= limit or (final and pending):
            raw = bytes(pending[:limit])
            del pending[:len(raw)]
            name = f'{stem}-{len(parts)+1:03}.part'
            with (ROOT / PREFIX / name).open('xb') as output:
                output.write(raw)
            parts.append(dict(path=PREFIX + name, bytes=len(raw), **identity(PREFIX + name)))

    with file.open('rb') as stream:
        for raw in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(raw)
            size += len(raw)
            pending.extend(compressor.compress(raw))
            flush()
    pending.extend(compressor.flush())
    flush(True)
    return dict(sha256=digest.hexdigest(), bytes=size, mode=file.stat().st_mode & 0o7777,
                parts=parts, encoding='ordered bounded gzip stream')
