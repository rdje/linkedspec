"""Repository-owned deferred-aggregate proof primitives; all data stays local."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='49ce3fb472b01dc6a7987b0038fae22686dee7cd'
PREFIX='docs/checkpoints/type-array-pipelines/'
OWNER='TYPE-REFERENCE-BOOK.1.2.9'
SOURCE='perl/LinkedSpec/CodeblockRuntime.pm'
sha=lambda value:hashlib.sha256(value).hexdigest()
encode=lambda value:base64.b64encode(value).decode()
decode=base64.b64decode


def read(path):
    assert not Path(path).is_absolute() and '..' not in Path(path).parts
    source=ROOT/path
    assert source.is_file() and not source.is_symlink(),path
    raw=source.read_bytes()
    return dict(sha256=sha(raw),mode=source.stat().st_mode&0o7777,base64=encode(raw))


def identity(path):
    return {key:value for key,value in read(path).items() if key!='base64'}


def run(command,**kwargs):
    result=subprocess.run(command,cwd=ROOT,capture_output=True,**kwargs)
    return dict(command=command,returncode=result.returncode,stdout_base64=encode(result.stdout),stderr_base64=encode(result.stderr))


def load(name):
    raw=(ROOT/(PREFIX+name)).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def write_new(name,value):
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    if name.endswith('.gz'):raw=gzip.compress(raw,mtime=0)
    with (ROOT/(PREFIX+name)).open('xb') as output:output.write(raw)


def unchanged(inputs):
    return all(identity(path)==item for path,item in inputs.items())
