"""Verify bounded tracked chunks and restore exact project-local proof aliases."""
import hashlib
import json
import os
from pathlib import Path
import re
import tempfile
import common as c

MANIFEST=c.PREFIX+'admission/portable/manifest.json'
CHUNK_BYTES=32*1024*1024
LOGICAL_PATHS=frozenset(c.PREFIX+path for path in (
    'admission/doc-inputs.json.gz',
    'admission/collection/pressure-inputs.json.gz',
    'admission/collection/pressure-final-inputs.json.gz'))


def _inside(root,relative):
    name=Path(relative)
    if name.is_absolute() or not name.parts or any(part in ('.','..') for part in name.parts):
        raise ValueError('Unsafe proof path')
    root=Path(root).resolve()
    if not root.is_relative_to(c.ROOT) or root.stat().st_dev!=c.ROOT.stat().st_dev:
        raise ValueError('Proof data must remain on the project volume')
    ancestor=root
    while ancestor!=c.ROOT:
        if (ancestor/'.git').exists():raise ValueError('Nested repository boundary')
        ancestor=ancestor.parent
    current=root
    for part in name.parts:
        current=current/part
        if current.is_symlink():raise ValueError('Proof paths must not contain symlinks')
        if current.is_dir() and (current/'.git').exists():raise ValueError('Nested repository boundary')
    if not current.resolve().is_relative_to(root):raise ValueError('Proof path escaped its root')
    return current


def validate_manifest(value):
    if value.get('version')!=1 or value.get('chunk_bytes')!=CHUNK_BYTES:
        raise ValueError('Unsupported proof chunk manifest')
    objects=value.get('objects')
    if not isinstance(objects,list) or len(objects)!=3 or {item.get('path') for item in objects}!=LOGICAL_PATHS:
        raise ValueError('Logical proof population mismatch')
    for item in objects:
        if not re.fullmatch(r'[0-9a-f]{64}',item.get('sha256','')):
            raise ValueError('Invalid logical digest')
        if type(item.get('size')) is not int or item['size']<=104857600:
            raise ValueError('Invalid logical size')
        if type(item.get('mode')) is not int or not 0<=item['mode']<=0o7777:
            raise ValueError('Invalid logical mode')
        parts=item.get('parts')
        if not isinstance(parts,list) or len(parts)!=(item['size']+CHUNK_BYTES-1)//CHUNK_BYTES:
            raise ValueError('Proof chunk count mismatch')
        for index,part in enumerate(parts):
            expected=c.PREFIX+'admission/portable/chunks/'+item['sha256']+f'/{index:04d}.part'
            size=min(CHUNK_BYTES,item['size']-index*CHUNK_BYTES)
            if part.get('path')!=expected or part.get('size')!=size:
                raise ValueError('Proof chunk order or size mismatch')
            if not re.fullmatch(r'[0-9a-f]{64}',part.get('sha256','')):
                raise ValueError('Invalid proof chunk digest')
    return value


def manifest():
    return validate_manifest(json.loads(_inside(c.ROOT,MANIFEST).read_bytes()))


def identity(path):
    if not path.is_file() or path.is_symlink():raise ValueError('Missing regular proof input')
    digest=hashlib.sha256();size=0
    with path.open('rb') as source:
        while block:=source.read(1024*1024):digest.update(block);size+=len(block)
    return dict(sha256=digest.hexdigest(),size=size,mode=path.stat().st_mode&0o7777)


def _verify_alias(path,item):
    if identity(path)!={key:item[key] for key in ('sha256','size','mode')}:
        raise ValueError('Existing logical proof bytes or mode mismatch')


def _write_parts(item,output):
    whole=hashlib.sha256();total=0
    for part in item['parts']:
        source=_inside(c.ROOT,part['path'])
        if not source.is_file():raise ValueError('Missing proof chunk')
        digest=hashlib.sha256();size=0
        with source.open('rb') as stream:
            while block:=stream.read(1024*1024):
                output.write(block);digest.update(block);whole.update(block);size+=len(block)
        if size!=part['size'] or digest.hexdigest()!=part['sha256']:
            raise ValueError('Proof chunk bytes mismatch')
        total+=size
    if total!=item['size'] or whole.hexdigest()!=item['sha256']:
        raise ValueError('Reassembled logical proof mismatch')


def ensure_all(value=None,destination_root=None):
    value=manifest() if value is None else validate_manifest(value)
    root=c.ROOT if destination_root is None else Path(destination_root)
    if not root.exists():raise ValueError('Proof destination root must already exist')
    scratch=_inside(c.ROOT,'.linkedspec-data/tmp/type-aggregate-rehydrate')
    scratch.mkdir(parents=True,exist_ok=True)
    restored=[]
    for item in value['objects']:
        target=_inside(root,item['path'])
        if target.exists():_verify_alias(target,item);continue
        target.parent.mkdir(parents=True,exist_ok=True)
        if target.parent.stat().st_dev!=c.ROOT.stat().st_dev:raise ValueError('Cross-volume proof output')
        temporary=None
        try:
            with tempfile.NamedTemporaryFile(dir=scratch,delete=False) as output:
                temporary=Path(output.name)
                _write_parts(item,output)
                output.flush();os.fsync(output.fileno());os.fchmod(output.fileno(),item['mode'])
            try:os.link(temporary,target)
            except FileExistsError:_verify_alias(target,item)
            _verify_alias(target,item)
            restored.append(item['path'])
        finally:
            if temporary is not None:temporary.unlink(missing_ok=True)
    return restored
