"""One-shot directly affected checks; reuse the sealed after-phase source inputs."""
import hashlib,json,subprocess,tarfile
from pathlib import Path
ROOT=Path.cwd().resolve();BASE=Path(__file__).resolve().parent.relative_to(ROOT);OUT=BASE/'final'
OUT.mkdir()
records=json.loads((BASE/'after/input-identities.json').read_text())
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==r['sha256'] for p,r in records.items())
paths=[Path(p) for p in ['t/key_count_result_guard_composition.t','t/value_copy_function.t','t/count_length_receiver_contract.t']]+[BASE/'capture_final.py']
extra={}
with tarfile.open(OUT/'additional-inputs-before-first-run.tar.gz','x:gz') as archive:
 for p in paths:
  assert p.is_file() and not p.is_symlink() and p.stat().st_dev==ROOT.stat().st_dev
  body=p.read_bytes();extra[str(p)]={'sha256':hashlib.sha256(body).hexdigest(),'bytes':len(body),'mode':p.stat().st_mode & 0o777}
  archive.add(p,arcname=str(p),recursive=False)
(OUT/'additional-input-identities.json').write_text(json.dumps(extra,indent=2,sort_keys=True)+'\n')
(OUT/'source-input-reference.txt').write_text(str(BASE/'after/inputs-before-first-get.tar.gz')+'\n')
commands={'direct':['prove','-v','-Iperl',*[str(p) for p in paths[:3]]],'owner-syntax':['perl','-Iperl','-c','perl/LinkedSpec/ActionIR/MethodLowering.pm']}
for name,arguments in commands.items():
 command=['bash','tools/project_data_run.sh','env','PERL5LIB=',*arguments]
 (OUT/(name+'-command.json')).write_text(json.dumps(command,indent=2)+'\n')
 with (OUT/(name+'-stdout.log')).open('xb') as stdout,(OUT/(name+'-stderr.log')).open('xb') as stderr:
  r=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr)
 (OUT/(name+'-exit.txt')).write_text(str(r.returncode)+'\n')
 assert r.returncode==0,'inspect actual full channels'
 assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==v['sha256'] for p,v in {**records,**extra}.items())
 print('final',name,'PASS',flush=True)
