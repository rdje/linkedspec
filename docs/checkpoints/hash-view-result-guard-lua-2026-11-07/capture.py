"""One sequential installed-host Lua phase with declared inputs before SDK use."""
import gzip,hashlib,json,os,subprocess,sys,tarfile
from pathlib import Path
ROOT=Path.cwd().resolve();BASE=Path(__file__).resolve().parent.relative_to(ROOT)
phase,=sys.argv[1:];assert phase in {'intake','before','after','direct'}
OUT=BASE/phase;OUT.mkdir();FIXTURE=Path('tests/fixtures/hash_view_result_guard_lua_cases.json')
paths=[Path(p) for p in subprocess.check_output(['git','ls-files','lua'],text=True).splitlines()]
paths += [BASE/p for p in ('prepare.py','capture.py','observer.lua','freeze_profiles.py')]
paths += [Path(p) for p in ('specs/user_function_definition.spec','tests/fixtures/hash_view_result_guard_cases.json','tests/fixtures/hash_view_result_guard_rust_profiles.json','tests/fixtures/hash_view_receiver_policy_perl_cases.json','tests/fixtures/value_copy_values.spec','tests/fixtures/value_copy_values.json','lua/test/hash_view_result_guard_composition_test.lua')]
paths += [Path('tools')/p for p in ('run_lua_project_data.sh','build_lua_native.sh','project_data_env.sh','project_data_run.sh','run_python_project_data.sh')]
paths.append(FIXTURE);profile=Path('tests/fixtures/hash_view_result_guard_lua_profiles.json')
if profile.exists():paths.append(profile)
if phase=='intake':(OUT/'cases.json').write_bytes(FIXTURE.read_bytes());paths.append(OUT/'cases.json')
records={}
with tarfile.open(OUT/'inputs-before-first-run.tar.gz','x:gz') as archive:
 for p in sorted(set(paths)):
  assert not p.is_absolute() and '..' not in p.parts and p.is_file() and not p.is_symlink() and p.stat().st_dev==ROOT.stat().st_dev
  b=p.read_bytes();records[str(p)]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),mode=p.stat().st_mode & 0o777);archive.add(p,arcname=p,recursive=False)
with tarfile.open(OUT/'inputs-before-first-run.tar.gz') as archive:assert {m.name:hashlib.sha256(archive.extractfile(m).read()).hexdigest() for m in archive if m.isfile()}=={p:r['sha256'] for p,r in records.items()}
(OUT/'input-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n');(OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
for host in ('puc','luajit'):
 target=OUT/host;target.mkdir()
 for name in ('emitted','parsed'):(target/name).mkdir()
 if phase=='intake':args=[str(BASE/'observer.lua'),str(OUT/'cases.json'),str(target)]
 else:
  tests=['lua/test/hash_view_result_guard_composition_test.lua']
  if phase=='direct':tests += ['lua/test/constructor_result_composition_test.lua','lua/test/value_copy_test.lua','lua/test/receiver_copy_arity_test.lua']
  args=['-e','; '.join('dofile('+json.dumps(p)+')' for p in tests)]
 env=dict(os.environ,LINKEDSPEC_HASH_VIEW_CAPTURE=str(target))
 for tag,arguments in [('version',['-v']),('normal',args)]:
  command=['bash','tools/run_lua_project_data.sh',host,*arguments]
  (target/(tag+'-command.json')).write_text(json.dumps(dict(argv=command,environment=dict(LINKEDSPEC_HASH_VIEW_CAPTURE=str(target))),indent=2)+'\n')
  with (target/(tag+'-stdout.log')).open('wb') as stdout,(target/(tag+'-stderr.log')).open('wb') as stderr:r=subprocess.run(command,cwd=ROOT,env=env,stdout=stdout,stderr=stderr)
  (target/(tag+'-exit.txt')).write_text(str(r.returncode)+'\n')
  for channel in ('stdout','stderr'):
   p=target/(tag+'-'+channel+'.log');b=p.read_bytes();q=Path(str(p)+'.gz');q.write_bytes(gzip.compress(b,mtime=0));assert gzip.decompress(q.read_bytes())==p.read_bytes();p.unlink()
  print(phase,host,tag,'exit'+str(r.returncode),flush=True)
  assert r.returncode in ((0,1) if tag=='normal' and phase=='before' else (0,)), 'inspect retained channels before a separately owned retry'
 files=sorted((target/'emitted').glob('*.lua'))+sorted((target/'parsed').glob('*.json'));assert len(files)==2*len(json.loads(FIXTURE.read_bytes()));artifacts={}
 with tarfile.open(target/'actual-emitted-parsed.tar.gz','x:gz') as archive:
  for p in files:
   b=p.read_bytes();artifacts[str(p)]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),mode=p.stat().st_mode & 0o777);archive.add(p,arcname=p,recursive=False)
 with tarfile.open(target/'actual-emitted-parsed.tar.gz') as archive:
  assert archive.getnames()==[str(p) for p in files]
  for p in files:assert archive.extractfile(str(p)).read()==p.read_bytes()
 (target/'artifact-identities.json').write_text(json.dumps(artifacts,indent=2,sort_keys=True)+'\n')
 for p in files:p.unlink()
 (target/'emitted').rmdir();(target/'parsed').rmdir()
for p,r in records.items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==r['sha256'] and Path(p).stat().st_mode & 0o777==r['mode']
(OUT/'complete.txt').write_text('Both installed host epochs complete; declared sources unchanged.\n');print(phase+': actual declared inputs/artifacts/full compressed channels retained for both hosts')
