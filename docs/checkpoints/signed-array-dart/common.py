"""Repository-local, immutable-input custody for Dart signed selectors."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/signed-array-dart/'
BASE='4e6ece603bbdf7c77b83a2e8c1f79946e7da0490'
OWNER='TYPE-REFERENCE-BOOK.1.2.17.4'
encode=lambda raw:base64.b64encode(raw).decode()
decode=base64.b64decode
sha=lambda raw:hashlib.sha256(raw).hexdigest()


def file(path):
    name=Path(path)
    assert not name.is_absolute() and '..' not in name.parts,path
    result=ROOT/name
    assert result.is_file() and not result.is_symlink(),path
    assert result.stat().st_dev==ROOT.stat().st_dev,path
    return result


def read(path):
    source=file(path);raw=source.read_bytes()
    return dict(base64=encode(raw),sha256=sha(raw),mode=source.stat().st_mode & 0o7777)


def identity(path):
    packet=read(path)
    return {key:packet[key] for key in ('sha256','mode')}


def save(name,value):
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    if name.endswith('.gz'):raw=gzip.compress(raw,mtime=0)
    with (ROOT/PREFIX/name).open('xb') as output:output.write(raw)


def load(name):
    raw=file(PREFIX+name).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def run(command,*,cwd=None,env=None):
    result=subprocess.run(command,cwd=cwd or ROOT,env=env,capture_output=True)
    return dict(command=[str(arg) for arg in command],
        working_directory=Path(cwd or ROOT).relative_to(ROOT).as_posix(),returncode=result.returncode,
        stdout_base64=encode(result.stdout),stderr_base64=encode(result.stderr))


def context(extras=()):
    paths=[]
    for row in subprocess.check_output(['git','ls-files','--stage','-z'],cwd=ROOT).split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1);mode,_,stage=metadata.split()
        assert stage==b'0'
        if mode in (b'100644',b'100755') and name.startswith((b'dart/',b'specs/')):
            paths.append(name.decode())
    paths+=['dart/.dart_tool/package_config.json','dart/.dart_tool/package_graph.json',
        'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_dart_project_data.sh',
        'tools/run_dart_local.sh','capability_conformance/signed_array_selector_contract.json',
        'capability_conformance/write_vivification_contract.json',
        'capability_conformance/map_leaves_mutation_contract.json',
        'capability_conformance/write_map_leaves_composition_contract.json']
    paths += [path.relative_to(ROOT).as_posix() for path in (ROOT/PREFIX).iterdir()
              if path.suffix in ('.py','.dart') and path.is_file()]
    paths+=list(extras)
    packets={path:read(path) for path in sorted(set(paths))}
    return dict(base=BASE,head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        sources=packets,inputs={path:{key:packet[key] for key in ('sha256','mode')}
            for path,packet in packets.items()},
        scope='Conservative first-party Dart/specification closure, actual package resolution, '
            'wrappers, frozen contracts and explicit probe inputs before compilation/execution. '
            'Installed SDK/OS and locked hosted test packages are read-only prerequisites. '
            'This baseline executes no package test population; later consumer fixtures need '
            'their own explicit enrollment. No dependency implementation or whole-environment replay.')


def unchanged(inputs):
    return all(identity(path)==value for path,value in inputs.items())


def archive(path,stem):
    source=file(path);raw=source.read_bytes();packed=gzip.compress(raw,mtime=0)
    limit=32*1024*1024-1024;parts=[]
    for offset in range(0,len(packed),limit):
        name=f'{stem}-{len(parts)+1:03}.part';block=packed[offset:offset+limit]
        with (ROOT/PREFIX/name).open('xb') as output:output.write(block)
        parts.append(dict(path=PREFIX+name,bytes=len(block),**identity(PREFIX+name)))
    return dict(path=path,sha256=sha(raw),bytes=len(raw),mode=source.stat().st_mode & 0o7777,
        parts=parts,encoding='ordered bounded gzip stream')
