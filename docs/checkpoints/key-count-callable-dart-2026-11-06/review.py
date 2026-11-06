"""Readonly Dart callable preservation; partial original and qualified direct grammar inputs."""
import copy,gzip,hashlib,io,json,re,subprocess,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/key-count-callable-dart-2026-11-06')
ACTIVATION='3a8e8812df01538112b9d714a9c12e5e82adc175'
PROBE='dart/tool/probe_key_count_callable_results.dart'
NORMAL='dart/test/key_count_callable_result_guard_composition_test.dart'
GRAMMAR='specs/user_function_definition.spec'
FIXTURE='tests/fixtures/key_count_callable_result_cases.json'
PROFILE='tests/fixtures/key_count_callable_dart_profiles.json'
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

def grammar_frames(body,prefix,source):
 rows=[json.loads(line.split(' ',1)[1]) for line in body.decode().splitlines() if line.startswith(prefix+' ')]
 assert rows==[{'path':GRAMMAR,'source':source.decode()}],'actual grammar string before SDK use'

def apply_patch(before,patch,path):
 lines=patch.decode().splitlines(keepends=True);assert lines[:2]==['--- '+path+'\n','+++ '+path+'\n']
 original=before.decode().splitlines(keepends=True);result=[];cursor=0;i=2
 while i<len(lines):
  m=re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@',lines[i]);assert m
  start=int(m[1])-1;assert cursor<=start;result+=original[cursor:start];cursor=start;old=new=0;i+=1
  while i<len(lines) and not lines[i].startswith('@@ '):
   line=lines[i];i+=1;assert line[0] in ' +-'
   if line[0] in ' -':assert original[cursor]==line[1:];cursor+=1;old+=1
   if line[0] in ' +':result.append(line[1:]);new+=1
  assert old==int(m[2] or 1) and new==int(m[4] or 1)
 return ''.join(result+original[cursor:]).encode()

def target(case,value,route,profiles):
 profile=profiles.get(case['id'])
 if profile:return profile['source']==case['source'] and same(value,profile[route])
 return same(value,{'value':case['expected']})

def validate(native,fresh,cases,profiles):
 ids=[c['id'] for c in cases];assert list(native)==list(fresh)==ids,'complete ordered actual source population'
 for c in cases:
  i=c['id'];assert set(native[i])=={'native','restored','plan'}
  for route,value in {**native[i],'fresh':fresh[i]}.items():assert target(c,value,route,profiles),'independent Dart targets/profiles'
  if c.get('expected_error'):
   assert all(c['expected_error'] in v['error'] for v in [*native[i].values(),fresh[i]])
   assert native[i]['native']==native[i]['restored'] and native[i]['plan']==fresh[i]
   assert native[i]['native']['class']=='RuntimeInterpreterException' and fresh[i]['class']=='GeneratedSourceException'
   assert fresh[i]['error']=='Generated Dart parser execution failed: '+native[i]['native']['error']
   assert native[i]['native']['diagnostic']['stage']=='runtime_execution'
  else:assert all(same(native[i]['native'],v) for v in [*native[i].values(),fresh[i]])
 assert native['boolean_terminal_profile']['native']==native['boolean_receiver_profile']['native']=={'value':None}
 assert same(native['function_controls']['native'],{'value':[False,1,'X']})

def main():
 phases=['intake','normal','direct','intake-qualified','normal-qualified','direct-qualified']
 data={p:custody(p) for p in phases};initial=data['intake']['root'];qualified=data['intake-qualified']['root'];normal=data['normal-qualified']['root'];direct=data['direct-qualified']['root']
 assert normal==direct,'qualified normal/direct actual declared inputs unchanged'
 assert all(GRAMMAR not in data[p]['root'] for p in ['intake','normal','direct']),'original direct-grammar custody remains partial'
 assert all(GRAMMAR in data[p]['root'] for p in phases if p.endswith('qualified'))
 grammar=qualified[GRAMMAR];assert grammar==subprocess.check_output(['git','show',ACTIVATION+':'+GRAMMAR])
 git={}
 with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git','archive','--format=tar',ACTIVATION,'dart']))) as archive:
  for m in archive:
   if m.isfile():git[m.name]=archive.extractfile(m).read()
 for p,source in initial.items():
  if p.startswith('dart/') and p!=PROBE and p in git:
   assert source==git[p],'actual historical own Dart input'
   assert all(data[phase]['root'][p]==source for phase in phases),'no Dart production prerequisite edit'
 assert initial[FIXTURE]==qualified[FIXTURE]==normal[FIXTURE]==subprocess.check_output(['git','show',ACTIVATION+':'+FIXTURE])
 assert apply_patch(data['normal']['root'][PROBE],gzip.decompress((ROOT/BASE/'probe-phase-guard.patch.gz').read_bytes()),PROBE)==data['direct']['root'][PROBE]
 assert apply_patch(data['direct']['root'][PROBE],gzip.decompress((ROOT/BASE/'probe-explicit-grammar.patch.gz').read_bytes()),PROBE)==qualified[PROBE]==normal[PROBE]
 assert apply_patch(data['normal']['root'][NORMAL],gzip.decompress((ROOT/BASE/'normal-explicit-grammar.patch.gz').read_bytes()),NORMAL)==normal[NORMAL]
 assert b'parserSpecSource: functionGrammarSource' in qualified[PROBE] and b'parserSpecSource: functionGrammarSource' in normal[NORMAL]
 assert b'phase.path.isEmpty' in qualified[PROBE]
 profiles=json.loads(normal[PROFILE]);cases=json.loads(initial[FIXTURE]);assert len(cases)==16
 assert set(profiles)=={'boolean_receiver_profile','boolean_terminal_profile','malformed_receiver_profile','needed_argument_error'}
 assert all(data[p]['root'][PROFILE]==normal[PROFILE] for p in phases if p!='intake')
 observations={};artifacts={};parsed={}
 for phase in phases:
  assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
 for phase in ['intake','intake-qualified']:
  native=frames(phase,'native','CALLABLE_KEY_COUNT_DART');fresh=frames(phase,'fresh','CALLABLE_KEY_COUNT_DART_FRESH')
  validate(native,fresh,cases,profiles);observations[phase]=(native,fresh)
  c=data[phase];inputs=frames(phase,'native','CALLABLE_KEY_COUNT_DART_INPUT');assert list(inputs)==[c['id'] for c in cases]
  assert json.loads(c['root'][str(BASE/phase/'cases.json')])==cases
  artifacts[phase]={};parsed[phase]={}
  for index,row in enumerate(cases):
   p=str(BASE/phase/'fresh/inputs'/f'case_{index}.json');body=c['fresh'][p]
   assert same(json.loads(body),inputs[row['id']]),'actual parsed input before SDK/module execution'
   parsed[phase][row['id']]=body
   p=str(BASE/phase/'fresh/lib'/f'case_{index}.dart');artifacts[phase][row['id']]=c['fresh'][p]
  assert len(artifacts[phase])==len(parsed[phase])==16
  for tag in ['root-analysis','fresh-analysis']:
   assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
  if phase.endswith('qualified'):grammar_frames(raw(BASE/phase/'native-stdout.log'),'CALLABLE_KEY_COUNT_DART_GRAMMAR',grammar)
 assert same(observations['intake'],observations['intake-qualified']),'all original semantic observations retained exactly'
 assert artifacts['intake']==artifacts['intake-qualified'] and parsed['intake']==parsed['intake-qualified'],'actual16 emitted and parsed bodies unchanged'
 native,fresh=observations['intake-qualified']
 for phase in ['normal','normal-qualified']:
  rows=tagged(raw(BASE/phase/'normal-stdout.log'),'CALLABLE_KEY_COUNT_DART_NORMAL')
  assert list(rows)==list(native) and same(rows,native),'actual normal/intake identity'
  assert re.findall(r'\+(\d+): All tests passed!',raw(BASE/phase/'normal-stdout.log').decode())==['16']
  assert (ROOT/BASE/phase/'normal-exit.txt').read_text()=='0\n' and (ROOT/BASE/phase/'root-analysis-exit.txt').read_text()=='0\n'
  if phase.endswith('qualified'):grammar_frames(raw(BASE/phase/'normal-stdout.log'),'CALLABLE_KEY_COUNT_DART_NORMAL_GRAMMAR',grammar)
 for phase in ['direct','direct-qualified']:
  assert (ROOT/BASE/phase/'normal-exit.txt').read_text()=='0\n'
  assert re.findall(r'\+(\d+): All tests passed!',raw(BASE/phase/'normal-stdout.log').decode())==['29']
 format_inputs=recover(BASE/'format/inputs-before-first-run.tar.gz',json.loads((ROOT/BASE/'format/input-identities.json').read_text()))
 for p in [PROBE,NORMAL,GRAMMAR]:assert format_inputs[p]==normal[p]
 assert (ROOT/BASE/'format/source-reference.txt').read_text()==str(BASE/'direct-qualified/root-before-first-run.tar.gz')+'\n'
 for tag in ['format','probe-analysis']:assert (ROOT/BASE/'format'/(tag+'-exit.txt')).read_text()=='0\n'
 assert (ROOT/BASE/'format/empty-phase-exit.txt').read_text()!='0\n'
 error=raw(BASE/'format/empty-phase-stderr.log').decode()
 assert 'phase must stay relative to the repository root' in error and 'FileSystemException' not in error and raw(BASE/'format/empty-phase-stdout.log')==b''
 for p,v in json.loads((ROOT/BASE/'raw-identities.json').read_text()).items():
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
 reject('Boolean peer normalization',lambda:mutated('boolean_terminal_profile','native',{'value':0}))
 reject('needed source error masked',lambda:mutated('needed_argument_error','plan',{'value':None}))
 lost=copy.deepcopy(fresh);lost.pop('wrong_array')
 reject('missing fresh member',lambda:validate(native,lost,cases,profiles))
 reject('grammar string drift',lambda:grammar_frames(raw(BASE/'intake-qualified/native-stdout.log'),'CALLABLE_KEY_COUNT_DART_GRAMMAR',grammar+b'\n'))
 reject('actual module drift',lambda:equal(digest(artifacts['intake-qualified']['compatible_counts']+b'\n'),digest(artifacts['intake']['compatible_counts'])))
 return dict(qualified_groups=16,compatible_targets=12,independent_profiles=4,routes=['native','restored','plan','fresh'],normal_pass=16,direct_pass=29,runtime_changes=0,original_semantics_preserved=16,actual_module_and_parsed_bodies_unchanged=16,recovery_corruptions=rejected,scope='original epochs remain partial for direct grammar custody; qualified epochs bind actual grammar before SDK use; full native/transitive/historical custody4.2 and peers/admission remain separate')

def equal(a,b):assert a==b
if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))
