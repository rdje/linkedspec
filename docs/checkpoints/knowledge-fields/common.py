"""Repository-local evidence helpers for supported Knowledge metadata projection."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'f7e8b292f3334fb8d6a8b3a5c51b67605d1fa2bf'
HOME = 'docs/checkpoints/knowledge-fields/'
OWNER = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12'
CLAIM = 'docs/claims/' + OWNER + '.json'
OLD_CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.6.json'
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
               (ROOT / path).stat().st_mode & 0o7777 == item['mode']
               for path, item in inputs.items())


def write_new(path, value, packed=False):
    data = (json.dumps(value, sort_keys=True, indent=None if packed else 1) + '\n').encode()
    if packed:
        data = gzip.compress(data, mtime=0)
    with (ROOT / path).open('xb') as output:
        output.write(data)
    return sha(data)
