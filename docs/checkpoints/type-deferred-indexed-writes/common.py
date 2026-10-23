"""Source-bound observations for the deferred indexed-write repair."""
import base64,gzip,hashlib,json,pathlib,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3]
BASE='24e9c72a31b7eb31ce94b09beab9655ae85378cb'
PREFIX='docs/checkpoints/type-deferred-indexed-writes/'
OWNER='TYPE-REFERENCE-BOOK.1.2.12'
SOURCES=['perl/LinkedSpec/CodeblockRuntime.pm','perl/LinkedSpec/ActionIR/MethodLowering.pm','perl/LinkedSpec/RuleIR/EmitContext.pm']
encode=lambda raw:base64.b64encode(raw).decode()
decode=base64.b64decode
sha=lambda raw:hashlib.sha256(raw).hexdigest()
def read(path):
 p=ROOT/path
 assert not pathlib.Path(path).is_absolute() and '..' not in pathlib.Path(path).parts
 assert p.is_file() and not p.is_symlink(),path
 raw=p.read_bytes()
 return dict(sha256=sha(raw),mode=p.stat().st_mode&0o7777,base64=encode(raw))
def identity(path):return {k:v for k,v in read(path).items() if k!='base64'}
def load(name):
 raw=(ROOT/PREFIX/name).read_bytes()
 return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)
def save(name,value):
 raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
 if name.endswith('.gz'):raw=gzip.compress(raw,mtime=0)
 with (ROOT/PREFIX/name).open('xb') as f:f.write(raw)
def run(command,**kwargs):
 p=subprocess.run(command,cwd=ROOT,capture_output=True,**kwargs)
 return dict(command=command,returncode=p.returncode,stdout_base64=encode(p.stdout),stderr_base64=encode(p.stderr))
def paths():
 result=set()
 for row in subprocess.check_output(['git','ls-files','--stage','-z'],cwd=ROOT).split(b'\0'):
  if row:
   meta,path=row.split(b'\t',1)
   if meta.split()[0] in (b'100644',b'100755'):result.add(path.decode())
 result.update(p for p in subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z'],cwd=ROOT).decode().split('\0') if p and (ROOT/p).is_file() and not (ROOT/p).is_symlink())
 return sorted(result)
def epoch():
 changed=set(subprocess.check_output(['git','diff','--name-only','-z',BASE],cwd=ROOT).decode().split('\0'))
 tracked=set(subprocess.check_output(['git','ls-files','-z'],cwd=ROOT).decode().split('\0'))
 return dict(base=BASE,inputs={p:identity(p) for p in paths()},overrides={p:read(p) for p in paths() if (p in changed or p not in tracked) and not p.endswith('.gz')})
def observe(plan):return run(['bash','tools/project_data_run.sh','perl','-Iperl',PREFIX+'probe.pl'],input=json.dumps(plan).encode())
def failures(run,plan):
 assert run['returncode']==0 and not decode(run['stderr_base64']),run
 rows=json.loads(decode(run['stdout_base64']))['rows']
 assert [r['id'] for r in rows]==[r['id'] for r in plan['cases']]
 failed={}
 for row,case in zip(rows,plan['cases']):
  errors=[]
  for route in ('descriptor','native','generated'):
   value=row[route]
   if 'error' not in case and (not value['completed'] or value['warnings'] or value['stdout'] or value['exception']):errors.append(route+'/diagnostic')
   if route=='descriptor':
    meta=value['value'] or {}
    if meta.get('canonical_action_ir_fallback_count')!=0 or meta.get('raw_perl_dependency_count')!=0:errors.append('descriptor/fallback')
   elif 'error' in case:
    detail=value['runtime_detail'] or value['exception'] or {}
    fields=detail.get('fields',{})
    if fields.get('code')=='generated_execution_failed':fields=fields.get('detail',{})
    if fields.get('code')!=case['error']:errors.append(route+'/typed-error')
   elif value['last_error'] or json.dumps(value['value'],sort_keys=True)!=json.dumps(case['expected'],sort_keys=True):errors.append(route+'/value')
  if errors:failed[case['id']]=errors
 return failed
