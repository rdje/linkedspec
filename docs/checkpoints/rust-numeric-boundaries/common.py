"""Repository-local custody for the Rust numeric conversion repair."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import zlib

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/rust-numeric-boundaries/'
BASE = 'f0d974aa1b337bbf2ee16e51c0297182e1e94f82'
OWNER = 'SESSION-STARTUP-READING.55.1'
encode = lambda raw: base64.b64encode(raw).decode()
decode = base64.b64decode
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def source(path):
    name = Path(path)
    assert not name.is_absolute() and '..' not in name.parts
    file = ROOT/name
    assert file.is_file() and not file.is_symlink(), path
    assert file.stat().st_dev == ROOT.stat().st_dev, path
    return file


def read(path):
    file = source(path)
    raw = file.read_bytes()
    return dict(base64=encode(raw), sha256=sha(raw), mode=file.stat().st_mode & 0o7777)


def identity(path):
    file = source(path)
    digest = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''):
            digest.update(block)
    return dict(sha256=digest.hexdigest(), mode=file.stat().st_mode & 0o7777)


def save(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(',', ':'))+'\n').encode()
    if name.endswith('.gz'):
        raw = gzip.compress(raw, mtime=0)
    with (ROOT/PREFIX/name).open('xb') as output:
        output.write(raw)


def load(name):
    raw = source(PREFIX+name).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def run(command, *, cwd=None, env=None):
    result = subprocess.run(command, cwd=cwd or ROOT, env=env, capture_output=True)
    return dict(command=[str(arg) for arg in command], returncode=result.returncode,
        stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr))


def context(extras=()):
    rows = subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=ROOT).split(b'\0')
    paths = []
    for row in rows:
        if not row:
            continue
        metadata, path = row.split(b'\t', 1)
        mode, _, stage = metadata.split()
        assert stage == b'0'
        if path.startswith(b'rust/') and mode in (b'100644', b'100755'):
            paths.append(path.decode())
    # The accepted signed-selector closure already names the root-level first-
    # party compile/test includes. Re-snapshot their actual current bytes; never
    # run any predecessor capture writer or inspect a dependency implementation.
    closure = json.loads(gzip.decompress(source(
        'docs/checkpoints/signed-array-rust/first-party-include-closure.json.gz').read_bytes()))
    paths += list(closure['accepted_inputs'])
    paths += ['tools/run_cargo_local.sh', 'tools/project_data_env.sh',
        'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
        'capability_conformance/scalar_numeric_contract.json',
        'capability_conformance/scalar_text_contract.json',
        'docs/checkpoints/signed-array-rust/first-party-include-closure.json.gz']
    paths += [file.relative_to(ROOT).as_posix() for file in (ROOT/PREFIX).glob('*.py')]
    paths += list(extras)
    packets = {path: read(path) for path in sorted(set(paths))}
    return dict(base=BASE, head=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT,
        text=True).strip(), sources=packets,
        inputs={path: {key: packet[key] for key in ('sha256', 'mode')} for path, packet in packets.items()},
        scope='Conservative current first-party input closure: every tracked Rust source/data/configuration input, accepted named root includes, wrappers/contracts and actual owned producer inputs. Installed SDK/OS and prepared published RGX products are read-only prerequisites. No dependency implementation is read and no whole-environment replay is claimed. Actual executables are retained separately; later generated inputs must be enrolled before execution.')


def unchanged(inputs):
    return all(identity(path) == item for path, item in inputs.items())


def archive(file, stem):
    file.relative_to(ROOT)
    assert file.is_file() and not file.is_symlink() and file.stat().st_dev == ROOT.stat().st_dev
    compressor = zlib.compressobj(level=6, wbits=31)
    digest, pending, parts, size = hashlib.sha256(), bytearray(), [], 0
    limit = 32*1024*1024-1024

    def flush(final=False):
        while len(pending) >= limit or (final and pending):
            raw = bytes(pending[:limit])
            del pending[:len(raw)]
            name = f'{stem}-{len(parts)+1:03}.part'
            with (ROOT/PREFIX/name).open('xb') as output:
                output.write(raw)
            parts.append(dict(path=PREFIX+name, bytes=len(raw), **identity(PREFIX+name)))

    with file.open('rb') as stream:
        for raw in iter(lambda: stream.read(1024*1024), b''):
            digest.update(raw)
            size += len(raw)
            pending.extend(compressor.compress(raw))
            flush()
    pending.extend(compressor.flush())
    flush(True)
    return dict(sha256=digest.hexdigest(), bytes=size, mode=file.stat().st_mode & 0o7777,
        parts=parts, encoding='ordered bounded gzip stream')
