"""Explicit one-shot capture after disposal; default historical review is read-only."""
from pathlib import Path
import base64,gzip,hashlib,json,subprocess,sys
R=Path(__file__).resolve().parents[4];P=Path(__file__).parent;W=R/'.linkedspec-data/verification/project-data-cleanup46-3'
assert sys.argv[1:]==['--capture']
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()=='73a054bafa2ddcbc2a18074efbf043a0e1f90405'
assert json.loads((W/'source-review.json').read_text())['quarantine_absent']
sha=lambda b:hashlib.sha256(b).hexdigest()
def split(path,stem):
    parts=[];digest=hashlib.sha256();size=0
    with path.open('rb') as stream:
        while raw:=stream.read(31*1024*1024):
            out=P/(stem+'-'+str(len(parts)+1).zfill(3)+'.part')
            with out.open('xb') as output:output.write(raw)
            assert out.read_bytes()==raw;digest.update(raw);size+=len(raw)
            parts.append({'path':out.relative_to(R).as_posix(),'bytes':len(raw),'sha256':sha(raw)})
    return {'parts':parts,'bytes':size,'sha256':digest.hexdigest()}
large={}
for name,stem in [('old-target-entries.jsonl.gz','entries'),('plan-nodes.jsonl.gz','nodes'),('current-test-executable.gz','current-test')]:large[name]=split(W/name,stem)
db=W/'inode-analysis.sqlite3'
database_identity={'bytes':db.stat().st_size,'sha256':hashlib.file_digest(db.open('rb'),'sha256').hexdigest()}
with db.open('rb') as source,(W/'inode-analysis.sqlite3.gz').open('xb') as target:
    with gzip.GzipFile(fileobj=target,mode='wb',mtime=0) as output:
        while raw:=source.read(1024*1024):output.write(raw)
large['inode-analysis.sqlite3.gz']=split(W/'inode-analysis.sqlite3.gz','inode-analysis')
paths={p for p in W.iterdir() if p.is_file() and p.name not in (*large,'inode-analysis.sqlite3')}
paths.update(p for p in (W/'compiler-probe').rglob('*') if p.is_file())
paths.update(W.parent.glob('*46_3*.py'));paths.update(P.glob('*.py'))
inputs=[]
for p in sorted(paths):
    assert p.is_file() and not p.is_symlink();raw=p.read_bytes()
    inputs.append({'path':p.relative_to(R).as_posix(),'bytes':len(raw),'sha256':sha(raw),'base64':base64.b64encode(raw).decode()})
epoch=json.loads(gzip.decompress((W/'producer-epoch.json.gz').read_bytes()))
for row in epoch['inputs']:assert sha((R/row['path']).read_bytes())==row['sha256'],'instrument epoch changed'
record={'owner':'TYPE-REFERENCE-BOOK.1.2.23.3.46.3','base':epoch['base'],'large':large,'database_identity':database_identity,'inputs':inputs,'limits':'Dated exact old-target metadata, opaque headers/content hashes, actual instruments/controls/quarantine/current Rust6/disposal/full residue observations. Unique-inode logical and allocated metadata are not physical/APFS free-space causality. Disposable original bytes are intentionally not archived and exact old builds are not reproducible from this checkpoint. Current input set is declared first-party source/fixtures/wrappers, not complete transitive dependency/toolchain closure. External OS/toolchain dependencies are read-only. No unsafe recovery, other-repository mutation, exhaustive test suite or cold dependency bootstrap.'}
with (P/'intake.json.gz').open('xb') as output:output.write(gzip.compress(json.dumps(record,sort_keys=True,separators=(',',':')).encode(),mtime=0))
assert (P/'intake.json.gz').stat().st_size<32*1024*1024
print(json.dumps({'inputs':len(inputs),'parts':sum(len(v['parts']) for v in large.values()),'intake_bytes':(P/'intake.json.gz').stat().st_size}),flush=True)
