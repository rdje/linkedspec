"""Prepare exact bounded chunks without changing the in-flight staged candidate."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c

OUT=ROOT/'.linkedspec-data/verification/type-aggregate-portable-chunks'
CHUNK=32*1024*1024


def main():
    saved=json.loads(gzip.decompress((ROOT/'.linkedspec-data/verification/type-aggregate-third-epoch.json.gz').read_bytes()))
    OUT.mkdir()
    objects=[]
    for path,size in sorted(saved['oversized'].items()):
        assert c.identity(path)==saved['inputs'][path]
        destination=OUT/saved['inputs'][path]['sha256'];destination.mkdir()
        parts=[];digest=hashlib.sha256();total=0
        with (ROOT/path).open('rb') as source:
            while raw:=source.read(CHUNK):
                name=f'{len(parts):04d}.part'
                with (destination/name).open('xb') as output:output.write(raw)
                assert (destination/name).read_bytes()==raw
                parts.append(dict(path=c.PREFIX+'admission/portable/chunks/'+destination.name+'/'+name,
                    size=len(raw),sha256=c.sha(raw)))
                digest.update(raw);total+=len(raw)
        assert digest.hexdigest()==saved['inputs'][path]['sha256'] and total==size
        independent=hashlib.sha256();count=0
        for part in parts:
            raw=(destination/Path(part['path']).name).read_bytes()
            assert c.sha(raw)==part['sha256'] and len(raw)==part['size']<=CHUNK
            independent.update(raw);count+=len(raw)
        assert independent.hexdigest()==digest.hexdigest() and count==total
        objects.append(dict(path=path,size=size,**saved['inputs'][path],parts=parts))
    manifest=dict(version=1,chunk_bytes=CHUNK,objects=objects,
        scope='Exact bytes and full modes of three preserved unpublished gzip artifacts; bounded '
              'tracked chunks reconstruct ignored project-local logical aliases without external storage.')
    raw=(json.dumps(manifest,sort_keys=True,separators=(',',':'))+'\n').encode()
    with (OUT/'manifest.json').open('xb') as output:output.write(raw)
    result=dict(manifest_sha256=c.sha(raw),objects=len(objects),parts=sum(len(item['parts']) for item in objects),
        logical_bytes=sum(item['size'] for item in objects),max_part_bytes=max(part['size'] for item in objects for part in item['parts']),
        independent_streamed_hashes=True,producer=c.read(Path(__file__).resolve().relative_to(ROOT).as_posix()))
    with (OUT/'preparation.json.gz').open('xb') as output:
        output.write(gzip.compress((json.dumps(result,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
    print('Portable chunks prepared:',result['objects'],'objects;',result['parts'],'parts;',result['logical_bytes'],'exact bytes')


if __name__=='__main__':main()
