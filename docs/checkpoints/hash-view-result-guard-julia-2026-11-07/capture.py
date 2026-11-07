"""One finite Julia epoch; declare actual own sources/grammar before SDK use."""
import gzip,hashlib,json,os,subprocess,sys,tarfile
from pathlib import Path
ROOT=Path.cwd().resolve();BASE=Path(__file__).resolve().parent.relative_to(ROOT)
phase,=sys.argv[1:];assert phase in {'intake','before','after','direct'}
OUT=BASE/phase;OUT.mkdir();FIXTURE=Path('tests/fixtures/hash_view_result_guard_julia_cases.json')
paths=[Path(p) for p in subprocess.check_output(['git','ls-files','julia'],text=True).splitlines()]
paths += [BASE/p for p in ('prepare.py','capture.py','observer.jl','freeze_profiles.py')]
paths += [Path(p) for p in ('specs/user_function_definition.spec','tests/fixtures/hash_view_result_guard_cases.json','tests/fixtures/hash_view_result_guard_rust_profiles.json','tests/fixtures/hash_view_receiver_policy_perl_cases.json','tests/fixtures/value_copy_values.spec','tests/fixtures/value_copy_values.json','julia/test/hash_view_result_guard_composition_test.jl')]
paths += [Path('tools')/p for p in ('run_julia_project_data.sh','project_data_env.sh','project_data_run.sh','run_python_project_data.sh')]
paths.append(FIXTURE)
profile=Path('tests/fixtures/hash_view_result_guard_julia_profiles.json')
if profile.exists():paths.append(profile)
if phase=='intake':
 (OUT/'cases.json').write_bytes(FIXTURE.read_bytes());paths.append(OUT/'cases.json')
records={}
with tarfile.open(OUT/'inputs-before-first-run.tar.gz','w:gz') as archive:
 for p in sorted(set(paths)):
  assert not p.is_absolute() and '..' not in p.parts and p.is_file() and not p.is_symlink() and p.stat().st_dev==ROOT.stat().st_dev
  b=p.read_bytes();records[str(p)]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),mode=p.stat().st_mode & 0o777)
  archive.add(p,arcname=p,recursive=False)
with tarfile.open(OUT/'inputs-before-first-run.tar.gz') as archive:
 assert {m.name:hashlib.sha256(archive.extractfile(m).read()).hexdigest() for m in archive if m.isfile()}=={p:r['sha256'] for p,r in records.items()}
(OUT/'input-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
(OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
env=dict(os.environ,JULIA_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',JULIA_PKG_PRECOMPILE_AUTO='0')
if phase=='intake':args=[str(BASE/'observer.jl'),str(OUT/'cases.json'),str(OUT)]
else:
 env['LINKEDSPEC_HASH_VIEW_CAPTURE']=str(OUT)
 tests=['julia/test/hash_view_result_guard_composition_test.jl']
 if phase=='direct':tests += ['julia/test/constructor_result_composition_test.jl','julia/test/value_copy_test.jl','julia/test/receiver_copy_arity_test.jl']
 args=['-e','using LinkedSpecJulia,JSON3,Test; for path in ARGS; include(path); end',*tests]
command=['bash','tools/run_julia_project_data.sh','--project=julia','--startup-file=no','--history-file=no','--depwarn=error',*args]
(OUT/'command.json').write_text(json.dumps(dict(argv=command,environment={k:env[k] for k in ('JULIA_NUM_THREADS','OPENBLAS_NUM_THREADS','JULIA_PKG_PRECOMPILE_AUTO','LINKEDSPEC_HASH_VIEW_CAPTURE') if k in env}),indent=2)+'\n')
with (OUT/'stdout.log').open('wb') as stdout,(OUT/'stderr.log').open('wb') as stderr:result=subprocess.run(command,cwd=ROOT,env=env,stdout=stdout,stderr=stderr)
(OUT/'exit.txt').write_text(str(result.returncode)+'\n')
for p,r in records.items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==r['sha256'] and Path(p).stat().st_mode & 0o777==r['mode']
for name in ('stdout.log','stderr.log'):
 p=OUT/name;b=p.read_bytes();q=Path(str(p)+'.gz');q.write_bytes(gzip.compress(b,mtime=0));assert gzip.decompress(q.read_bytes())==p.read_bytes();p.unlink()
artifacts={};files=sorted((OUT/'emitted').glob('*.jl'))+sorted((OUT/'parsed').glob('*.json'))
assert len(files)==2*len(json.loads(FIXTURE.read_bytes()))
with tarfile.open(OUT/'actual-emitted-parsed.tar.gz','w:gz') as archive:
 for p in files:
  b=p.read_bytes();artifacts[str(p)]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),mode=p.stat().st_mode & 0o777);archive.add(p,arcname=p,recursive=False)
with tarfile.open(OUT/'actual-emitted-parsed.tar.gz') as archive:
 assert archive.getnames()==[str(p) for p in files]
 for p in files:assert archive.extractfile(str(p)).read()==p.read_bytes()
(OUT/'artifact-identities.json').write_text(json.dumps(artifacts,indent=2,sort_keys=True)+'\n')
for p in files:p.unlink()
(OUT/'emitted').rmdir();(OUT/'parsed').rmdir()
print(phase+': exit'+str(result.returncode)+'; actual declared inputs/modules/parsed bodies/full channels retained')
assert result.returncode in ((0,1) if phase=='before' else (0,)), 'inspect retained complete epoch before any retry'
