"""Repository-local evidence primitives for the Rust signed-selector leaf."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
BASE = '691d2d87690ce3f9052c1d032a3e862ee5d76211'
PREFIX = 'docs/checkpoints/signed-array-rust/'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.17.3'
encode = lambda value: base64.b64encode(value).decode()
decode = base64.b64decode
sha = lambda value: hashlib.sha256(value).hexdigest()


def source(path):
    name = Path(path)
    assert not name.is_absolute() and '..' not in name.parts
    result = ROOT / name
    assert result.is_file() and not result.is_symlink(), path
    return result


def read(path):
    file = source(path)
    raw = file.read_bytes()
    return dict(sha256=sha(raw), mode=file.stat().st_mode & 0o7777, base64=encode(raw))


def identity(path):
    file = source(path)
    digest = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(sha256=digest.hexdigest(), mode=file.stat().st_mode & 0o7777)


def run(command, **kwargs):
    result = subprocess.run(command, cwd=ROOT, capture_output=True, **kwargs)
    return dict(command=command, returncode=result.returncode,
        stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr))


def load(name):
    raw = source(PREFIX + name).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def write_new(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()
    if name.endswith('.gz'):
        raw = gzip.compress(raw, mtime=0)
    with (ROOT / PREFIX / name).open('xb') as output:
        output.write(raw)


def unchanged(inputs):
    return all(identity(path) == item for path, item in inputs.items())
