"""Finite acquisition I/O: repository-relative inputs, gzip-first complete channels."""
import gzip,hashlib,json,subprocess,tarfile
from pathlib import Path
ROOT=Path.cwd().resolve()
BASE=Path('docs/checkpoints/hash-value-result-guard-julia-2026-11-07')
OWNER=Path('julia/src/runtime/Interpreter.jl')
NORMAL=Path('julia/test/hash_value_result_guard_composition_test.jl')
FIXTURE=Path('tests/fixtures/hash_value_result_guard_julia_cases.json')
PROFILE=Path('tests/fixtures/hash_value_result_guard_julia_profiles.json')
GRAMMAR=Path('specs/user_function_definition.spec')
def digest(body):return hashlib.sha256(body).hexdigest()
def freeze(out,paths,stem='input',name='inputs-before-first-run.tar.gz'):
    records={}
    with tarfile.open(out/name,'w:gz') as archive:
        for p in sorted(set(paths)):
            assert not p.is_absolute() and '..' not in p.parts and p.is_file() and not p.is_symlink() and p.stat().st_dev==ROOT.stat().st_dev,p
            b=p.read_bytes();records[str(p)]=dict(bytes=len(b),sha256=digest(b),mode=p.stat().st_mode&0o777)
            archive.add(p,arcname=p,recursive=False)
    with tarfile.open(out/name) as archive:
        assert set(archive.getnames())==set(records)
        for member in archive:
            r=records[member.name];b=archive.extractfile(member).read()
            assert len(b)==r['bytes'] and digest(b)==r['sha256'] and member.mode&0o777==r['mode']
    (out/(stem+'-identities.json')).write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
    return records

def verify(records):
    for p,r in records.items():
        q=Path(p);assert q.is_file() and not q.is_symlink() and digest(q.read_bytes())==r['sha256'] and q.stat().st_mode&0o777==r['mode'],p

def execute(out,tag,command,env):
    (out/(tag+'-command.json')).write_text(json.dumps(dict(argv=command,cwd='.',environment={k:env[k] for k in ('JULIA_NUM_THREADS','OPENBLAS_NUM_THREADS','JULIA_PKG_PRECOMPILE_AUTO','LINKEDSPEC_HASH_VALUE_CAPTURE') if k in env}),indent=2)+'\n')
    result=subprocess.run(command,cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for channel in ('stdout','stderr'):(out/(tag+'-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(result,channel),mtime=0))
    (out/(tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
    return result

def artifacts(out):
    files=sorted((out/'emitted').glob('*.jl'))+sorted((out/'parsed').glob('*.json'))
    assert len(files)==178
    records=freeze(out,files,'artifact','actual-emitted-parsed.tar.gz')
    verify(records)
    for p in files:p.unlink()
    (out/'emitted').rmdir();(out/'parsed').rmdir()

def frames(body,tag='HASH_VALUE_JULIA_NORMAL'):
    rows={}
    for line in body.decode().splitlines():
        if line.startswith(tag+' '):
            _,key,value=line.split(' ',2);assert key not in rows;rows[key]=json.loads(value)
    assert len(rows)==89
    return rows
