"""Repository-local evidence helpers for the bounded migration-guidance repair."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '1a8b202018a387c87425442375f53c3ee5e820d4'
PREFIX = 'docs/checkpoints/type-reference-migrations/'
OWNER = 'TYPE-REFERENCE-BOOK.1.1'
CLAIM = 'docs/claims/' + OWNER + '.json'
PRIOR_CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12.json'
PRIOR_PUBLISHER = 'docs/checkpoints/knowledge-fields/publish.py'
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
    return all(sha((ROOT / path).read_bytes()) == item['sha256'] and
               (ROOT / path).stat().st_mode & 0o7777 == item['mode'] for path, item in inputs.items())


def write_new(path, value, packed=False):
    raw = (json.dumps(value, sort_keys=True, indent=None if packed else 1) + '\n').encode()
    if packed:
        raw = gzip.compress(raw, mtime=0)
    with (ROOT / path).open('xb') as output:
        output.write(raw)
    return sha(raw)
