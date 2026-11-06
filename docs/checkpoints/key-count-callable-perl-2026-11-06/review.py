"""Readonly recovery of finite authored callable CountKeys epochs; no latest-code claim."""
import copy,gzip,hashlib,json,re,subprocess,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path.cwd();BASE=Path(__file__).parent.relative_to(ROOT)
OWNER='perl/LinkedSpec/ActionIR/MethodLowering.pm'
ACTIVATION='e0053a827a6cc7b4f65ec60d5f1cd5062acda162'
FIXTURE='tests/fixtures/key_count_callable_result_cases.json'
NORMAL='t/key_count_callable_result_guard_composition.t'
PROFILES='tests/fixtures/key_count_callable_perl_profiles.json'
def digest(b):return hashlib.sha256(b).hexdigest()
def canonical(x):return json.dumps(x,sort_keys=True,separators=(',',':'))
def raw(path):return gzip.decompress(Path(str(path)+'.gz').read_bytes())
def inputs(phase,additional=False):
 out=BASE/phase
 name='additional-input-identities.json' if additional else 'input-identities.json'
 capsule='additional-inputs-before-first-run.tar.gz' if additional else 'inputs-before-first-get.tar.gz'
 records=json.loads((out/name).read_text());bodies={}
 with tarfile.open(out/capsule) as archive:
  for m in archive:
   p=PurePosixPath(m.name)
   assert m.isfile() and not p.is_absolute() and '..' not in p.parts and m.name not in bodies
   b=archive.extractfile(m).read();v=records[m.name]
   assert digest(b)==v['sha256'] and len(b)==v['bytes'] and m.mode==v['mode']
   bodies[m.name]=b
 assert bodies.keys()==records.keys()
 return bodies

def tagged(body,tag):
 rows={}
 for line in body.decode().splitlines():
  m=re.match(r'^\s*(?:#\s*)?'+re.escape(tag)+r' (\S+) (.*)$',line)
  if m:
   assert m[1] not in rows,'duplicate frame';rows[m[1]]=json.loads(m[2])
 return rows

def target(case,row,profiles):
 if any(row.get(k) for k in ['descriptor_error','build_error','emission_error','load_error']):return False
 if row['native_callable']!=1 or row['loaded']!=1 or row['warnings']!=[]:return False
 if row['native_cursor']!=0 or row['fresh_cursor']!=0:return False
 profile=profiles.get(case['id']) if case.get('profile_only') or case.get('expected_error') else None
 for route in ['native','fresh']:
  expected=profile[route] if profile else case['expected']
  error=profile[route+'_error'] if profile else None
  if canonical(row[route])!=canonical(expected) or row[route+'_error']!=error:return False
 meta=profile['metadata'] if profile else dict(language_agnostic_action_ir_ready=1,canonical_action_ir_fallback_count=0,raw_perl_dependency_count=0,unresolved_helper_count=0,unresolved_helpers=[])
 return row['metadata']==meta

def apply_patch(before,patch):
 lines=patch.decode().splitlines(keepends=True)
 assert lines[0]==f'diff --git a/{OWNER} b/{OWNER}\n'
 assert re.fullmatch(r'index [0-9a-f]{40}\.\.[0-9a-f]{40} 100644\n',lines[1])
 assert lines[2:4]==[f'--- a/{OWNER}\n',f'+++ b/{OWNER}\n']
 original=before.decode().splitlines(keepends=True);result=[];cursor=0;i=4
 while i<len(lines):
  m=re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@',lines[i]);assert m
  start=int(m[1])-1;assert cursor<=start;result+=original[cursor:start];cursor=start
  old=new=0;i+=1
  while i<len(lines) and not lines[i].startswith('@@ '):
   line=lines[i];i+=1;assert line[0] in ' +-'
   if line[0] in ' -':assert original[cursor]==line[1:];cursor+=1;old+=1
   if line[0] in ' +':result.append(line[1:]);new+=1
  assert old==int(m[2] or 1) and new==int(m[4] or 1)
 return ''.join(result+original[cursor:]).encode()

def check_modules(phase,rows,frames,cases):
 assert list(rows)==list(frames)==[c['id'] for c in cases]
 for case in cases:
  i=case['id'];r=rows[i];f=frames[i];assert f['source']==case['source']
  for name,suffix in [('module','pm'),('handler','handler.pl')]:
   b=gzip.decompress((BASE/phase/'modules'/(i+'.'+suffix+'.gz')).read_bytes())
   key=name+'_input';assert r[key]['path']==str(BASE/phase/'modules'/(i+'.'+suffix+'.gz'))
   assert digest(b)==r[key]['sha256'] and len(b)==r[key]['bytes']
   assert b.decode()==f['emitted' if name=='module' else 'handler']

def semantic(row):return {k:v for k,v in row.items() if k not in ['module_input','handler_input']}

def validate():
 records=json.loads((BASE/'raw-identities-qualified.json').read_text())
 original_records=json.loads(gzip.decompress((BASE/'raw-identities.json.gz').read_bytes()))
 assert len(original_records)==len(records)
 for original_name,original_value in original_records.items():
  suffix=str(BASE)+'/'
  assert original_name.count(suffix)==1
  name=suffix+original_name.split(suffix,1)[1]
  expected={**original_value,'capsule':name+'.gz'}
  assert records[name]==expected and original_value['capsule']==original_name+'.gz'
 for name,v in records.items():
  p=PurePosixPath(name);assert not p.is_absolute() and '..' not in p.parts
  capsule=Path(v['capsule']).read_bytes();body=raw(Path(name))
  assert digest(capsule)==v['capsule_sha256'] and digest(body)==v['sha256'] and len(body)==v['bytes']
 epochs={p:inputs(p) for p in ['intake','intake-qualified','terminal-profile','before','after']}
 original=epochs['before'][OWNER]
 assert original==subprocess.check_output(['git','show',ACTIVATION+':'+OWNER])
 assert all(e[OWNER]==original for p,e in epochs.items() if p!='after')
 assert apply_patch(original,(BASE/'producer-change.patch').read_bytes())==epochs['after'][OWNER]
 for p in epochs['before']:
  if p.startswith(('perl/','specs/')) and p!=OWNER:assert epochs['after'][p]==epochs['before'][p]
 assert epochs['before'][FIXTURE]==epochs['after'][FIXTURE]
 assert epochs['before'][NORMAL]==epochs['after'][NORMAL]
 assert epochs['before'][PROFILES]==epochs['after'][PROFILES]
 cases=json.loads(epochs['after'][FIXTURE]);profiles=json.loads(epochs['after'][PROFILES])
 assert len(cases)==16
 before=tagged(raw(BASE/'before/stdout-1.log'),'CALLABLE_KEY_COUNT_PERL')
 after=tagged(raw(BASE/'after/stdout-1.log'),'CALLABLE_KEY_COUNT_PERL')
 failing={c['id'] for c in cases if not target(c,before[c['id']],profiles)}
 assert failing=={'compatible_counts','wrong_array','wrong_hash','later_with','copy_guard','logical_guard','count_consumers','source_once_snapshot','boolean_receiver_profile'}
 assert all(target(c,after[c['id']],profiles) for c in cases)
 healthy=set(before)-failing
 assert all(semantic(before[i])==semantic(after[i]) for i in healthy),'healthy complete semantic profiles unchanged'
 for phase,rows,exits in [('before',before,[1,0]),('after',after,[0,0])]:
  assert json.loads((BASE/phase/'exits.json').read_text())==exits
  public=raw(BASE/phase/'stdout-1.log');assert raw(BASE/phase/'stderr-1.log')==b''
  check_modules(phase,rows,tagged(public,'CALLABLE_KEY_COUNT_INPUT'),cases)
  normal=tagged(raw(BASE/phase/'stderr-0.log'),'CALLABLE_KEY_COUNT_NORMAL_ACTUAL')
  assert list(normal)==list(rows) and all(semantic(rows[i])==normal[i] for i in rows)
  normal_inputs=tagged(raw(BASE/phase/'stdout-0.log'),'CALLABLE_KEY_COUNT_NORMAL_INPUT')
  assert list(normal_inputs)==[str(i) for i in range(1,17)]
  for i,c in enumerate(cases,1):
   f=normal_inputs[str(i)];b=gzip.decompress((BASE/phase/'normal-modules'/f'module-{i}.pm.gz').read_bytes())
   assert f['source']==c['source'] and b.decode()==f['emitted']
  assert (b'Result: FAIL' if phase=='before' else b'Result: PASS') in raw(BASE/phase/'stdout-0.log')
 for phase in ['intake','intake-qualified','terminal-profile']:
  assert (BASE/phase/'exit.txt').read_text()=='0\n' and raw(BASE/phase/'stderr.log')==b''
  c=json.loads(epochs[phase][FIXTURE] if phase!='terminal-profile' else epochs[phase][str(BASE/'terminal-profile-cases.json')])
  body=raw(BASE/phase/'stdout.log');rows=tagged(body,'CALLABLE_KEY_COUNT_PERL');frames=tagged(body,'CALLABLE_KEY_COUNT_INPUT')
  assert list(rows)==[x['id'] for x in c]
  if phase=='intake':
   assert len(c)==14 and rows['function_controls']['emission_error'] and not rows['function_controls']['native_callable']
   check_modules(phase,{i:r for i,r in rows.items() if i!='function_controls'},{i:f for i,f in frames.items() if i!='function_controls'},[x for x in c if x['id']!='function_controls'])
   assert all(semantic(rows[i])==semantic(before[i]) for i in rows if i!='function_controls')
  else:
   check_modules(phase,rows,frames,c)
   assert all(semantic(rows[i])==semantic(before[i]) for i in rows)
  if phase=='intake-qualified':
   assert len(c)==15
   assert all(profiles[i]=={k:rows[i][k] for k in profiles[i]} for i in profiles)
  if phase=='terminal-profile':
   r=rows['boolean_terminal_profile'];assert canonical(r['native'])==canonical(r['fresh'])=='0' and r['metadata']['language_agnostic_action_ir_ready']==1
 extra=inputs('final',additional=True)
 assert len(extra)==4 and (BASE/'final/source-input-reference.txt').read_text()==str(BASE/'after/inputs-before-first-get.tar.gz')+'\n'
 for name in ['direct','owner-syntax']:
  assert (BASE/'final'/(name+'-exit.txt')).read_text()=='0\n'
 assert b'Result: PASS' in raw(BASE/'final/direct-stdout.log')
 # Mutate independent observations, actual producer bytes and artifacts: each distinguishing oracle must reject.
 controls=[]
 def reject(name,operation):
  try:operation()
  except (AssertionError,KeyError):controls.append(name)
  else:raise AssertionError('ineffective corruption '+name)
 def corrupt_target(i,key,value):
  r=copy.deepcopy(after[i]);r[key]=value;assert target(next(c for c in cases if c['id']==i),r,profiles)
 reject('compatible numeric regression',lambda:corrupt_target('compatible_counts','native',before['compatible_counts']['native']))
 reject('skipped source or later effects',lambda:corrupt_target('later_with','fresh',['ran','W']))
 reject('needed source error masked',lambda:corrupt_target('needed_argument_error','native_error',None))
 reject('Boolean diagnostic wrongly retained',lambda:corrupt_target('boolean_receiver_profile','metadata',before['boolean_receiver_profile']['metadata']))
 reject('producer input drift',lambda:assert_equal(digest(original+b'\n'),digest(original)))
 reject('actual module drift',lambda:assert_equal(digest(frames['boolean_terminal_profile']['emitted'].encode()+b'\n'),digest(frames['boolean_terminal_profile']['emitted'].encode())))
 return dict(authored_groups=16,before_pass=7,before_red=9,after_pass=16,healthy_preserved=7,recovery_corruptions=controls,scope='historical exact epochs; current-code freshness uses maintained normal, peers/full admission separate')

def assert_equal(a,b):assert a==b
if __name__=='__main__':print(json.dumps(validate(),indent=2,sort_keys=True))
