"""Repository-local source/contract authority inventory helpers."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'cf4dceccd24bc6642fc9c7d8d10b329e136849b6'
PREFIX = 'docs/checkpoints/type-reference-inventory/'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.0'
CLAIM = 'docs/claims/' + OWNER + '.json'
OLD_CLAIM = 'docs/claims/TYPE-REFERENCE-BOOK.1.1.json'
OLD_PUBLISHER = 'docs/checkpoints/type-reference-migrations/publish.py'
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
