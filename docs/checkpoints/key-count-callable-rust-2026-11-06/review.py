"""Readonly finite Rust callable CountKeys preservation and actual-input recovery."""
import copy,gzip,hashlib,io,json,re,subprocess,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/key-count-callable-rust-2026-11-06')
ACTIVATION='fb0cb2ce89004f93d2ae4153e28684422984c760'
FIXTURE='tests/fixtures/key_count_callable_result_cases.json'
PROFILE='tests/fixtures/key_count_callable_rust_profiles.json'
NORMAL='rust/linkedspec-runtime/tests/key_count_callable_result_guard_composition.rs'
def digest(body): return hashlib.sha256(body).hexdigest()


def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool): return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)): return a==b
    if type(a) is not type(b): return False
    if isinstance(a,list): return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict): return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b


def raw(path):
    path=ROOT/path
    return path.read_bytes() if path.exists() else gzip.decompress(Path(str(path)+'.gz').read_bytes())


def recover(path,expected):
    found={}
    with tarfile.open(ROOT/path) as archive:
        for member in archive.getmembers():
            name=PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts
            assert member.name not in found
            body=archive.extractfile(member).read(); item=expected[member.name]
            assert digest(body)==item['sha256'] and len(body)==item['bytes']
            assert member.mode & 0o777 == item['mode']
            found[member.name]=body
    assert found.keys()==expected.keys(), 'declared archive completeness'
    return found


def custody(phase):
    records=json.loads((ROOT/BASE/phase/'custody.json').read_text())
    return {Path(r['archive']).name.split('-before-first-run')[0]: recover(Path(r['archive']),r['files']) for r in records}


def frames(phase,tag,prefix):
    assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
    result={}
    for line in raw(BASE/phase/(tag+'-stdout.log')).decode().splitlines():
        if line.startswith(prefix+' '):
            _,name,body=line.split(' ',2)
            assert name not in result
            result[name]=json.loads(body)
    return result



def tagged(body,prefix):
 result={}
 for line in body.decode().splitlines():
  if line.startswith(prefix+' '):
   _,i,value=line.split(' ',2);assert i not in result;result[i]=json.loads(value)
 return result

def target(case,value,route,profiles):
 profile=profiles.get(case['id'])
 if profile:
  return profile['source']==case['source'] and same(value,profile[route])
 return same(value,{'value':case['expected']})

def validate(native,fresh,cases,profiles):
 ids=[c['id'] for c in cases]
 assert list(native)==list(fresh)==ids,'complete actual ordered source population'
 for c in cases:
  i=c['id'];assert set(native[i])=={'native','restored','plan'}
  for route,value in {**native[i],'fresh':fresh[i]}.items():assert target(c,value,route,profiles),'independent target/profiles'
  if c.get('expected_error'):
   assert all(c['expected_error'] in v['error'] for v in [*native[i].values(),fresh[i]])
   assert native[i]['native']==native[i]['restored']
   assert native[i]['plan']==fresh[i]
   assert fresh[i]['error']=='Generated Rust parser execution failed: '+native[i]['native']['error']
  else:assert all(same(native[i]['native'],v) for v in [*native[i].values(),fresh[i]])
 assert same(native['boolean_terminal_profile']['native'],{'value':0})
 assert same(native['boolean_receiver_profile']['native'],{'value':1})

def main():
 recovered={p:custody(p) for p in ['intake','normal','direct']}
 initial=recovered['intake']['root'];normal=recovered['normal']['root'];direct=recovered['direct']['root']
 assert normal==direct,'normal/direct declared source inputs unchanged'
 git={}
 with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git','archive','--format=tar',ACTIVATION,'rust']))) as archive:
  for m in archive:
   if m.isfile():git[m.name]=archive.extractfile(m).read()
 for p,body in initial.items():
  if p.startswith('rust/'):
   assert git[p]==body,'actual historical Git Rust input'
   assert normal[p]==body,'no Rust production/test prerequisite changes'
 assert initial[FIXTURE]==normal[FIXTURE]==subprocess.check_output(['git','show',ACTIVATION+':'+FIXTURE])
 for phase in recovered:
  assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
  assert recovered[phase]['root'][str(BASE/'observer.rs')]==initial[str(BASE/'observer.rs')]
 cases=json.loads(initial[FIXTURE]);profiles=json.loads(normal[PROFILE]);assert len(cases)==16
 assert set(profiles)=={'boolean_receiver_profile','boolean_terminal_profile','malformed_receiver_profile','needed_argument_error'}
 native=frames('intake','native','CALLABLE_KEY_COUNT_RUST');fresh=frames('intake','fresh','CALLABLE_KEY_COUNT_RUST_FRESH')
 validate(native,fresh,cases,profiles)
 c=recovered['intake'];assert json.loads(c['native'][str(BASE/'intake/cases.json')])==cases
 assert c['native'][str(BASE/'intake/native/src/main.rs')]==initial[str(BASE/'observer.rs')]
 compiled=frames('intake','native','CALLABLE_KEY_COUNT_RUST_INPUT')
 assert list(compiled)==[c['id'] for c in cases]
 modules={p:b for p,b in c['fresh'].items() if '/src/generated/' in p}
 assert {Path(p).name for p in modules}=={c['id']+'.rs' for c in cases}
 for row in cases:
  i=row['id'];body=c['fresh'][str(BASE/'intake/fresh/inputs'/(i+'.json'))]
  assert body.decode()==compiled[i]['compiled'],'actual serialized pre-execution input'
  assert any(i+'.rs' in c['fresh'][str(BASE/'intake/fresh/src/lib.rs')].decode() for _ in [0])
 normal_rows=tagged(raw(BASE/'normal/normal-stderr.log'),'CALLABLE_KEY_COUNT_RUST_NORMAL')
 assert set(normal_rows)==set(native)
 assert all(same(normal_rows[i],native[i]) for i in native),'actual normal/intake three-route semantic identity'
 tests=re.findall(r'^test (\w+) \.\.\. (ok|FAILED)$',raw(BASE/'normal/normal-stdout.log').decode(),re.M)
 assert len(tests)==16 and {i for i,state in tests if state=='ok'}==set(native)
 assert (ROOT/BASE/'normal/normal-exit.txt').read_text()=='0\n'
 assert (ROOT/BASE/'direct/normal-exit.txt').read_text()=='0\n'
 assert re.findall(r'test result: ok\. (\d+) passed; 0 failed;',raw(BASE/'direct/normal-stdout.log').decode())==['25','4']
 info=json.loads((ROOT/BASE/'format/input.json').read_text());assert info['path']==NORMAL and digest(normal[NORMAL])==info['sha256'] and len(normal[NORMAL])==info['bytes']
 assert (ROOT/BASE/'format/exit.txt').read_text()=='0\n' and raw(BASE/'format/stderr.log')==b''
 sealed=json.loads((ROOT/BASE/'raw-identities.json').read_text())
 for p,v in sealed.items():
  assert not PurePosixPath(p).is_absolute() and '..' not in PurePosixPath(p).parts
  capsule=(ROOT/v['capsule']).read_bytes();body=gzip.decompress(capsule)
  assert digest(capsule)==v['capsule_sha256'] and digest(body)==v['sha256'] and len(body)==v['bytes'] and body==raw(Path(p))
 rejected=[]
 def reject(name,operation):
  try:operation()
  except (AssertionError,KeyError):rejected.append(name)
  else:raise AssertionError('ineffective corruption '+name)
 def mutated(i,route,value):
  n=copy.deepcopy(native);f=copy.deepcopy(fresh)
  if route=='fresh':f[i]=value
  else:n[i][route]=value
  validate(n,f,cases,profiles)
 reject('compatible numeric regression',lambda:mutated('compatible_counts','native',{'value':[1,None,2,'1 KEYS']}))
 reject('later effect leak',lambda:mutated('later_with','fresh',{'value':['ran','W']}))
 reject('needed error masked',lambda:mutated('needed_argument_error','plan',{'value':None}))
 reject('Boolean zero kind drift',lambda:mutated('boolean_terminal_profile','native',{'value':False}))
 lost=copy.deepcopy(fresh);lost.pop('wrong_hash')
 reject('missing fresh route member',lambda:validate(native,lost,cases,profiles))
 reject('producer input drift',lambda:equal(digest(initial['rust/linkedspec-runtime/src/engine.rs']+b'\n'),digest(git['rust/linkedspec-runtime/src/engine.rs'])))
 return dict(authored_groups=16,intake_pass=16,routes=['native','restored','plan','fresh'],normal_pass=16,direct_pass=29,runtime_changes=0,recovery_corruptions=rejected,scope='historical exact inputs; current freshness uses normal; no peer/full-custody/isolation/admission inference')

def equal(a,b):assert a==b
if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))
