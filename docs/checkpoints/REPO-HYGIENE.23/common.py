"""Owned same-volume capture helpers; source packets and channels stay exact."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/REPO-HYGIENE.23/'
OWNER='REPO-HYGIENE.23'
BASE='c2c4ab05de1e08de56bee77fd6671724720728c8'
sha=lambda raw:hashlib.sha256(raw).hexdigest()
encode=lambda raw:base64.b64encode(raw).decode()
decode=base64.b64decode


def source(name):
    path=Path(name)
    assert not path.is_absolute() and '..' not in path.parts,name
    result=ROOT/path
    assert result.is_file() and not result.is_symlink(),name
    assert result.stat().st_dev==ROOT.stat().st_dev,name
    return result


def read(name):
    path=source(name);raw=path.read_bytes()
    return dict(base64=encode(raw),sha256=sha(raw),mode=path.stat().st_mode & 0o7777)


def identity(name):
    value=read(name)
    return {key:value[key] for key in ('sha256','mode')}


def save(name,value):
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    if name.endswith('.gz'):raw=gzip.compress(raw,mtime=0)
    assert len(raw)<32*1024*1024,'split oversized evidence before publication'
    with (ROOT/PREFIX/name).open('xb') as output:output.write(raw)


def load(name):
    raw=source(PREFIX+name).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def run(command,*,cwd=None,env=None):
    result=subprocess.run(command,cwd=cwd or ROOT,env=env,capture_output=True)
    return dict(command=[str(arg) for arg in command],
        working_directory=Path(cwd or ROOT).relative_to(ROOT).as_posix(),returncode=result.returncode,
        stdout_base64=encode(result.stdout),stderr_base64=encode(result.stderr))


def snapshot(extra=()):
    paths=[path.relative_to(ROOT).as_posix() for path in (ROOT/PREFIX).iterdir()
        if path.is_file() and path.suffix=='.py']
    paths += list(extra)
    files={path:read(path) for path in sorted(set(paths))}
    return dict(sources=files,inputs={path:{key:value[key] for key in ('sha256','mode')}
        for path,value in files.items()},head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip())


def unchanged(inputs):
    return all(identity(path)==expected for path,expected in inputs.items())
