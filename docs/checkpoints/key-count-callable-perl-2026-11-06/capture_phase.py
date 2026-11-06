"""One-shot actual normal and public source observation per immutable phase."""
import hashlib,json,subprocess,sys,tarfile
from pathlib import Path
ROOT=Path.cwd().resolve();BASE=Path(__file__).resolve().parent.relative_to(ROOT)
phase=sys.argv[1];assert phase in ['before','after'];OUT=BASE/phase
OUT.mkdir();(OUT/'normal-modules').mkdir();(OUT/'modules').mkdir()
paths=[Path(p) for p in subprocess.check_output(['git','ls-files','perl','specs','tests/fixtures','tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh'],text=True).splitlines()]
paths += list(BASE.glob('*.py'))+[BASE/'observer.pl',BASE/'terminal-profile-cases.json',Path('tests/fixtures/key_count_callable_result_cases.json'),Path('tests/fixtures/key_count_callable_perl_profiles.json'),Path('t/key_count_callable_result_guard_composition.t')]
records={}
with tarfile.open(OUT/'inputs-before-first-get.tar.gz','x:gz') as archive:
 for p in sorted(set(paths)):
  assert not p.is_absolute() and '..' not in p.parts and not p.is_symlink() and p.is_file()
  assert p.stat().st_dev==ROOT.stat().st_dev
  body=p.read_bytes();records[str(p)]={'sha256':hashlib.sha256(body).hexdigest(),'bytes':len(body),'mode':p.stat().st_mode & 0o777}
  archive.add(p,arcname=str(p),recursive=False)
(OUT/'input-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
(OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
commands=[['bash','tools/project_data_run.sh','env','PERL5LIB=','LINKEDSPEC_KEY_COUNT_CALLABLE_DIR='+str(OUT/'normal-modules'),'prove','-v','-Iperl','t/key_count_callable_result_guard_composition.t'],['bash','tools/project_data_run.sh','env','PERL5LIB=','perl','-Iperl',str(BASE/'observer.pl'),'tests/fixtures/key_count_callable_result_cases.json',str(OUT/'modules')]]
results=[]
for i,command in enumerate(commands):
 (OUT/('command-'+str(i)+'.json')).write_text(json.dumps(command,indent=2)+'\n')
 with (OUT/('stdout-'+str(i)+'.log')).open('xb') as stdout,(OUT/('stderr-'+str(i)+'.log')).open('xb') as stderr:
  result=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr)
 results.append(result.returncode)
 print(phase,i,result.returncode,flush=True)
(OUT/'exits.json').write_text(json.dumps(results)+'\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==r['sha256'] for p,r in records.items())
assert results==([1,0] if phase=='before' else [0,0]),'inspect complete actual channels'
