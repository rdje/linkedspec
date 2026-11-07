"""Repository-local finite Lua acquisition, actual native inputs, gzip-first channels."""
import gzip,hashlib,json,os,subprocess,tarfile
from pathlib import Path
ROOT=Path.cwd().resolve()
BASE=Path('docs/checkpoints/hash-value-result-guard-lua-2026-11-07')
OWNER=Path('lua/src/linkedspec/interpreter.lua')
NORMAL=Path('lua/test/hash_value_result_guard_composition_test.lua')
FIXTURE=Path('tests/fixtures/hash_value_result_guard_lua_cases.json')
PROFILE=Path('tests/fixtures/hash_value_result_guard_lua_profiles.json')
GRAMMAR=Path('specs/user_function_definition.spec')
HOSTS=('puc','luajit')
def digest(body):return hashlib.sha256(body).hexdigest()
def freeze(out,paths,stem='input',name='inputs-before-first-run.tar.gz'):
    rows={}
    with tarfile.open(out/name,'x:gz') as archive:
        for p in sorted(set(paths)):
            assert not p.is_absolute() and '..' not in p.parts and p.is_file() and not p.is_symlink() and p.stat().st_dev==ROOT.stat().st_dev,p
            body=p.read_bytes();rows[str(p)]=dict(bytes=len(body),sha256=digest(body),mode=p.stat().st_mode&0o777)
            archive.add(p,arcname=p,recursive=False)
    with tarfile.open(out/name) as archive:
        assert set(archive.getnames())==set(rows)
        for m in archive:
            r=rows[m.name];b=archive.extractfile(m).read();assert len(b)==r['bytes'] and digest(b)==r['sha256'] and m.mode&0o777==r['mode']
    (out/(stem+'-identities.json')).write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
    return rows

def verify(rows):
    for p,r in rows.items():
        q=Path(p);assert q.is_file() and not q.is_symlink() and digest(q.read_bytes())==r['sha256'] and q.stat().st_mode&0o777==r['mode'],p

def execute(out,tag,command,env):
    keys=('LUA_PATH','LUA_CPATH','LINKEDSPEC_LUA_TEST_RUNTIME','LINKEDSPEC_HASH_VALUE_CAPTURE','LINKEDSPEC_HASH_VALUE_INPUT_ROOT')
    (out/(tag+'-command.json')).write_text(json.dumps(dict(argv=command,cwd='.',environment={k:env[k] for k in keys if k in env}),indent=2)+'\n')
    r=subprocess.run(command,cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for channel in ('stdout','stderr'):(out/(tag+'-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(r,channel),mtime=0))
    (out/(tag+'-exit.txt')).write_text(str(r.returncode)+'\n')
    return r

def build_native(out,host,env):
    native=out/'native'
    result=execute(out,'build',['bash','tools/build_lua_native.sh',host,str(native)],env);assert result.returncode==0
    files=[native/name for name in ('linkedspec_regex_pcre2.so','linkedspec_filesystem_native.so','linkedspec_mcp_system.so')]
    assert set(native.iterdir())==set(files)
    rows=freeze(out,files,'native','native-before-first-run.tar.gz')
    return native,rows

def artifacts(out):
    files=sorted((out/'emitted').glob('*.lua'))+sorted((out/'parsed').glob('*.json'));assert len(files)==178
    rows=freeze(out,files,'artifact','actual-emitted-parsed.tar.gz');verify(rows)
    for p in files:p.unlink()
    (out/'emitted').rmdir();(out/'parsed').rmdir()

def frames(body,tag='HASH_VALUE_LUA_NORMAL'):
    rows={}
    for line in body.decode().splitlines():
        if line.startswith(tag+' '):
            _,key,value=line.split(' ',2);assert key not in rows;rows[key]=json.loads(value)
    assert len(rows)==89
    return rows
