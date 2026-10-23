"""Repository-local evidence primitives for the dated artifact review."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
BASE = '1e6096435e0ea14a8414a263939bbb75cb2b1310'
PREFIX = 'docs/checkpoints/REPO-HYGIENE.21/'
OWNER = 'REPO-HYGIENE.21'
SOURCE = 'perl/LinkedSpec/CodeblockRuntime.pm'
SOURCES = [SOURCE, 'perl/LinkedSpec/ActionIR/MethodLowering.pm', 'perl/LinkedSpec/BindingRuntime.pm']
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


def paths(excluded=()):
    result = set()
    for row in subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=ROOT).split(b'\0'):
        if row:
            metadata, name = row.split(b'\t', 1)
            mode, _, stage = metadata.split()
            assert stage == b'0'
            if mode in (b'100644', b'100755'):
                result.add(name.decode())
    result.update(path for path in subprocess.check_output(
        ['git', 'ls-files', '--others', '--exclude-standard', '-z'], cwd=ROOT).decode().split('\0') if path)
    return sorted(result - set(excluded))


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
