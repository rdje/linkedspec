"""Source-bound evidence for registered array pipelines and length lowering."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
BASE = 'afc58252ca36d53076929cd51e3ad445e4953341'
PREFIX = 'docs/checkpoints/type-registered-array-pipelines/'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.11'
SOURCES = ['perl/LinkedSpec/ActionIR/MethodLowering.pm', 'perl/LinkedSpec/CodeblockRuntime.pm']
encode = lambda raw: base64.b64encode(raw).decode()
decode = base64.b64decode
sha = lambda raw: hashlib.sha256(raw).hexdigest()

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
    packet = read(path)
    return {key: packet[key] for key in ('sha256', 'mode')}

def load(name):
    raw = source(PREFIX+name).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)

def write_new(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(',', ':'))+'\n').encode()
    if name.endswith('.gz'):
        raw = gzip.compress(raw, mtime=0)
    with (ROOT/PREFIX/name).open('xb') as stream:
        stream.write(raw)

def run(command, **kwargs):
    process = subprocess.run(command, cwd=ROOT, capture_output=True, **kwargs)
    return dict(command=command, returncode=process.returncode,
        stdout_base64=encode(process.stdout), stderr_base64=encode(process.stderr))

def epoch(extras=()):
    """All main-repository inputs, without recursively embedding old evidence."""
    rows = subprocess.check_output(['git','ls-files','--stage','-z'],cwd=ROOT).split(b'\0')
    paths = set(extras)
    for row in rows:
        if row:
            metadata, name = row.split(b'\t',1)
            mode, _, stage = metadata.split()
            assert stage == b'0'
            if mode in (b'100644',b'100755'):
                paths.add(name.decode())
    paths.update(name for name in subprocess.check_output(
        ['git','ls-files','--others','--exclude-standard','-z'],cwd=ROOT).decode().split('\0') if name)
    inputs = {path:identity(path) for path in sorted(paths)}
    changed = set(subprocess.check_output(
        ['git','diff','--name-only','-z',BASE],cwd=ROOT).decode().split('\0'))
    tracked = {row.split(b'\t',1)[1].decode() for row in rows if row}
    overrides = {path:read(path) for path in paths
        if (path in changed or path not in tracked) and not path.endswith(('.gz','.part'))}
    return dict(base=BASE, inputs=inputs, overrides=overrides,
        scope='Every regular main-repository tracked/new input at this epoch; unchanged bytes recover at real accepted Git, changed/new plain inputs are retained whole, immutable compressed inputs keep exact byte/full-mode identities. Gitlinks, symlinks and other repositories are excluded. System tools and documented dependency outputs are read-only prerequisites.')

def observe(plan):
    return run(['bash','tools/project_data_run.sh','perl','-Iperl',PREFIX+'probe.pl'],
        input=json.dumps(plan).encode())
