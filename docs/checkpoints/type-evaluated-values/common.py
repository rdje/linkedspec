"""Repository-local source/contract authority inventory helpers."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'c053c9dcf24a78cc8b551187f47cdb7aefb03eb3'
PREFIX = 'docs/checkpoints/type-evaluated-values/'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.3'
CLAIM = 'docs/claims/' + OWNER + '.json'
OLD_CLAIM = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.0.json'
OLD_PUBLISHER = 'docs/checkpoints/type-reference-inventory/publish.py'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
decode = base64.b64decode


def read(path):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink(), path
    value = source.read_bytes()
    return dict(base64=encode(value), sha256=sha(value), mode=source.stat().st_mode & 0o7777)


def run(command, **kwargs):
    result = subprocess.run(command, cwd=ROOT, capture_output=True, **kwargs)
    return dict(command=command, returncode=result.returncode,
                stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr))


def unchanged(inputs):
    return all(read(path) == item for path, item in inputs.items())


def write_new(path, value, packed=False):
    raw = (json.dumps(value, sort_keys=True, indent=None if packed else 1) + '\n').encode()
    if packed:
        raw = gzip.compress(raw, mtime=0)
    with (ROOT / path).open('xb') as output:
        output.write(raw)
    return sha(raw)
